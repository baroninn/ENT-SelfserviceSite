using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Web.Mvc;

namespace ColumbusPortal.Controllers
{
    public class HomeController : Controller
    {
        HomeModel model = new HomeModel();
        [OutputCache(Duration = 300, VaryByParam = "none")] // cached for 300 seconds
        [Authorize]
        public ActionResult Index()
        {
            return View();
        }

        [Authorize]
        public ActionResult MyClaims()
        {
            return View();
        }

        [Authorize]
        public ActionResult ChangeLog()
        {
            return View();
        }

        [Authorize]
        public ActionResult MyInfo()
        {
            return View();
        }

        [Authorize]
        public ActionResult Log()
        {
            model.Log = CommonCAS.GetLog();

            if (model.Log.Count == 0) { model.Log.Add("Log is empty..."); }

            return View(model);
        }
        [Authorize]
        public ActionResult AzureLog()
        {
            model.AzureLog = CommonCAS.GetAzureLog();

            if (model.AzureLog.Count == 0) { model.AzureLog.Add("AzureLog is empty..."); }

            return View(model);
        }
    }
}