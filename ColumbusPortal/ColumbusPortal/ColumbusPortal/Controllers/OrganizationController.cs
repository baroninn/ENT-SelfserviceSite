using System;
using System.Linq;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Management.Automation;

namespace ColumbusPortal.Controllers
{
    
    public class OrganizationController : Controller
    {
        OrganizationModel model = new OrganizationModel();

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult Create()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult Create(FormCollection _POST)
        {
            try
            {
                CustomOrganization organization = new CustomOrganization()
                {
                    Name = _POST["name"],
                    initials = _POST["initials"].ToUpper(),
                    EmailDomainName = _POST["emaildomainname"].ToLower(),
                    Subnet = _POST["subnet"],
                    Vlan = _POST["vlan"],
                    Gateway = _POST["gateway"],
                    IPAddressRangeStart = _POST["ipaddressrangestart"],
                    IPAddressRangeEnd = _POST["ipaddressrangeend"],
                    CreateVMM = _POST["createvmm"] == "on" ? true : false
                };

                model.Organization = organization;

                if (model.Organizations.Contains(organization.initials))
                {
                    throw new ArgumentException(string.Format("The organizaton '{0}' already exists.", organization.initials));
                }

                if (organization.initials.Length < 2 || organization.initials.Length > 5)
                {
                    throw new ArgumentException("The organizaton name must be between 2 and 5 characters.");
                }

                if (!organization.EmailDomainName.Contains(".") || organization.EmailDomainName.Contains("@"))
                {
                    throw new ArgumentException(string.Format("'{0}' is not a valid email domain name.", organization.EmailDomainName));
                }

                CommonCAS.Log(string.Format("has run Organization/Create() to create {0}", organization.initials));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateOrganization(organization.initials, organization.Name, organization.EmailDomainName, organization.Subnet, organization.Vlan, organization.Gateway, organization.IPAddressRangeStart, organization.IPAddressRangeEnd, organization.CreateVMM);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}' created.", organization.initials));

                CommonCAS.Stats("Organization/Create");

                return View("Create", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveCustomer(FormCollection _POST)
        {
            try
            {
                model.RemoveCustomer = new CustomRemoveCustomer()
                {
                    Organization = _POST["organization"],
                    RemoveData = _POST["removedata"] == "on" ? true : false,
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.Organizations.Contains(model.RemoveCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.Log(string.Format("has run Organization/RemoveCustomer() to remove customer '{0}'", model.RemoveCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveCustomer(model.RemoveCustomer.Organization, model.RemoveCustomer.RemoveData, model.RemoveCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Customer '{0}' removed, Check manual steps.", model.RemoveCustomer.Organization));

                CommonCAS.Stats("Organization/RemoveCustomer");

                return View("RemoveCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult DisableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult DisableCustomer(FormCollection _POST)
        {
            try
            {
                model.DisableCustomer = new CustomDisableCustomer()
                {
                    Organization = _POST["organization"],
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.Organizations.Contains(model.DisableCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.Log(string.Format("has run Organization/DisableCustomer()", model.DisableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DisableCustomer(model.DisableCustomer.Organization, model.DisableCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been disabled and Activesync is disabled on mailbox.", model.DisableCustomer.Organization));

                CommonCAS.Stats("Organization/DisableCustomer");

                return View("DisableCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult EnableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult EnableCustomer(FormCollection _POST)
        {
            try
            {
                model.EnableCustomer = new CustomEnableCustomer()
                {
                    Organization = _POST["organization"],
                };

                if (!model.Organizations.Contains(model.EnableCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.Log(string.Format("has run Organization/EnableCustomer()", model.EnableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.EnableCustomer(model.EnableCustomer.Organization);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been enabled and Activesync is enabled on mailbox.", model.EnableCustomer.Organization));

                CommonCAS.Stats("Organization/EnableCustomer");

                return View("EnableCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddDomain(FormCollection _POST)
        {
            try
            {
                CustomDomain AddDomain = new CustomDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"],
                    AddasEmail = _POST["addasemail"] == "on" ? true : false
                };

                model.Domain = AddDomain;

                CommonCAS.Log(string.Format("has run Organization/AddDomain() for organization {0} to add domain {1}", AddDomain.Organization, AddDomain.Domain));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddDomain(AddDomain.Organization, AddDomain.Domain, AddDomain.AddasEmail);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("'{0}' added for organization '{1}'.", model.Domain.Domain, model.Domain.Organization));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("Domain {0} has been added with following info:", AddDomain.Domain));

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                            CommonCAS.Log(string.Format("Domain {0} info: {1}", AddDomain.Domain, message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Organization/AddDomain");

                return View("AddDomain", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveDomain(FormCollection _POST)
        {
            try
            {
                CustomDomain RemoveDomain = new CustomDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domainname"],
                    RemoveasEmail = _POST["removeasemail"] == "on" ? true : false
                };

                model.Domain = RemoveDomain;

                CommonCAS.Log(string.Format("has run Organization/RemoveDomain() for organization {0} to Remove domain {1}", RemoveDomain.Organization, RemoveDomain.Domain));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveDomain(RemoveDomain.Organization, RemoveDomain.Domain, RemoveDomain.RemoveasEmail);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("'{0}' Removed for organization '{1}'.", model.Domain.Domain, model.Domain.Organization));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("Domain {0} has been removed with following info:", RemoveDomain.Domain));

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                            CommonCAS.Log(string.Format("Domain {0} info: {1}", RemoveDomain.Domain, message.ToString()));
                        }
                    }
                }

                CommonCAS.Stats("Organization/RemoveDomain");

                return View("RemoveDomain", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display disable user page
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateAllAdmins()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Disable POSTed user and display result page
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateAllAdmins(FormCollection _POST)
        {

            try
            {
                model.CreateALLAdmins.Organization = _POST["organization"];

                CommonCAS.Log(string.Format("has run Organization/CreateALLAdmins() for customer {0}", model.CreateALLAdmins.Organization));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateALLAdmins(model.CreateALLAdmins.Organization);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("Admins successfully created.");
                    }
                    else
                    {

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("Organization/CreateALLAdmins");

                return View("CreateALLAdmins", model);
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
