using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Models
{
    // model for View display in the user controller
    public class OrganizationModel : BaseModel
    {
        public CustomOrganization Organization = new CustomOrganization();
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public CustomRemoveCustomer RemoveCustomer = new CustomRemoveCustomer();
        public CustomDisableCustomer DisableCustomer = new CustomDisableCustomer();
        public CustomEnableCustomer EnableCustomer = new CustomEnableCustomer();
    }

    // Custom User type containing relevant user information
    public class CustomOrganization
    {
        public string Name { get; set; }
        public string EmailDomainName { get; set; }
        public string Subnet { get; set; }
        public string Vlan { get; set; }
        public string IPAddressRangeStart { get; set; }
        public string IPAddressRangeEnd { get; set; }

    }

    public class CustomRemoveCustomer
    {
        public string Organization { get; set; }

        public bool RemoveData { get; set; }

        public bool Confirm { get; set; }
    }

    public class CustomDisableCustomer
    {
        public string Organization { get; set; }

        public bool Confirm { get; set; }
    }

    public class CustomEnableCustomer
    {
        public string Organization { get; set; }
    }
    public class CustomConvertCustomer
    {
        public string Organization { get; set; }

        public bool Confirm { get; set; }
    }
}