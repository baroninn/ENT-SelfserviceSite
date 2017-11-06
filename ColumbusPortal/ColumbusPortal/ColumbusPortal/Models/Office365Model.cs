
namespace ColumbusPortal.Models
{
    // model for View display in the 365 controller
    public class Office365Model : BaseModel
    {
        public CustomVerifyDomain VerifyDomain = new CustomVerifyDomain();
        public CustomGetTenantInfo GetTenantInfo = new CustomGetTenantInfo();
        public CustomStartDirSync StartDirSync = new CustomStartDirSync();
    }


    public class CustomVerifyDomain
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
    }

    public class CustomGetTenantInfo
    {
        public string Organization { get; set; }
        public string TenantID { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }

    }

    public class CustomStartDirSync
    {
        public string Organization { get; set; }
        public string Policy { get; set; }
        public bool Force { get; set; }
    }


}