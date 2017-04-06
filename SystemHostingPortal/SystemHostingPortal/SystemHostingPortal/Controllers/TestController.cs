using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Controllers
{
    [Authorize(Roles = "Access_Level_20")]
    public class TestController : Controller
    {
        //
        // GET: /Test/

        public string Index()
        {
            /*string str = "";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.CustomerReportTest();
                var result = ps.Invoke();

                foreach (PSObject p in result)
                {
                    //foreach (PSPropertyInfo pi in p.Properties)
                    //{
                    //    str += string.Format("{0} - {1}<br />", pi.Name, pi.Value);
                    //}

                    //Dictionary<string, string> users = (Dictionary<string, string>)p.Properties["ExchangeUsers"].Value;
                    Hashtable users = (Hashtable)p.Properties["ExchangeUsers"].Value;

                    foreach (DictionaryEntry user in users)
                    {
                        str += string.Format("{0} - {1}<br />", user.Key, user.Value);
                        //str += user + "<br />";
                    }
                }
            }

            return str;*/
            return "";
        }

    }
}
