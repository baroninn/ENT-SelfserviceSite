using System;
using System.Collections.Generic;
using System.Web.Configuration;
using ColumbusPortal.Models;
using System.Management.Automation;

namespace ColumbusPortal.Logic
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
            ps.AddParameter("UserName", user.UserName.Trim());
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
            ps.AddParameter("UserPrincipalName", user.UserPrincipalName);
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
            if (user.DelData == true)
            {
                ps.AddParameter("DelData", user.DelData);
            }

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
        public MyPowerShell GetDomain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDomain.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        /// <summary>
        /// Returns list of domains for organization in Office 365
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public MyPowerShell GetO365Domain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDomain.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("O365", true);

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
            ps.AddParameter("UserName", newMailbox.UserName);
            ps.AddParameter("Password", newMailbox.Password);
            ps.AddParameter("DisplayName", newMailbox.DisplayName);
            ps.AddParameter("DomainName", newMailbox.DomainName);
            ps.AddParameter("Type", newMailbox.Type);
            if (newMailbox.EmailAddresses.Count > 0) { ps.AddParameter("EmailAddresses", newMailbox.EmailAddresses); }

            return this;
        }
        public MyPowerShell StartIntuneDeviceTask(string organization, string task, string id, string message, string phone, string footer)
        {
            ps.AddCommand(psScriptPath + @"\StartIntuneDeviceTask.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("task", task);
            ps.AddParameter("id", id);
            ps.AddParameter("message", message);
            ps.AddParameter("phoneNumber", phone);
            ps.AddParameter("footer", footer);
            return this;
        }

        public MyPowerShell CreateDistributionGroup(CustomDistributionGroup newDistributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\CreateDistributionGroup.ps1");
            ps.AddParameter("Organization", newDistributionGroup.Organization);
            ps.AddParameter("Name", newDistributionGroup.Name);
            ps.AddParameter("UserName", newDistributionGroup.UserName);
            ps.AddParameter("DomainName", newDistributionGroup.DomainName);
            ps.AddParameter("ManagedBy", newDistributionGroup.ManagedBy);
            ps.AddParameter("RequireSenderAuthentication", newDistributionGroup.RequireSenderAuthentication);
            return this;
        }

        public MyPowerShell AddDistributionGroupManager(CustomDistributionGroup distributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\Add-DistributionGroupManager.ps1");
            ps.AddParameter("Organization", distributionGroup.Organization);
            ps.AddParameter("Group", distributionGroup.UserName);
            ps.AddParameter("Manager", distributionGroup.ManagedBy);
            
            return this;
        }


        public MyPowerShell SetMailforward(CustomMailforward mailforward)
        {
            ps.AddCommand(psScriptPath + @"\SetMailForward.ps1");
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
            ps.AddParameter("UserName", distributionGroup.UserName);

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

        public MyPowerShell SetCalendarPermissions(CustomCalendarPermissions calendarPermissions)
        {
            ps.AddCommand(psScriptPath + @"\Set-CalendarPermissions.ps1");
            ps.AddParameter("Organization", calendarPermissions.Organization);
            ps.AddParameter("UserPrincipalName", calendarPermissions.UserPrincipalName);
            ps.AddParameter("User", calendarPermissions.User);
            ps.AddParameter("AccessRights", calendarPermissions.AccessRights);

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
            ps.AddParameter("UserName", extuser.UserName);
            ps.AddParameter("DomainName", extuser.DomainName);
            ps.AddParameter("DisplayName", extuser.DisplayName);
            ps.AddParameter("Description", extuser.Description);
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
            ps.AddParameter("UserPrincipalName", enableUser.UserPrincipalName);
            if (enableUser.Confirm) { ps.AddParameter("Confirm"); }

            return this;
        }

        public MyPowerShell CreateOrganization(CustomOrganization Organization, CustomCrayonTenantInfoDetailed CrayonTenantInfoDetailed)
        {
            ps.AddCommand(psScriptPath + @"\CreateOrganization.ps1")
                .AddParameter("Platform", Organization.Platform)
                .AddParameter("Initials", Organization.initials)
                .AddParameter("Name", Organization.Name)
                .AddParameter("EmailDomainName", Organization.EmailDomainName)
                .AddParameter("Subnet", Organization.Subnet)
                .AddParameter("Vlan", Organization.Vlan)
                .AddParameter("Gateway", Organization.Gateway)
                .AddParameter("IPAddressRangeStart", Organization.IPAddressRangeStart)
                .AddParameter("IPAddressRangeEnd", Organization.IPAddressRangeEnd)
                .AddParameter("CreateVMM", Organization.CreateVMM)
                .AddParameter("createcrayon", Organization.createcrayon)
                .AddParameter("InvoiceProfile", CrayonTenantInfoDetailed.InvoiceProfile)
                .AddParameter("CrayonDomainPrefix", CrayonTenantInfoDetailed.DomainPrefix)
                .AddParameter("CrayonFirstName", CrayonTenantInfoDetailed.FirstName)
                .AddParameter("CrayonLastName", CrayonTenantInfoDetailed.LastName)
                .AddParameter("CrayonEmail", CrayonTenantInfoDetailed.Email)
                .AddParameter("CrayonPhoneNumber", CrayonTenantInfoDetailed.PhoneNumber)
                .AddParameter("CrayonCustomerFirstName", CrayonTenantInfoDetailed.CustomerFirstName)
                .AddParameter("CrayonCustomerLastName", CrayonTenantInfoDetailed.CustomerLastName)
                .AddParameter("CrayonAddressLine1", CrayonTenantInfoDetailed.AddressLine1)
                .AddParameter("CrayonCity", CrayonTenantInfoDetailed.City)
                .AddParameter("CrayonRegion", CrayonTenantInfoDetailed.Region)
                .AddParameter("CrayonPostalCode", CrayonTenantInfoDetailed.PostalCode)
            ;

            return this;
        }

        public MyPowerShell GetCustomerReportLive(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCustomerReportLive.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetCustomerReportSQL(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCustomerReportSQL.ps1")
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

        public MyPowerShell VerifyDomain(string organization, string domain)
        {
            ps.AddCommand(psScriptPath + @"\ConfirmO365Domain.ps1")
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

        public MyPowerShell AddDomain(string organization, string domain, bool addasemail)
        {
            ps.AddCommand(psScriptPath + @"\AddDomain.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain)
              .AddParameter("AddasEmail", addasemail);
            return this;
        }

        public MyPowerShell RemoveDomain(string organization, string domain, bool removeasemail)
        {
            ps.AddCommand(psScriptPath + @"\RemoveDomain.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain)
              .AddParameter("RemoveAsEmail", removeasemail);
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
        public MyPowerShell UpdateConf(CustomUpdateConf UpdateConf)
        {
            ps.AddCommand(psScriptPath + @"\UpdateConf.ps1");
            ps.AddParameter("Organization", UpdateConf.Organization);
            ps.AddParameter("Platform", UpdateConf.Platform);
            ps.AddParameter("Name", UpdateConf.Name);
            ps.AddParameter("UserContainer", UpdateConf.UserContainer);
            ps.AddParameter("ExchangeServer", UpdateConf.ExchangeServer);
            ps.AddParameter("DomainFQDN", UpdateConf.DomainFQDN);
            ps.AddParameter("NETBIOS", UpdateConf.NETBIOS);
            ps.AddParameter("CustomerOUDN", UpdateConf.CustomerOUDN);
            ps.AddParameter("AdminUserOUDN", UpdateConf.AdminUserOUDN);
            ps.AddParameter("ExternalUserOUDN", UpdateConf.ExternalUserOUDN);
            ps.AddParameter("EmailDomains", UpdateConf.EmailDomains);
            ps.AddParameter("TenantID", UpdateConf.TenantID);
            ps.AddParameter("AdminUser", UpdateConf.AdminUser);
            ps.AddParameter("AdminPass", UpdateConf.AdminPass);
            ps.AddParameter("AADsynced", UpdateConf.AADsynced);
            ps.AddParameter("ADConnectServer", UpdateConf.ADConnectServer);
            ps.AddParameter("DomainDC", UpdateConf.DomainDC);
            ps.AddParameter("NavMiddleTier", UpdateConf.NavMiddleTier);
            ps.AddParameter("SQLServer", UpdateConf.SQLServer);
            ps.AddParameter("AdminRDS", UpdateConf.AdminRDS);
            ps.AddParameter("AdminRDSPort", UpdateConf.AdminRDSPort);
            ps.AddParameter("AppID", UpdateConf.AppID);
            ps.AddParameter("AppSecret", UpdateConf.AppSecret);
            ps.AddParameter("Service365", UpdateConf.Service365);
            ps.AddParameter("ServiceCompute", UpdateConf.ServiceCompute);
            ps.AddParameter("ServiceIntune", UpdateConf.ServiceIntune);

            return this;
        }

        public MyPowerShell GetCurrentConf(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCurrentConf.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell SetPassword(string organization, string userprincipalname, string password, bool passwordneverexpires)
        {
            ps.AddCommand(psScriptPath + @"\SetPassword.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("UserPrincipalName", userprincipalname)
              .AddParameter("Password", password)
              .AddParameter("PasswordNeverExpires", passwordneverexpires);
            return this;
        }

        public MyPowerShell GetADUsers(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetADUsers.ps1")
                .AddParameter("Organization", organization);
                if (userprincipalname != null)
            { 
                ps.AddParameter("UserPrincipalName", userprincipalname);
            }

            return this;
        }

        public MyPowerShell GetVMServers()
        {
            ps.AddCommand(psScriptPath + @"\GetVMServers.ps1");

            return this;
        }

        public MyPowerShell GetVMServerslvl25()
        {
            ps.AddCommand(psScriptPath + @"\GetVMServerslvl25.ps1");

            return this;
        }

        public MyPowerShell GetVMVHDs(string vmid)
        {
            ps.AddCommand(psScriptPath + @"\GetVMVHDs.ps1")
                .AddParameter("VMID", vmid);

            return this;
        }

        public MyPowerShell GetVMInfo(string vmid)
        {
            ps.AddCommand(psScriptPath + @"\GetVMInfo.ps1")
              .AddParameter("VMID", vmid);
            return this;
        }

        public MyPowerShell ExpandVHD(string vmid, string vhdid, string datetime, string gb, string email, string taskid)
        {
            ps.AddCommand(psScriptPath + @"\ExpandVHD.ps1")
              .AddParameter("VMID", vmid)
              .AddParameter("VHDID", vhdid)
              .AddParameter("DateTime", datetime)
              .AddParameter("GB", gb)
              .AddParameter("TaskID", taskid)
              .AddParameter("Email", email);
            return this;
        }
        
        public MyPowerShell ExpandCPURAM(string vmid, string datetime, string cpu, string ram, string email, string dynamicmemoryenabled, string taskid)
        {
            ps.AddCommand(psScriptPath + @"\ExpandCPURAM.ps1")
              .AddParameter("VMID", vmid)
              .AddParameter("DateTime", datetime)
              .AddParameter("CPU", cpu)
              .AddParameter("RAM", ram)
              .AddParameter("Email", email)
              .AddParameter("TaskID", taskid)
              .AddParameter("DynamicMemoryEnabled", dynamicmemoryenabled); ;
            return this;
        }

        public MyPowerShell StartDirSync(string organization, string policy, bool force)
        {
            ps.AddCommand(psScriptPath + @"\StartDirSync.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Policy", policy)
              .AddParameter("Force", force);
            return this;
        }

        public MyPowerShell ScheduleReboot(string vmid, string datetime, string email, string taskid)
        {
            ps.AddCommand(psScriptPath + @"\ScheduleReboot.ps1")
              .AddParameter("VMID", vmid)
              .AddParameter("DateTime", datetime)
              .AddParameter("TaskID", taskid)
              .AddParameter("Email", email);
            return this;
        }

        /// <summary>
        /// Create a new admin account
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public MyPowerShell CreateAdmin(CustomUser user)
        {
            ps.AddCommand(psScriptPath + @"\CreateAdmin.ps1");
            ps.AddParameter("FirstName", user.FirstName.Trim());
            ps.AddParameter("LastName", user.LastName.Trim());
            ps.AddParameter("SamAccountName", user.SamAccountName.Trim());
            ps.AddParameter("Password", user.Password);
            ps.AddParameter("DisplayName", user.DisplayName);
            ps.AddParameter("Department", user.Department);

            return this;
        }

        public MyPowerShell RemoveAdmin(CustomUser user)
        {
            ps.AddCommand(psScriptPath + @"\RemoveAdmin.ps1");
            ps.AddParameter("SamAccountName", user.SamAccountName.Trim());

            return this;
        }

        public MyPowerShell CreateALLAdmins(string organization)
        {
            ps.AddCommand(psScriptPath + @"\CreateALLAdmins.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell ResetAdminPassword(CustomUser user)
        {
            ps.AddCommand(psScriptPath + @"\ResetAdminPassword.ps1");
            ps.AddParameter("SamAccountName", user.SamAccountName.Trim());
            ps.AddParameter("Password", user.Password.Trim());

            return this;
        }

        public MyPowerShell GetAdminUsers()
        {
            ps.AddCommand(psScriptPath + @"\GetAdminUsers.ps1");
            return this;
        }

        public MyPowerShell GetPendingReboot()
        {
            ps.AddCommand(psScriptPath + @"\GetPendingReboot.ps1");
            return this;
        }

        public MyPowerShell GetLatestAlerts(string alert)
        {
            ps.AddCommand(psScriptPath + @"\GetLatestAlerts.ps1");
            if (alert == "Freespace")
            {
                ps.AddParameter("FreeSpace");
            }
            if (alert == "LatestAlerts")
            {
                ps.AddParameter("LatestAlerts");
            }
            if (alert == "PendingReboots")
            {
                ps.AddParameter("PendingReboots");
            }
            return this;
        }

        public MyPowerShell GetAlertFreeSpace()
        {
            ps.AddCommand(psScriptPath + @"\GetAlertFreeSpace.ps1");
            return this;
        }
        public MyPowerShell GetScheduledJobs(string job)
        {
            ps.AddCommand(psScriptPath + @"\GetScheduledJobs.ps1");
                ps.AddParameter("job", job);
            return this;
        }

        public MyPowerShell CreateEXTAdminUser(CustomEXTAdminUser EXTAdminUser)
        {
            ps.AddCommand(psScriptPath + @"\CreateEXTAdminUser.ps1");
            ps.AddParameter("Organization", EXTAdminUser.Organization);
            ps.AddParameter("ID", EXTAdminUser.ID);
            ps.AddParameter("FirstName", EXTAdminUser.FirstName);
            ps.AddParameter("LastName", EXTAdminUser.LastName);
            ps.AddParameter("Email", EXTAdminUser.Email);
            ps.AddParameter("Company", EXTAdminUser.Company);
            ps.AddParameter("Description", EXTAdminUser.Description);
            ps.AddParameter("SamAccountName", EXTAdminUser.SamAccountName);
            ps.AddParameter("Password", EXTAdminUser.Password);
            ps.AddParameter("ExpireDate", EXTAdminUser.ExpireDate);
            return this;
        }

        public MyPowerShell ScheduleEXTAdminUser(CustomEXTAdminUser EXTAdminUser)
        {
            ps.AddCommand(psScriptPath + @"\ScheduleEXTAdminUser.ps1");
            ps.AddParameter("firstname", EXTAdminUser.FirstName);
            ps.AddParameter("lastname", EXTAdminUser.LastName);
            ps.AddParameter("customer", EXTAdminUser.Customer);
            ps.AddParameter("company", EXTAdminUser.Company);
            ps.AddParameter("email", EXTAdminUser.Email);
            ps.AddParameter("description", EXTAdminUser.Description);
            ps.AddParameter("expiredate", EXTAdminUser.ExpireDate);
            return this;
        }

        public MyPowerShell GetEXTAdminUser(string id, string status, string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetEXTAdminUsers.ps1");
            ps.AddParameter("ID", id);
            ps.AddParameter("Organization", organization);
            ps.AddParameter("Status", status);
            return this;
        }
        public MyPowerShell GetCASAdminUser(string id, string status, string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCASAdminUsers.ps1");
            ps.AddParameter("ID", id);
            ps.AddParameter("Organization", organization);
            ps.AddParameter("Status", status);
            return this;
        }
        public MyPowerShell GetCASAdminUserALL()
        {
            ps.AddCommand(psScriptPath + @"\GetCASAdminUsersALL.ps1");
            return this;
        }
        public MyPowerShell RemoveEXTAdminUser(string id, string Organization)
        {
            ps.AddCommand(psScriptPath + @"\RemoveEXTAdminUser.ps1");
            ps.AddParameter("ID", id);
            ps.AddParameter("Organization", Organization);
            return this;
        }
        public MyPowerShell RemoveCASAdminUser(string id, string Organization)
        {
            ps.AddCommand(psScriptPath + @"\RemoveCASAdminUser.ps1");
            ps.AddParameter("ID", id);
            ps.AddParameter("Organization", Organization);
            return this;
        }
        public MyPowerShell RemoveCASAdminUserALL(string username)
        {
            ps.AddCommand(psScriptPath + @"\RemoveCASAdminUserALL.ps1");
            ps.AddParameter("UserName", username);
            return this;
        }

        public MyPowerShell UpdateNAVCustomer(CustomNAVCustomer UpdateNAVCustomer)
        {
            ps.AddCommand(psScriptPath + @"\UpdateNAVCustomer.ps1");
            ps.AddParameter("Organization", UpdateNAVCustomer.Organization);
            ps.AddParameter("Platform", UpdateNAVCustomer.Platform);
            ps.AddParameter("Name", UpdateNAVCustomer.Name);
            ps.AddParameter("NavMiddleTier", UpdateNAVCustomer.NavMiddleTier);
            ps.AddParameter("SQLServer", UpdateNAVCustomer.SQLServer);
            ps.AddParameter("LoginInfo", UpdateNAVCustomer.LoginInfo);
            ps.AddParameter("RDSServer", UpdateNAVCustomer.RDSServer);

            return this;
        }

        public MyPowerShell RemoveNAVCustomer(string Organization)
        {
            ps.AddCommand(psScriptPath + @"\RemoveNAVCustomer.ps1");
            ps.AddParameter("Organization", Organization);
            return this;
        }

        public MyPowerShell CreateNAVCustomer(CustomNAVCustomer UpdateNAVCustomer)
        {
            ps.AddCommand(psScriptPath + @"\CreateNAVCustomer.ps1");
            ps.AddParameter("Organization", UpdateNAVCustomer.Organization);
            ps.AddParameter("Platform", UpdateNAVCustomer.Platform);
            ps.AddParameter("Name", UpdateNAVCustomer.Name);
            ps.AddParameter("NavMiddleTier", UpdateNAVCustomer.NavMiddleTier);
            ps.AddParameter("SQLServer", UpdateNAVCustomer.SQLServer);
            ps.AddParameter("LoginInfo", UpdateNAVCustomer.LoginInfo);
            ps.AddParameter("RDSServer", UpdateNAVCustomer.RDSServer);

            return this;
        }

        public MyPowerShell GetCurrentNAVCustomerConf(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCurrentNAVCustomerConf.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetCASOrganizations()
        {
            ps.AddCommand(psScriptPath + @"\GetCASOrganizations.ps1");

            return this;
        }
        public MyPowerShell SetOOFMessage(CustomOOF OOF)
        {
            ps.AddCommand(psScriptPath + @"\SetOOFMessage.ps1")
            .AddParameter("Organization", OOF.Organization)
            .AddParameter("UserPrincipalName", OOF.UserPrincipalName)
            .AddParameter("StartTime", OOF.StartTime)
            .AddParameter("EndTime", OOF.EndTime)
            .AddParameter("Internal", OOF.Internal)
            .AddParameter("External", OOF.External);

            return this;
        }
        public MyPowerShell GetOOFMessage(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetOOFMessage.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public MyPowerShell RemoveOOFMessage(CustomOOF OOF)
        {
            ps.AddCommand(psScriptPath + @"\RemoveOOFMessage.ps1")
            .AddParameter("Organization", OOF.Organization)
            .AddParameter("UserPrincipalName", OOF.UserPrincipalName);

            return this;
        }
        public MyPowerShell GetAzureServices(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureServices.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureVMs(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureVMs.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureIntuneDevice(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureIntuneDevice.ps1")
            .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetAzureIntuneComplianceOverview(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureIntuneComplianceOverview.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureSecurity(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureSecurity.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureRessourceGroups(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureRessourceGroups.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureStorageAccounts(string organization, string ressourcegroupname)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureStorageAccounts.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("RessourceGroupName", ressourcegroupname);

            return this;
        }
        public MyPowerShell GetAzureVirtualNetworks(string organization, string ressourcegroupname)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureVirtualNetworks.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("RessourceGroupName", ressourcegroupname);

            return this;
        }
        public MyPowerShell GetAzureAvailabilitySets(string organization, string ressourcegroupname)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureAvailabilitySets.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("RessourceGroupName", ressourcegroupname);

            return this;
        }
        public MyPowerShell GetAzureVMSizes(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureVMSizes.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureLocations(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureLocations.ps1")
            .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell GetAzureVirtualSubnets(string organization, string name, string ressourcegroupname)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureVirtualSubnets.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("RessourceGroupName", ressourcegroupname)
            .AddParameter("Name", name);

            return this;
        }
        public MyPowerShell GetAzurePublicIPs(string organization, string location)
        {
            ps.AddCommand(psScriptPath + @"\GetAzurePublicIPs.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("Location", location);

            return this;
        }
        public MyPowerShell GetAzureNetworkInterfaces(string organization, string ressourcegroupname)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureNetworkInterfaces.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("RessourceGroupName", ressourcegroupname);

            return this;
        }

        public MyPowerShell GetAzureIntuneDeviceConfiguration(string organization, string id)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureIntuneDeviceConfiguration.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("ID", id);

            return this;
        }
        public MyPowerShell UpdateAzureIntuneDeviceConfiguration(CustomAzureDeviceConfiguration AzureDeviceConfiguration)
        {
            if (AzureDeviceConfiguration.platform == "Android")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneDeviceConfiguration.ps1")
                .AddParameter("Organization", AzureDeviceConfiguration.organization)
                .AddParameter("Platform", AzureDeviceConfiguration.platform)
                .AddParameter("DisplayName", AzureDeviceConfiguration.displayName)
                .AddParameter("Description", AzureDeviceConfiguration.description)
                .AddParameter("Id", AzureDeviceConfiguration.id)
                .AddParameter("appsBlockClipboardSharing", AzureDeviceConfiguration.appsBlockClipboardSharing)
                .AddParameter("appsBlockCopyPaste", AzureDeviceConfiguration.appsBlockCopyPaste)
                .AddParameter("appsBlockYouTube", AzureDeviceConfiguration.appsBlockYouTube)
                .AddParameter("BlueToothBlocked", AzureDeviceConfiguration.bluetoothBlocked)
                .AddParameter("CameraBlocked", AzureDeviceConfiguration.cameraBlocked)
                .AddParameter("cellularBlockDataRoaming", AzureDeviceConfiguration.cellularBlockDataRoaming)
                .AddParameter("cellularBlockMessaging", AzureDeviceConfiguration.cellularBlockMessaging)
                .AddParameter("cellularBlockVoiceRoaming", AzureDeviceConfiguration.cellularBlockVoiceRoaming)
                .AddParameter("cellularBlockWiFiTethering", AzureDeviceConfiguration.cellularBlockWiFiTethering)
                .AddParameter("locationServicesBlocked", AzureDeviceConfiguration.locationServicesBlocked)
                .AddParameter("googleAccountBlockAutoSync", AzureDeviceConfiguration.googleAccountBlockAutoSync)
                .AddParameter("googlePlayStoreBlocked", AzureDeviceConfiguration.googlePlayStoreBlocked)
                .AddParameter("NFCBlocked", AzureDeviceConfiguration.nfcBlocked)
                .AddParameter("passwordMinimumLength", AzureDeviceConfiguration.passwordMinimumLength)
                .AddParameter("passwordBlockFingerprintUnlock", AzureDeviceConfiguration.passwordBlockFingerprintUnlock)
                .AddParameter("passwordBlockTrustAgents", AzureDeviceConfiguration.passwordBlockTrustAgents)
                .AddParameter("passwordExpirationDays", AzureDeviceConfiguration.passwordExpirationDays)
                .AddParameter("passwordMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("passwordPreviousPasswordBlockCount", AzureDeviceConfiguration.passwordPreviousPasswordBlockCount)
                .AddParameter("passwordSignInFailureCountBeforeFactoryReset", AzureDeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset)
                .AddParameter("passwordRequiredType", AzureDeviceConfiguration.passwordRequiredType)
                .AddParameter("passwordRequired", AzureDeviceConfiguration.passwordRequired)
                .AddParameter("factoryResetBlocked", AzureDeviceConfiguration.factoryResetBlocked)
                .AddParameter("powerOffBlocked", AzureDeviceConfiguration.powerOffBlocked)
                .AddParameter("screenCaptureBlocked", AzureDeviceConfiguration.screenCaptureBlocked)
                .AddParameter("deviceSharingAllowed", AzureDeviceConfiguration.deviceSharingAllowed)
                .AddParameter("storageBlockGoogleBackup", AzureDeviceConfiguration.storageBlockGoogleBackup)
                .AddParameter("storageBlockRemovableStorage", AzureDeviceConfiguration.storageBlockRemovableStorage)
                .AddParameter("storageRequireDeviceEncryption", AzureDeviceConfiguration.storageRequireDeviceEncryption)
                .AddParameter("storageRequireRemovableStorageEncryption", AzureDeviceConfiguration.storageRequireRemovableStorageEncryption)
                .AddParameter("voiceAssistantBlocked", AzureDeviceConfiguration.voiceAssistantBlocked)
                .AddParameter("voiceDialingBlocked", AzureDeviceConfiguration.voiceDialingBlocked)
                .AddParameter("webBrowserBlockPopups", AzureDeviceConfiguration.webBrowserBlockPopups)
                .AddParameter("webBrowserBlockAutofill", AzureDeviceConfiguration.webBrowserBlockAutofill)
                .AddParameter("webBrowserBlockJavaScript", AzureDeviceConfiguration.webBrowserBlockJavaScript)
                .AddParameter("webBrowserBlocked", AzureDeviceConfiguration.webBrowserBlocked)
                .AddParameter("webBrowserCookieSettings", AzureDeviceConfiguration.webBrowserCookieSettings)
                .AddParameter("wiFiBlocked", AzureDeviceConfiguration.wiFiBlocked);
            }
            if (AzureDeviceConfiguration.platform == "AFW")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneDeviceConfiguration.ps1")
                .AddParameter("Organization", AzureDeviceConfiguration.organization)
                .AddParameter("Platform", AzureDeviceConfiguration.platform)
                .AddParameter("DisplayName", AzureDeviceConfiguration.displayName)
                .AddParameter("Description", AzureDeviceConfiguration.description)
                .AddParameter("Id", AzureDeviceConfiguration.id)
                .AddParameter("workProfileDataSharingType", AzureDeviceConfiguration.workProfileDataSharingType)
                .AddParameter("workProfileBlockNotificationsWhileDeviceLocked", AzureDeviceConfiguration.workProfileBlockNotificationsWhileDeviceLocked)
                .AddParameter("workProfileDefaultAppPermissionPolicy", AzureDeviceConfiguration.workProfileDefaultAppPermissionPolicy)
                .AddParameter("workProfileRequirePassword", AzureDeviceConfiguration.workProfileRequirePassword)
                .AddParameter("workProfilePasswordMinimumLength", AzureDeviceConfiguration.workProfilePasswordMinimumLength)
                .AddParameter("workProfilePasswordMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("workProfilePasswordSignInFailureCountBeforeFactoryReset", AzureDeviceConfiguration.workProfilePasswordSignInFailureCountBeforeFactoryReset)
                .AddParameter("workProfilePasswordExpirationDays", AzureDeviceConfiguration.workProfilePasswordExpirationDays)
                .AddParameter("workProfilePasswordRequiredType", AzureDeviceConfiguration.workProfilePasswordRequiredType)
                .AddParameter("workProfilePasswordPreviousPasswordBlockCount", AzureDeviceConfiguration.workProfilePasswordPreviousPasswordBlockCount)
                .AddParameter("workProfilePasswordBlockFingerprintUnlock", AzureDeviceConfiguration.workProfilePasswordBlockFingerprintUnlock)
                .AddParameter("workProfilePasswordBlockTrustAgents", AzureDeviceConfiguration.workProfilePasswordBlockTrustAgents)
                .AddParameter("afwpasswordMinimumLength", AzureDeviceConfiguration.afwpasswordMinimumLength)
                .AddParameter("afwpasswordMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.afwpasswordMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("afwpasswordSignInFailureCountBeforeFactoryReset", AzureDeviceConfiguration.afwpasswordSignInFailureCountBeforeFactoryReset)
                .AddParameter("afwpasswordExpirationDays", AzureDeviceConfiguration.afwpasswordExpirationDays)
                .AddParameter("afwpasswordRequiredType", AzureDeviceConfiguration.afwpasswordRequiredType)
                .AddParameter("afwpasswordPreviousPasswordBlockCount", AzureDeviceConfiguration.afwpasswordPreviousPasswordBlockCount)
                .AddParameter("afwpasswordBlockFingerprintUnlock", AzureDeviceConfiguration.afwpasswordBlockFingerprintUnlock)
                .AddParameter("afwpasswordBlockTrustAgents", AzureDeviceConfiguration.afwpasswordBlockTrustAgents)
                ;
            }
            if (AzureDeviceConfiguration.platform == "macOS")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneDeviceConfiguration.ps1")
                .AddParameter("Organization", AzureDeviceConfiguration.organization)
                .AddParameter("Platform", AzureDeviceConfiguration.platform)
                .AddParameter("DisplayName", AzureDeviceConfiguration.displayName)
                .AddParameter("Description", AzureDeviceConfiguration.description)
                .AddParameter("Id", AzureDeviceConfiguration.id)
                .AddParameter("macpasswordMinimumLength", AzureDeviceConfiguration.macpasswordMinimumLength)
                .AddParameter("macpasswordBlockSimple", AzureDeviceConfiguration.macpasswordBlockSimple)
                .AddParameter("macpasswordMinimumCharacterSetCount", AzureDeviceConfiguration.macpasswordMinimumCharacterSetCount)
                .AddParameter("macpasswordMinutesOfInactivityBeforeLock", AzureDeviceConfiguration.macpasswordMinutesOfInactivityBeforeLock)
                .AddParameter("macpasswordExpirationDays", AzureDeviceConfiguration.macpasswordExpirationDays)
                .AddParameter("macpasswordRequiredType", AzureDeviceConfiguration.macpasswordRequiredType)
                .AddParameter("macpasswordPreviousPasswordBlockCount", AzureDeviceConfiguration.macpasswordPreviousPasswordBlockCount)
                .AddParameter("macpasswordMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.macpasswordMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("macpasswordRequired", AzureDeviceConfiguration.macpasswordRequired)
                ;
            }
            if (AzureDeviceConfiguration.platform == "IOS")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneDeviceConfiguration.ps1")
                .AddParameter("Organization", AzureDeviceConfiguration.organization)
                .AddParameter("Platform", AzureDeviceConfiguration.platform)
                .AddParameter("DisplayName", AzureDeviceConfiguration.displayName)
                .AddParameter("Description", AzureDeviceConfiguration.description)
                .AddParameter("Id", AzureDeviceConfiguration.id)
                .AddParameter("accountBlockModification", AzureDeviceConfiguration.accountBlockModification)
                .AddParameter("activationLockAllowWhenSupervised", AzureDeviceConfiguration.activationLockAllowWhenSupervised)
                .AddParameter("airDropBlocked", AzureDeviceConfiguration.airDropBlocked)
                .AddParameter("airDropForceUnmanagedDropTarget", AzureDeviceConfiguration.airDropForceUnmanagedDropTarget)
                .AddParameter("airPlayForcePairingPasswordForOutgoingRequests", AzureDeviceConfiguration.airPlayForcePairingPasswordForOutgoingRequests)
                .AddParameter("appleWatchBlockPairing", AzureDeviceConfiguration.appleWatchBlockPairing)
                .AddParameter("appleWatchForceWristDetection", AzureDeviceConfiguration.appleWatchForceWristDetection)
                .AddParameter("appleNewsBlocked", AzureDeviceConfiguration.appleNewsBlocked)
                .AddParameter("appStoreBlockAutomaticDownloads", AzureDeviceConfiguration.appStoreBlockAutomaticDownloads)
                .AddParameter("appStoreBlocked", AzureDeviceConfiguration.appStoreBlocked)
                .AddParameter("appStoreBlockInAppPurchases", AzureDeviceConfiguration.appStoreBlockInAppPurchases)
                .AddParameter("appStoreBlockUIAppInstallation", AzureDeviceConfiguration.appStoreBlockUIAppInstallation)
                .AddParameter("appStoreRequirePassword", AzureDeviceConfiguration.appStoreRequirePassword)
                .AddParameter("bluetoothBlockModification", AzureDeviceConfiguration.bluetoothBlockModification)
                .AddParameter("ioscameraBlocked", AzureDeviceConfiguration.ioscameraBlocked)
                .AddParameter("ioscellularBlockDataRoaming", AzureDeviceConfiguration.ioscellularBlockDataRoaming)
                .AddParameter("cellularBlockGlobalBackgroundFetchWhileRoaming", AzureDeviceConfiguration.cellularBlockGlobalBackgroundFetchWhileRoaming)
                .AddParameter("cellularBlockPerAppDataModification", AzureDeviceConfiguration.cellularBlockPerAppDataModification)
                .AddParameter("cellularBlockPersonalHotspot", AzureDeviceConfiguration.cellularBlockPersonalHotspot)
                .AddParameter("ioscellularBlockVoiceRoaming", AzureDeviceConfiguration.ioscellularBlockVoiceRoaming)
                .AddParameter("certificatesBlockUntrustedTlsCertificates", AzureDeviceConfiguration.certificatesBlockUntrustedTlsCertificates)
                .AddParameter("classroomAppBlockRemoteScreenObservation", AzureDeviceConfiguration.classroomAppBlockRemoteScreenObservation)
                .AddParameter("classroomAppForceUnpromptedScreenObservation", AzureDeviceConfiguration.classroomAppForceUnpromptedScreenObservation)
                .AddParameter("configurationProfileBlockChanges", AzureDeviceConfiguration.configurationProfileBlockChanges)
                .AddParameter("definitionLookupBlocked", AzureDeviceConfiguration.definitionLookupBlocked)
                .AddParameter("deviceBlockEnableRestrictions", AzureDeviceConfiguration.deviceBlockEnableRestrictions)
                .AddParameter("deviceBlockEraseContentAndSettings", AzureDeviceConfiguration.deviceBlockEraseContentAndSettings)
                .AddParameter("deviceBlockNameModification", AzureDeviceConfiguration.deviceBlockNameModification)
                .AddParameter("diagnosticDataBlockSubmission", AzureDeviceConfiguration.diagnosticDataBlockSubmission)
                .AddParameter("diagnosticDataBlockSubmissionModification", AzureDeviceConfiguration.diagnosticDataBlockSubmissionModification)
                .AddParameter("documentsBlockManagedDocumentsInUnmanagedApps", AzureDeviceConfiguration.documentsBlockManagedDocumentsInUnmanagedApps)
                .AddParameter("documentsBlockUnmanagedDocumentsInManagedApps", AzureDeviceConfiguration.documentsBlockUnmanagedDocumentsInManagedApps)
                .AddParameter("enterpriseAppBlockTrust", AzureDeviceConfiguration.enterpriseAppBlockTrust)
                .AddParameter("enterpriseAppBlockTrustModification", AzureDeviceConfiguration.enterpriseAppBlockTrustModification)
                .AddParameter("faceTimeBlocked", AzureDeviceConfiguration.faceTimeBlocked)
                .AddParameter("findMyFriendsBlocked", AzureDeviceConfiguration.findMyFriendsBlocked)
                .AddParameter("gamingBlockGameCenterFriends", AzureDeviceConfiguration.gamingBlockGameCenterFriends)
                .AddParameter("gamingBlockMultiplayer", AzureDeviceConfiguration.gamingBlockMultiplayer)
                .AddParameter("gameCenterBlocked", AzureDeviceConfiguration.gameCenterBlocked)
                .AddParameter("hostPairingBlocked", AzureDeviceConfiguration.hostPairingBlocked)
                .AddParameter("iBooksStoreBlocked", AzureDeviceConfiguration.iBooksStoreBlocked)
                .AddParameter("iBooksStoreBlockErotica", AzureDeviceConfiguration.iBooksStoreBlockErotica)
                .AddParameter("iCloudBlockActivityContinuation", AzureDeviceConfiguration.iCloudBlockActivityContinuation)
                .AddParameter("iCloudBlockBackup", AzureDeviceConfiguration.iCloudBlockBackup)
                .AddParameter("iCloudBlockDocumentSync", AzureDeviceConfiguration.iCloudBlockDocumentSync)
                .AddParameter("iCloudBlockManagedAppsSync", AzureDeviceConfiguration.iCloudBlockManagedAppsSync)
                .AddParameter("iCloudBlockPhotoLibrary", AzureDeviceConfiguration.iCloudBlockPhotoLibrary)
                .AddParameter("iCloudBlockPhotoStreamSync", AzureDeviceConfiguration.iCloudBlockPhotoStreamSync)
                .AddParameter("iCloudBlockSharedPhotoStream", AzureDeviceConfiguration.iCloudBlockSharedPhotoStream)
                .AddParameter("iCloudRequireEncryptedBackup", AzureDeviceConfiguration.iCloudRequireEncryptedBackup)
                .AddParameter("iTunesBlockExplicitContent", AzureDeviceConfiguration.iTunesBlockExplicitContent)
                .AddParameter("iTunesBlockMusicService", AzureDeviceConfiguration.iTunesBlockMusicService)
                .AddParameter("iTunesBlockRadio", AzureDeviceConfiguration.iTunesBlockRadio)
                .AddParameter("keyboardBlockAutoCorrect", AzureDeviceConfiguration.keyboardBlockAutoCorrect)
                .AddParameter("keyboardBlockDictation", AzureDeviceConfiguration.keyboardBlockDictation)
                .AddParameter("keyboardBlockPredictive", AzureDeviceConfiguration.keyboardBlockPredictive)
                .AddParameter("keyboardBlockShortcuts", AzureDeviceConfiguration.keyboardBlockShortcuts)
                .AddParameter("keyboardBlockSpellCheck", AzureDeviceConfiguration.keyboardBlockSpellCheck)
                .AddParameter("lockScreenBlockControlCenter", AzureDeviceConfiguration.lockScreenBlockControlCenter)
                .AddParameter("lockScreenBlockNotificationView", AzureDeviceConfiguration.lockScreenBlockNotificationView)
                .AddParameter("lockScreenBlockPassbook", AzureDeviceConfiguration.lockScreenBlockPassbook)
                .AddParameter("lockScreenBlockTodayView", AzureDeviceConfiguration.lockScreenBlockTodayView)
                .AddParameter("mediaContentRatingApps", AzureDeviceConfiguration.mediaContentRatingApps)
                .AddParameter("messagesBlocked", AzureDeviceConfiguration.messagesBlocked)
                .AddParameter("notificationsBlockSettingsModification", AzureDeviceConfiguration.notificationsBlockSettingsModification)
                .AddParameter("passcodeBlockFingerprintUnlock", AzureDeviceConfiguration.passcodeBlockFingerprintUnlock)
                .AddParameter("passcodeBlockFingerprintModification", AzureDeviceConfiguration.passcodeBlockFingerprintModification)
                .AddParameter("passcodeBlockModification", AzureDeviceConfiguration.passcodeBlockModification)
                .AddParameter("passcodeBlockSimple", AzureDeviceConfiguration.passcodeBlockSimple)
                .AddParameter("passcodeExpirationDays", AzureDeviceConfiguration.passcodeExpirationDays)
                .AddParameter("passcodeMinimumLength", AzureDeviceConfiguration.passcodeMinimumLength)
                .AddParameter("passcodeMinutesOfInactivityBeforeLock", AzureDeviceConfiguration.passcodeMinutesOfInactivityBeforeLock)
                .AddParameter("passcodeMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.passcodeMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("passcodeMinimumCharacterSetCount", AzureDeviceConfiguration.passcodeMinimumCharacterSetCount)
                .AddParameter("passcodePreviousPasscodeBlockCount", AzureDeviceConfiguration.passcodePreviousPasscodeBlockCount)
                .AddParameter("passcodeSignInFailureCountBeforeWipe", AzureDeviceConfiguration.passcodeSignInFailureCountBeforeWipe)
                .AddParameter("passcodeRequiredType", AzureDeviceConfiguration.passcodeRequiredType)
                .AddParameter("passcodeRequired", AzureDeviceConfiguration.passcodeRequired)
                .AddParameter("podcastsBlocked", AzureDeviceConfiguration.podcastsBlocked)
                .AddParameter("safariBlockAutofill", AzureDeviceConfiguration.safariBlockAutofill)
                .AddParameter("safariBlockJavaScript", AzureDeviceConfiguration.safariBlockJavaScript)
                .AddParameter("safariBlockPopups", AzureDeviceConfiguration.safariBlockPopups)
                .AddParameter("safariBlocked", AzureDeviceConfiguration.safariBlocked)
                .AddParameter("safariCookieSettings", AzureDeviceConfiguration.safariCookieSettings)
                .AddParameter("safariRequireFraudWarning", AzureDeviceConfiguration.safariRequireFraudWarning)
                .AddParameter("iosscreenCaptureBlocked", AzureDeviceConfiguration.iosscreenCaptureBlocked)
                .AddParameter("siriBlocked", AzureDeviceConfiguration.siriBlocked)
                .AddParameter("siriBlockedWhenLocked", AzureDeviceConfiguration.siriBlockedWhenLocked)
                .AddParameter("siriBlockUserGeneratedContent", AzureDeviceConfiguration.siriBlockUserGeneratedContent)
                .AddParameter("siriRequireProfanityFilter", AzureDeviceConfiguration.siriRequireProfanityFilter)
                .AddParameter("spotlightBlockInternetResults", AzureDeviceConfiguration.spotlightBlockInternetResults)
                .AddParameter("iosvoiceDialingBlocked", AzureDeviceConfiguration.iosvoiceDialingBlocked)
                .AddParameter("wallpaperBlockModification", AzureDeviceConfiguration.wallpaperBlockModification)
                .AddParameter("wiFiConnectOnlyToConfiguredNetworks", AzureDeviceConfiguration.wiFiConnectOnlyToConfiguredNetworks);
            }
            if (AzureDeviceConfiguration.platform == "Win10")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneDeviceConfiguration.ps1")
                .AddParameter("Organization", AzureDeviceConfiguration.organization)
                .AddParameter("Platform", AzureDeviceConfiguration.platform)
                .AddParameter("DisplayName", AzureDeviceConfiguration.displayName)
                .AddParameter("Description", AzureDeviceConfiguration.description)
                .AddParameter("Id", AzureDeviceConfiguration.id)
                .AddParameter("winscreenCaptureBlocked", AzureDeviceConfiguration.winscreenCaptureBlocked)
                .AddParameter("copyPasteBlocked", AzureDeviceConfiguration.copyPasteBlocked)
                .AddParameter("deviceManagementBlockManualUnenroll", AzureDeviceConfiguration.deviceManagementBlockManualUnenroll)
                .AddParameter("certificatesBlockManualRootCertificateInstallation", AzureDeviceConfiguration.certificatesBlockManualRootCertificateInstallation)
                .AddParameter("wincameraBlocked", AzureDeviceConfiguration.wincameraBlocked)
                .AddParameter("oneDriveDisableFileSync", AzureDeviceConfiguration.oneDriveDisableFileSync)
                .AddParameter("winstorageBlockRemovableStorage", AzureDeviceConfiguration.winstorageBlockRemovableStorage)
                .AddParameter("winlocationServicesBlocked", AzureDeviceConfiguration.winlocationServicesBlocked)
                .AddParameter("internetSharingBlocked", AzureDeviceConfiguration.internetSharingBlocked)
                .AddParameter("deviceManagementBlockFactoryResetOnMobile", AzureDeviceConfiguration.deviceManagementBlockFactoryResetOnMobile)
                .AddParameter("usbBlocked", AzureDeviceConfiguration.usbBlocked)
                .AddParameter("antiTheftModeBlocked", AzureDeviceConfiguration.antiTheftModeBlocked)
                .AddParameter("cortanaBlocked", AzureDeviceConfiguration.cortanaBlocked)
                .AddParameter("voiceRecordingBlocked", AzureDeviceConfiguration.voiceRecordingBlocked)
                .AddParameter("settingsBlockEditDeviceName", AzureDeviceConfiguration.settingsBlockEditDeviceName)
                .AddParameter("settingsBlockAddProvisioningPackage", AzureDeviceConfiguration.settingsBlockAddProvisioningPackage)
                .AddParameter("settingsBlockRemoveProvisioningPackage", AzureDeviceConfiguration.settingsBlockRemoveProvisioningPackage)
                .AddParameter("experienceBlockDeviceDiscovery", AzureDeviceConfiguration.experienceBlockDeviceDiscovery)
                .AddParameter("experienceBlockTaskSwitcher", AzureDeviceConfiguration.experienceBlockTaskSwitcher)
                .AddParameter("experienceBlockErrorDialogWhenNoSIM", AzureDeviceConfiguration.experienceBlockErrorDialogWhenNoSIM)
                .AddParameter("winpasswordRequired", AzureDeviceConfiguration.winpasswordRequired)
                .AddParameter("winpasswordRequiredType", AzureDeviceConfiguration.winpasswordRequiredType)
                .AddParameter("winpasswordMinimumLength", AzureDeviceConfiguration.winpasswordMinimumLength)
                .AddParameter("winpasswordMinutesOfInactivityBeforeScreenTimeout", AzureDeviceConfiguration.winpasswordMinutesOfInactivityBeforeScreenTimeout)
                .AddParameter("winpasswordSignInFailureCountBeforeFactoryReset", AzureDeviceConfiguration.winpasswordSignInFailureCountBeforeFactoryReset)
                .AddParameter("winpasswordExpirationDays", AzureDeviceConfiguration.winpasswordExpirationDays)
                .AddParameter("winpasswordPreviousPasswordBlockCount", AzureDeviceConfiguration.winpasswordPreviousPasswordBlockCount)
                .AddParameter("winpasswordRequireWhenResumeFromIdleState", AzureDeviceConfiguration.winpasswordRequireWhenResumeFromIdleState)
                .AddParameter("winpasswordBlockSimple", AzureDeviceConfiguration.winpasswordBlockSimple)
                .AddParameter("storageRequireMobileDeviceEncryption", AzureDeviceConfiguration.storageRequireMobileDeviceEncryption)
                .AddParameter("personalizationDesktopImageUrl", AzureDeviceConfiguration.personalizationDesktopImageUrl)
                .AddParameter("privacyBlockInputPersonalization", AzureDeviceConfiguration.privacyBlockInputPersonalization)
                .AddParameter("privacyAutoAcceptPairingAndConsentPrompts", AzureDeviceConfiguration.privacyAutoAcceptPairingAndConsentPrompts)
                .AddParameter("lockScreenBlockActionCenterNotifications", AzureDeviceConfiguration.lockScreenBlockActionCenterNotifications)
                .AddParameter("personalizationLockScreenImageUrl", AzureDeviceConfiguration.personalizationLockScreenImageUrl)
                .AddParameter("lockScreenAllowTimeoutConfiguration", AzureDeviceConfiguration.lockScreenAllowTimeoutConfiguration)
                .AddParameter("lockScreenBlockCortana", AzureDeviceConfiguration.lockScreenBlockCortana)
                .AddParameter("lockScreenBlockToastNotifications", AzureDeviceConfiguration.lockScreenBlockToastNotifications)
                .AddParameter("lockScreenTimeoutInSeconds", AzureDeviceConfiguration.lockScreenTimeoutInSeconds)
                .AddParameter("windowsStoreBlocked", AzureDeviceConfiguration.windowsStoreBlocked)
                .AddParameter("windowsStoreBlockAutoUpdate", AzureDeviceConfiguration.windowsStoreBlockAutoUpdate)
                .AddParameter("appsAllowTrustedAppsSideloading", AzureDeviceConfiguration.appsAllowTrustedAppsSideloading)
                .AddParameter("developerUnlockSetting", AzureDeviceConfiguration.developerUnlockSetting)
                .AddParameter("sharedUserAppDataAllowed", AzureDeviceConfiguration.sharedUserAppDataAllowed)
                .AddParameter("windowsStoreEnablePrivateStoreOnly", AzureDeviceConfiguration.windowsStoreEnablePrivateStoreOnly)
                .AddParameter("appsBlockWindowsStoreOriginatedApps", AzureDeviceConfiguration.appsBlockWindowsStoreOriginatedApps)
                .AddParameter("storageRestrictAppDataToSystemVolume", AzureDeviceConfiguration.storageRestrictAppDataToSystemVolume)
                .AddParameter("storageRestrictAppInstallToSystemVolume", AzureDeviceConfiguration.storageRestrictAppInstallToSystemVolume)
                .AddParameter("gameDvrBlocked", AzureDeviceConfiguration.gameDvrBlocked)
                .AddParameter("smartScreenEnableAppInstallControl", AzureDeviceConfiguration.smartScreenEnableAppInstallControl)
                .AddParameter("edgeBlocked", AzureDeviceConfiguration.edgeBlocked)
                .AddParameter("edgeBlockAddressBarDropdown", AzureDeviceConfiguration.edgeBlockAddressBarDropdown)
                .AddParameter("edgeSyncFavoritesWithInternetExplorer", AzureDeviceConfiguration.edgeSyncFavoritesWithInternetExplorer)
                .AddParameter("edgeClearBrowsingDataOnExit", AzureDeviceConfiguration.edgeClearBrowsingDataOnExit)
                .AddParameter("edgeBlockSendingDoNotTrackHeader", AzureDeviceConfiguration.edgeBlockSendingDoNotTrackHeader)
                .AddParameter("edgeCookiePolicy", AzureDeviceConfiguration.edgeCookiePolicy)
                .AddParameter("edgeBlockJavaScript", AzureDeviceConfiguration.edgeBlockJavaScript)
                .AddParameter("edgeBlockPopups", AzureDeviceConfiguration.edgeBlockPopups)
                .AddParameter("edgeBlockSearchSuggestions", AzureDeviceConfiguration.edgeBlockSearchSuggestions)
                .AddParameter("edgeBlockSendingIntranetTrafficToInternetExplorer", AzureDeviceConfiguration.edgeBlockSendingIntranetTrafficToInternetExplorer)
                .AddParameter("edgeBlockAutofill", AzureDeviceConfiguration.edgeBlockAutofill)
                .AddParameter("edgeBlockPasswordManager", AzureDeviceConfiguration.edgeBlockPasswordManager)
                .AddParameter("edgeEnterpriseModeSiteListLocation", AzureDeviceConfiguration.edgeEnterpriseModeSiteListLocation)
                .AddParameter("edgeBlockDeveloperTools", AzureDeviceConfiguration.edgeBlockDeveloperTools)
                .AddParameter("edgeBlockExtensions", AzureDeviceConfiguration.edgeBlockExtensions)
                .AddParameter("edgeBlockInPrivateBrowsing", AzureDeviceConfiguration.edgeBlockInPrivateBrowsing)
                .AddParameter("edgeDisableFirstRunPage", AzureDeviceConfiguration.edgeDisableFirstRunPage)
                .AddParameter("edgeFirstRunUrl", AzureDeviceConfiguration.edgeFirstRunUrl)
                .AddParameter("edgeAllowStartPagesModification", AzureDeviceConfiguration.edgeAllowStartPagesModification)
                .AddParameter("edgeBlockAccessToAboutFlags", AzureDeviceConfiguration.edgeBlockAccessToAboutFlags)
                .AddParameter("webRtcBlockLocalhostIpAddress", AzureDeviceConfiguration.webRtcBlockLocalhostIpAddress)
                .AddParameter("edgeSearchEngine", AzureDeviceConfiguration.edgeSearchEngine)
                .AddParameter("edgeCustomURL", AzureDeviceConfiguration.edgeCustomURL)
                .AddParameter("edgeBlockCompatibilityList", AzureDeviceConfiguration.edgeBlockCompatibilityList)
                .AddParameter("edgeBlockLiveTileDataCollection", AzureDeviceConfiguration.edgeBlockLiveTileDataCollection)
                .AddParameter("edgeRequireSmartScreen", AzureDeviceConfiguration.edgeRequireSmartScreen)
                .AddParameter("smartScreenBlockPromptOverride", AzureDeviceConfiguration.smartScreenBlockPromptOverride)
                .AddParameter("smartScreenBlockPromptOverrideForFiles", AzureDeviceConfiguration.smartScreenBlockPromptOverrideForFiles)
                .AddParameter("safeSearchFilter", AzureDeviceConfiguration.safeSearchFilter)
                .AddParameter("microsoftAccountBlocked", AzureDeviceConfiguration.microsoftAccountBlocked)
                .AddParameter("accountsBlockAddingNonMicrosoftAccountEmail", AzureDeviceConfiguration.accountsBlockAddingNonMicrosoftAccountEmail)
                .AddParameter("microsoftAccountBlockSettingsSync", AzureDeviceConfiguration.microsoftAccountBlockSettingsSync)
                .AddParameter("cellularData", AzureDeviceConfiguration.cellularData)
                .AddParameter("cellularBlockDataWhenRoaming", AzureDeviceConfiguration.cellularBlockDataWhenRoaming)
                .AddParameter("cellularBlockVpn", AzureDeviceConfiguration.cellularBlockVpn)
                .AddParameter("cellularBlockVpnWhenRoaming", AzureDeviceConfiguration.cellularBlockVpnWhenRoaming)
                .AddParameter("winbluetoothBlocked", AzureDeviceConfiguration.winbluetoothBlocked)
                .AddParameter("bluetoothBlockDiscoverableMode", AzureDeviceConfiguration.bluetoothBlockDiscoverableMode)
                .AddParameter("bluetoothBlockPrePairing", AzureDeviceConfiguration.bluetoothBlockPrePairing)
                .AddParameter("bluetoothBlockAdvertising", AzureDeviceConfiguration.bluetoothBlockAdvertising)
                .AddParameter("connectedDevicesServiceBlocked", AzureDeviceConfiguration.connectedDevicesServiceBlocked)
                .AddParameter("winnfcBlocked", AzureDeviceConfiguration.winnfcBlocked)
                .AddParameter("winwiFiBlocked", AzureDeviceConfiguration.winwiFiBlocked)
                .AddParameter("wiFiBlockAutomaticConnectHotspots", AzureDeviceConfiguration.wiFiBlockAutomaticConnectHotspots)
                .AddParameter("wiFiBlockManualConfiguration", AzureDeviceConfiguration.wiFiBlockManualConfiguration)
                .AddParameter("wiFiScanInterval", AzureDeviceConfiguration.wiFiScanInterval)
                .AddParameter("settingsBlockSettingsApp", AzureDeviceConfiguration.settingsBlockSettingsApp)
                .AddParameter("settingsBlockSystemPage", AzureDeviceConfiguration.settingsBlockSystemPage)
                .AddParameter("settingsBlockChangePowerSleep", AzureDeviceConfiguration.settingsBlockChangePowerSleep)
                .AddParameter("settingsBlockDevicesPage", AzureDeviceConfiguration.settingsBlockDevicesPage)
                .AddParameter("settingsBlockNetworkInternetPage", AzureDeviceConfiguration.settingsBlockNetworkInternetPage)
                .AddParameter("settingsBlockPersonalizationPage", AzureDeviceConfiguration.settingsBlockPersonalizationPage)
                .AddParameter("settingsBlockAppsPage", AzureDeviceConfiguration.settingsBlockAppsPage)
                .AddParameter("settingsBlockAccountsPage", AzureDeviceConfiguration.settingsBlockAccountsPage)
                .AddParameter("settingsBlockTimeLanguagePage", AzureDeviceConfiguration.settingsBlockTimeLanguagePage)
                .AddParameter("settingsBlockChangeSystemTime", AzureDeviceConfiguration.settingsBlockChangeSystemTime)
                .AddParameter("settingsBlockChangeRegion", AzureDeviceConfiguration.settingsBlockChangeRegion)
                .AddParameter("settingsBlockChangeLanguage", AzureDeviceConfiguration.settingsBlockChangeLanguage)
                .AddParameter("settingsBlockGamingPage", AzureDeviceConfiguration.settingsBlockGamingPage)
                .AddParameter("settingsBlockEaseOfAccessPage", AzureDeviceConfiguration.settingsBlockEaseOfAccessPage)
                .AddParameter("settingsBlockPrivacyPage", AzureDeviceConfiguration.settingsBlockPrivacyPage)
                .AddParameter("settingsBlockUpdateSecurityPage", AzureDeviceConfiguration.settingsBlockUpdateSecurityPage)
                .AddParameter("defenderRequireRealTimeMonitoring", AzureDeviceConfiguration.defenderRequireRealTimeMonitoring)
                .AddParameter("defenderRequireBehaviorMonitoring", AzureDeviceConfiguration.defenderRequireBehaviorMonitoring)
                .AddParameter("defenderRequireNetworkInspectionSystem", AzureDeviceConfiguration.defenderRequireNetworkInspectionSystem)
                .AddParameter("defenderScanDownloads", AzureDeviceConfiguration.defenderScanDownloads)
                .AddParameter("defenderScanScriptsLoadedInInternetExplorer", AzureDeviceConfiguration.defenderScanScriptsLoadedInInternetExplorer)
                .AddParameter("defenderBlockEndUserAccess", AzureDeviceConfiguration.defenderBlockEndUserAccess)
                .AddParameter("defenderSignatureUpdateIntervalInHours", AzureDeviceConfiguration.defenderSignatureUpdateIntervalInHours)
                .AddParameter("defenderMonitorFileActivity", AzureDeviceConfiguration.defenderMonitorFileActivity)
                .AddParameter("defenderDaysBeforeDeletingQuarantinedMalware", AzureDeviceConfiguration.defenderDaysBeforeDeletingQuarantinedMalware)
                .AddParameter("defenderScanMaxCpu", AzureDeviceConfiguration.defenderScanMaxCpu)
                .AddParameter("defenderScanArchiveFiles", AzureDeviceConfiguration.defenderScanArchiveFiles)
                .AddParameter("defenderScanIncomingMail", AzureDeviceConfiguration.defenderScanIncomingMail)
                .AddParameter("defenderScanRemovableDrivesDuringFullScan", AzureDeviceConfiguration.defenderScanRemovableDrivesDuringFullScan)
                .AddParameter("defenderScanMappedNetworkDrivesDuringFullScan", AzureDeviceConfiguration.defenderScanMappedNetworkDrivesDuringFullScan)
                .AddParameter("defenderScanNetworkFiles", AzureDeviceConfiguration.defenderScanNetworkFiles)
                .AddParameter("defenderRequireCloudProtection", AzureDeviceConfiguration.defenderRequireCloudProtection)
                .AddParameter("defenderPromptForSampleSubmission", AzureDeviceConfiguration.defenderPromptForSampleSubmission)
                .AddParameter("defenderScheduledQuickScanTime", AzureDeviceConfiguration.defenderScheduledQuickScanTime)
                .AddParameter("defenderScanType", AzureDeviceConfiguration.defenderScanType)
                .AddParameter("defenderSystemScanSchedule", AzureDeviceConfiguration.defenderSystemScanSchedule)
                .AddParameter("defenderScheduledScanTime", AzureDeviceConfiguration.defenderScheduledScanTime)
                .AddParameter("defenderPotentiallyUnwantedAppAction", AzureDeviceConfiguration.defenderPotentiallyUnwantedAppAction)
                .AddParameter("defenderDetectedMalwareActions", AzureDeviceConfiguration.defenderDetectedMalwareActions)
                .AddParameter("defenderlowseverity", AzureDeviceConfiguration.defenderlowseverity)
                .AddParameter("defendermoderateseverity", AzureDeviceConfiguration.defendermoderateseverity)
                .AddParameter("defenderhighseverity", AzureDeviceConfiguration.defenderhighseverity)
                .AddParameter("defendersevereseverity", AzureDeviceConfiguration.defendersevereseverity)
                .AddParameter("startBlockUnpinningAppsFromTaskbar", AzureDeviceConfiguration.startBlockUnpinningAppsFromTaskbar)
                .AddParameter("logonBlockFastUserSwitching", AzureDeviceConfiguration.logonBlockFastUserSwitching)
                .AddParameter("startMenuHideFrequentlyUsedApps", AzureDeviceConfiguration.startMenuHideFrequentlyUsedApps)
                .AddParameter("startMenuHideRecentlyAddedApps", AzureDeviceConfiguration.startMenuHideRecentlyAddedApps)
                .AddParameter("startMenuMode", AzureDeviceConfiguration.startMenuMode)
                .AddParameter("startMenuHideRecentJumpLists", AzureDeviceConfiguration.startMenuHideRecentJumpLists)
                .AddParameter("startMenuAppListVisibility", AzureDeviceConfiguration.startMenuAppListVisibility)
                .AddParameter("startMenuHidePowerButton", AzureDeviceConfiguration.startMenuHidePowerButton)
                .AddParameter("startMenuHideUserTile", AzureDeviceConfiguration.startMenuHideUserTile)
                .AddParameter("startMenuHideLock", AzureDeviceConfiguration.startMenuHideLock)
                .AddParameter("startMenuHideSignOut", AzureDeviceConfiguration.startMenuHideSignOut)
                .AddParameter("startMenuHideShutDown", AzureDeviceConfiguration.startMenuHideShutDown)
                .AddParameter("startMenuHideSleep", AzureDeviceConfiguration.startMenuHideSleep)
                .AddParameter("startMenuHideHibernate", AzureDeviceConfiguration.startMenuHideHibernate)
                .AddParameter("startMenuHideSwitchAccount", AzureDeviceConfiguration.startMenuHideSwitchAccount)
                .AddParameter("startMenuHideRestartOptions", AzureDeviceConfiguration.startMenuHideRestartOptions)
                .AddParameter("startMenuPinnedFolderDocuments", AzureDeviceConfiguration.startMenuPinnedFolderDocuments)
                .AddParameter("startMenuPinnedFolderDownloads", AzureDeviceConfiguration.startMenuPinnedFolderDownloads)
                .AddParameter("startMenuPinnedFolderFileExplorer", AzureDeviceConfiguration.startMenuPinnedFolderFileExplorer)
                .AddParameter("startMenuPinnedFolderHomeGroup", AzureDeviceConfiguration.startMenuPinnedFolderHomeGroup)
                .AddParameter("startMenuPinnedFolderMusic", AzureDeviceConfiguration.startMenuPinnedFolderMusic)
                .AddParameter("startMenuPinnedFolderNetwork", AzureDeviceConfiguration.startMenuPinnedFolderNetwork)
                .AddParameter("startMenuPinnedFolderPersonalFolder", AzureDeviceConfiguration.startMenuPinnedFolderPersonalFolder)
                .AddParameter("startMenuPinnedFolderPictures", AzureDeviceConfiguration.startMenuPinnedFolderPictures)
                .AddParameter("startMenuPinnedFolderSettings", AzureDeviceConfiguration.startMenuPinnedFolderSettings)
                .AddParameter("startMenuPinnedFolderVideos", AzureDeviceConfiguration.startMenuPinnedFolderVideos)
                ;
            }

                return this;
        }
        public MyPowerShell GetAzureIntuneComplianceSetting(string organization, string id)
        {
            ps.AddCommand(psScriptPath + @"\GetAzureIntuneComplianceSetting.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("ID", id);

            return this;
        }
        public MyPowerShell UpdateAzureIntuneComplianceSetting(CustomAzureDeviceComplianceSetting AzureDeviceComplianceSetting)
        {
            if (AzureDeviceComplianceSetting.platform == "Android")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneComplianceSetting.ps1")
                .AddParameter("Organization", AzureDeviceComplianceSetting.organization)
                .AddParameter("Platform", AzureDeviceComplianceSetting.platform)
                .AddParameter("DisplayName", AzureDeviceComplianceSetting.displayName)
                .AddParameter("Description", AzureDeviceComplianceSetting.description)
                .AddParameter("Id", AzureDeviceComplianceSetting.id)
                .AddParameter("securityBlockJailbrokenDevices", AzureDeviceComplianceSetting.securityBlockJailbrokenDevices)
                .AddParameter("deviceThreatProtectionRequiredSecurityLevel", AzureDeviceComplianceSetting.deviceThreatProtectionRequiredSecurityLevel)
                .AddParameter("osMinimumVersion", AzureDeviceComplianceSetting.osMinimumVersion)
                .AddParameter("osMaximumVersion", AzureDeviceComplianceSetting.osMaximumVersion)
                .AddParameter("passwordRequired", AzureDeviceComplianceSetting.passwordRequired)
                .AddParameter("passwordMinimumLength", AzureDeviceComplianceSetting.passwordMinimumLength)
                .AddParameter("passwordRequiredType", AzureDeviceComplianceSetting.passwordRequiredType)
                .AddParameter("passwordMinutesOfInactivityBeforeLock", AzureDeviceComplianceSetting.passwordMinutesOfInactivityBeforeLock)
                .AddParameter("passwordExpirationDays", AzureDeviceComplianceSetting.passwordExpirationDays)
                .AddParameter("passwordPreviousPasswordBlockCount", AzureDeviceComplianceSetting.passwordPreviousPasswordBlockCount)
                .AddParameter("storageRequireEncryption", AzureDeviceComplianceSetting.storageRequireEncryption)
                .AddParameter("securityPreventInstallAppsFromUnknownSources", AzureDeviceComplianceSetting.securityPreventInstallAppsFromUnknownSources)
                .AddParameter("securityDisableUsbDebugging", AzureDeviceComplianceSetting.securityDisableUsbDebugging)
                .AddParameter("minAndroidSecurityPatchLevel", AzureDeviceComplianceSetting.minAndroidSecurityPatchLevel)
                ;
            }
            if (AzureDeviceComplianceSetting.platform == "AFW")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneComplianceSetting.ps1")
                .AddParameter("Organization", AzureDeviceComplianceSetting.organization)
                .AddParameter("Platform", AzureDeviceComplianceSetting.platform)
                .AddParameter("DisplayName", AzureDeviceComplianceSetting.displayName)
                .AddParameter("Description", AzureDeviceComplianceSetting.description)
                .AddParameter("Id", AzureDeviceComplianceSetting.id)
                .AddParameter("afwsecurityBlockJailbrokenDevices", AzureDeviceComplianceSetting.afwsecurityBlockJailbrokenDevices)
                .AddParameter("afwdeviceThreatProtectionRequiredSecurityLevel", AzureDeviceComplianceSetting.afwdeviceThreatProtectionRequiredSecurityLevel)
                .AddParameter("afwosMinimumVersion", AzureDeviceComplianceSetting.afwosMinimumVersion)
                .AddParameter("afwosMaximumVersion", AzureDeviceComplianceSetting.afwosMaximumVersion)
                .AddParameter("afwpasswordRequired", AzureDeviceComplianceSetting.afwpasswordRequired)
                .AddParameter("afwpasswordMinimumLength", AzureDeviceComplianceSetting.afwpasswordMinimumLength)
                .AddParameter("afwpasswordRequiredType", AzureDeviceComplianceSetting.afwpasswordRequiredType)
                .AddParameter("afwpasswordMinutesOfInactivityBeforeLock", AzureDeviceComplianceSetting.afwpasswordMinutesOfInactivityBeforeLock)
                .AddParameter("afwpasswordExpirationDays", AzureDeviceComplianceSetting.afwpasswordExpirationDays)
                .AddParameter("afwpasswordPreviousPasswordBlockCount", AzureDeviceComplianceSetting.afwpasswordPreviousPasswordBlockCount)
                .AddParameter("afwstorageRequireEncryption", AzureDeviceComplianceSetting.afwstorageRequireEncryption)
                .AddParameter("afwsecurityPreventInstallAppsFromUnknownSources", AzureDeviceComplianceSetting.afwsecurityPreventInstallAppsFromUnknownSources)
                .AddParameter("afwsecurityDisableUsbDebugging", AzureDeviceComplianceSetting.afwsecurityDisableUsbDebugging)
                .AddParameter("afwminAndroidSecurityPatchLevel", AzureDeviceComplianceSetting.afwminAndroidSecurityPatchLevel)
                ;
            }
            if (AzureDeviceComplianceSetting.platform == "IOS")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneComplianceSetting.ps1")
                .AddParameter("Organization", AzureDeviceComplianceSetting.organization)
                .AddParameter("Platform", AzureDeviceComplianceSetting.platform)
                .AddParameter("DisplayName", AzureDeviceComplianceSetting.displayName)
                .AddParameter("Description", AzureDeviceComplianceSetting.description)
                .AddParameter("Id", AzureDeviceComplianceSetting.id)
                .AddParameter("managedEmailProfileRequired", AzureDeviceComplianceSetting.managedEmailProfileRequired)
                .AddParameter("iossecurityBlockJailbrokenDevices", AzureDeviceComplianceSetting.iossecurityBlockJailbrokenDevices)
                .AddParameter("iosdeviceThreatProtectionRequiredSecurityLevel", AzureDeviceComplianceSetting.iosdeviceThreatProtectionRequiredSecurityLevel)
                .AddParameter("iososMinimumVersion", AzureDeviceComplianceSetting.iososMinimumVersion)
                .AddParameter("iososMaximumVersion", AzureDeviceComplianceSetting.iososMaximumVersion)
                .AddParameter("passcodeRequired", AzureDeviceComplianceSetting.passcodeRequired)
                .AddParameter("passcodeBlockSimple", AzureDeviceComplianceSetting.passcodeBlockSimple)
                .AddParameter("passcodeMinimumLength", AzureDeviceComplianceSetting.passcodeMinimumLength)
                .AddParameter("passcodeRequiredType", AzureDeviceComplianceSetting.passcodeRequiredType)
                .AddParameter("passcodeMinimumCharacterSetCount", AzureDeviceComplianceSetting.passcodeMinimumCharacterSetCount)
                .AddParameter("passcodeMinutesOfInactivityBeforeLock", AzureDeviceComplianceSetting.passcodeMinutesOfInactivityBeforeLock)
                .AddParameter("passcodeExpirationDays", AzureDeviceComplianceSetting.passcodeExpirationDays)
                .AddParameter("passcodePreviousPasscodeBlockCount", AzureDeviceComplianceSetting.passcodePreviousPasscodeBlockCount)
                ;
            }
            if (AzureDeviceComplianceSetting.platform == "Win10")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneComplianceSetting.ps1")
                .AddParameter("Organization", AzureDeviceComplianceSetting.organization)
                .AddParameter("Platform", AzureDeviceComplianceSetting.platform)
                .AddParameter("DisplayName", AzureDeviceComplianceSetting.displayName)
                .AddParameter("Description", AzureDeviceComplianceSetting.description)
                .AddParameter("Id", AzureDeviceComplianceSetting.id)
                .AddParameter("bitLockerEnabled", AzureDeviceComplianceSetting.bitLockerEnabled)
                .AddParameter("secureBootEnabled", AzureDeviceComplianceSetting.secureBootEnabled)
                .AddParameter("codeIntegrityEnabled", AzureDeviceComplianceSetting.codeIntegrityEnabled)
                .AddParameter("winosMinimumVersion", AzureDeviceComplianceSetting.winosMinimumVersion)
                .AddParameter("winosMaximumVersion", AzureDeviceComplianceSetting.winosMaximumVersion)
                .AddParameter("mobileOsMinimumVersion", AzureDeviceComplianceSetting.mobileOsMinimumVersion)
                .AddParameter("mobileOsMaximumVersion", AzureDeviceComplianceSetting.mobileOsMaximumVersion)
                .AddParameter("winpasswordRequired", AzureDeviceComplianceSetting.winpasswordRequired)
                .AddParameter("passwordBlockSimple", AzureDeviceComplianceSetting.passwordBlockSimple)
                .AddParameter("winpasswordRequiredType", AzureDeviceComplianceSetting.winpasswordRequiredType)
                .AddParameter("winpasswordMinimumLength", AzureDeviceComplianceSetting.winpasswordMinimumLength)
                .AddParameter("winpasswordMinutesOfInactivityBeforeLock", AzureDeviceComplianceSetting.winpasswordMinutesOfInactivityBeforeLock)
                .AddParameter("winpasswordExpirationDays", AzureDeviceComplianceSetting.winpasswordExpirationDays)
                .AddParameter("winpasswordPreviousPasswordBlockCount", AzureDeviceComplianceSetting.winpasswordPreviousPasswordBlockCount)
                .AddParameter("winpasswordRequiredToUnlockFromIdle", AzureDeviceComplianceSetting.winpasswordRequiredToUnlockFromIdle)
                .AddParameter("winstorageRequireEncryption", AzureDeviceComplianceSetting.winstorageRequireEncryption)
                ;
            }
            if (AzureDeviceComplianceSetting.platform == "macOS")
            {
                ps.AddCommand(psScriptPath + @"\UpdateAzureIntuneComplianceSetting.ps1")
                .AddParameter("Organization", AzureDeviceComplianceSetting.organization)
                .AddParameter("Platform", AzureDeviceComplianceSetting.platform)
                .AddParameter("DisplayName", AzureDeviceComplianceSetting.displayName)
                .AddParameter("Description", AzureDeviceComplianceSetting.description)
                .AddParameter("Id", AzureDeviceComplianceSetting.id)
                .AddParameter("systemIntegrityProtectionEnabled", AzureDeviceComplianceSetting.systemIntegrityProtectionEnabled)
                .AddParameter("macosMinimumVersion", AzureDeviceComplianceSetting.macosMinimumVersion)
                .AddParameter("macosMaximumVersion", AzureDeviceComplianceSetting.macosMaximumVersion)
                .AddParameter("macpasswordRequired", AzureDeviceComplianceSetting.macpasswordRequired)
                .AddParameter("macpasswordMinimumLength", AzureDeviceComplianceSetting.macpasswordMinimumLength)
                .AddParameter("macpasswordRequiredType", AzureDeviceComplianceSetting.macpasswordRequiredType)
                .AddParameter("macpasswordMinutesOfInactivityBeforeLock", AzureDeviceComplianceSetting.macpasswordMinutesOfInactivityBeforeLock)
                .AddParameter("macpasswordExpirationDays", AzureDeviceComplianceSetting.macpasswordExpirationDays)
                .AddParameter("macpasswordPreviousPasswordBlockCount", AzureDeviceComplianceSetting.macpasswordPreviousPasswordBlockCount)
                .AddParameter("macstorageRequireEncryption", AzureDeviceComplianceSetting.macstorageRequireEncryption)
                .AddParameter("macpasswordMinimumCharacterSetCount", AzureDeviceComplianceSetting.macpasswordMinimumCharacterSetCount)
                ;
            }

            return this;
        }

        public MyPowerShell CreateVM(CustomCreateVM CreateVM)
        {
            ps.AddCommand(psScriptPath + @"\CreateAzureVM.ps1");
            ps.AddParameter("Name", CreateVM.Name);
            ps.AddParameter("Organization", CreateVM.Organization);
            ps.AddParameter("Location", CreateVM.Location);
            ps.AddParameter("Subnet", CreateVM.Subnet);
            ps.AddParameter("RessourceGroupName", CreateVM.RessourceGroupName);
            ps.AddParameter("StorageAccount", CreateVM.StorageAccount);
            ps.AddParameter("VirtualNetwork", CreateVM.VirtualNetwork);
            ps.AddParameter("NetworkInterface", CreateVM.NetworkInterface);
            ps.AddParameter("PublicIP", CreateVM.PublicIP);
            ps.AddParameter("AvailabilitySet", CreateVM.AvailabilitySet);
            ps.AddParameter("VMSize", CreateVM.VmSize);

            return this;
        }
        public MyPowerShell CreateAzurePIP(CustomCreateAzurePIP CreateAzurePIP)
        {
            ps.AddCommand(psScriptPath + @"\CreateAzurePIP.ps1");
            ps.AddParameter("Organization", CreateAzurePIP.Organization);
            ps.AddParameter("Name", CreateAzurePIP.Name);
            ps.AddParameter("RessourceGroupName", CreateAzurePIP.RessourceGroupName);
            ps.AddParameter("AllocationMethod", CreateAzurePIP.AllocationMethod);
            ps.AddParameter("Version", CreateAzurePIP.Version);
            ps.AddParameter("Location", CreateAzurePIP.Location);

            return this;
        }

        public MyPowerShell RemoveScheduledJobs(string[] jobs)
        {
            ps.AddCommand(psScriptPath + @"\RemoveScheduledJobs.ps1");
            ps.AddParameter("Id", jobs);

            return this;
        }

        public MyPowerShell CreateDefaultIntuneConfiguration(CustomCreateDefaultIntuneConfiguration CreateDefaultIntuneConfiguration)
        {
            ps.AddCommand(psScriptPath + @"\CreateDefaultIntuneConfiguration.ps1");
            ps.AddParameter("Organization", CreateDefaultIntuneConfiguration.Organization);

            return this;
        }

        public MyPowerShell GetIntuneOverview(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetIntuneOverview.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell CreateCrayonTenant(CustomCrayonTenant CrayonTenant)
        {
            ps.AddCommand(psScriptPath + @"\NewCrayonTenant.ps1");
            ps.AddParameter("Name", CrayonTenant.Name);
            ps.AddParameter("DomainPrefix", CrayonTenant.DomainPrefix);
            ps.AddParameter("Reference", CrayonTenant.Reference);
            ps.AddParameter("InvoiceProfile", CrayonTenant.InvoiceProfile);
            ps.AddParameter("FirstName", CrayonTenant.FirstName);
            ps.AddParameter("LastName", CrayonTenant.LastName);
            ps.AddParameter("Email", CrayonTenant.Email);
            ps.AddParameter("PhoneNumber", CrayonTenant.PhoneNumber);
            ps.AddParameter("CustomerFirstName", CrayonTenant.CustomerFirstName);
            ps.AddParameter("CustomerLastName", CrayonTenant.CustomerLastName);
            ps.AddParameter("AddressLine1", CrayonTenant.AddressLine1);
            ps.AddParameter("City", CrayonTenant.City);
            ps.AddParameter("Region", CrayonTenant.Region);
            ps.AddParameter("PostalCode", CrayonTenant.PostalCode);

            return this;
        }

        public MyPowerShell GetCrayonInvoiceProfiles()
        {
            ps.AddCommand(psScriptPath + @"\GetCrayonInvoiceProfiles.ps1");

            return this;
        }
        public MyPowerShell CreatePSAppRegistration(string organization)
        {
            ps.AddCommand(psScriptPath + @"\CreatePSAppRegistration.ps1")
                .AddParameter("Organization", organization);

            return this;
        }
        public MyPowerShell SetCloudAdminPassword(string organization)
        {
            ps.AddCommand(psScriptPath + @"\SetCloudAdminPassword.ps1")
                .AddParameter("Organization", organization);

            return this;
        }
    }
}