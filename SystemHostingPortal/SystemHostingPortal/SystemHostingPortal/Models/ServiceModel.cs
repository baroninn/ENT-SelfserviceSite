using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SystemHostingPortal.Models
{
    public class ServiceModel : BaseModel
    {
        public CustomCustomerReport CustomerReport;
    }

    public class CustomCustomerReport
    {
        public string Organization { get; set; }
        public SPLA Licenses;
        public string ExchangeQuota { get; set; }
        public double ExchangefQuota { get; set; }
        public string ExchangeUsage { get; set; }
        public double ExchangefUsage { get; set; }
        public List<ADUser> ADUsers;
        public List<ENTServer> ENTServers;
        public List<Info365> Info365s;
        public int ADUsersCount { get; set; }
        public int ADLightUsersCount { get; set; }
        public int ADFullUsersCount { get; set; }
        public int ENTServersCount { get; set; }
        public string TotalUsage { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }
        public string TenantID { get; set; }
        public string DatabaseUsage { get; set; }
        public double TotalfUsage { get; set; }
        public string FileServerFree { get; set; }
        public double FileServerfFree { get; set; }
        public string FileServerTotal { get; set; }
        public double FileServerfTotal { get; set; }
        public string FileServerUsed { get; set; }
        public double FileServerfUsed { get; set; }
        public double DatabasefUsage { get; set;}

        public int DiskTotal
        {
            get
            {
                return (int)TotalfUsage;
            }
        }

        //public List<Server> Servers;

        public CustomCustomerReport()
        {
            Licenses = new SPLA();
            ADUsers = new List<ADUser>();
            ENTServers = new List<ENTServer>();
            Info365s = new List<Info365>();
        }
    }

    public class SPLA 
    {
        public List<string> FullUser = new List<string>();
        public List<string> LightUser = new List<string>();
    }


    public class ADUser
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public string LightUser { get; set; }
    }

    public class ENTServer
    {
        public string Name { get; set; }
        public string CPU { get; set; }
        public string RAM { get; set; }
        public string OS { get; set; }
    }

    public class Info365
    {
        public string PartnerName { get; set; }
        public string License { get; set; }
        public string ActiveUnits { get; set; }
        public string ConsumedUnits { get; set; }
        public string FreeUnits { get; set; }
    }
}