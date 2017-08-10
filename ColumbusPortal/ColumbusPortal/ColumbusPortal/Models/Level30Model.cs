using System.Collections.Generic;
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
        public CustomSharedCustomer UpdateSharedCustomer = new CustomSharedCustomer();
        public CustomEXTAdminUser EXTAdminUser = new CustomEXTAdminUser();
        public CustomCASAdminUser CASAdminUser = new CustomCASAdminUser();
        public List<CustomEXTAdminUserLIST> EXTAdminUserLIST = new List<CustomEXTAdminUserLIST>();
        public List<CustomCASAdminUserLIST> CASAdminUserLIST = new List<CustomCASAdminUserLIST>();

    }

    public class CustomUpdateConf
    {
        public string Organization { get; set; }
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

    }

    public class CustomGetConfLIST
    {
        public string Organization { get; set; }
        public string Name { get; set; }
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

    }

    public class CustomExpandVHD
    {
        [Required]
        public string VMID { get; set; }
        [Required]
        public string VHDID { get; set; }
        [Required]
        public string DateTime { get; set; }
        [Required]
        public string GB { get; set; }
        [Required]
        public string Email { get; set; }
        [Required, MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        public string TaskID { get; set; }
    }

    public class CustomExpandCPURAM
    {
        [Required]
        public string VMID { get; set; }

        [Required]
        public string DateTime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "CPU is required, and can be a max of 16 cores..")]
        [RegularExpression(@"\d{1,16}", ErrorMessage = "Please enter a valid number (1-16).")]
        public string CPU { get; set; }

        [Required]
        public string RAM { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required(ErrorMessage = "Required...")]
        [MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        [StringLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
        public string TaskID { get; set; }

        public string DynamicMemoryEnabled { get; set; }
    }

    public class CustomScheduleReboot
    {
        [Required]
        public string VMID { get; set; }
        [Required]
        public string DateTime { get; set; }
        [Required]
        public string Email { get; set; }
        [Required, MinLength(6, ErrorMessage = "Please enter a correct taskid from Navision")]
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
        [EmailAddressAttribute]
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
        [EmailAddressAttribute]
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
        [EmailAddressAttribute]
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
        [EmailAddressAttribute]
        public string Email { get; set; }
        public string Description { get; set; }
        public string Company { get; set; }
        public string Department { get; set; }
        public string UserName { get; set; }
        public string DateTime { get; set; }
        public string ExpireDate { get; set; }
    }

    public class CustomSharedCustomer
    {
        public string Organization { get; set; }
        public string Name { get; set; }
        public string NavMiddleTier { get; set; }
        public string SQLServer { get; set; }
    }

}