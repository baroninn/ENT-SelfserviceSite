using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;

namespace SystemHostingPortal.Controllers
{
    public class ServiceController : Controller
    {
        ServiceModel model = new ServiceModel();

        [Authorize(Roles = "Role_Level_5, Role_Level_20, Access_SelfService_FullAccess")]
        public ActionResult CustomerReport() 
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_Level_5, Access_Level_20, Access_SelfService_FullAccess")]
        public ActionResult CustomerReport(FormCollection _POST)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = _POST["organization"];

                Common.Log(string.Format("has run Service/CustomerReport/{0}", model.CustomerReport.Organization));
                
                CustomerReportGenerateLive();
                //CustomerReportGenerate();

                Common.Stats("Service/CustomerReport/" + model.CustomerReport.Organization);

                return View("CustomerReportSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string CustomerReportCSV(string organization)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = organization;

                CustomerReportGenerateLive();

                string retStr = "<pre>";

                retStr += string.Format("<table><tr><td>FileServer usage:</td><td>{0}</td></tr><tr><td>FileServer Free:</td><td>{1}</td></tr><tr><td>FileServer Total:</td><td>{2} GB</td></tr><tr><td>&nbsp;</td></tr><tr><td>Total disk usage:</td><td>{3} GB</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td></table>", model.CustomerReport.FileServerfUsed, model.CustomerReport.FileServerfFree, model.CustomerReport.FileServerfTotal, model.CustomerReport.TotalfUsage);

                retStr += "<table><tr><td>Name</td><td>Email</td></tr>";
                foreach (ADUser user in model.CustomerReport.ADUsers)
                {
                    retStr += string.Format("<tr><td>{0}</td><td>{1}</td></tr>", user.Name, user.Email);
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Full Users (" + model.CustomerReport.Licenses.FullUser.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.FullUser)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Light User (" + model.CustomerReport.Licenses.LightUser.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.LightUser)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office 365 information: </td></tr>";
                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>PartnerName </td><td>License </td><td>ActiveUnits </td><td>ConsumedUnits </td><td>FreeUnits </td></tr>";
                foreach (Info365 info in model.CustomerReport.Info365s)
                {
                    retStr += string.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>", info.PartnerName, info.License, info.ActiveUnits, info.ConsumedUnits, info.FreeUnits);
                }
                retStr += "</table>";



                return retStr + "</pre>";
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return model.Message + string.Join("<br />", model.MessageList);
            }
        }

        private void CustomerReportGenerateLive()
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCustomerReportLive(model.CustomerReport.Organization);
                var result = ps.Invoke().Single();
                var aduser = (PSObject)result.Properties["ADUser"].Value;
                var server = (PSObject)result.Properties["Server"].Value;
                var office365 = (PSObject)result.Properties["Office365"].Value;
                var fileserver = (PSObject)result.Properties["FileServer"].Value;
                var totalstorage = (PSObject)result.Properties["Totalstorage"].Value;
                var users = (Object[])aduser.Properties["Users"].Value;
                var servers = (Object[])server.Properties["Servers"].Value;
                var info365s = (Object[])office365.Properties["Info"].Value;

                var database = (PSObject)result.Properties["Database"].Value;
                

                model.CustomerReport.DatabasefUsage = double.Parse(database.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.DatabaseUsage = model.CustomerReport.DatabasefUsage.ToString("F1") + " GB";

                model.CustomerReport.TotalfUsage = double.Parse(totalstorage.Properties["TotalAllocated"].Value.ToString());
                model.CustomerReport.TotalUsage = model.CustomerReport.TotalfUsage.ToString("F1") + " GB";

                model.CustomerReport.FileServerfTotal = double.Parse(fileserver.Properties["Allocated"].Value.ToString());
                model.CustomerReport.FileServerTotal = model.CustomerReport.FileServerfTotal.ToString("F1") + " GB";
                model.CustomerReport.FileServerfFree = double.Parse(fileserver.Properties["FreeSpace"].Value.ToString());
                model.CustomerReport.FileServerFree = model.CustomerReport.FileServerfFree.ToString("F1") + " GB";
                model.CustomerReport.FileServerfUsed = double.Parse(fileserver.Properties["Used"].Value.ToString());
                model.CustomerReport.FileServerUsed = model.CustomerReport.FileServerfUsed.ToString("F1") + " GB";


                model.CustomerReport.ADUsersCount = 0;
                model.CustomerReport.ADFullUsersCount = 0;
                model.CustomerReport.ADLightUsersCount = 0;
                model.CustomerReport.ENTServersCount = 0;


                foreach (PSObject user in users)
                {
                    model.CustomerReport.ADUsersCount++;
                    model.CustomerReport.ADUsers.Add(new ADUser
                    {
                        Email = user.Properties["PrimarySmtpAddress"].Value.ToString(),
                        Name = user.Properties["DisplayName"].Value.ToString(),
                        LightUser = user.Properties["LightUser"].Value.ToString(),

                    });

                    string testUser = user.Properties["TestUser"].Value.ToString();
                    string type = user.Properties["Type"].Value.ToString();
                    string disabled = user.Properties["Disabled"].Value.ToString();
                    string displayName = user.Properties["DisplayName"].Value.ToString();
                    string lightuser = user.Properties["LightUser"].Value.ToString();


                    // Do not add MailOnly accounts to Windows nor Office.
                    if (lightuser.Equals("True"))
                    {
                        model.CustomerReport.Licenses.LightUser.Add(displayName);
                        model.CustomerReport.ADLightUsersCount++;
                    }
                    else
                    {
                        model.CustomerReport.ADFullUsersCount++;
                        model.CustomerReport.Licenses.FullUser.Add(displayName);
                    }

                }

                model.CustomerReport.ADUsers.OrderBy(x => x);

                foreach (PSObject ent in servers)
                {
                    model.CustomerReport.ENTServers.Add(new ENTServer
                    {
                        OS = ent.Properties["OperatingSystem"].Value.ToString(),
                        Name = ent.Properties["Name"].Value.ToString(),
                        CPU = ent.Properties["CPUCount"].Value.ToString(),
                        RAM = (double.Parse(ent.Properties["Memory"].Value.ToString())  / 1024).ToString("F1") + " GB"
                    });
                    model.CustomerReport.ENTServersCount++;
                }

                foreach (PSObject info in info365s)
                {

                    model.CustomerReport.Info365s.Add(new Info365
                    {
                        License = info.Properties["License"].Value.ToString(),
                        PartnerName = info.Properties["PartnerName"].Value.ToString(),
                        ActiveUnits = info.Properties["ActiveUnits"].Value.ToString(),
                        ConsumedUnits = info.Properties["ConsumedUnits"].Value.ToString(),
                        FreeUnits = info.Properties["FreeUnits"].Value.ToString(),
                    });

                }
                

                //throw new Exception(mailbox.Properties["TotalAllocated"].Value.ToString());
            }
        }

