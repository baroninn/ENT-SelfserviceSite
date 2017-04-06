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

        // Display Addomain view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddDomain(FormCollection _POST)
        {
            try
            {
                model.AddDomain = new CustomAddDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"]
                };

                if (!model.Organizations.Contains(model.AddDomain.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                Common.Log(string.Format("has run Office365/AddDomain() to add '{0}' for '{1}'", model.AddDomain.Domain, model.AddDomain.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddUPN(model.AddDomain.Organization, model.AddDomain.Domain);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Domain '{0}' added for organization '{1}'.", model.AddDomain.Domain, model.AddDomain.Organization));

                Common.Stats("Office365/AddDomain");

                return View("AddDomain", model);
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
