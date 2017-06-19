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
    
    public class Office365Controller : Controller
    {
        Office365Model model = new Office365Model();

        // Display Verifyomain view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult VerifyDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult VerifyDomain(FormCollection _POST)
        {
            try
            {
                model.VerifyDomain = new CustomVerifyDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domainname"]
                };

                if (!model.Organizations.Contains(model.VerifyDomain.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                Common.Log(string.Format("has run Office365/VerifyDomain() to verify '{0}' for '{1}'", model.VerifyDomain.Domain, model.VerifyDomain.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.VerifyDomain(model.VerifyDomain.Organization, model.VerifyDomain.Domain);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Domain {0} has been added.", model.VerifyDomain.Domain));
                    }
                    else
                    {

                        foreach (PSObject message in result)
                        {
                            Common.Log(string.Format("Domain {0} info: {1}", model.VerifyDomain.Domain, message.ToString()));
                            throw new Exception(string.Format(message.ToString()));
                        }
                    }
                }

                model.OKMessage.Add(string.Format("Domain '{0}' added for organization '{1}'.", model.VerifyDomain.Domain, model.VerifyDomain.Organization));

                Common.Stats("Office365/VerifyDomain");

                return View("VerifyDomain", model);
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
        /// Ajax function for aquiring TenantIDs
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetTenantID(string organization)
        {
            string returnstr = "<table>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetTenantID(organization);
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td><b>Office 365 PartnerName : </b></td><td>" + item.Members["PartnerName"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 TenantID    : </b></td><td>" + item.Members["Id"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 Admin       : </b></td><td>" + item.Members["Admin"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 License     : </b></td><td>" + item.Members["License"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

    }
}
