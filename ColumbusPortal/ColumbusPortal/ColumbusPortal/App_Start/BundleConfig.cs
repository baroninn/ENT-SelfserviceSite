using System.Web;
using System.Web.Optimization;

namespace ColumbusPortal
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/js1").Include(
                        "~/Scripts/jquery.min.js",
                        "~/Scripts/jquery.validate.min.js",
                        "~/Scripts/jquery.validate.unobtrusive.min.js",
                        "~/Scripts/jquery.datetimepicker.full.min.js",
                        "~/Scripts/jquery-confirm.min.js",
                        "~/Scripts/jquery.collapse.min.js",
                        "~/Scripts/moment.min.js"

            ));
            bundles.Add(new ScriptBundle("~/bundles/js2").Include(
                        "~/Scripts/shtfunctions.min.js",
                        "~/Scripts/modernizr-2.8.3.js"
                        ));
            bundles.Add(new ScriptBundle("~/bundles/jqueryUI").Include(
                        "~/Scripts/jquery-ui.min.js"
            ));

            bundles.Add(new ScriptBundle("~/bundles/jsconfirm").Include(
                        "~/Scripts/jquery-confirm.min.js"
            ));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.min.js",
                      "~/Scripts/respond.min.js"
            ));

            bundles.Add(new StyleBundle("~/bundles/css").Include(
                      "~/Content/reset.min.css",
                      "~/Content/styleOrange.min.css",
                      "~/Content/jquery-ui.min.css",
                      "~/Content/jquery.datetimepicker.min.css",
                      "~/Content/jquery-confirm.min.css"
            ));
            bundles.Add(new StyleBundle("~/bundles/cssjquery").Include(
                      "~/Content/jquery-ui.min.css",
                      "~/Content/jquery.datetimepicker.min.css",
                      "~/Content/jquery-confirm.min.css"
            ));
            bundles.Add(new StyleBundle("~/bundles/cssjsconfirm").Include(
                      "~/Content/jquery-confirm.min.css"
            ));
        }
    }
}
