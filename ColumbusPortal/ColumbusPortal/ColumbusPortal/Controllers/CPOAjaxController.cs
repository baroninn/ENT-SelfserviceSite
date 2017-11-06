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

namespace ColumbusPortal.Controllers
{

    [Authorize(Roles = "Access_SelfService_FullAccess")]
    public class CPOAjaxController : Controller
    {
        class AjaxCPOMailContact
        {
            public string Name { get; set; }
            public string PrimarySmtpAddress { get; set; }
        }
        public string CPOGetMailContacts(string organization)
        {
            try
            {
                List<AjaxCPOMailContact> mailContacts = new List<AjaxCPOMailContact>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetMailContacts(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject contact in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(contact);

                        mailContacts.Add(new AjaxCPOMailContact()
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


        public class AjaxDistributionGroup
        {
            public string Name { get; set; }
            public string PrimarySmtpAddress { get; set; }
        }
        public string CPOGetDistributionGroups(string organization)
        {
            try
            {
                List<AjaxDistributionGroup> distributionGroups = new List<AjaxDistributionGroup>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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


        public class CPOAjaxMailboxFolderPermission
        {
            public string User { get; set; }
            public string AccessRights { get; set; }
        }
        public string CPOGetCalendarPermissions(string organization, string userprincipalname)
        {
            try
            {

                List<CPOAjaxMailboxFolderPermission> folderPermissions = new List<CPOAjaxMailboxFolderPermission>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetCalendarPermissions(organization, userprincipalname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject folderPermission in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(folderPermission);
                        folderPermissions.Add(new CPOAjaxMailboxFolderPermission()
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
        public string CPORemoveCalendarPermissions(string organization, string userprincipalname, string user)
        {
            try
            {
                string[] users = new JavaScriptSerializer().Deserialize<string[]>(user);

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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

        public class AjaxMailbox
        {
            public string Name { get; set; }
            public string UserPrincipalName { get; set; }
            public string RecipientTypeDetails { get; set; }
            public string[] EmailAddresses { get; set; }
        }
        public string CPOGetMailbox(string organization, string name)
        {
            try
            {
                List<AjaxMailbox> mailboxes = new List<AjaxMailbox>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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

        public class AjaxMailForward
        {
            public string Organization { get; set; }
            public string UserPrincipalName { get; set; }
            public string Name { get; set; }
            public string ForwardingAddress { get; set; }
            public bool DeliverToMailboxAndForward { get; set; }
        }

        // Ajax function - returns the current mailforward set on a mailbox
        public string CPOGetMailforward(string organization, string userprincipalname)
        {
            try
            {
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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
        public string CPOGetResourceMetering(string servername)
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

        public class CPOAjaxAcceptedDomain
        {
            public string Name { get; set; }
            public string DomainName { get; set; }
        }
        public string CPOGetAcceptedDomain(string organization)
        {
            try
            {
                List<CPOAjaxAcceptedDomain> domains = new List<CPOAjaxAcceptedDomain>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetAcceptedDomain(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject domain in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(domain);
                        domains.Add(new CPOAjaxAcceptedDomain()
                        {
                            Name = properties["Name"].ToString(),
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

        public class AjaxSendAsGroups
        {
            public string Name { get; set; }

            public string DistinguishedName { get; set; }

            public string Description { get; set; }
        }
        public string CPOGetSendAsGroups(string organization)
        {
            try
            {
                List<AjaxSendAsGroups> groups = new List<AjaxSendAsGroups>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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

        public class AjaxCTXGoldenServers
        {
            public string Name { get; set; }


        }
        public string CPOGetCTXGoldenServers(string solution, bool mcsenabled)
        {
            try
            {
                List<AjaxCTXGoldenServers> servers = new List<AjaxCTXGoldenServers>();

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetCTXGoldenServers(solution, mcsenabled);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject Server in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(Server);
                        servers.Add(new AjaxCTXGoldenServers()
                        {
                            Name = properties["Name"].ToString(),
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(servers);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
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
        public string CPOGetCurrentOOF(string organization, string userprincipalname)
        {
            try
            {
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
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

    }
}
