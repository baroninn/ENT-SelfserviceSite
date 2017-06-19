using System;
using System.Dynamic;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using System.Security.Principal;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;
using System.Text.RegularExpressions;

namespace SystemHostingPortal.Controllers
{
    [Authorize(Roles = "Access_SelfService_FullAccess")]
    public class HomeController : Controller
    {
        HomeModel model = new HomeModel();
        [OutputCache(Duration = 300, VaryByParam = "none")] // cached for 300 seconds
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Log()
        {
            model.Log = Common.GetLog();

            if (model.Log.Count == 0) { model.Log.Add("Log is empty..."); }

            return View(model);
        }

        public ActionResult AzureLog()
        {
            model.AzureLog = Common.GetAzureLog();

            if (model.AzureLog.Count == 0) { model.AzureLog.Add("AzureLog is empty..."); }

            return View(model);
        }

        public ActionResult Test()
        {

            return View();
        }
    }
}
