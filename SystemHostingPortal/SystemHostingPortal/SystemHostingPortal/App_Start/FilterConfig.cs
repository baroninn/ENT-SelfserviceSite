using System.Web;
using System.Dynamic;
using System.Web.Mvc;
using System.Web.Security;
using System.Security.Principal;

namespace SystemHostingPortal
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}