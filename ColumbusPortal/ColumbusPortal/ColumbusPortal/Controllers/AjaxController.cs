using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using System.Web.UI.DataVisualization.Charting;
using ColumbusPortal.Logic;
using XKCDPasswordGen;

namespace ColumbusPortal.Controllers
{
    public class JsonException
    {
        public bool Failure { get; set; }
        public string Message { get; set; }
        public string InnerMessage { get; set; }
        public string Stack { get; set; }

        public JsonException(Exception exc)
        {
            Failure = true;
            Message = exc.Message;
            InnerMessage = exc.InnerException != null ? exc.InnerException.Message : "";
            Stack = exc.StackTrace.Replace("\r", "");
        }

        public override string ToString()
        {
            return new JavaScriptSerializer().Serialize(this);
        }
    }

    
    public class AjaxController : Controller
    {
        class AjaxMailContact
        {
            public string Name { get; set; }
            public string PrimarySmtpAddress { get; set; }
        }
        public string GetMailContacts(string organization)
        {
            try
            {
                List<AjaxMailContact> mailContacts = new List<AjaxMailContact>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetMailContacts(organization);
                    IEnumerable<PSObject> result = ps.Invoke(); 

                    foreach (PSObject contact in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(contact);

                        mailContacts.Add(new AjaxMailContact()
                        {
                            Name = properties["DisplayName"].ToString(),
                            PrimarySmtpAddress = properties["PrimarySmtpAddress"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(mailContacts);
                
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        public string GetXKCDPassword(string type)
        {
            Random r = new Random();
            int rInt = r.Next(0, 9);

            string password = "";
            if (type == "user")
            {
                password = XkcdPasswordGen.Generate(2, "");
            }
            if (type == "svc")
            {
                password = XkcdPasswordGen.Generate(6, "");
            }
            return password.First().ToString().ToUpper() + password.Substring(1) + rInt.ToString();

        }

        public class AjaxDistributionGroup
        {
            public string Name { get; set; }
            public string PrimarySmtpAddress { get; set; }
        }
        public string GetDistributionGroups(string organization)
        {
            try
            {
                List<AjaxDistributionGroup> distributionGroups = new List<AjaxDistributionGroup>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetDistributionGroups(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject group in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(group);
                        distributionGroups.Add(new AjaxDistributionGroup()
                        {
                            Name = properties["DisplayName"].ToString(),
                            PrimarySmtpAddress = properties["PrimarySmtpAddress"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(distributionGroups);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }


        public class AjaxMailboxFolderPermission
        {
            public string User { get; set; }
            public string AccessRights { get; set; }
        }
        public string GetCalendarPermissions(string organization, string userprincipalname)
        {
            try
            {

                List<AjaxMailboxFolderPermission> folderPermissions = new List<AjaxMailboxFolderPermission>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetCalendarPermissions(organization, userprincipalname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject folderPermission in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(folderPermission);
                        folderPermissions.Add(new AjaxMailboxFolderPermission()
                        {
                            User = properties["User"].ToString(),
                            AccessRights = properties["AccessRights"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(folderPermissions);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string RemoveCalendarPermissions(string organization, string userprincipalname, string user)
        {
            try
            {
                string[] users = new JavaScriptSerializer().Deserialize<string[]>(user);

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveCalendarPermissions(organization, userprincipalname, users).Invoke();
                }

                return "[]";
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }


            //return "Org: " + organization + ", Id: " + identity + ", User: " + string.Join(" & ", new JavaScriptSerializer().Deserialize<string[]>(user));
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxMailbox
        {
            public string Name { get; set; }
            public string UserPrincipalName { get; set; }
            public string RecipientTypeDetails { get; set; }
            public string[] EmailAddresses { get; set; }
        }
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetMailbox(string organization, string name)
        {
            try
            {
                List<AjaxMailbox> mailboxes = new List<AjaxMailbox>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetMailbox(organization, name);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject mailbox in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(mailbox);
                        mailboxes.Add(new AjaxMailbox()
                        {
                            Name = properties["Name"].ToString(),
                            UserPrincipalName = properties["UserPrincipalName"].ToString(),
                            RecipientTypeDetails = properties["RecipientTypeDetails"].ToString(),
                            EmailAddresses = properties["EmailAddresses"].ToString().Split(' ')
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(mailboxes);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetCALMailbox(string organization, string name)
        {
            try
            {
                List<AjaxMailbox> calmailboxes = new List<AjaxMailbox>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetMailbox(organization, name); 
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject mailbox in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(mailbox);
                        calmailboxes.Add(new AjaxMailbox()
                        {
                            Name = properties["Name"].ToString(),
                            UserPrincipalName = properties["UserPrincipalName"].ToString(),
                            RecipientTypeDetails = properties["RecipientTypeDetails"].ToString(),
                            EmailAddresses = properties["EmailAddresses"].ToString().Split(' ')
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(calmailboxes);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxMailForward
        {
            public string Organization { get; set; }
            public string UserPrincipalName { get; set; }
            public string Name { get; set; }
            public string ForwardingAddress { get; set; }
            public bool DeliverToMailboxAndForward { get; set; }
        }

        // Ajax function - returns the current mailforward set on a mailbox
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetMailforward(string organization, string userprincipalname)
        {
            try
            {
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetMailforward(organization, userprincipalname);
                    PSObject result = ps.Invoke().Single();

                    return new JavaScriptSerializer().Serialize(new AjaxMailForward()
                    {
                        Organization = result.Members["Organization"].Value.ToString(),
                        UserPrincipalName = result.Members["UserPrincipalName"].Value.ToString(),
                        Name = result.Members["Name"].Value.ToString(),
                        ForwardingAddress = result.Members["ForwardingAddress"].Value.ToString(),
                        DeliverToMailboxAndForward = bool.Parse(result.Members["DeliverToMailboxAndForward"].Value.ToString())
                    });
                }

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        class ResourceMeteringEntry
        {
            //[Description], [Timestamp], [AvgCPU], [MaxRAM], [AggregatedAverageNormalizedIOPS]
            public string Description { get; set; }
            //public DateTime Timestamp { get; set; }
            public string Timestamp { get; set; }
            public int AvgCPU { get; set; }
            public int MaxRAM { get; set; }
            public int IOPS { get; set; }
            public int TotalRAM { get; set; }
        }
        public class AjaxResourceMetering
        {
            public string ServerName { get; set; }
            public string CPUGraph { get; set; }
            public string RAMGraph { get; set; }
            public string IOPSGraph { get; set; }
            public string Description { get; set; }
        }
        public string GetResourceMetering(string servername)
        {
            List<ResourceMeteringEntry> meteringEntries = new List<ResourceMeteringEntry>();
            AjaxResourceMetering returnObject = new AjaxResourceMetering();

            try
            {
                // scoop data from db, yessiree
                using (SqlConnection connection = new SqlConnection("Data Source=DMZ027C1B\\SQLEXPRESS;Initial Catalog=Serverdata;Trusted_Connection=True"))
                {
                    connection.Open();

                    SqlCommand command = connection.CreateCommand();

                    command.CommandText = "SELECT TOP(32) [Description], [Timestamp], [AvgCPU], [MaxRAM], [AggregatedAverageNormalizedIOPS], [TotalRAM] FROM [VMResourceMetering] WHERE [VMName] = @VMName ORDER BY [Timestamp] DESC";

                    SqlParameter vmName = new SqlParameter("@VMName", SqlDbType.VarChar, 250);

                    vmName.Value = servername;

                    command.Parameters.Add(vmName);

                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        meteringEntries.Add(new ResourceMeteringEntry()
                        {
                            AvgCPU = int.Parse(reader["AvgCPU"].ToString()),
                            Description = reader["Description"].ToString(),
                            IOPS = int.Parse(reader["AggregatedAverageNormalizedIOPS"].ToString()),
                            MaxRAM = int.Parse(reader["MaxRAM"].ToString()),
                            //Timestamp = DateTime.Parse(reader["Timestamp"].ToString())
                            Timestamp = reader["Timestamp"].ToString(),
                            TotalRAM = int.Parse(reader["TotalRAM"].ToString())
                        });

                        returnObject.Description = reader["Description"].ToString();
                    }
                }

                meteringEntries.Reverse();

                var chartCpu = new Chart();
                var chartCpuArea = new ChartArea();
                chartCpu.Width = 1000;
                chartCpu.Height = 200;
                chartCpu.ChartAreas.Add(chartCpuArea);
                chartCpu.Series.Add("CPU");
                chartCpu.Series["CPU"].ChartType = SeriesChartType.Line;


                var chartRam = new Chart();
                var chartRamArea = new ChartArea();
                chartRam.Width = 1000;
                chartRam.Height = 200;
                chartRam.ChartAreas.Add(chartRamArea);
                chartRam.Series.Add("MaxRAM");
                chartRam.Series["MaxRAM"].ChartType = SeriesChartType.Line;
                chartRam.Series.Add("TotalRAM");
                chartRam.Series["TotalRAM"].ChartType = SeriesChartType.Line;
                chartRam.Series["TotalRAM"].Color = System.Drawing.Color.Red;

                var chartIops = new Chart();
                var chartIopsArea = new ChartArea();
                chartIops.Width = 1000;
                chartIops.Height = 200;
                chartIops.ChartAreas.Add(chartIopsArea);
                chartIops.Series.Add("IOPS");
                chartIops.Series["IOPS"].ChartType = SeriesChartType.Line;


                foreach (var entry in meteringEntries)
                {
                    chartCpu.Series["CPU"].Points.AddXY(entry.Timestamp, entry.AvgCPU);
                    chartRam.Series["MaxRAM"].Points.AddXY(entry.Timestamp, entry.MaxRAM);
                    chartRam.Series["TotalRAM"].Points.AddXY(entry.Timestamp, entry.TotalRAM);
                    chartIops.Series["IOPS"].Points.AddXY(entry.Timestamp, entry.IOPS);
                }

                using (MemoryStream stream = new MemoryStream())
                {
                    chartCpu.SaveImage(stream, ChartImageFormat.Png);
                    returnObject.CPUGraph = Convert.ToBase64String(stream.ToArray());
                }
                using (MemoryStream stream = new MemoryStream())
                {
                    chartRam.SaveImage(stream, ChartImageFormat.Png);
                    returnObject.RAMGraph = Convert.ToBase64String(stream.ToArray());
                }
                using (MemoryStream stream = new MemoryStream())
                {
                    chartIops.SaveImage(stream, ChartImageFormat.Png);
                    returnObject.IOPSGraph = Convert.ToBase64String(stream.ToArray());
                }

                return new JavaScriptSerializer().Serialize(returnObject);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        // Function for getting domain as select list..
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxDomain
        {
            public string DomainName { get; set; }
            public string Status { get; set; }
            public string IsDefault { get; set; }
        }
        public string GetDomain(string organization)
        {
            try
            {
                List<AjaxDomain> domains = new List<AjaxDomain>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetDomain(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject domain in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(domain);
                        domains.Add(new AjaxDomain()
                        {
                            DomainName = properties["DomainName"].ToString(),
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(domains);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetO365Domain(string organization)
        {
            try
            {
                string initials = organization.Split(' ')[0];

                List<AjaxDomain> domains = new List<AjaxDomain>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetO365Domain(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject domain in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(domain);
                        domains.Add(new AjaxDomain()
                        {
                            DomainName = properties["DomainName"].ToString(),
                            Status = properties["Status"].ToString(),
                            IsDefault = properties["IsDefault"].ToString(),
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(domains);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxSendAsGroups
        {
            public string Name { get; set; }

            public string DistinguishedName { get; set; }

            public string Description { get; set; }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetSendAsGroups(string organization)
        {
            try
            {
                List<AjaxSendAsGroups> groups = new List<AjaxSendAsGroups>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetSendAsGroups(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject Group in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(Group);
                        groups.Add(new AjaxSendAsGroups()
                        {
                            Name = properties["Name"].ToString(),
                            DistinguishedName = properties["DistinguishedName"].ToString(),
                            Description = properties["Description"].ToString(),
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(groups);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }


        // Function for getting AD users as select list..
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxADUser
        {
            public string Name { get; set; }
            public string DistinguishedName { get; set; }
            public string UserPrincipalName { get; set; }
            public string[] proxyAddresses { get; set; }
            public string Enabled { get; set; }
        }
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetADUsersList(string organization, string userprincipalname)
        {
            try
            {
                List<AjaxADUser> users = new List<AjaxADUser>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetADUsers(organization, userprincipalname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject User in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(User);
                        users.Add(new AjaxADUser()
                        {
                            Name = properties["Name"].ToString(),
                            DistinguishedName = properties["DistinguishedName"].ToString(),
                            UserPrincipalName = properties["UserPrincipalName"].ToString(),
                            //proxyAddresses = properties["proxyAddresses"].ToString().Split(','),
                            Enabled = properties["Enabled"].ToString(),
                        });
                    }

                }

                return new JavaScriptSerializer().Serialize(users);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        // Function for getting AD users as select list..
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxADUserProxy
        {
            public string[] proxyAddresses { get; set; }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetADUsersProxy(string organization, string userprincipalname)
        {
            try
            {
                List<AjaxADUser> users = new List<AjaxADUser>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetADUsers(organization, userprincipalname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject User in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(User);
                        users.Add(new AjaxADUser()
                        {
                            proxyAddresses = properties["proxyAddresses"].ToString().Split(','),
                        });
                    }

                }

                return new JavaScriptSerializer().Serialize(users);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxVMVHDs
        {
            public string Name { get; set; }
            public string VHDID { get; set; }
            public string Size { get; set; }

        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetVMVHDs(string vmid)
        {
            try
            {
                List<AjaxVMVHDs> vhds = new List<AjaxVMVHDs>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetVMVHDs(vmid);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject VHD in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(VHD);
                        vhds.Add(new AjaxVMVHDs()
                        {
                            Name = properties["Name"].ToString(),
                            VHDID = properties["VHDID"].ToString(),
                            Size = properties["Size"].ToString(),
                        });
                    }

                }


                return new JavaScriptSerializer().Serialize(vhds);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxVMSQL
        {
            public string Name { get; set; }
            public string id { get; set; }

        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetVMSQL(string level)
        {
            try
            {
                List<AjaxVMSQL> vms = new List<AjaxVMSQL>();

                string conString = "Server=sht004;Integrated Security=true;Database=VirtualManagerDB";
                SqlConnection con = new SqlConnection(conString);

                var selectSql = "";

                if (level == "lvl25")
                {
                    selectSql = "select * from[dbo].[tbl_WLC_VObject] " +
                    "where (CloudId not like '4aa7203c-a223-40f8-9ca8-657332ea4fc6' " +
                    "and CloudId not like '80981c48-fad9-4103-8a4d-efc40da5c908' " +
                    "and CloudId not like '5cc40dfe-67c0-40c9-b921-8925eb7c28b4' " +
                    "and CloudId not like '50e3a28c-adc7-4737-b8d7-e5fd2e7a066c' " +
                    "and CloudId not like 'd0900697-d818-43a4-9854-71ac049be9ac')" +
                    " and " +
                    "(ObjectType = '1') order by Name; ";

                }
                else
                {
                    selectSql = "select * from[dbo].[tbl_WLC_VObject] WHERE ObjectType = '1' order by Name";
                }
                //string selectSql = "select * from [dbo].[tbl_WLC_VObject] where CloudId = '8f687697-4317-4435-9db1-cc5f03a8066b'";
                SqlCommand cmd = new SqlCommand(selectSql, con);

                try
                {
                    con.Open();

                    using (SqlDataReader read = cmd.ExecuteReader())
                    {
                        while (read.Read())
                        {
                            vms.Add(new AjaxVMSQL()
                            {
                                Name = (read["Name"].ToString()),
                                id = (read["ObjectId"].ToString()),
                            });
                        }
                    }
                }
                finally
                {
                    con.Close();
                }


                return new JavaScriptSerializer().Serialize(vms);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }
      
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxLog
        {
            public string entry { get; set; }

        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string Log(string entry)
        {
            CommonCAS.Log(string.Format("{0}", entry));

            return entry;
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public class AjaxGetCurrentOOF
        {
            public string Organization { get; set; }
            public string UserPrincipalName { get; set; }
            public string StartTime { get; set; }
            public string EndTime { get; set; }
            public string AutoReplyState { get; set; }
            public string InternalMessage { get; set; }
            public string ExternalMessage { get; set; }
            public string ExternalAudience { get; set; }
        }

        // Ajax function - returns the current mailforward set on a mailbox
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string GetCurrentOOF(string organization, string userprincipalname)
        {
            try
            {
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetOOFMessage(organization, userprincipalname);
                    PSObject result = ps.Invoke().Single();

                    return new JavaScriptSerializer().Serialize(new AjaxGetCurrentOOF()
                    {
                        StartTime = result.Members["StartTime"].Value.ToString(),
                        EndTime = result.Members["EndTime"].Value.ToString(),
                        AutoReplyState = result.Members["AutoReplyState"].Value.ToString(),
                        InternalMessage = result.Members["InternalMessage"].Value.ToString(),
                        ExternalMessage = result.Members["ExternalMessage"].Value.ToString(),
                        ExternalAudience = result.Members["ExternalAudience"].Value.ToString()
                    });
                }

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string RemoveScheduledJobs(string id)
        {
            try
            {
                string[] jobs = new JavaScriptSerializer().Deserialize<string[]>(id);

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveScheduledJobs(jobs).Invoke();
                }

                return "[]";
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }
    }
}
