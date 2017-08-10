using System;
using System.Data;
using System.Linq;
using System.Management.Automation;
using System.Web.Helpers;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;

namespace ColumbusPortal.Controllers
{
    public class ServiceController : Controller
    {
        ServiceModel model = new ServiceModel();

        
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
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        [ValidateAntiForgeryToken]
        public ActionResult CustomerReport(FormCollection _POST)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = _POST["organization"];

                CommonCAS.Log(string.Format("has run Service/CustomerReport/{0}", model.CustomerReport.Organization));
                
                CustomerReportGenerateSQL();
                //CustomerReportGenerate();

                CommonCAS.Stats("Service/CustomerReport/" + model.CustomerReport.Organization);

                return View("CustomerReportSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
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
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
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

        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        public string CustomerReportCSVSQL(string organization)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = organization;

                CustomerReportGenerateSQL();

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
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        private void CustomerReportGenerateSQL()
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCustomerReportSQL(model.CustomerReport.Organization);
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
                        RAM = (double.Parse(ent.Properties["Memory"].Value.ToString()) / 1024).ToString("F1") + " GB"
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
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
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

                CommonCAS.Log(string.Format("has run Service/ExpandVHD() to Expand VHD on {0} at date {1}, with TaskID {2}. The VHD has been scheduled for {3} GB more..", ExpandVHD.VMID, ExpandVHD.DateTime, ExpandVHD.TaskID, ExpandVHD.GB));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandVHD(ExpandVHD.VMID, ExpandVHD.VHDID, ExpandVHD.DateTime, ExpandVHD.GB, ExpandVHD.Email, ExpandVHD.TaskID);
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
                            CommonCAS.Log(string.Format("ExpandVHD() extra info: {0}", message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Service/ExpandVHD");

                return View("ExpandVHD", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
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
                    Email = _POST["email"],
                    DynamicMemoryEnabled = _POST[""]
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


                CommonCAS.Log(string.Format("has run Service/ExpandVHD() to Expand CPU/RAM on server {0}, at date {1}, with TaskID {2}", ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.TaskID));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandCPURAM(ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM, ExpandCPURAM.Email, ExpandCPURAM.DynamicMemoryEnabled, ExpandCPURAM.TaskID);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The VM has been scheduled for expansion on {0}. CPU/RAM will be set to: {1} Cores, and {2} GB RAM.", ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM));

                CommonCAS.Stats("Service/ExpandCPURAM");

                return View("ExpandCPURAM", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
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

        // Display reboot view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ScheduleReboot()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        // Post Schedule Reboot and return view
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ScheduleReboot(FormCollection _POST)
        {
            try
            {
                // Schedule Reboot and create View.
                CustomScheduleReboot ScheduleReboot = new CustomScheduleReboot()
                {
                    TaskID = _POST["taskid"].ToString(),
                    VMID = _POST["vmid"].ToUpper(),
                    DateTime = _POST["datetime"].ToString(),
                    Email = _POST["email"]
                };

                if (ScheduleReboot.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ScheduleReboot.TaskID.Length < 6 || ScheduleReboot.TaskID.Length > 8)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }

                CommonCAS.Log(string.Format("has run Service/ScheduleReboot() to Reboot {0} at date {1}, with TaskID {2}.", ScheduleReboot.VMID, ScheduleReboot.DateTime, ScheduleReboot.TaskID));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ScheduleReboot(ScheduleReboot.VMID, ScheduleReboot.DateTime, ScheduleReboot.Email, ScheduleReboot.TaskID);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("The VM has been scheduled for reboot on {0}", ScheduleReboot.DateTime));
                    }
                    else
                    {
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                            CommonCAS.Log(string.Format("Has run Service/ScheduleReboot() with info: {1}", ScheduleReboot.TaskID, message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Service/ScheduleReboot");

                return View("ScheduleReboot", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display PendingReboot view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ScomPendingReboot()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetPendingReboot()
        {
            string returnstr = "<table class='SQLlight'><tr><td style='width: 300px; text-align: left;'><b>ServerName</b></td><td style='width: 120px; text-align: left;'><b>Name</b></td><td style='width: 100px; text-align: left;'><b>Severity</b></td><td style='width: 180px; text-align: left;'><b>TimeRaised</b></td></tr>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetPendingReboot();
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td style='width: 150px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                    returnstr += "<td style='width: 120px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td>";
                    returnstr += "<td style='width: 100px; text-align: left;'>" + item.Members["Severity"].Value.ToString() + "</td>";
                    returnstr += "<td style='width: 180px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // Display latest alert view

        public ActionResult ScomLatestAlerts()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }


        public string GetLatestAlerts(string alert)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetLatestAlerts(alert);
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    returnstr += "<tr><td><b>No alerts! Be happy..</b></td></tr>";
                }
                else
                {
                    // Returns string with properties..
                    foreach (var item in result)
                    {
                        var severity = item.Members["Severity"].Value.ToString();
                        var name = item.Members["Name"].Value.ToString();

                        if (name == "Pending Reboot")
                        {
                            returnstr += "<center><table class='SQLlight'><tr><td style='display: block; width: 450px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                            returnstr += "<td style='width: 200px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td>";
                            returnstr += "<td style='width: 250px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr><br/></table>";
                        }
                        else
                        {
                            if (severity == "Error")
                            {
                                returnstr += "<center><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>ServerName</b></td><td style='width: 150px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Name</b></td><td style='width: 260px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Severity</b></td><td style='width: 100px; text-align: left; color: #e60000; font-weight:bold;'>" + item.Members["Severity"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>TimeRaised</b></td><td style='width: 180px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='display:block; width: 850px; word-break: break-all; text-align: left;'>" + item.Members["Description"].Value.ToString() + "</td></tr></tr></table></center></br>";
                            }
                            if (severity == "Warning")
                            {
                                returnstr += "<center><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>ServerName</b></td><td style='width: 150px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Name</b></td><td style='width: 260px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Severity</b></td><td style='width: 100px; text-align: left; color: #cccc00; font-weight:bold;'>" + item.Members["Severity"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>TimeRaised</b></td><td style='width: 180px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='display:block; width: 850px; word-break: break-all; text-align: left;'>" + item.Members["Description"].Value.ToString() + "</td></tr></tr></table></center></br>";
                            }
                        }

                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // Display latest alert view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ScomAlertFree()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetAlertFreeSpace()
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetAlertFreeSpace();
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    var severity = item.Members["Severity"].Value.ToString();

                    if (severity == "Error")
                    {
                        returnstr += "<center><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>ServerName</b></td><td style='width: 150px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Name</b></td><td style='width: 260px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Severity</b></td><td style='width: 100px; text-align: left; color: #e60000; font-weight:bold;'>" + item.Members["Severity"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>TimeRaised</b></td><td style='width: 180px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='display:block; width: 850px; word-break: break-all; text-align: left;'>" + item.Members["Description"].Value.ToString() + "</td></tr></tr></table></center></br>";
                    }
                    if (severity == "Warning")
                    {
                        returnstr += "<center><table class='SQLlight'><b>ServerName</b></td><td style='width: 150px; text-align: left;'>" + item.Members["PrincipalName"].Value.ToString() + "</td>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Name</b></td><td style='width: 260px; text-align: left;'>" + item.Members["Name"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Severity</b></td><td style='width: 100px; text-align: left; color: #cccc00; font-weight:bold;'>" + item.Members["Severity"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>TimeRaised</b></td><td style='width: 180px; text-align: left;'>" + item.Members["TimeRaised"].Value.ToString() + "</td></tr>";
                        returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='display:block; width: 850px; word-break: break-all; text-align: left;'>" + item.Members["Description"].Value.ToString() + "</td></tr></tr></table></center></br>";
                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetScheduledJobs(string job)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetScheduledJobs(job);
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    returnstr += "<tr><td><b>No current schedules!..</b></td></tr>";
                }
                else
                {
                    // Returns string with properties..
                    foreach (var item in result)
                    {
                        {
                            returnstr += "<center><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>VM Name</b></td><td style='text-align: left;'>" + item.Members["VMName"].Value.ToString() + "</td>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Parameters</b></td><td style='text-align: left'>" + item.Members["Parameters"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Opgave nr.</b></td><td style='text-align: left'>" + item.Members["TaskID"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Email Status To</b></td><td style='text-align: left; color: #e60000; font-weight:bold'>" + item.Members["EmailStatusTo"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Scheduled Time</b></td><td style='text-align: left'>" + item.Members["ScheduledTime"].Value.ToString() + "</td></tr></table></center></br>";
                        }
                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

    }
}
