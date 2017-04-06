using System;
using System.Dynamic;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;

namespace SystemHostingPortal.Controllers
{
    [Authorize(Roles = "Access_SelfService_FullAccess")]
    public class HomeController : Controller
    {
        HomeModel model = new HomeModel();

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

        public ActionResult Test()
        {

            return View();
        }
    }
}
