using System.Web;
using System.Dynamic;
using System.Web.Mvc;

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