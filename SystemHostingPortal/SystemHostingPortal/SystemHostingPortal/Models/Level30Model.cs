using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Dynamic;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Models
{
    // model for View display in the level30 controller
    public class Level30Model : BaseModel
    {
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public CustomGetConf GetConf = new CustomGetConf();
        public CustomExpandVHD ExpandVHD = new CustomExpandVHD();
        public CustomExpandCPURAM ExpandCPURAM = new CustomExpandCPURAM();

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

    public class CustomGetConf
    {
        public string Organization { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }

    }

    public class CustomExpandVHD
    {
        public string Name { get; set; }
        public string VHDID { get; set; }
        public string DateTime { get; set; }
        public string GB { get; set; }
        public string Email { get; set; }
    }

    public class CustomExpandCPURAM
    {
        public string Name { get; set; }
        public string DateTime { get; set; }
        public string CPU { get; set; }
        public string RAM { get; set; }
        public string Email { get; set; }
    }


}