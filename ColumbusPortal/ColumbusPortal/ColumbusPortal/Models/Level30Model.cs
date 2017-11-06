using System.Collections.Generic;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;

namespace ColumbusPortal.Models
{
    // model for View display in the level30 controller
    public class Level30Model : BaseModel
    {
        public CustomUpdateConf UpdateConf = new CustomUpdateConf();
        public List<CustomGetConfLIST> GetConfList = new List<CustomGetConfLIST>();
        public CustomExpandVHD ExpandVHD = new CustomExpandVHD();
        public CustomExpandCPURAM ExpandCPURAM = new CustomExpandCPURAM();
        public CustomScheduleReboot ScheduleReboot = new CustomScheduleReboot();
        public CustomServerInfo ServerInfo = new CustomServerInfo();
        public List<CustomUser> UserList = new List<CustomUser>();
        public CustomNAVCustomer UpdateNAVCustomer = new CustomNAVCustomer();
        public CustomEXTAdminUser EXTAdminUser = new CustomEXTAdminUser();
        public CustomCASAdminUser CASAdminUser = new CustomCASAdminUser();
        public List<CustomEXTAdminUserLIST> EXTAdminUserLIST = new List<CustomEXTAdminUserLIST>();
        public List<CustomCASAdminUserLIST> CASAdminUserLIST = new List<CustomCASAdminUserLIST>();

    }

    public class CustomUpdateConf
    {
        public string Organization { get; set; }
        public string Platform { get; set; }
        public string Name { get; set; }
        public string UserContainer { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }
        public string NETBIOS { get; set; }
        public string CustomerOUDN { get; set; }
        public string AdminUserOUDN { get; set; }
        public string ExternalUserOUDN { get; set; }
        public List<string> EmailDomains;
        public string TenantID { get; set; }
        public string AdminUser { get; set; }
        public string AdminPass { get; set; }
        public string AADsynced { get; set; }
        public string ADConnectServer { get; set; }
        public string DomainDC { get; set; }
        public string NavMiddleTier { get; set; }
        public string SQLServer { get; set; }
        public string AdminRDS { get; set; }
        public string AdminRDSPort { get; set; }
        public string AppID { get; set; }
        public string AppSecret { get; set; }

        /// <summary>
        /// Test on enable services..
        /// </summary>
        public bool ServiceSQL { get; set; }
        public bool ServiceAzureAD { get; set; }
        public bool ServiceCompute { get; set; }
        public bool Service365 { get; set; }
        public bool ServiceIntune { get; set; }

    }

    public class CustomGetConfLIST
    {
        public string Organization { get; set; }
        public string Name { get; set; }
        public string Platform { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }
        public string NETBIOS { get; set; }
        public string CustomerOUDN { get; set; }
        public string EmailDomains { get; set; }
        public string TenantID { get; set; }
        public string AdminUser { get; set; }
        public string AdminPass { get; set; }
        public string AADsynced { get; set; }
        public string ADConnectServer { get; set; }
        public string DomainDC { get; set; }
        public string UserContainer { get; set; }
        public string AdminUserOUDN { get; set; }
        public string ExternalUserOUDN { get; set; }
        public string NavMiddleTier { get; set; }
        public string SQLServer { get; set; }
        public string AdminRDS { get; set; }
        public string AdminRDSPort { get; set; }
        public string ServiceSQL { get; set; }
        public string ServiceAzureAD { get; set; }
        public string ServiceCompute { get; set; }
        public string Service365 { get; set; }
        public string AppID { get; set; }
        public string AppSecret { get; set; }
        public string ServiceIntune { get; set; }

    }

    public class CustomExpandVHD
    {
        [Required]
        public string VMID { get; set; }

        [Required]
        public string VHDID { get; set; }

        [Required]
        public string DateTime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "GB is required..")]
        public string GB { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Required...")]
        [MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        [MaxLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        public string TaskID { get; set; }
    }

    public class CustomExpandCPURAM
    {
        [Required]
        public string VMID { get; set; }

        [Required]
        public string DateTime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "CPU is required..")]
        public string CPU { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "RAM cannot be null.. If not changing it, put in the current RAM of the VM..")]
        public string RAM { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        //[EmailAddress(ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Required...")]
        [MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        [MaxLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        public string TaskID { get; set; }

        public string DynamicMemoryEnabled { get; set; }
    }

    public class CustomScheduleReboot
    {
        [Required]
        public string VMID { get; set; }
        [Required]
        public string DateTime { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Required...")]
        [MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        [MaxLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        public string TaskID { get; set; }
    }

    public class CustomServerInfo
    {
        public string VMID { get; set; }
        public string CPU { get; set; }
        public string RAM { get; set; }
        public string DynamicMemoryEnabled { get; set; }
    }

    public class CustomEXTAdminUser
    {
        public string Organization { get; set; }
        public string Customer { get; set; }
        public string ID { get; set; }
        public string Status { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string DisplayName { get; set; }
        public string SamAccountName { get; set; }

        [EmailAddress]
        public string Email { get; set; }

        [DataType(DataType.Password)]
        public string Password { get; set; }
        public string Description { get; set; }
        public string Company { get; set; }
        public string DateTime { get; set; }
        public string ExpireDate { get; set; }
    }

    public class CustomEXTAdminUserLIST
    {
        public string Organization { get; set; }
        public string Customer { get; set; }
        public string ID { get; set; }
        public string Status { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string DisplayName { get; set; }
        public string SamAccountName { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }
        public string Description { get; set; }
        public string Company { get; set; }
        public string DateTime { get; set; }
        public string ExpireDate { get; set; }
    }

    public class CustomCASAdminUser
    {
        public string Organization { get; set; }
        public string Customer { get; set; }
        public string ID { get; set; }
        public string Status { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string DisplayName { get; set; }
        public string SamAccountName { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }

        [DataType(DataType.Password)]
        public string Password { get; set; }
        public string Description { get; set; }
        public string Company { get; set; }
        public string DateTime { get; set; }
        public string ExpireDate { get; set; }
    }

    public class CustomCASAdminUserLIST
    {
        public string Organization { get; set; }
        public string Customer { get; set; }
        public string ID { get; set; }
        public string Status { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string DisplayName { get; set; }
        public string SamAccountName { get; set; }

        [Required(ErrorMessage = "Email is mandatory!")]
        [RegularExpression(@"^(([-\w\d]+)(\.[-\w\d]+)*@([-\w\d]+)(\.[-\w\d]+)*(\.([a-zA-Z]{2,5}|[\d]{1,3})){1,2})$", ErrorMessage = "Please enter correctly formated email.")]
        public string Email { get; set; }
        public string Description { get; set; }
        public string Company { get; set; }
        public string Department { get; set; }
        public string UserName { get; set; }
        public string DateTime { get; set; }
        public string ExpireDate { get; set; }
    }

    public class CustomNAVCustomer
    {
        public string Organization { get; set; }
        public string Platform { get; set; }
        public string Name { get; set; }
        public string NavMiddleTier { get; set; }
        public string SQLServer { get; set; }

        [AllowHtml]
        [UIHint("tinymce_full_compressed")]
        public string LoginInfo { get; set; }
        public string RDSServer { get; set; }
    }

}