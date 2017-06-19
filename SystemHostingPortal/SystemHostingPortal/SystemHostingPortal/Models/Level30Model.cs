using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Dynamic;
using System.ComponentModel.DataAnnotations;
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
        public string NETBIOS { get; set; }
        public string CustomerOUDN { get; set; }
        public List<string> Domains;
        public string TenantID365 { get; set; }
        public string AdminUser365 { get; set; }
        public string AdminPass365 { get; set; }
        public string AADsynced { get; set; }
        public string ADConnectServer { get; set; }
        public string DomainDC { get; set; }

    }

    public class CustomGetConf
    {
        public string Organization { get; set; }
        public string ExchangeServer { get; set; }
        public string DomainFQDN { get; set; }

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
    }


}