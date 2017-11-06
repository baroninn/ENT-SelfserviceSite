using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Management.Automation;
using System.Web.Script.Serialization;

namespace ColumbusPortal.Controllers
{
    public class CrayonController : Controller
    {
        CrayonModel model = new CrayonModel();

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateCrayonTenant()
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

        // Create POSTed crayon tenant
        [HttpPost]
        [Authorize(Roles = "Role_Level_30")]
        public ActionResult CreateCrayonTenant(FormCollection _POST)
        {
            try
            {
                CustomCrayonTenant CrayonTenant = new CustomCrayonTenant()
                {
                    Name = _POST["Name"],
                    Reference = _POST["Reference"],
                    InvoiceProfile = _POST["InvoiceProfile"],
                    DomainPrefix = _POST["DomainPrefix"],
                    FirstName = _POST["FirstName"],
                    LastName = _POST["LastName"],
                    Email = _POST["Email"],
                    PhoneNumber = _POST["PhoneNumber"],
                    CustomerFirstName = _POST["CustomerFirstName"],
                    CustomerLastName = _POST["CustomerLastName"],
                    AddressLine1 = _POST["AddressLine1"],
                    City = _POST["City"],
                    Region = _POST["Region"],
                    PostalCode = _POST["PostalCode"],
                };

                model.CrayonTenant = CrayonTenant;

                CommonCAS.Log(string.Format("has run Crayon/CreateTenant() to create {0}", CrayonTenant.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateCrayonTenant(CrayonTenant);
                    var result = ps.Invoke().Single();

                    model.CrayonTenantDetailed.Name = result.Members["Name"].Value.ToString();
                    model.CrayonTenantDetailed.DomainPrefix = result.Members["DomainPrefix"].Value.ToString();
                    model.CrayonTenantDetailed.PublisherCustomerId = result.Members["PublisherCustomerId"].Value.ToString();
                    model.CrayonTenantDetailed.ExternalPublisherCustomerId = result.Members["ExternalPublisherCustomerId"].Value.ToString();
                    model.CrayonTenantDetailed.Reference = result.Members["Reference"].Value.ToString();
                    model.CrayonTenantDetailed.AdminUser = result.Members["AdminUser"].Value.ToString();
                    model.CrayonTenantDetailed.AdminPass = result.Members["AdminPass"].Value.ToString();

                }

                CommonCAS.Log(string.Format("Crayon Tenant {0} created with: {1}, {2}", CrayonTenant.Reference, model.CrayonTenantDetailed.AdminUser, model.CrayonTenantDetailed.AdminPass));

                model.OKMessage.Add(string.Format("Crayon Tenant '{0}' created.", CrayonTenant.Name));

                CommonCAS.Stats("Crayon/CreateCrayonTenant");

                return View("CreateCrayonTenantSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }
        public string GetCrayonInvoiceProfiles()
        {
            try
            {
                List<CustomCrayonInvoiceProfile> CrayonInvoiceProfiles = new List<CustomCrayonInvoiceProfile>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetCrayonInvoiceProfiles();
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject profiles in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(profiles);

                        CrayonInvoiceProfiles.Add(new CustomCrayonInvoiceProfile()
                        {
                            Name = properties["Name"].ToString(),
                            Id = properties["Id"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(CrayonInvoiceProfiles);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

    }
}