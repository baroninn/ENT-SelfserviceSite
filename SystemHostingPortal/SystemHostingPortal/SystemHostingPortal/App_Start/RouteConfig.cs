using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace SystemHostingPortal
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "CtrlOnly", "{controller}",
                defaults: new { controller = "Home", action = "Index" });
            routes.MapRoute(
                "CtrlAction", "{controller}/{action}",
                defaults: new { controller = "Home", action = "Index" });

            routes.MapRoute(
                name: "Default", url: "",
                defaults: new { controller = "Home", action = "Index" }
            );
        }
    }
}