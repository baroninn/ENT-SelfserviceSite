using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Models
{
    // model for View display in the 365 controller
    public class Office365Model : BaseModel
    {
        public CustomAddDomain AddDomain = new CustomAddDomain();
        public CustomEnable365Customer Enable365Customer = new CustomEnable365Customer();
        public CustomGetTenantInfo GetTenantInfo = new CustomGetTenantInfo();
    }


    public class CustomAddDomain
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
    }
    public class CustomEnable365Customer
    {
        public string Organization { get; set; }
        public string TenantID { get; set; }
        public string TenantAdmin { get; set; }
        public string TenantPass { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }

    }

    public class CustomGetTenantInfo
    {
        public string Organization { get; set; }
        public string TenantID { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }

    }
}