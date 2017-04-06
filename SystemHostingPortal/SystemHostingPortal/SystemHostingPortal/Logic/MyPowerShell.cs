using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using SystemHostingPortal.Models;
using System.Management.Automation;

namespace SystemHostingPortal.Logic
{
    public class MyPowerShell : IDisposable
    {
        private string psScriptPath = WebConfigurationManager.AppSettings["PowerShellScriptPath"].ToString();
        private PowerShell ps = PowerShell.Create(RunspaceMode.NewRunspace);

        public MyPowerShell()
        {
            AddScript("Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force");
            AddScript("$ErrorActionPreference = 'STOP'");
        }

        /// <summary>
        /// Add a script to be processed
        /// </summary>
        /// <param name="script"></param>
        /// <param name="args"></param>
        /// <returns></returns>
        public MyPowerShell AddScript(string script)
        {
            ps.AddScript(script);
            return this;
        }

        public MyPowerShell AddScript(string script, params object[] args)
        {
            ps.AddScript(string.Format(script, args));
            return this;
        }

        public MyPowerShell AddCommand(string command)
        {
            ps.AddCommand(command);
            return this;
        }
        public MyPowerShell AddParameter(string parameter, object value)
        {
            ps.AddParameter(parameter, value);
            return this;
        }
        public MyPowerShell AddParameter(string parameter)
        {
            ps.AddParameter(parameter);
            return this;
        }


        public IEnumerable<PSObject> Invoke()
        {
            var result = ps.Invoke();
            return result;
        }

        public void Dispose()
        {
            ps.Dispose();
            ps = null;
        }


        /// <summary>
        /// Get Organizations
        /// </summary>
        /// 
        /// 
        public MyPowerShell GetOrganizations()
        {
            ps.AddCommand(psScriptPath + @"\GetOrganizations.ps1");

            return this;
        }
        /// <summary>
        /// Create a new user account
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public MyPowerShell CreateUser(CustomUser user)
        {
            ps.AddCommand(psScriptPath + @"\CreateUser.ps1");
            ps.AddParameter("Organization", user.Organization);
            ps.AddParameter("FirstName", user.FirstName.Trim());
            ps.AddParameter("LastName", user.LastName.Trim());
            ps.AddParameter("UserPrincipalName", user.UserPrincipalName.Trim());
            ps.AddParameter("Password", user.Password);
            ps.AddParameter("DomainName", user.DomainName);
            ps.AddParameter("CopyFrom", user.CopyFrom);
            if (user.TestUser) { ps.AddParameter("TestUser", true); }
            if (user.PasswordNeverExpires) { ps.AddParameter("PasswordNeverExpires", true); }

            return this;
        }

        /// <summary>
        /// Disable a user account
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public MyPowerShell DisableUser(CustomUser user)
        {
            if (!(user.Confirm)) { throw new Exception("Missing action Confirm. Can't do nothing."); }

            ps.AddCommand(psScriptPath + @"\DisableUser.ps1");
            ps.AddParameter("Organization", user.Organization);
            ps.AddParameter("DistinguishedName", user.DistinguishedName);
            if (user.Confirm) { ps.AddParameter("Confirm"); }

            return this;
        }
        
        /// <summary>
        /// Completely remove a user
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public MyPowerShell RemoveUser(CustomUser user)
        {
            ps.AddCommand(psScriptPath + @"\RemoveUser.ps1");
            ps.AddParameter("Organization", user.Organization);
            ps.AddParameter("UserPrincipalName", user.UserPrincipalName);

            return this;
        }

        /// <summary>
        /// Add alias to user
        /// </summary>
        /// <param name="addAlias"></param>
        /// <returns></returns>
        public MyPowerShell AddAlias(CustomAlias addAlias)
        {
            ps.AddCommand(psScriptPath + @"\AddAlias.ps1");
            ps.AddParameter("Organization", addAlias.Organization);
            ps.AddParameter("UserPrincipalName", addAlias.UserPrincipalName);
            ps.AddParameter("EmailAddresses", addAlias.EmailAddresses);
            if (addAlias.SetFirstAsPrimary) { ps.AddParameter("SetFirstAsPrimary", true); }

            return this;
        }