        public ActionResult CustomerReportPieChartDisk(string iUsage, string iQuota)
                {
                    //iUsage = iUsage.Replace(',', '.');
                    //iQuota = iQuota.Replace(',', '.');

                    double usage = double.Parse(iUsage);
                    double quota = double.Parse(iQuota);

                    double usagePct = usage / quota * 100;
                    double quotaPct = 100 - usagePct;

                    var key = new Chart(width: 100, height: 100).AddSeries(
                        chartType: "pie",
                        legend: "Space utulization",
                        xValue: new[] { "Used", "Free" },
                        yValues: new[] { usagePct, quotaPct }).Write("png");

                    return null;
                }

        // Display Expand view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ExpandVHD()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Post VHD changes and return view
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ExpandVHD(FormCollection _POST)
        {
            try
            {
                // Expand VHD and create View.
                CustomExpandVHD ExpandVHD = new CustomExpandVHD()
                {
                    TaskID = _POST["taskid"],
                    VMID = _POST["vmid"].ToUpper(),
                    VHDID = _POST["vhdid"],
                    DateTime = _POST["datetime"].ToString(),
                    GB = _POST["gb"],
                    Email = _POST["email"]
                };

                var GB = Convert.ToInt32(ExpandVHD.GB);

                if (GB > 50)
                {
                    throw new ArgumentException("For more than 50 GB, please contact Drift..");
                }

                if (ExpandVHD.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ExpandVHD.TaskID.Length < 6 || ExpandVHD.TaskID.Length > 6)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }

                Common.Log(string.Format("has run Service/ExpandVHD() to Expand VHD on {0} at date {1}, with TaskID {2}. The VHD has been scheduled for {3} GB more..", ExpandVHD.VMID, ExpandVHD.DateTime, ExpandVHD.TaskID, ExpandVHD.GB));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandVHD(ExpandVHD.VMID, ExpandVHD.VHDID, ExpandVHD.DateTime, ExpandVHD.GB, ExpandVHD.Email);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("The VM has been scheduled for expansion on {0}, with {1} GB", ExpandVHD.DateTime, ExpandVHD.GB));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("VM has been expanded with following info:"));

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                            Common.Log(string.Format("Has run Service/ExpandVHD() with info: {1}", ExpandVHD.TaskID, message.ToString()));
                        }
                    }
                }

                Common.Stats("Service/ExpandVHD");

                return View("ExpandVHD", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }



        // Display Expand CPU view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ExpandCPURAM()
        {
              
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Post CPU changes and return view
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ExpandCPURAM(FormCollection _POST)
        {
            try
            {
                // Expand CPU and create View.
                CustomExpandCPURAM ExpandCPURAM = new CustomExpandCPURAM()
                {
                    
                    TaskID = _POST["taskid"],
                    VMID = _POST["vmid"].ToUpper(),
                    DateTime = _POST["datetime"].ToString(),
                    CPU = _POST["cpu"].ToString(),
                    RAM = _POST["ram"].ToString(),
                    Email = _POST["email"]
                };

                var CPU = Convert.ToInt32(ExpandCPURAM.CPU);
                var RAM = Convert.ToInt32(ExpandCPURAM.RAM);

                if (CPU > 4)
                {
                    throw new ArgumentException("For core numbers over 4, please contact Drift..");
                }

                if (RAM > 24)
                {
                    throw new ArgumentException("For RAM configurations over 24, please contact Drift..");
                }

                if (ExpandCPURAM.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ExpandCPURAM.TaskID.Length < 6 || ExpandCPURAM.TaskID.Length > 6)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }


                Common.Log(string.Format("has run Service/ExpandVHD() to Expand CPU/RAM on server {0}, at date {1}, with TaskID {2}", ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.TaskID));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandCPURAM(ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM, ExpandCPURAM.Email);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The VM has been scheduled for expansion on {0}. CPU/RAM will be set to: {1} Cores, and {2} GB RAM.", ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM));

                Common.Stats("Service/ExpandCPURAM");

                return View("ExpandCPURAM", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        /// <summary>
        /// Ajax function for aquiring CPU and RAM for VMs
        /// </summary>
        /// <param name="VMID"></param>
        /// <returns></returns>
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetVMInfo(string vmid)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetVMInfo(vmid);
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td><b>Current CPU Count : </b></td><td class='lefttd'>" + item.Members["CPUCount"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Current Memory Count : </b></td><td>" + item.Members["Memory"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>DynamicMemoryEnabled : </b></td><td>" + item.Members["DynamicMemoryEnabled"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

    }
}
