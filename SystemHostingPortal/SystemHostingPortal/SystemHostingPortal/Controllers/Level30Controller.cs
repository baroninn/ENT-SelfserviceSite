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
                    CustomerOUDN = _POST["customeroudn"],
                    AcceptedDomains = _POST["accepteddomains"],
                    TenantID365 = _POST["tenantid365"],
                    AdminUser365 = _POST["adminuser365"],
                    AdminPass365 = _POST["adminpass365"]
                };

                Common.Log(string.Format("has run Organization/UpdateConf() to create {0}", UpdateConf.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateConf(UpdateConf.Organization, UpdateConf.ExchangeServer, UpdateConf.DomainFQDN, UpdateConf.CustomerOUDN, UpdateConf.AcceptedDomains, UpdateConf.TenantID365, UpdateConf.AdminUser365, UpdateConf.AdminPass365);
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
                const int MaxLength = 75;
                // Returns PSObject with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td class=" + "lefttd" + "><b>ExchangeServer: </b></td><td>" + item.Members["ExchangeServer"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>DomainFQDN: </b></td><td>" + item.Members["DomainFQDN"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>Domain: </b></td><td>" + item.Members["Domain"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>Customer OU DN: </b></td><td>" + item.Members["CustomerOUDN"].Value.ToString() + "</td></tr></table>";
                  //  returnstr += "<tr><td class=" + "lefttd" + "><b>Accepted Domains : </b></td><td>" + item.Members["AcceptedDomains"].Value.ToString() + "</td></tr>";
                    returnstr += "<table><tr><td class=" + "lefttd" + "><b>Accepted Domains: </b></td><td>" + item.Members["AcceptedDomains"].Value.ToString().PadRight(MaxLength).Substring(0, MaxLength) + "</td></tr></table>";
                    returnstr += "<table><tr><td class=" + "lefttd" + "><b>TenantID365: </b></td><td>" + item.Members["TenantID365"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AdminUser365: </b></td><td>" + item.Members["AdminUser365"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td class=" + "lefttd" + "><b>AdminPass365: </b></td><td>" + item.Members["AdminPass365"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // test config get.. Needs to be retrieved by .net instead of javascript..
        private void GetConf()
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCurrentConf(model.GetConf.Organization);
                var result = ps.Invoke().Single();
                var DomainFQDN = (PSObject)result.Properties["DomainFQDN"].Value;
                var ExchangeServer = (PSObject)result.Properties["ExchangeServer"].Value;

                model.GetConf.DomainFQDN = (DomainFQDN.Members.ToString());
                model.GetConf.ExchangeServer = model.GetConf.ExchangeServer.ToString();

            }
        }



    }
}