        /// <summary>
        /// Returns list of accepted emaildomains for organization
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public MyPowerShell GetAcceptedDomain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAcceptedDomain.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        /// <summary>
        /// Returns TenantID data for organization
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public MyPowerShell GetTenantID(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetTenantID.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        /// <summary>
        /// Removes alias from user
        /// </summary>
        /// <param name="removeAlias"></param>
        /// <returns></returns>
        public MyPowerShell RemoveAlias(CustomAlias removeAlias)
        {
            ps.AddCommand(psScriptPath + @"\RemoveAlias.ps1");
            ps.AddParameter("Organization", removeAlias.Organization);
            ps.AddParameter("UserPrincipalName", removeAlias.UserPrincipalName);
            ps.AddParameter("EmailAddresses", removeAlias.EmailAddresses);

            return this;
        }

        public MyPowerShell GetExistingAliases(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetExistingAliases.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public MyPowerShell GetMailboxes(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxes.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell AddMailboxPermission(CustomMailboxPermission addMailboxPermission)
        {
            ps.AddCommand(psScriptPath + @"\AddMailboxPermission.ps1");
            ps.AddParameter("Organization", addMailboxPermission.Organization);
            ps.AddParameter("UserPrincipalName", addMailboxPermission.UserPrincipalName);
            if (addMailboxPermission.FullAccess) { ps.AddParameter("FullAccess"); }
            if (addMailboxPermission.SendAs) { ps.AddParameter("SendAs"); }

            return this;
        }

        public MyPowerShell CreateMailbox(CustomMailbox newMailbox)
        {
            ps.AddCommand(psScriptPath + @"\CreateMailbox.ps1");
            ps.AddParameter("Organization", newMailbox.Organization);
            ps.AddParameter("Name", newMailbox.Name);
            ps.AddParameter("PrimarySmtpAddress", newMailbox.UserPrincipalName);
            ps.AddParameter("Type", newMailbox.Type);
            if (newMailbox.EmailAddresses.Count > 0) { ps.AddParameter("EmailAddresses", newMailbox.EmailAddresses); }

            return this;
        }

        /*public MyPowerShell CustomerReportTest()
        {
            ps.AddCommand("C:\\Scripts\\GetReportTest.ps1");
            return this;
        }*/

        public MyPowerShell CreateDistributionGroup(CustomDistributionGroup newDistributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\CreateDistributionGroup.ps1");
            ps.AddParameter("Organization", newDistributionGroup.Organization);
            ps.AddParameter("Name", newDistributionGroup.Name);
            ps.AddParameter("PrimarySmtpAddress", newDistributionGroup.UserPrincipalName);
            ps.AddParameter("ManagedBy", newDistributionGroup.ManagedBy);
            ps.AddParameter("RequireSenderAuthentication", newDistributionGroup.RequireSenderAuthentication);
            return this;
        }

        public MyPowerShell AddDistributionGroupManager(CustomDistributionGroup distributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\Add-DistributionGroupManager.ps1");
            ps.AddParameter("Organization", distributionGroup.Organization);
            ps.AddParameter("Group", distributionGroup.PrimarySmtpAddress);
            ps.AddParameter("Manager", distributionGroup.ManagedBy);
            
            return this;
        }


        public MyPowerShell SetMailforward(CustomMailforward mailforward)
        {
            ps.AddCommand(psScriptPath + @"\SetMailforward.ps1");
            ps.AddParameter("Organization", mailforward.Organization);
            ps.AddParameter("UserPrincipalName", mailforward.UserPrincipalName);
            ps.AddParameter("ForwardingAddress", mailforward.ForwardingSmtpAddress);
            ps.AddParameter("ForwardingType", mailforward.ForwardingType);
            if (mailforward.DeliverToMailboxAndForward) { ps.AddParameter("DeliverToMailboxAndForward", true); }

            return this;
        }

        public MyPowerShell GetMailforward(string organization, string userPrincipalName)
        {
            ps.AddCommand(psScriptPath + @"\GetMailforward.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userPrincipalName);

            return this;
        }

        public MyPowerShell CreateServiceUser(CustomServiceUser serviceUser)
        {
            ps.AddCommand(psScriptPath + @"\CreateServiceUser.ps1");
            ps.AddParameter("Organization", serviceUser.Organization);
            ps.AddParameter("Service", serviceUser.Service);
            ps.AddParameter("Description", serviceUser.Description);
            ps.AddParameter("Password", serviceUser.Password);
            if (serviceUser.Management) { ps.AddParameter("Management"); }

            return this;
        }

        public MyPowerShell GetMailboxPlans(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxPlans.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetMailboxPlan(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxPlan.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public MyPowerShell SetMailboxPlan(CustomMailboxPlan mailboxPlan)
        {
            ps.AddCommand(psScriptPath + @"\SetMailboxPlan.ps1");
            ps.AddParameter("Organization", mailboxPlan.Organization);
            ps.AddParameter("UserPrincipalName", mailboxPlan.UserPrincipalName);
            ps.AddParameter("MailboxPlan", mailboxPlan.MailboxPlan);

            return this;
        }

        public MyPowerShell SetMailboxAutoResize(CustomMailboxAutoResize mailboxResize)
        {
            ps.AddCommand(psScriptPath + @"\SetMailboxAutoResize.ps1");
            ps.AddParameter("Organization", mailboxResize.Organization);
            ps.AddParameter("ExcludeFromAutoSize", mailboxResize.ExcludeFromAutoResize);

            return this;
        }

        public MyPowerShell GetUserMemberOf(CustomUserMemberOf memberOf)
        {
            ps.AddCommand(psScriptPath + @"\GetUserMemberOf.ps1");
            ps.AddParameter("Organization", memberOf.Organization);
            ps.AddParameter("UserPrincipalName", memberOf.UserPrincipalName);

            return this;
        }

        public MyPowerShell GetDeviceReport(CustomDeviceReport deviceReport)
        {
            ps.AddCommand(psScriptPath + @"\GetDeviceReport.ps1");
            ps.AddParameter("Organization", deviceReport.Organization);
            ps.AddParameter("Name", deviceReport.UserPrincipalName);

            return this;
        }

        public MyPowerShell GetMailContacts(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailContacts.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell DeleteMailContact(CustomMailContact mailContact)
        {
            ps.AddCommand(psScriptPath + @"\DeleteMailContact.ps1");
            ps.AddParameter("Organization", mailContact.Organization);
            ps.AddParameter("PrimarySmtpAddress", mailContact.PrimarySmtpAddress);

            return this;
        }

        public MyPowerShell DeleteDistributionGroup(CustomDistributionGroup distributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\DeleteDistributionGroup.ps1");
            ps.AddParameter("Organization", distributionGroup.Organization);
            ps.AddParameter("PrimarySmtpAddress", distributionGroup.PrimarySmtpAddress);

            return this;
        }

        public MyPowerShell GetDistributionGroups(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDistributionGroups.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetCalendarPermissions(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\Get-CalendarPermissions.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public MyPowerShell GetMailbox(string organization, string name)
        {
            ps.AddCommand(psScriptPath + @"\GetMailbox.ps1");
            ps.AddParameter("Organization", organization);
            if (name != string.Empty)
            {
                ps.AddParameter("Name", name);
            }

            return this;
        }

        public MyPowerShell SetCalendarPermissions(CustomCalendarPermssions calendarPermssions)
        {
            ps.AddCommand(psScriptPath + @"\Set-CalendarPermissions.ps1");
            ps.AddParameter("Organization", calendarPermssions.Organization);
            ps.AddParameter("UserPrincipalName", calendarPermssions.UserPrincipalName);
            ps.AddParameter("User", calendarPermssions.User);
            ps.AddParameter("AccessRights", calendarPermssions.AccessRights);

            return this;
        }

        public MyPowerShell RemoveCalendarPermissions(string organization, string userprincipalname, string[] users)
        {
            ps.AddCommand(psScriptPath + @"\Remove-CalendarPermissions.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);
            ps.AddParameter("User", users);

            return this;
        }

        public MyPowerShell RemoveMailbox(CustomMailbox mailbox)
        {
            ps.AddCommand(psScriptPath + @"\Remove-Mailbox.ps1");
            ps.AddParameter("Organization", mailbox.Organization);
            ps.AddParameter("Identity", mailbox.UserPrincipalName);

            return this;
        }

        public MyPowerShell CreateExtUser(CustomExtUser extuser)
        {
            ps.AddCommand(psScriptPath + @"\CreateExtUser.ps1");
            ps.AddParameter("Organization", extuser.Organization);
            ps.AddParameter("Vendor", extuser.Name);
            ps.AddParameter("ExpirationDate", extuser.ExpirationDate);
            ps.AddParameter("Password", extuser.Password);

            return this;
        }

        public MyPowerShell GetDefaultAcceptedDomain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDefaultAcceptedDomain.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell AddMailboxPermissionFullAccess(CustomMailboxPermissionFullAccess mailboxPermissionFullAccess)
        {
            ps.AddCommand(psScriptPath + @"\AddMailboxPermissionFullAccess.ps1");
            ps.AddParameter("Organization", mailboxPermissionFullAccess.Organization);
            ps.AddParameter("UserPrincipalName", mailboxPermissionFullAccess.UserPrincipalName);

            return this;
        }

        public MyPowerShell EnableUser(CustomUser enableUser)
        {
            ps.AddCommand(psScriptPath + @"\EnableUser.ps1");
            ps.AddParameter("Organization", enableUser.Organization);
            ps.AddParameter("DistinguishedName", enableUser.DistinguishedName);
            if (enableUser.Confirm) { ps.AddParameter("Confirm"); }

            return this;
        }

        public MyPowerShell CreateOrganization(string organization, string emaildomainname, string subnet, string vlan, string ipaddressrangestart, string ipaddressrangeend, bool createvmm)
        {
            ps.AddCommand(psScriptPath + @"\CreateOrganization.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("EmailDomainName", emaildomainname)
                .AddParameter("Subnet", subnet)
                .AddParameter("Vlan", vlan)
                .AddParameter("IPAddressRangeStart", ipaddressrangestart)
                .AddParameter("IPAddressRangeEnd", ipaddressrangeend)
                .AddParameter("CreateVMM", createvmm);

            return this;
        }

        public MyPowerShell GetCustomerReportLive(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCustomerReportLive.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell RemoveCustomer(string organization, bool removedata, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\RemoveCustomer.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("RemoveData", removedata)
                .AddParameter("Confirm", confirm);


            return this;
        }

        public MyPowerShell EnableCustomer(string organization)
        {
            ps.AddCommand(psScriptPath + @"\EnableCustomer.ps1")
              .AddParameter("Organization", organization);
            return this;
        }

        public MyPowerShell DisableCustomer(string organization, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\DisableCustomer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Confirm", confirm);
            return this;
        }

        public MyPowerShell AddUPN(string organization, string domain)
        {
            ps.AddCommand(psScriptPath + @"\AddUPNSuffix.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain);
            return this;
        }

        public MyPowerShell Enable365Customer(string organization, string tenantid, string tenantadmin, string tenantpass)
        {
            ps.AddCommand(psScriptPath + @"\Enable365Customer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("TenantID", tenantid)
              .AddParameter("TenantAdmin", tenantadmin)
              .AddParameter("TenantPass", tenantpass);
            return this;
        }

        public MyPowerShell ConvertCustomer(string organization, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\ConvertCustomer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Confirm", confirm);
            return this;
        }

        public MyPowerShell AddAcceptedDomain(string organization, string domain, bool setasupn)
        {
            ps.AddCommand(psScriptPath + @"\AddAcceptedDomain.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain)
              .AddParameter("SetAsUPN", setasupn);
            return this;
        }

        public MyPowerShell GetItemsReport(string organization, string mail, bool getall)
        {
            ps.AddCommand(psScriptPath + @"\GetItemsReport.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Mail", mail)
              .AddParameter("GetALL", getall);
            return this;
        }

        public MyPowerShell EnableSikkermail(string organization, string sendasgroup, string alias, bool remove, bool force, bool updateall)
        {
            ps.AddCommand(psScriptPath + @"\EnableSikkermail.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("SendAsGroup", sendasgroup)
              .AddParameter("Alias", alias)
              .AddParameter("Remove", remove)
              .AddParameter("Force", force)
              .AddParameter("UpdateAll", updateall);
            return this;
        }

        public MyPowerShell GetSendAsGroups(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetSendAsGroups.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell UpdateVersionConf(string organization, bool updateall)
        {
            ps.AddCommand(psScriptPath + @"\UpdateVersionConf.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("UpdateAll", updateall);
            return this;
        }
        public MyPowerShell UpdateConf(string organization, string exchangeserver, string domainfqdn, string customeroudn, string accepteddomains, string tenantid365, string adminuser365, string adminpass365)
        {
            ps.AddCommand(psScriptPath + @"\UpdateConf.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("ExchangeServer", exchangeserver)
                .AddParameter("DomainFQDN", domainfqdn)
                .AddParameter("CustomerOUDN", customeroudn)
                .AddParameter("AcceptedDomains", accepteddomains)
                .AddParameter("TenantID365", tenantid365)
                .AddParameter("AdminUser365", adminuser365)
                .AddParameter("AdminPass365", adminpass365);

            return this;
        }

        public MyPowerShell GetCurrentConf(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCurrentConf.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell SetPassword(string organization, string distinguishedname, string password, bool passwordneverexpires)
        {
            ps.AddCommand(psScriptPath + @"\SetPassword.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("DistinguishedName", distinguishedname)
              .AddParameter("Password", password)
              .AddParameter("PasswordNeverExpires", passwordneverexpires);
            return this;
        }

        public MyPowerShell GetADUsers(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetADUsers.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetVMServers()
        {
            ps.AddCommand(psScriptPath + @"\GetVMServers.ps1");

            return this;
        }

        public MyPowerShell GetVMVHDs(string vhdid)
        {
            ps.AddCommand(psScriptPath + @"\GetVMVHDs.ps1")
                .AddParameter("VHDID", vhdid);

            return this;
        }

        public MyPowerShell GetVMInfo(string id)
        {
            ps.AddCommand(psScriptPath + @"\GetVMInfo.ps1")
              .AddParameter("ID", id);
            return this;
        }

        public MyPowerShell ExpandVHD(string name, string vhdid, string datetime, string gb, string email)
        {
            ps.AddCommand(psScriptPath + @"\ExpandVHD.ps1")
              .AddParameter("Name", name)
              .AddParameter("VHDID", vhdid)
              .AddParameter("DateTime", datetime)
              .AddParameter("GB", gb)
              .AddParameter("Email", email);
            return this;
        }

        public MyPowerShell ExpandCPURAM(string name, string datetime, string cpu, string ram, string email)
        {
            ps.AddCommand(psScriptPath + @"\ExpandCPURAM.ps1")
              .AddParameter("Name", name)
              .AddParameter("DateTime", datetime)
              .AddParameter("CPU", cpu)
              .AddParameter("RAM", ram)
              .AddParameter("Email", email);
            return this;
        }

    }
}