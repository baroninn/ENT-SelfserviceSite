using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Web.Script.Serialization;
using System.Management.Automation;

namespace ColumbusPortal.Controllers
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
                    Name = _POST["Name"],
                    UserContainer = _POST["usercontainer"],
                    ExchangeServer = _POST["exchangeserver"],
                    DomainFQDN = _POST["domainfqdn"],
                    NETBIOS = _POST["netbios"],
                    CustomerOUDN = _POST["customeroudn"],
                    AdminUserOUDN = _POST["adminuseroudn"],
                    ExternalUserOUDN = _POST["externaluseroudn"],
                    EmailDomains = _POST["emaildomains"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>(),
                    TenantID = _POST["tenantid"],
                    AdminUser = _POST["adminuser"],
                    AdminPass = _POST["adminpass"],
                    AADsynced = _POST["aadsynced"],
                    ADConnectServer = _POST["adconnectserver"],
                    DomainDC = _POST["domaindc"],
                    NavMiddleTier = _POST["navmiddletier"],
                    SQLServer = _POST["sqlserver"],
                    AdminRDS = _POST["adminrds"],
                    AdminRDSPort = _POST["adminrdsport"]

                };
                for (int i = 0; i < UpdateConf.EmailDomains.Count; i++) { UpdateConf.EmailDomains[i] = UpdateConf.EmailDomains[i].Trim(); }

                model.UpdateConf = UpdateConf;

                CommonCAS.Log(string.Format("has run Organization/UpdateConf() for {0}", UpdateConf.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateConf(UpdateConf);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The configuration has been updated for {0}", UpdateConf.Organization));

                CommonCAS.Stats("Organization/UpdateConf");

                return View("UpdateConf", model);
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
        /// Ajax function for aquiring currentconf
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
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

        /// <summary>
        /// Get current conf to JSON
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetCurrentConfLIST(string organization)
        {
            try
            {
                List<CustomGetConfLIST> GetConfList = new List<CustomGetConfLIST>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetCurrentConf(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject conf in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(conf);
                        GetConfList.Add(new CustomGetConfLIST()
                        {
                            Name = properties["Name"].ToString(),
                            UserContainer = properties["UserContainer"].ToString(),
                            ExchangeServer = properties["ExchangeServer"].ToString(),
                            DomainFQDN = properties["DomainFQDN"].ToString(),
                            NETBIOS = properties["NETBIOS"].ToString(),
                            CustomerOUDN = properties["CustomerOUDN"].ToString(),
                            AdminUserOUDN = properties["AdminUserOUDN"].ToString(),
                            ExternalUserOUDN = properties["ExternalUserOUDN"].ToString(),
                            TenantID = properties["TenantID"].ToString(),
                            AdminUser = properties["AdminUser"].ToString(),
                            AdminPass = properties["AdminPass"].ToString(),
                            AADsynced = properties["AADsynced"].ToString(),
                            ADConnectServer = properties["ADConnectServer"].ToString(),
                            DomainDC = properties["DomainDC"].ToString(),
                            NavMiddleTier = properties["NavMiddleTier"].ToString(),
                            SQLServer = properties["SQLServer"].ToString(),
                            AdminRDS = properties["AdminRDS"].ToString(),
                            AdminRDSPort = properties["AdminRDSPort"].ToString(),
                            EmailDomains = properties["EmailDomains"].ToString(),
                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(GetConfList);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }
        /// <summary>
        /// Get current conf to JSON
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetconfDomainsLIST(string organization)
        {
            try
            {
                List<CustomGetConfLIST> GetConfList = new List<CustomGetConfLIST>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetCurrentConf(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject conf in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(conf);
                        GetConfList.Add(new CustomGetConfLIST()
                        {
                            DomainFQDN = properties["DomainFQDN"].ToString(),
                            ExchangeServer = properties["ExchangeServer"].ToString(),
                            NETBIOS = properties["NETBIOS"].ToString(),
                            CustomerOUDN = properties["CustomerOUDN"].ToString(),
                            TenantID = properties["TenantID365"].ToString(),
                            AdminUser = properties["AdminUser365"].ToString(),
                            AdminPass = properties["AdminPass365"].ToString(),
                            AADsynced = properties["AADsynced"].ToString(),
                            ADConnectServer = properties["ADConnectServer"].ToString(),
                            DomainDC = properties["DomainDC"].ToString(),

                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(GetConfList);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Role_Level_30")]
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

        // Display Expand view
        [Authorize(Roles = "Role_Level_30")]
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
        [Authorize(Roles = "Role_Level_30")]
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

                CommonCAS.Log(string.Format("has run Level30/ExpandVHD() to Expand VHD on {0} at date {1}, with TaskID {2}. The VHD has been scheduled for {3} GB more..", ExpandVHD.VMID, ExpandVHD.DateTime, ExpandVHD.TaskID, ExpandVHD.GB));

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
                            CommonCAS.Log(string.Format("Has run Level30/ExpandVHD() with info: {1}", ExpandVHD.TaskID, message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Level30/ExpandVHD");

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
        [Authorize(Roles = "Role_Level_30")]
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
                    Email = _POST["email"],
                    DynamicMemoryEnabled = _POST["dynamicmb"]
                };

                if (ExpandCPURAM.TaskID.Length == 0)
                {
                    throw new ArgumentException("Please enter a task id");
                }

                if (ExpandCPURAM.TaskID.Length < 6 || ExpandCPURAM.TaskID.Length > 6)
                {
                    throw new ArgumentException("The taskid must be 6 characters long.");
                }

                CommonCAS.Log(string.Format("has run Level30/ExpandVHD() to Expand CPU/RAM on server {0}, at date {1}, with TaskID {2}", ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.TaskID));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ExpandCPURAM(ExpandCPURAM.VMID, ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM, ExpandCPURAM.Email, ExpandCPURAM.DynamicMemoryEnabled, ExpandCPURAM.TaskID);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The VM has been scheduled for expansion on {0}. CPU/RAM will be set to: {1} Cores, and {2} GB RAM.", ExpandCPURAM.DateTime, ExpandCPURAM.CPU, ExpandCPURAM.RAM));

                CommonCAS.Stats("Level30/ExpandCPURAM");

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
        [Authorize(Roles = "Role_Level_30")]
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
                    var CPUCount = item.Members["CPUCount"].Value;
                    returnstr += "<tr><td><b>Current CPU Count : </b></td><td class='lefttd'>" + item.Members["CPUCount"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Current Memory Count : </b></td><td>" + item.Members["Memory"].Value.ToString() + " GB" + "</td></tr>";
                    returnstr += "<tr><td><b>DynamicMemoryEnabled : </b></td><td>" + item.Members["DynamicMemoryEnabled"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        /// <summary>
        /// Ajax function for aquiring CPU and RAM for VMs
        /// </summary>
        /// <param name="VMID"></param>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetVMInfotoModel(string vmid)
        {

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetVMInfo(vmid);
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    model.ExpandCPURAM.CPU = item.Members["CPUCount"].Value.ToString();
                    model.ExpandCPURAM.RAM = item.Members["Memory"].Value.ToString();
                    model.ExpandCPURAM.DynamicMemoryEnabled = item.Members["DynamicMemoryEnabled"].Value.ToString();
                }
            }

            return model.ExpandCPURAM.CPU;
        }

        // Function for getting VMInfo as select list..
        [Authorize(Roles = "Role_Level_30")]
        public class Lvl30ServerInfo
        {
            public string VMID { get; set; }
            public string CPU { get; set; }
            public string RAM { get; set; }
            public string DynamicMemoryEnabled { get; set; }
        }
        public string GetVMInfo3(string vmid)
        {
            try
            {
                List<Lvl30ServerInfo> ServerInfo = new List<Lvl30ServerInfo>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetVMInfo(vmid);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject infoobject in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(infoobject);
                        ServerInfo.Add(new Lvl30ServerInfo()
                        {
                            CPU = properties["CPU"].ToString(),
                            RAM = properties["RAM"].ToString(),
                            DynamicMemoryEnabled = properties["DynamicMemoryEnabled"].ToString(),
                        });
                    }

                }

                return new JavaScriptSerializer().Serialize(ServerInfo);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        // Display create ADMIN view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed admin and display create Admin view
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateAdmin(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomUser newUser = new CustomUser()
                {
                    FirstName = _POST["firstname"],
                    LastName = _POST["lastname"],
                    Password = _POST["password"],
                    SamAccountName = _POST["samaccountname"],
                    DisplayName = _POST["displayname"],
                    Department = _POST["department"],
                };

                model.UserList.Add(newUser);

                CommonCAS.Log(string.Format("has run Level30/CreateAdmin() to create {0}", newUser.SamAccountName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateAdmin(newUser);
                    var result = ps.Invoke();

                    if (result.Count() > 0)
                    {
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }

                    }
                }

                CommonCAS.Stats("Level30/CreateAdmin");

                return View("CreateAdminSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public string GetAdminUsers()
        {
            string returnstr = "<table class='SQL'><tr><td style='display: block; width: 250px;'><b>DisplayName</b></td><td style='width: 180px;'><b>FirstName</b></td><td style='width: 150px;'><b>LastName</b></td><td style='width: 150px;'><b>SamAccount</b></td><td style='width: 100px;'><b>Department</b></td></tr>"; ;

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetAdminUsers();
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td>" + item.Members["DisplayName"].Value.ToString() + "</td>";
                    returnstr += "<td>" + item.Members["FirstName"].Value.ToString() + "</td>";
                    returnstr += "<td>" + item.Members["LastName"].Value.ToString() + "</td>";
                    returnstr += "<td>" + item.Members["SamAccountName"].Value.ToString() + "</td>";
                    returnstr += "<td>" + item.Members["Department"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // Display create ADMIN view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed admin and display create Admin view
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveAdmin(FormCollection _POST)
        {
            try
            {
                // set up an admin account for display in view
                CustomUser removeUser = new CustomUser()
                {
                    SamAccountName = _POST["samaccountname"],
                };

                model.UserList.Add(removeUser);

                CommonCAS.Log(string.Format("has run Level30/RemoveAdmin() to remove {0}", removeUser.SamAccountName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveAdmin(removeUser);
                    var result = ps.Invoke();

                    if (result.Count() > 0)
                    {
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }

                    }
                }

                CommonCAS.Stats("Level30/RemoveAdmin");

                return View("RemoveAdmin", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create ADMIN view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult ResetAdminPassword()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed admin and display create Admin view
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult ResetAdminPassword(FormCollection _POST)
        {
            try
            {
                // set up an admin account for display in view
                CustomUser resetUser = new CustomUser()
                {
                    SamAccountName = _POST["samaccountname"],
                    Password = _POST["password"],
                };

                model.UserList.Add(resetUser);

                CommonCAS.Log(string.Format("has run Level30/ResetAdminPassword() to reset password for {0}", resetUser.SamAccountName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ResetAdminPassword(resetUser);
                    var result = ps.Invoke();

                    if (result.Count() > 0)
                    {
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }

                    }
                }

                CommonCAS.Stats("Level30/ResetAdminPassword");

                return View("ResetAdminPassword", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Function for getting adminusers as select list..
        [Authorize(Roles = "Role_Level_30")]
        public class Level30AdminUsers
        {
            public string SamAccountName { get; set; }
            public string DisplayName { get; set; }

        }
        [Authorize(Roles = "Role_Level_30")]
        public string GetAdminUsersLIST()
        {
            try
            {
                List<Level30AdminUsers> admins = new List<Level30AdminUsers>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAdminUsers();
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject Admin in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(Admin);
                        admins.Add(new Level30AdminUsers()
                        {
                            SamAccountName = properties["SamAccountName"].ToString(),
                            DisplayName = properties["DisplayName"].ToString(),
                        });
                    }
                    
                }
                return new JavaScriptSerializer().Serialize(admins);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateEXTAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateEXTAdmin(FormCollection _POST)
        {
            try
            {
                CustomEXTAdminUser EXTAdminUser = new CustomEXTAdminUser()
                {
                    Organization = _POST["Organization"].ToString(),
                    ID = _POST["ID"].ToString(),
                    FirstName = _POST["FirstName"].ToString(),
                    LastName = _POST["LastName"].ToString(),
                    Email = _POST["Email"].ToString(),
                    Company = _POST["Company"].ToString(),
                    Description = _POST["Description"].ToString(),
                    SamAccountName = _POST["SamAccountName"].ToString(),
                    Password = _POST["Password"].ToString(),
                    ExpireDate = _POST["ExpireDate"].ToString(),
                };

                //if (!model.Organizations.Contains(model.EXTAdminUser.Organization))
                //{
                //    throw new Exception(string.Format("{0} does not exist.", EXTAdminUser.Organization));
                //}

                CommonCAS.Log(string.Format("has run Level30/CreateEXTAdmin(), '{0}' for '{1}'", EXTAdminUser.SamAccountName, EXTAdminUser.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateEXTAdminUser(EXTAdminUser);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Admin {0} has been added.", EXTAdminUser.SamAccountName));
                    }
                    else
                    {

                        foreach (PSObject message in result)
                        {
                            CommonCAS.Log(string.Format("Admin {0} info: {1}", EXTAdminUser.SamAccountName, message.ToString()));
                            model.OKMessage.Add(string.Format(message.ToString()));
                        }
                    }
                }

                model.OKMessage.Add(string.Format("EXT Admin '{0}' added for organization '{1}'.", EXTAdminUser.SamAccountName, EXTAdminUser.Organization));

                CommonCAS.Stats("Level30/CreateEXTAdmin");

                return View("CreateEXTAdmin", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display CreateEXTAdmin view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveEXTAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveEXTAdmin(FormCollection _POST)
        {
            try
            {
                CustomEXTAdminUser EXTAdminUser = new CustomEXTAdminUser()
                {
                    Organization = _POST["Organization"].ToString(),
                    ID = _POST["ID"].ToString(),
                };

                //if (!model.Organizations.Contains(model.EXTAdminUser.Organization))
                //{
                //    throw new Exception(string.Format("{0} does not exist.", EXTAdminUser.Organization));
                //}

                CommonCAS.Log(string.Format("has run Level30/RemoveEXTAdmin(), '{0}' for '{1}'", EXTAdminUser.ID, EXTAdminUser.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveEXTAdminUser(EXTAdminUser.ID, EXTAdminUser.Organization);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Admin {0} has been added.", EXTAdminUser.ID));
                    }
                    else
                    {

                        foreach (PSObject message in result)
                        {
                            CommonCAS.Log(string.Format("Remove Admin info: {1}", EXTAdminUser.ID, message.ToString()));
                            model.OKMessage.Add(string.Format("Extra info: {0}", message.ToString()));
                        }
                    }
                }

                model.OKMessage.Add(string.Format("EXT Admin '{0}' Removed for organization '{1}'.", EXTAdminUser.ID, EXTAdminUser.Organization));

                CommonCAS.Stats("Level30/RemoveEXTAdmin");

                return View("RemoveEXTAdmin", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display CreateEXTAdmin view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult ScheduleEXTAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult ScheduleEXTAdmin(FormCollection _POST)
        {
            try
            {
                CustomEXTAdminUser EXTAdminUser = new CustomEXTAdminUser()
                {
                    Customer = _POST["Customer"].ToString(),
                    FirstName = _POST["FirstName"].ToString(),
                    LastName = _POST["LastName"].ToString(),
                    Email = _POST["Email"].ToString(),
                    Company = _POST["Company"].ToString(),
                    Description = _POST["Description"].ToString(),
                    ExpireDate = _POST["ExpireDate"].ToString(),
                };

                // Used for success email
                model.EXTAdminUser.Email = EXTAdminUser.Email;

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ScheduleEXTAdminUser(EXTAdminUser);
                    var result = ps.Invoke();

                }

                return View("ScheduleEXTAdminSuccess", model);
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
        /// Get current EXT Admins
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetEXTAdminUsersSELECT(string id, string status, string organization)
        {
            try
            {
                List<CustomEXTAdminUserLIST> EXTAdmins = new List<CustomEXTAdminUserLIST>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetEXTAdminUser(id, status, organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject EXTAdmin in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(EXTAdmin);
                        EXTAdmins.Add(new CustomEXTAdminUserLIST()
                        {
                            Customer = properties["Customer"].ToString(),
                            ID = properties["ID"].ToString(),
                            Organization = properties["Organization"].ToString(),
                            Status = properties["Status"].ToString(),
                            FirstName = properties["FirstName"].ToString(),
                            LastName = properties["LastName"].ToString(),
                            Email = properties["Email"].ToString(),
                            Description = properties["Description"].ToString(),
                            Company = properties["Company"].ToString(),
                            ExpireDate = properties["ExpireDate"].ToString(),
                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(EXTAdmins);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public string GetEXTAdminUsers(string id, string status, string organization)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetEXTAdminUser(id, status, organization);
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    returnstr += "<tr><td><b>Nothing here!..</b></td></tr>";
                }
                else
                {
                    // Returns string with properties..
                    foreach (var item in result)
                    {
                        var Status = item.Members["Status"].Value.ToString();

                        if (Status == "Done")
                        {
                            {
                                returnstr += "<center><table class='SQLdark'><tr><td style='width: 150px; text-align: left;'><b>Customer</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Customer"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Firstname</b></td><td style='text-align: left'>" + item.Members["FirstName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Lastname</b></td><td style='text-align: left'>" + item.Members["LastName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>SamAccountName</b></td><td style='text-align: left'>" + item.Members["SamAccountName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Email</b></td><td style='text-align: left'>" + item.Members["Email"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Customer</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Customer"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Company</b></td><td style='text-align: left; font-weight:bold; color: #e60000'>" + item.Members["Company"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='text-align: left'>" + item.Members["Description"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Expiry date</b></td><td style='text-align: left'>" + item.Members["ExpireDate"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Created</b></td><td style='text-align: left'>" + item.Members["DateTime"].Value.ToString() + "</td></tr></table></center></br>";
                            }
                        }
                        if (Status == "Scheduled")
                        {
                            {
                                returnstr += "<center><table class='SQLdark'><tr><td style='width: 150px; text-align: left;'><b>ID</b></td><td style='text-align: left;'>" + item.Members["ID"].Value.ToString() + "</td>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Firstname</b></td><td style='text-align: left'>" + item.Members["FirstName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Lastname</b></td><td style='text-align: left'>" + item.Members["LastName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Email</b></td><td style='text-align: left'>" + item.Members["Email"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Customer</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Customer"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Company</b></td><td style='text-align: left; font-weight:bold; color: #e60000'>" + item.Members["Company"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='text-align: left'>" + item.Members["Description"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Expiry date</b></td><td style='text-align: left'>" + item.Members["ExpireDate"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Created</b></td><td style='text-align: left'>" + item.Members["DateTime"].Value.ToString() + "</td></tr></table></center></br>";
                            }
                        }
                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }


        /// <summary>
        /// Get current EXT Admins
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetCASAdminUsersSELECT(string id, string status, string organization)
        {
            try
            {
                List<CustomCASAdminUserLIST> CASAdmins = new List<CustomCASAdminUserLIST>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetCASAdminUser(id, status, organization.ToString().Split(' ')[0]);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject CASAdmin in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(CASAdmin);
                        CASAdmins.Add(new CustomCASAdminUserLIST()
                        {
                            ID = properties["ID"].ToString(),
                            Organization = properties["Organization"].ToString().Split(' ')[0],
                            Status = properties["Status"].ToString(),
                            UserName = properties["UserName"].ToString(),
                            FirstName = properties["FirstName"].ToString(),
                            LastName = properties["LastName"].ToString(),
                            Email = properties["Email"].ToString(),
                            Description = properties["Description"].ToString(),
                            Department = properties["Department"].ToString(),
                            ExpireDate = properties["ExpireDate"].ToString(),
                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(CASAdmins);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public string GetCASAdminUsers(string id, string status, string organization)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCASAdminUser(id, status, organization);
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    returnstr += "<tr><td><b>Nothing here!..</b></td></tr>";
                }
                else
                {
                    // Returns string with properties..
                    foreach (var item in result)
                    {
                        var Status = item.Members["Status"].Value.ToString();

                        if (Status == "Done")
                        {
                            {
                                returnstr += "<center><table class='SQLdark'><tr><td style='width: 150px; text-align: left;'><b>ID</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["ID"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Firstname</b></td><td style='text-align: left'>" + item.Members["FirstName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Lastname</b></td><td style='text-align: left'>" + item.Members["LastName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>UserName</b></td><td style='text-align: left'>" + item.Members["UserName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Email</b></td><td style='text-align: left'>" + item.Members["Email"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Department</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Department"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Organization</b></td><td style='text-align: left; font-weight:bold; color: #e60000'>" + item.Members["Organization"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='text-align: left'>" + item.Members["Description"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Expiry date</b></td><td style='text-align: left'>" + item.Members["ExpireDate"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Created</b></td><td style='text-align: left'>" + item.Members["DateTime"].Value.ToString() + "</td></tr></table></center></br>";
                            }
                        }
                        if (Status == "Deleted")
                        {
                            {
                                returnstr += "<center><table class='SQLdark'><tr><td style='width: 150px; text-align: left;'><b>ID</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["ID"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Firstname</b></td><td style='text-align: left'>" + item.Members["FirstName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Lastname</b></td><td style='text-align: left'>" + item.Members["LastName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>UserName</b></td><td style='text-align: left'>" + item.Members["UserName"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Email</b></td><td style='text-align: left'>" + item.Members["Email"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Department</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Department"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Organization</b></td><td style='text-align: left; font-weight:bold; color: #e60000'>" + item.Members["Organization"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Description</b></td><td style='text-align: left'>" + item.Members["Description"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Expiry date</b></td><td style='text-align: left'>" + item.Members["ExpireDate"].Value.ToString() + "</td></tr>";
                                returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Created</b></td><td style='text-align: left'>" + item.Members["DateTime"].Value.ToString() + "</td></tr></table></center></br>";
                            }
                        }
                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // Display RemoveCASAdmin view
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveCASAdmin()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveCASAdmin(FormCollection _POST)
        {
            try
            {
                CustomCASAdminUser CASAdminUser = new CustomCASAdminUser()
                {
                    Organization = _POST["Organization"].ToString().Split(' ')[0],
                    ID = _POST["ID"].ToString(),
                };

                //if (!model.Organizations.Contains(model.EXTAdminUser.Organization))
                //{
                //    throw new Exception(string.Format("{0} does not exist.", EXTAdminUser.Organization));
                //}

                CommonCAS.Log(string.Format("has run Level30/RemoveCASAdmin(), '{0}' for '{1}'", CASAdminUser.ID, CASAdminUser.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveCASAdminUser(CASAdminUser.ID, CASAdminUser.Organization);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Admin {0} has been removed.", CASAdminUser.ID));
                    }
                    else
                    {

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(string.Format("Info: {0}", message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Level30/RemoveCASAdmin");

                return View("RemoveCASAdmin", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }



        [Authorize(Roles = "Role_Level_30")]
        public ActionResult UpdateSharedCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult UpdateSharedCustomer(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomSharedCustomer UpdateSharedCustomer = new CustomSharedCustomer()
                {
                    Organization = _POST["organization"].ToUpper(),
                    Name = _POST["Name"],
                    NavMiddleTier = _POST["navmiddletier"],
                    SQLServer = _POST["sqlserver"]

                };

                model.UpdateSharedCustomer = UpdateSharedCustomer;

                CommonCAS.Log(string.Format("has run Level30/UpdateSharedCustomer() for {0}", UpdateSharedCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateSharedCustomer(UpdateSharedCustomer);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The configuration has been updated for {0}", UpdateSharedCustomer.Organization));

                CommonCAS.Stats("Level30/UpdateSharedCustomer");

                return View("UpdateSharedCustomer", model);
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
        /// Get current conf to JSON
        /// </summary>
        /// <returns></returns>
        [Authorize(Roles = "Role_Level_30")]
        public string GetCurrentSharedCustomerConfLIST(string organization)
        {
            try
            {
                List<CustomGetConfLIST> GetConfList = new List<CustomGetConfLIST>();


                using (MyPowerShell ps = new MyPowerShell())
                {
                    var shortorganization = organization.ToString().Split(' ')[0];
                    ps.GetCurrentSharedCustomerConf(shortorganization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject conf in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(conf);
                        GetConfList.Add(new CustomGetConfLIST()
                        {
                            Name = properties["Name"].ToString(),
                            NavMiddleTier = properties["NavMiddleTier"].ToString(),
                            SQLServer = properties["SQLServer"].ToString(),
                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(GetConfList);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateSharedCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateSharedCustomer(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomSharedCustomer UpdateSharedCustomer = new CustomSharedCustomer()
                {
                    Organization = _POST["organization"].ToUpper(),
                    Name = _POST["Name"],
                    NavMiddleTier = _POST["navmiddletier"],
                    SQLServer = _POST["sqlserver"]

                };

                model.UpdateSharedCustomer = UpdateSharedCustomer;

                CommonCAS.Log(string.Format("has run Level30/CreateSharedCustomer() for {0}", UpdateSharedCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateSharedCustomer(UpdateSharedCustomer);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The configuration has been updated for {0}", UpdateSharedCustomer.Organization));

                CommonCAS.Stats("Level30/CreateSharedCustomer");

                return View("CreateSharedCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Role_Level_30")]
        public string GetCASOrganizations()
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCASOrganizations();
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    returnstr += "<tr><td><b>Nothing here!..</b></td></tr>";
                }
                else
                {
                    // Returns string with properties..
                    foreach (var item in result)
                    {

                        {
                            returnstr += "<center><table class='SQLlight'><tr><td style='width: 150px; text-align: left;'><b>Organization</b></td><td style='text-align: left; font-weight:bold'>" + item.Members["Organization"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>Name</b></td><td style='text-align: left'>" + item.Members["Name"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>NavMiddleTier</b></td><td style='text-align: left'>" + item.Members["NavMiddleTier"].Value.ToString() + "</td></tr>";
                            returnstr += "<tr><td style='width: 150px; text-align: left;'><b>SQLServer</b></td><td style='text-align: left'>" + item.Members["SQLServer"].Value.ToString() + "</td></tr></table></center></br>";
                        }
                    
                    }
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveSharedCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult RemoveSharedCustomer(FormCollection _POST)
        {
            try
            {
                CustomSharedCustomer UpdateSharedCustomer = new CustomSharedCustomer()
                {
                    Organization = _POST["organization"].ToString().Split(' ')[0]

                };

                CommonCAS.Log(string.Format("has run Level30/RemoveSharedCustomer() for {0}", UpdateSharedCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveSharedCustomer(UpdateSharedCustomer.Organization);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("The configuration has been removed for {0}", UpdateSharedCustomer.Organization));

                CommonCAS.Stats("Level30/RemoveSharedCustomer");

                return View("RemoveSharedCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

    }
}
