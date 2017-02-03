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
        public List<ExchangeUser> ExchangeUsers;
        public int ExchangeUsersCount { get; set; }
        public string DiskQuota { get; set; }
        public string DiskUsage { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }
        public string TenantID { get; set; }
        public string DatabaseUsage { get; set; }
        public double DiskfUsage { get; set; }
        public double DiskfQuota { get; set; }
        public double DatabasefUsage { get; set;}
        public int DiskServers
        {
            get
            {
                int total = 0;
                foreach (Server s in Servers)
                {
                    foreach (ServerDisk d in s.Disks)
                    {
                        try
                        {
                            total += int.Parse(d.Size.Split(' ')[0]);
                        }
                        catch { }
                    }
                }

                return total;
            }
        }

        public int DiskTotal
        {
            get
            {
                return (int)ExchangefQuota + (int)DiskfQuota + DiskServers;
            }
        }

        public List<Server> Servers;

        public CustomCustomerReport()
        {
            Licenses = new SPLA();
            ExchangeUsers = new List<ExchangeUser>();
            Servers = new List<Server>();
        }
    }

    public class SPLA 
    {
        public List<string> Windows = new List<string>();
        public List<string> OfficeStandard = new List<string>();
        public List<string> OfficeProfessional = new List<string>();
        public List<string> Outlook = new List<string>();
        public List<string> Unknown = new List<string>();
        public List<string> StudJur = new List<string>();
        public List<string> MailOnly = new List<string>();
    }

/*    public class Office365info
    {
        public string Enabled { get; set; }
        public string Admin { get; set; }
        public string License { get; set; }
        public string TenantID { get; set; }
    } */

    public class ExchangeUser
    {
        public string Name { get; set; }
        public string Usage { get; set; }
        public string Quota { get; set; }
        public string Email { get; set; }
    }

    public class Server
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public List<ServerDisk> Disks = new List<ServerDisk>();
    }

    public class ServerDisk
    {
        public string DeviceID { get; set; }
        public string Size { get; set; }
    }
}