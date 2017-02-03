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
    [Authorize(Roles = "Access_SelfService_FullAccess")]
    public class OrganizationController : Controller
    {
        OrganizationModel model = new OrganizationModel();

        // Display create view
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
        public ActionResult Create(FormCollection _POST)
        {
            try
            {

                // set up a user account for display in view
                CustomOrganization organization = new CustomOrganization()
                {
                    Name = _POST["name"].ToUpper(),
                    EmailDomainName = _POST["emaildomainname"].ToLower(),
                    FileServer = _POST["fileserver"],
                    FileServerDriveLetter = _POST["driveletter"],
                    Solution = _POST["solution"].ToUpper()
                };

                model.Organization = organization;

                if (model.Organizations.Contains(model.Organization.Name))
                {
                    throw new ArgumentException(string.Format("The organizaton '{0}' already exists.", model.Organization.Name));
                }

                switch (model.Organization.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "MEMBER2015":
                        break;
                    case "LEGAL":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.Organization.Solution));
                }

                if (model.Organization.Name.Length < 2 || model.Organization.Name.Length > 5)
                {
                    throw new ArgumentException("The organizaton name must be between 2 and 5 characters.");
                }

                if (!model.Organization.EmailDomainName.Contains(".") || model.Organization.EmailDomainName.Contains("@"))
                {
                    throw new ArgumentException(string.Format("'{0}' is not a valid email domain name.", model.Organization.EmailDomainName));
                }

                if (!model.Organization.EmailDomainName.StartsWith("dummy."))
                {
                    model.Organization.EmailDomainName = "dummy." + model.Organization.EmailDomainName;
                }

                Common.Log(string.Format("has run Organization/Create() to create {0}", model.Organization.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateOrganization(model.Organization.Name, model.Organization.EmailDomainName, model.Organization.Solution, model.Organization.FileServer, model.Organization.FileServerDriveLetter);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}' created with solution '{1}'.", model.Organization.Name, model.Organization.Solution));

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
        public ActionResult SetNavCompanyName()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        public ActionResult SetNavCompanyName(FormCollection _POST)
        {
            try
            {
                model.NavCompanyName = new CustomNavCompanyName()
                {
                    Organization = _POST["organization"],
                    CompanyName = _POST["navcompanyname"],
                    Solution = _POST["solution"].ToUpper(),
                    NativeDatabase = _POST["nativedb"] == "on" ? true : false,
                    Force = _POST["force"] == "on" ? true : false
                };

                if (!model.Organizations.Contains(model.NavCompanyName.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                switch (model.NavCompanyName.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "MEMBER2015":
                        break;
                    case "LEGAL":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.NavCompanyName.Solution));
                }

                Common.Log(string.Format("has run Organization/SetNavCompanyName() to set CompanyName '{0}' for '{1}'", model.NavCompanyName.CompanyName, model.NavCompanyName.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetNavCompanyName(model.NavCompanyName.Organization, model.NavCompanyName.CompanyName, model.NavCompanyName.Solution, model.NavCompanyName.NativeDatabase, model.NavCompanyName.Force);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("CompanyName '{0}' set for organization '{1}'.", model.NavCompanyName.CompanyName, model.NavCompanyName.Organization));

                Common.Stats("Organization/SetNavCompanyName");

                return View("SetNavCompanyName", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        public ActionResult RemoveDummyDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        [HttpPost]
        public ActionResult RemoveDummyDomain(FormCollection _POST)
        {
            try
            {
                model.RemoveDummyDomain = new CustomRemoveDummyDomain()
                {
                    Organization = _POST["organization"]
                };

                if (!model.Organizations.Contains(model.RemoveDummyDomain.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                Common.Log(string.Format("has run Organization/RemoveDummyDomain().", model.RemoveDummyDomain.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveDummyDomain(model.RemoveDummyDomain.Organization);
                    var result = ps.Invoke();

                    foreach (PSObject message in result)
                    {
                        model.OKMessage.Add(message.ToString());
                    }
                }

                //model.OKMessage.Add(string.Format("CompanyName '{0}' set for organization '{1}'.", model.RemoveDummyDomain.CompanyName, model.RemoveDummyDomain.Organization));

                Common.Stats("Organization/RemoveDummyDomain");

                return View("RemoveDummyDomain", model);
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
        public ActionResult RemoveCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
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
        public ActionResult DisableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
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
        public ActionResult EnableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
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

        // Display convert view
        public ActionResult ConvertCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        public ActionResult ConvertCustomer(FormCollection _POST)
        {
            try
            {
                model.ConvertCustomer = new CustomConvertCustomer()
                {
                    Organization = _POST["organization"],
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.Organizations.Contains(model.ConvertCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                Common.Log(string.Format("has run Organization/ConvertCustomer()", model.ConvertCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.ConvertCustomer(model.ConvertCustomer.Organization, model.ConvertCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', has been convertet.", model.ConvertCustomer.Organization));

                Common.Stats("Organization/ConvertCustomer");

                return View("ConvertCustomer", model);
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
