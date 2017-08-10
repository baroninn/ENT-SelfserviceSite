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

        /* public MyPowerShell RemoveCalendarPermissions(CustomCalendarPermissions calendarPermissions)
         {
             ps.AddCommand(psScriptPath + @"\Remove-CalendarPermissions.ps1");
             ps.AddParameter("Organization", calendarPermissions.Organization);
             ps.AddParameter("UserPrincipalName", calendarPermissions.UserPrincipalName);
             ps.AddParameter("User", calendarPermissions.User);

             return this;
         }*/

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

        public MyPowerShell CreateOrganization(string initials, string name, string emaildomainname, string subnet, string vlan, string gateway, string ipaddressrangestart, string ipaddressrangeend, bool createvmm)
        {
            ps.AddCommand(psScriptPath + @"\CreateOrganization.ps1")
                
                .AddParameter("Initials", initials)
                .AddParameter("Name", name)
                .AddParameter("EmailDomainName", emaildomainname)
                .AddParameter("Subnet", subnet)
                .AddParameter("Vlan", vlan)
                .AddParameter("Gateway", gateway)
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

        public MyPowerShell StartDirSync(string organization, string policy)
        {
            ps.AddCommand(psScriptPath + @"\StartDirSync.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Policy", policy);
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

        public MyPowerShell UpdateSharedCustomer(CustomSharedCustomer UpdateSharedCustomer)
        {
            ps.AddCommand(psScriptPath + @"\UpdateSharedCustomer.ps1");
            ps.AddParameter("Organization", UpdateSharedCustomer.Organization);
            ps.AddParameter("Name", UpdateSharedCustomer.Name);
            ps.AddParameter("NavMiddleTier", UpdateSharedCustomer.NavMiddleTier);
            ps.AddParameter("SQLServer", UpdateSharedCustomer.SQLServer);

            return this;
        }

        public MyPowerShell RemoveSharedCustomer(string Organization)
        {
            ps.AddCommand(psScriptPath + @"\RemoveSharedCustomer.ps1");
            ps.AddParameter("Organization", Organization);
            return this;
        }

        public MyPowerShell CreateSharedCustomer(CustomSharedCustomer UpdateSharedCustomer)
        {
            ps.AddCommand(psScriptPath + @"\CreateSharedCustomer.ps1");
            ps.AddParameter("Organization", UpdateSharedCustomer.Organization);
            ps.AddParameter("Name", UpdateSharedCustomer.Name);
            ps.AddParameter("NavMiddleTier", UpdateSharedCustomer.NavMiddleTier);
            ps.AddParameter("SQLServer", UpdateSharedCustomer.SQLServer);

            return this;
        }

        public MyPowerShell GetCurrentSharedCustomerConf(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCurrentSharedCustomerConf.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public MyPowerShell GetCASOrganizations()
        {
            ps.AddCommand(psScriptPath + @"\GetCASOrganizations.ps1");

            return this;
        }
    }
}