using System.Collections.Generic;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;

namespace ColumbusPortal.Models
{
    // model for View display in the user controller
    public class OrganizationModel : BaseModel
    {
        public CustomOrganization Organization = new CustomOrganization();
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public CustomDomain Domain = new CustomDomain();
        public CustomCreateALLAdmins CreateALLAdmins = new CustomCreateALLAdmins();
        public CustomCrayonTenantInfoDetailed CrayonTenantDetailed = new CustomCrayonTenantInfoDetailed();

    }

    // Custom User type containing relevant user information
    public class CustomOrganization
    {
        [Required]
        public string Name { get; set; }
        [Required]
        public string Platform { get; set; }
        [Required]
        public string initials { get; set; }
        [Required]
        public string EmailDomainName { get; set; }

        [RegularExpression(@"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$", ErrorMessage = "Please type correct Subnet mask")]
        public string Subnet { get; set; }

        public string Vlan { get; set; }

        [RegularExpression(@"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", ErrorMessage = "Incorrect IP Address, try again..")]
        public string Gateway { get; set; }

        [RegularExpression(@"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", ErrorMessage = "Incorrect IP Address, try again..")]
        public string IPAddressRangeStart { get; set; }

        [RegularExpression(@"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$", ErrorMessage = "Incorrect IP Address, try again..")]
        public string IPAddressRangeEnd { get; set; }
        public bool CreateVMM { get; set; }
        public bool createcrayon { get; set; }
        public CustomCrayonTenantInfoDetailed CrayonTenantDetailed { get; set; }

    }


    public class CustomDomain
    {
        [Required]
        public string Organization { get; set; }
        [Required]
        public string Domain { get; set; }
        public bool AddasEmail { get; set; }
        public bool RemoveasEmail { get; set; }
    }
    public class CustomCreateALLAdmins
    {
        public string Organization { get; set; }
    }
}