using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;

namespace SystemHostingPortal.Controllers
{
    public class ServiceController : Controller
    {
        ServiceModel model = new ServiceModel();

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CustomerReport() 
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CustomerReport(FormCollection _POST)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = _POST["organization"];

                Common.Log(string.Format("has run Service/CustomerReport/{0}", model.CustomerReport.Organization));
                
                CustomerReportGenerateLive();
                //CustomerReportGenerate();

                Common.Stats("Service/CustomerReport/" + model.CustomerReport.Organization);

                return View("CustomerReportSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string CustomerReportCSV(string organization)
        {
            try
            {
                model.CustomerReport = new CustomCustomerReport();
                model.CustomerReport.Organization = organization;

                CustomerReportGenerate();

                string retStr = "<pre>";

                retStr += string.Format("<table><tr><td>Disk usage:</td><td>{0}</td></tr><tr><td>Disk quota:</td><td>{1}</td></tr><tr><td>Exchange usage:</td><td>{2} GB</td></tr><tr><td>Exchange quota:</td><td>{3:0.00} GB</td></tr><tr><td>Server disks:</td><td>{4} GB</td></tr><tr><td>Total disk usage:</td><td>{5} GB</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td></table>", model.CustomerReport.DiskUsage, model.CustomerReport.DiskQuota, model.CustomerReport.ExchangefUsage, model.CustomerReport.ExchangefQuota, model.CustomerReport.DiskServers, model.CustomerReport.DiskTotal);

                retStr += "<table><tr><td>Name</td><td>Email</td><td>Usage</td><td>Quota</td></tr>";
                foreach (ExchangeUser user in model.CustomerReport.ExchangeUsers)
                {
                    retStr += string.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>", user.Name, user.Email, user.Usage, user.Quota);
                }
                retStr += "</table>";

                retStr += "<table><tr><td colspan=3>&nbsp;</td></tr><tr><td>Server</td><td>Device ID</td><td>Size</td></tr>";
                foreach (Server s in model.CustomerReport.Servers)
                {
                    foreach (ServerDisk d in s.Disks)
                    {
                        retStr += string.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", s.Name, d.DeviceID, d.Size);
                    }
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Windows Licenses (" + model.CustomerReport.Licenses.Windows.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.Windows)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office Standard Licenses (" + model.CustomerReport.Licenses.OfficeStandard.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.OfficeStandard)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office Professional Licenses (" + model.CustomerReport.Licenses.OfficeProfessional.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.OfficeProfessional)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Outlook Licenses (" + model.CustomerReport.Licenses.Outlook.Count + ")</td></tr>";
                foreach (string user in model.CustomerReport.Licenses.Outlook)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                return retStr + "</pre>";
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return model.Message + string.Join("<br />", model.MessageList);
            }
        }

        private void CustomerReportGenerateLive()
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetCustomerReportLive(model.CustomerReport.Organization);
                var result = ps.Invoke().Single();
                var mailbox = (PSObject)result.Properties["Mailbox"].Value;
                var files = (PSObject)result.Properties["Files"].Value;
                var users = (Object[])mailbox.Properties["Users"].Value;
                var database = (PSObject)result.Properties["Database"].Value;
                var office365 = (PSObject)result.Properties["Office365"].Value;

                model.CustomerReport.DatabasefUsage = double.Parse(database.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.DatabaseUsage = model.CustomerReport.DatabasefUsage.ToString("F1") + " GB";

                model.CustomerReport.DiskfUsage = double.Parse(files.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.DiskUsage = model.CustomerReport.DiskfUsage.ToString("F1") + " GB";
                model.CustomerReport.DiskfQuota = double.Parse(files.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.DiskQuota = model.CustomerReport.DiskfQuota.ToString("F1") + " GB";

                model.CustomerReport.ExchangefQuota = double.Parse(mailbox.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.ExchangeQuota = model.CustomerReport.ExchangefQuota.ToString("F1");
                model.CustomerReport.ExchangefUsage = double.Parse(mailbox.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CustomerReport.ExchangeUsage = model.CustomerReport.ExchangefUsage.ToString("F1");
                model.CustomerReport.ExchangeUsersCount = 0;

                model.CustomerReport.TenantID = Convert.ToString(office365.Properties["TenantID"].Value.ToString());
                model.CustomerReport.Admin = Convert.ToString(office365.Properties["Admin"].Value.ToString());
                model.CustomerReport.License = Convert.ToString(office365.Properties["License"].Value.ToString());
                model.CustomerReport.PartnerName = Convert.ToString(office365.Properties["PartnerName"].Value.ToString());


                foreach (PSObject user in users)
                {
                    model.CustomerReport.ExchangeUsers.Add(new ExchangeUser
                    {
                        Email = user.Properties["PrimarySmtpAddress"].Value.ToString(),
                        Name = user.Properties["DisplayName"].Value.ToString(),
                        Quota = (double.Parse(user.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024).ToString("F0") + " GB",
                        Usage = (double.Parse(user.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024).ToString("F1") + " GB"
                    });

                    string testUser = user.Properties["TestUser"].Value.ToString();
                    string type = user.Properties["Type"].Value.ToString();
                    string disabled = user.Properties["Disabled"].Value.ToString();
                    string displayName = user.Properties["DisplayName"].Value.ToString();
                    string studJur = user.Properties["StudJur"].Value.ToString();
                    string mailOnly = user.Properties["MailOnly"].Value.ToString();

                    if (testUser != "True" && (type == "UserMailbox" && disabled != "True")) 
                    {
                        model.CustomerReport.ExchangeUsersCount++;
                        
                        // Do not add MailOnly accounts to Windows nor Office.
                        if (mailOnly == "True")
                        {
                            model.CustomerReport.Licenses.MailOnly.Add(displayName);
                        }
                        else
                        {
                            model.CustomerReport.Licenses.Windows.Add(displayName);
                            model.CustomerReport.Licenses.OfficeStandard.Add(displayName);
                        }

                        if (studJur == "True")
                        {
                            model.CustomerReport.Licenses.StudJur.Add(displayName);
                        }
                    }
                }

                //throw new Exception(mailbox.Properties["TotalAllocated"].Value.ToString());
            }
        }

        private void CustomerReportGenerate()
        {
            using (SqlConnection sqlConnection = new SqlConnection("Data Source=DMZ027C1B\\SQLEXPRESS;Initial Catalog=CustomerReport;User ID=CustomerReport;Password=Systemhosting Customer Report SQL Password"))
            {
                sqlConnection.Open();

                //model.MessageList.Add("SPLA");
                #region SPLA
                using (SqlCommand command = new SqlCommand("SELECT u.name AS Name, t.[description] AS Type FROM users AS u, splatypes AS t, spla AS s WHERE s.orgid = (SELECT id FROM organization WHERE name = @Organization) AND u.id = s.userid AND s.typeid = t.id", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string name = sqlReader["Name"].ToString();
                        string type = sqlReader["Type"].ToString();

                        switch (type)
                        {
                            case "Windows License":
                                model.CustomerReport.Licenses.Windows.Add(name);
                                break;
                            case "Office Standard":
                                model.CustomerReport.Licenses.OfficeStandard.Add(name);
                                break;
                            case "Office Professional":
                                model.CustomerReport.Licenses.OfficeProfessional.Add(name);
                                break;
                            case "Outlook":
                                model.CustomerReport.Licenses.Outlook.Add(name);
                                break;
                            default:
                                model.CustomerReport.Licenses.Unknown.Add(name);
                                break;
                        }
                    }

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Exchange");
                #region Exchange
                using (SqlCommand command = new SqlCommand("SELECT name, primarysmtp, exchusage, exchquota FROM users WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string name = sqlReader["name"].ToString();
                        string email = sqlReader["primarysmtp"].ToString();
                        string quota = sqlReader["exchquota"].ToString().Replace('.', ','); // doubleingpoint conversion is fucked up due to localization hi!~
                        string usage = sqlReader["exchusage"].ToString().Replace('.', ',');

                        try {
                            usage = string.Format("{0:0.00} {1}", double.Parse(usage.Split(' ')[0]), usage.Split(' ')[1]);
                        }
                        catch { }

                        try
                        {
                            double fQuota = double.Parse(quota.Split(' ')[0]);
                            switch (quota.Split(' ')[1])
                            {
                                case "GB":
                                    // gb is good
                                    break;
                                case "MB":
                                    fQuota = fQuota / 1024; // upgrade to gb
                                    break;
                                case "KB":
                                    fQuota = fQuota / (1024 * 1024); // upgrade to gb
                                    break;
                                case "B":
                                    fQuota = 0;
                                    break;
                            }

                            model.CustomerReport.ExchangefQuota += fQuota;

                            double fUsage = double.Parse(usage.Split(' ')[0]);
                            switch (usage.Split(' ')[1])
                            {
                                case "GB":
                                    // gb is good
                                    break;
                                case "MB":
                                    fUsage = fUsage / 1024;
                                    break;
                                case "KB":
                                    fUsage = fUsage / (1024 * 1024);
                                    break;
                                case "B":
                                    fUsage = 0;
                                    break;
                            }

                            model.CustomerReport.ExchangefUsage += fUsage;
                        }
                        catch (Exception exc)
                        {
                            model.MessageList.Add("Exception : " + exc.Message);
                        }

                        model.CustomerReport.ExchangeUsers.Add(new ExchangeUser() { Name = name, Quota = quota, Usage = usage, Email = email });
                    }

                    //convert to int for pretty, instead of 123,18327481414141 GB
                    model.CustomerReport.ExchangeQuota = model.CustomerReport.ExchangefQuota.ToString() + " GB";

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Disk");
                #region Disk
                using (SqlCommand command = new SqlCommand("SELECT usage, quota FROM [disk] WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string quota = sqlReader["quota"].ToString();
                        string usage = sqlReader["usage"].ToString();

                        // disk usage and quota has , as doubleing point seperator instead of . so it needs replacing before it can be parsed properly
                        model.CustomerReport.DiskQuota = quota;
                        model.CustomerReport.DiskUsage = usage;

                        double fQuota = 0;
                        double.TryParse(model.CustomerReport.DiskQuota.Split(' ')[0], out fQuota);
                        switch (model.CustomerReport.DiskQuota.Split(' ')[1])
                        {
                            case "GB":
                                // gb is good
                                break;
                            case "MB":
                                fQuota = fQuota / 1024; // upgrade to gb
                                break;
                            case "KB":
                                fQuota = fQuota / (1024 * 1024); // upgrade to gb
                                break;
                            case "B":
                                fQuota = 0;
                                break;
                            default:
                                fQuota = 0;
                                break;
                        }

                        double fUsage = 0;
                        double.TryParse(model.CustomerReport.DiskUsage.Split(' ')[0], out fUsage);
                        switch (model.CustomerReport.DiskUsage.Split(' ')[1])
                        {
                            case "GB":
                                // gb is good
                                break;
                            case "MB":
                                fUsage = fUsage / 1024;
                                break;
                            case "KB":
                                fUsage = fUsage / (1024 * 1024);
                                break;
                            case "B":
                                fUsage = 0;
                                break;
                            default:
                                fUsage = 0;
                                break;
                        }

                        //model.MessageList.Add(string.Format("Quota: {0} Usage: {1}", model.CustomerReport2.DiskQuota, model.CustomerReport2.DiskUsage));

                        model.CustomerReport.DiskfUsage = fUsage;
                        model.CustomerReport.DiskfQuota = fQuota;
                    }

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Servers");
                #region Servers
                using (SqlCommand command = new SqlCommand("SELECT id, name FROM servers WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        
                        string name = sqlReader["name"].ToString();
                        int id = (int)sqlReader["id"];
                        //model.MessageList.Add(string.Format("id: {0} name: {1}", id, name));

                        Server s = new Server() { Name = name, Id = id };

                        model.CustomerReport.Servers.Add(s);

                    }

                    sqlReader.Close();
                }

                foreach (Server s in model.CustomerReport.Servers)
                {
                    using (SqlCommand command = new SqlCommand("SELECT deviceid, size FROM serverdisks WHERE serverid = @ServerID", sqlConnection))
                    {
                        command.Parameters.Add("@ServerID", SqlDbType.Int).Value = s.Id;

                        SqlDataReader sqlReader = command.ExecuteReader();

                        while (sqlReader.Read())
                        {
                            string deviceid = sqlReader["deviceid"].ToString();
                            string size = sqlReader["size"].ToString();
                            //model.MessageList.Add(string.Format("id: {0} size: {1}", deviceid, size));

                            s.Disks.Add(new ServerDisk() { DeviceID = deviceid, Size = size });
                        }

                        sqlReader.Close();
                    }
                }
                #endregion


                // and now to make pretty the numbers
                model.CustomerReport.ExchangefQuota = Math.Round(model.CustomerReport.ExchangefQuota, 2);
                model.CustomerReport.ExchangefUsage = Math.Round(model.CustomerReport.ExchangefUsage, 2);

                model.CustomerReport.DiskfUsage = Math.Round(model.CustomerReport.DiskfUsage, 2);
                model.CustomerReport.DiskfQuota = Math.Round(model.CustomerReport.DiskfQuota, 2);
            }
        }

        public ActionResult CustomerReportPieChartDisk(string iUsage, string iQuota)
        {
            //iUsage = iUsage.Replace(',', '.');
            //iQuota = iQuota.Replace(',', '.');

            double usage = double.Parse(iUsage);
            double quota = double.Parse(iQuota);

            double usagePct = usage / quota * 100;
            double quotaPct = 100 - usagePct;

            var key = new Chart(width: 100, height: 100).AddSeries(
                chartType: "pie",
                legend: "Space utulization",
                xValue: new[] { "Used", "Free" },
                yValues: new[] { usagePct, quotaPct }).Write("png");

            return null;
        }
    }
}
