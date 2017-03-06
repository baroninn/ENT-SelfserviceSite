using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Models
{
    // model for View display in the 365 controller
    public class Level30Model : BaseModel
    {
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public CustomCurrentConf CurrentConf = new CustomCurrentConf();
    }


    public class CustomUpdateConf
    {
        public string Organization { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }
        public string CustomerOUDN { get; set; }
        public string AcceptedDomains { get; set; }
        public string TenantID365 { get; set; }
        public string AdminUser365 { get; set; }
        public string AdminPass365 { get; set; }

    }

    public class CustomCurrentConf
    {
        public string Organization { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }

    }

}