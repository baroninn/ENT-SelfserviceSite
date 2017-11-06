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
        // Display Connect view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult ConnectAdminRDS()
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
                    Platform = _POST["platform"],
                    Name = _POST["Organization.Name"],
                    initials = _POST["Organization.initials"].ToUpper(),
                    EmailDomainName = _POST["Organization.EmailDomainName"].ToLower(),
                    Subnet = _POST["Organization.Subnet"],
                    Vlan = _POST["Organization.Vlan"],
                    Gateway = _POST["Organization.Gateway"],
                    IPAddressRangeStart = _POST["Organization.IPAddressRangeStart"],
                    IPAddressRangeEnd = _POST["Organization.IPAddressRangeEnd"],
                    CreateVMM = _POST["createvmm"] == "on" ? true : false,
                    createcrayon = _POST["createcrayon"] == "on" ? true : false,
                };

                CustomCrayonTenantInfoDetailed crayontenantinfodetailed = new CustomCrayonTenantInfoDetailed()
                {
                    InvoiceProfile = _POST["InvoiceProfile"].ToString(),
                    DomainPrefix = _POST["CrayonDomainPrefix"],
                    FirstName = _POST["CrayonFirstName"],
                    LastName = _POST["CrayonLastName"],
                    Email = _POST["CrayonTenantInfoDetailed.CrayonEmail"],
                    PhoneNumber = _POST["CrayonPhoneNumber"],
                    CustomerFirstName = _POST["CrayonCustomerFirstName"],
                    CustomerLastName = _POST["CrayonCustomerLastName"],
                    AddressLine1 = _POST["CrayonAddressLine1"],
                    City = _POST["CrayonCity"],
                    Region = _POST["CrayonRegion"],
                    PostalCode = _POST["CrayonPostalCode"]

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
                    ps.CreateOrganization(organization, crayontenantinfodetailed);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Organization '{0}' created.", organization.initials));
                        CommonCAS.Log(string.Format("has run Organization/Create() to create {0}", organization.initials));
                    }
                    else
                    {
                        CommonCAS.Log(string.Format("has run Organization/Create() to create {0}", organization.initials));
                        model.OKMessage.Add(string.Format("Organization '{0}' created with following info:", organization.initials));
                        
                        if (organization.createcrayon)
                        {
                            foreach (PSObject item in result)
                            {
                                model.CrayonTenantDetailed.ExternalPublisherCustomerId = item.Members["ExternalPublisherCustomerId"].Value.ToString();
                                model.CrayonTenantDetailed.AdminUser = item.Members["AdminUser"].Value.ToString();
                                model.CrayonTenantDetailed.AdminPass = item.Members["AdminPass"].Value.ToString();
                                
                            }
                        }
                    }
                }

                CommonCAS.Stats("Organization/Create");
                return View("CreateSuccess", model);
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
