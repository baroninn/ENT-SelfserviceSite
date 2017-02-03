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
        public CustomNavCompanyName NavCompanyName = new CustomNavCompanyName();
        public CustomRemoveDummyDomain RemoveDummyDomain = new CustomRemoveDummyDomain();
        public CustomRemoveCustomer RemoveCustomer = new CustomRemoveCustomer();
        public CustomDisableCustomer DisableCustomer = new CustomDisableCustomer();
        public CustomEnableCustomer EnableCustomer = new CustomEnableCustomer();
        public CustomConvertCustomer ConvertCustomer = new CustomConvertCustomer();
        public List<string> FileServers = Directory.GetFileServers();
    }

    // Custom User type containing relevant user information
    public class CustomOrganization
    {
        public string Name { get; set; }
        public string EmailDomainName { get; set; }
        public string FileServer { get; set; }
        public string FileServerDriveLetter { get; set; }
        public string Solution { get; set; }
    }

    public class CustomNavCompanyName
    {
        public string Organization { get; set; }
        public string CompanyName { get; set; }
        public string Solution { get; set; }
        public bool NativeDatabase { get; set; }
        public bool Force { get; set; }
    }

    public class CustomRemoveDummyDomain
    {
        public string Organization { get; set; }
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