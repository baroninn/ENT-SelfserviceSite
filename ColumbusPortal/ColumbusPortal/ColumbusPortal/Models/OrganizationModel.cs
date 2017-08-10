

namespace ColumbusPortal.Models
{
    // model for View display in the user controller
    public class OrganizationModel : BaseModel
    {
        public CustomOrganization Organization = new CustomOrganization();
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public CustomRemoveCustomer RemoveCustomer = new CustomRemoveCustomer();
        public CustomDisableCustomer DisableCustomer = new CustomDisableCustomer();
        public CustomEnableCustomer EnableCustomer = new CustomEnableCustomer();
        public CustomDomain Domain = new CustomDomain();
        public CustomCreateALLAdmins CreateALLAdmins = new CustomCreateALLAdmins();
    }

    // Custom User type containing relevant user information
    public class CustomOrganization
    {
        public string Name { get; set; }
        public string initials { get; set; }
        public string EmailDomainName { get; set; }
        public string Subnet { get; set; }
        public string Vlan { get; set; }
        public string Gateway { get; set; }
        public string IPAddressRangeStart { get; set; }
        public string IPAddressRangeEnd { get; set; }
        public bool CreateVMM { get; set; }

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

    public class CustomDomain
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
        public bool AddasEmail { get; set; }
        public bool RemoveasEmail { get; set; }
    }
    public class CustomCreateALLAdmins
    {
        public string Organization { get; set; }
    }
}