using System;
using System.Collections.Generic;
using System.Dynamic;
using System.DirectoryServices;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;
using System.ComponentModel.DataAnnotations;
using System.Management.Automation;

namespace SystemHostingPortal.Controllers
{

    public class Level30Controller : Controller
    {
        Level30Model model = new Level30Model();

        // Display create view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult UpdateConf()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed user and display create view
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult UpdateConf(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomUpdateConf UpdateConf = new CustomUpdateConf()
                {
                    Organization = _POST["organization"].ToUpper(),
                    ExchangeServer = _POST["exchangeserver"],
                    DomainFQDN = _POST["domainfqdn"],
                    NETBIOS = _POST["netbios"],
                    CustomerOUDN = _POST["customeroudn"],
                    Domains = _POST["domains"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>(),
                    TenantID365 = _POST["tenantid365"],
                    AdminUser365 = _POST["adminuser365"],
                    AdminPass365 = _POST["adminpass365"],
                    AADsynced = _POST["aadsynced"],
                    ADConnectServer = _POST["adconnectserver"],
                    DomainDC = _POST["domaindc"]

                };
                for (int i = 0; i < UpdateConf.Domains.Count; i++) { UpdateConf.Domains[i] = UpdateConf.Domains[i].Trim(); }

                model.UpdateConf = UpdateConf;

                Common.Log(string.Format("has run Organization/UpdateConf() for {0}", UpdateConf.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateConf(UpdateConf);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The configuration has been updated for {0}", UpdateConf.Organization));

                Common.Stats("Organization/UpdateConf");

                return View("UpdateConf", model);
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
        /// Ajax function for aquiring currentconf
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public string GetCurrentConf(string organization)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCurrentConf(organization);
                var result = ps.Invoke();
                // Returns PSObject with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td class=" + "lefttd" + "><b>ExchangeServer: </b></td><td>" + item.Members["ExchangeServer"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>DomainFQDN: </b></td><td>" + item.Members["DomainFQDN"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>NETBIOS: </b></td><td>" + item.Members["NETBIOS"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>Customer OU DN: </b></td><td>" + item.Members["CustomerOUDN"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>TenantID365: </b></td><td>" + item.Members["TenantID365"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AdminUser365: </b></td><td>" + item.Members["AdminUser365"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AdminPass365: </b></td><td>" + item.Members["AdminPass365"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AADsynced: </b></td><td>" + item.Members["AADsynced"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>ADConnect Server: </b></td><td>" + item.Members["ADConnectServer"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AD Server: </b></td><td>" + item.Members["DomainDC"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        public string GetDomain(string organization)
        {
            string returnstr = "<ul>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetDomain(organization);
                var result = ps.Invoke();

                // Returns PSObject with properties: Name, DomainName, DomainType, Default
                foreach (var item in result)
                {
                    returnstr += "<li>" + item.Members["DomainName"].Value.ToString() + "</li>";
                }
            }

            returnstr += "</ul>";

            return returnstr;
        }

        // test config get.. Needs to be retrieved by .net instead of javascript..
        public void GetConf(string organization)
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCurrentConf(organization);
                var result = ps.Invoke().Single();
                var DomainFQDN = (PSObject)result.Properties["DomainFQDN"].Value;
                var ExchangeServer = (PSObject)result.Properties["ExchangeServer"].Value;

                model.UpdateConf.DomainFQDN = DomainFQDN.ToString();
                model.UpdateConf.ExchangeServer = ExchangeServer.ToString();

            }
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

                if (ExpandVHD.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ExpandVHD.TaskID.Length < 6 || ExpandVHD.TaskID.Length > 6)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }

                Common.Log(string.Format("has run Level30/ExpandVHD() to Expand VHD on {0} at date {1}, with TaskID {2}. The VHD has been scheduled for {3} GB more..", ExpandVHD.VMID, ExpandVHD.DateTime, ExpandVHD.TaskID, ExpandVHD.GB));

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
                            Common.Log(string.Format("Has run Level30/ExpandVHD() with info: {1}", ExpandVHD.TaskID, message.ToString()));
                        }
                    }
                }

                Common.Stats("Level30/ExpandVHD");

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
        [Authorize(Roles = "Role_Level_30")]
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

                if (ExpandCPURAM.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ExpandCPURAM.TaskID.Length < 6 || ExpandCPURAM.TaskID.Length > 6)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }

                Common.Log(string.Format("has run Level30/ExpandVHD() to Expand CPU/RAM on server {0}, at date {1}, with TaskID {2}", ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.TaskID));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandCPURAM(ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM, ExpandCPURAM.Email);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The VM has been scheduled for expansion on {0}. CPU/RAM will be set to: {1} Cores, and {2} GB RAM.", ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM));

                Common.Stats("Level30/ExpandCPURAM");

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
                    returnstr += "<tr><td><b>Current Memory Count : </b></td><td>" + item.Members["Memory"].Value.ToString() + " GB" + "</td></tr>";
                    returnstr += "<tr><td><b>DynamicMemoryEnabled : </b></td><td>" + item.Members["DynamicMemoryEnabled"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

    }
}
