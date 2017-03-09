using System;
using System.Collections.Generic;
using System.DirectoryServices;
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
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult Create(FormCollection _POST)
        {
            try
            {

                // set up a user account for display in view
                CustomOrganization organization = new CustomOrganization()
                {
                    Name = _POST["name"].ToUpper(),
                    EmailDomainName = _POST["emaildomainname"].ToLower(),
                    Subnet = _POST["subnet"].ToLower(),
                    Vlan = _POST["vlan"].ToLower(),
                    IPAddressRangeStart = _POST["ipaddressrangestart"].ToLower(),
                    IPAddressRangeEnd = _POST["ipaddressrangeend"].ToLower(),
                };

                model.Organization = organization;

                if (model.Organizations.Contains(model.Organization.Name))
                {
                    throw new ArgumentException(string.Format("The organizaton '{0}' already exists.", model.Organization.Name));
                }

                if (model.Organization.Name.Length < 2 || model.Organization.Name.Length > 5)
                {
                    throw new ArgumentException("The organizaton name must be between 2 and 5 characters.");
                }

                if (!model.Organization.EmailDomainName.Contains(".") || model.Organization.EmailDomainName.Contains("@"))
                {
                    throw new ArgumentException(string.Format("'{0}' is not a valid email domain name.", model.Organization.EmailDomainName));
                }

                Common.Log(string.Format("has run Organization/Create() to create {0}", model.Organization.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateOrganization(model.Organization.Name, model.Organization.EmailDomainName, model.Organization.Subnet, model.Organization.Vlan, model.Organization.IPAddressRangeStart, model.Organization.IPAddressRangeEnd);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}' created.", model.Organization.Name));

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
