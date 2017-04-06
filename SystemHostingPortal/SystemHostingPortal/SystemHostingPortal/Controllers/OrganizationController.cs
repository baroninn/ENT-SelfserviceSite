using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Dynamic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;
using System.Management.Automation;

namespace SystemHostingPortal.Controllers
{
    
    public class OrganizationController : Controller
    {
        OrganizationModel model = new OrganizationModel();

        // Display create view
        [Authorize(Roles = "Role_Level_30")]
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
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult Create(FormCollection _POST)
        {
            try
            {
                CustomOrganization organization = new CustomOrganization()
                {
                    Name = _POST["name"].ToUpper(),
                    EmailDomainName = _POST["emaildomainname"].ToLower(),
                    Subnet = _POST["subnet"],
                    Vlan = _POST["vlan"],
                    IPAddressRangeStart = _POST["ipaddressrangestart"],
                    IPAddressRangeEnd = _POST["ipaddressrangeend"],
                    CreateVMM = _POST["createvmm"] == "on" ? true : false
                };

                model.Organization = organization;

                if (model.Organizations.Contains(organization.Name))
                {
                    throw new ArgumentException(string.Format("The organizaton '{0}' already exists.", organization.Name));
                }

                if (organization.Name.Length < 2 || organization.Name.Length > 5)
                {
                    throw new ArgumentException("The organizaton name must be between 2 and 5 characters.");
                }

                if (!organization.EmailDomainName.Contains(".") || organization.EmailDomainName.Contains("@"))
                {
                    throw new ArgumentException(string.Format("'{0}' is not a valid email domain name.", organization.EmailDomainName));
                }

                Common.Log(string.Format("has run Organization/Create() to create {0}", organization.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateOrganization(organization.Name, organization.EmailDomainName, organization.Subnet, organization.Vlan, organization.IPAddressRangeStart, organization.IPAddressRangeEnd, organization.CreateVMM);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}' created.", organization.Name));

                Common.Stats("Organization/Create");

                return View("Create", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
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

                Common.Log(string.Format("has run Organization/RemoveCustomer() to remove customer '{0}'", model.RemoveCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveCustomer(model.RemoveCustomer.Organization, model.RemoveCustomer.RemoveData, model.RemoveCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Customer '{0}' removed, Check manual steps.", model.RemoveCustomer.Organization));

                Common.Stats("Organization/RemoveCustomer");

                return View("RemoveCustomer", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
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

                Common.Log(string.Format("has run Organization/DisableCustomer()", model.DisableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DisableCustomer(model.DisableCustomer.Organization, model.DisableCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been disabled and Activesync is disabled on mailbox.", model.DisableCustomer.Organization));

                Common.Stats("Organization/DisableCustomer");

                return View("DisableCustomer", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
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

                Common.Log(string.Format("has run Organization/EnableCustomer()", model.EnableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.EnableCustomer(model.EnableCustomer.Organization);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been enabled and Activesync is enabled on mailbox.", model.EnableCustomer.Organization));

                Common.Stats("Organization/EnableCustomer");

                return View("EnableCustomer", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }



    }
}
