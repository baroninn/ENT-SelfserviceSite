using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using ColumbusPortal.Models;
using System.Management.Automation;

namespace ColumbusPortal.Logic
{
    public class CPOMyPowerShell : IDisposable
    {
        private string psScriptPath = WebConfigurationManager.AppSettings["CPOScriptPath"].ToString();
        private PowerShell ps = PowerShell.Create(RunspaceMode.NewRunspace);

        public CPOMyPowerShell()
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
        public CPOMyPowerShell AddScript(string script)
        {
            ps.AddScript(script);
            return this;
        }

        public CPOMyPowerShell AddScript(string script, params object[] args)
        {
            ps.AddScript(string.Format(script, args));
            return this;
        }

        public CPOMyPowerShell AddCommand(string command)
        {
            ps.AddCommand(command);
            return this;
        }
        public CPOMyPowerShell AddParameter(string parameter, object value)
        {
            ps.AddParameter(parameter, value);
            return this;
        }
        public CPOMyPowerShell AddParameter(string parameter)
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
        public CPOMyPowerShell CreateUser(CustomCPOUser user)
        {
            ps.AddCommand(psScriptPath + @"\CreateUser.ps1");
            ps.AddParameter("Organization", user.Organization);
            ps.AddParameter("FirstName", user.FirstName.Trim());
            ps.AddParameter("LastName", user.LastName.Trim());
            ps.AddParameter("UserPrincipalName", user.UserPrincipalName.Trim());
            ps.AddParameter("Password", user.Password);
            ps.AddParameter("DomainName", user.DomainName);

            if (user.EmailAddresses.Count > 0) { ps.AddParameter("EmailAlias", user.EmailAddresses); }
            if (user.TestUser) { ps.AddParameter("TestUser", true); }
            if (user.PasswordNeverExpires) { ps.AddParameter("PasswordNeverExpires", true); }
            if (user.StudJur) { ps.AddParameter("StudJur", true); }
            if (user.MailOnly) { ps.AddParameter("MailOnly", true); }

            return this;
        }

        /// <summary>
        /// Disable a user account
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public CPOMyPowerShell DisableUser(CustomCPOUser user)
        {
            if (!(user.Disable || user.HideFromAddressList || user.Remove)) { throw new Exception("Missing action Disable/HideFromAddressList/Delete. Can't do nothing."); }

            ps.AddCommand(psScriptPath + @"\DisableUser.ps1");
            ps.AddParameter("Organization", user.Organization);
            ps.AddParameter("UserPrincipalName", user.UserPrincipalName);
            if (user.Disable) { ps.AddParameter("Disable"); }
            if (user.HideFromAddressList) { ps.AddParameter("HideFromAddressList"); }
            if (user.Remove) { ps.AddParameter("Delete"); }

            return this;
        }

        /// <summary>
        /// Completely remove a user
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public CPOMyPowerShell RemoveUser(CustomCPOUser user)
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
        public CPOMyPowerShell AddAlias(CustomCPOAlias addAlias)
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
        public CPOMyPowerShell GetAcceptedDomain(string organization)
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
        public CPOMyPowerShell GetTenantInformation(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetTenantInformation.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        /// <summary>
        /// Removes alias from user
        /// </summary>
        /// <param name="removeAlias"></param>
        /// <returns></returns>
        public CPOMyPowerShell RemoveAlias(CustomCPOAlias removeAlias)
        {
            ps.AddCommand(psScriptPath + @"\RemoveAlias.ps1");
            ps.AddParameter("Organization", removeAlias.Organization);
            ps.AddParameter("UserPrincipalName", removeAlias.UserPrincipalName);
            ps.AddParameter("EmailAddresses", removeAlias.EmailAddresses);

            return this;
        }

        public CPOMyPowerShell GetExistingAliases(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetExistingAliases.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public CPOMyPowerShell GetMailboxes(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxes.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell AddMailboxPermission(CustomCPOMailboxPermission addMailboxPermission)
        {
            ps.AddCommand(psScriptPath + @"\AddMailboxPermission.ps1");
            ps.AddParameter("Organization", addMailboxPermission.Organization);
            ps.AddParameter("UserPrincipalName", addMailboxPermission.UserPrincipalName);
            if (addMailboxPermission.FullAccess) { ps.AddParameter("FullAccess"); }
            if (addMailboxPermission.SendAs) { ps.AddParameter("SendAs"); }

            return this;
        }

        public CPOMyPowerShell CreateBatch(List<CustomCPOUser> userList, bool PasswordNeverExpires)
        {
            List<PSObject> newUserList = new List<PSObject>();

            foreach (CustomCPOUser user in userList)
            {
                PSObject newObj = new PSObject();

                newObj.Members.Add(new PSNoteProperty("TenantName", user.Organization));
                newObj.Members.Add(new PSNoteProperty("PrimarySmtpAddress", user.UserPrincipalName));
                newObj.Members.Add(new PSNoteProperty("FirstName", user.FirstName));
                newObj.Members.Add(new PSNoteProperty("LastName", user.LastName));
                newObj.Members.Add(new PSNoteProperty("Password", user.Password));
                newObj.Members.Add(new PSNoteProperty("EmailAlias", user.EmailAddresses));
                newObj.Members.Add(new PSNoteProperty("PasswordNeverExpires", PasswordNeverExpires));
                newObj.Members.Add(new PSNoteProperty("TestUser", false));

                newUserList.Add(newObj);
            }

            ps.AddCommand(psScriptPath + @"\CreateBatch.ps1");
            ps.AddParameter("UserList", newUserList);

            return this;
        }

        public CPOMyPowerShell CreateMailbox(CustomCPOMailbox newMailbox)
        {
            ps.AddCommand(psScriptPath + @"\CreateMailbox.ps1");
            ps.AddParameter("Organization", newMailbox.Organization);
            ps.AddParameter("Name", newMailbox.Name);
            ps.AddParameter("PrimarySmtpAddress", newMailbox.UserPrincipalName);
            ps.AddParameter("Type", newMailbox.Type);
            if (newMailbox.EmailAddresses.Count > 0) { ps.AddParameter("EmailAddresses", newMailbox.EmailAddresses); }

            return this;
        }

        /*public CPOMyPowerShell CustomerReportTest()
        {
            ps.AddCommand("C:\\Scripts\\GetReportTest.ps1");
            return this;
        }*/

        public CPOMyPowerShell CreateDistributionGroup(CustomCPODistributionGroup newDistributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\CreateDistributionGroup.ps1");
            ps.AddParameter("Organization", newDistributionGroup.Organization);
            ps.AddParameter("Name", newDistributionGroup.Name);
            ps.AddParameter("PrimarySmtpAddress", newDistributionGroup.UserPrincipalName);
            ps.AddParameter("ManagedBy", newDistributionGroup.ManagedBy);
            ps.AddParameter("RequireSenderAuthentication", newDistributionGroup.RequireSenderAuthentication);
            return this;
        }

        public CPOMyPowerShell AddDistributionGroupManager(CustomCPODistributionGroup distributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\Add-DistributionGroupManager.ps1");
            ps.AddParameter("Organization", distributionGroup.Organization);
            ps.AddParameter("Group", distributionGroup.PrimarySmtpAddress);
            ps.AddParameter("Manager", distributionGroup.ManagedBy);

            return this;
        }


        public CPOMyPowerShell SetMailforward(CustomCPOMailforward mailforward)
        {
            ps.AddCommand(psScriptPath + @"\SetMailforward.ps1");
            ps.AddParameter("Organization", mailforward.Organization);
            ps.AddParameter("UserPrincipalName", mailforward.UserPrincipalName);
            ps.AddParameter("ForwardingAddress", mailforward.ForwardingSmtpAddress);
            ps.AddParameter("ForwardingType", mailforward.ForwardingType);
            if (mailforward.DeliverToMailboxAndForward) { ps.AddParameter("DeliverToMailboxAndForward", true); }

            return this;
        }

        public CPOMyPowerShell GetMailforward(string organization, string userPrincipalName)
        {
            ps.AddCommand(psScriptPath + @"\GetMailforward.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userPrincipalName);

            return this;
        }

        public CPOMyPowerShell CreateServiceUser(CustomCPOServiceUser serviceUser)
        {
            ps.AddCommand(psScriptPath + @"\CreateServiceUser.ps1");
            ps.AddParameter("Organization", serviceUser.Organization);
            ps.AddParameter("Service", serviceUser.Service);
            ps.AddParameter("Description", serviceUser.Description);
            ps.AddParameter("Password", serviceUser.Password);
            if (serviceUser.Management) { ps.AddParameter("Management"); }

            return this;
        }

        public CPOMyPowerShell GetMailboxPlans(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxPlans.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell GetMailboxPlan(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetMailboxPlan.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public CPOMyPowerShell SetMailboxPlan(CustomCPOMailboxPlan mailboxPlan)
        {
            ps.AddCommand(psScriptPath + @"\SetMailboxPlan.ps1");
            ps.AddParameter("Organization", mailboxPlan.Organization);
            ps.AddParameter("UserPrincipalName", mailboxPlan.UserPrincipalName);
            ps.AddParameter("MailboxPlan", mailboxPlan.MailboxPlan);

            return this;
        }

        public CPOMyPowerShell SetMailboxAutoResize(CustomCPOMailboxAutoResize mailboxResize)
        {
            ps.AddCommand(psScriptPath + @"\SetMailboxAutoResize.ps1");
            ps.AddParameter("Organization", mailboxResize.Organization);
            ps.AddParameter("ExcludeFromAutoSize", mailboxResize.ExcludeFromAutoResize);

            return this;
        }

        public CPOMyPowerShell GetUserMemberOf(CustomCPOUserMemberOf memberOf)
        {
            ps.AddCommand(psScriptPath + @"\GetUserMemberOf.ps1");
            ps.AddParameter("Organization", memberOf.Organization);
            ps.AddParameter("UserPrincipalName", memberOf.UserPrincipalName);

            return this;
        }

        public CPOMyPowerShell GetDeviceReport(CustomCPODeviceReport deviceReport)
        {
            ps.AddCommand(psScriptPath + @"\GetDeviceReport.ps1");
            ps.AddParameter("Organization", deviceReport.Organization);
            ps.AddParameter("Name", deviceReport.UserPrincipalName);

            return this;
        }

        public CPOMyPowerShell GetMailContacts(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetMailContacts.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell DeleteMailContact(CustomCPOMailContact mailContact)
        {
            ps.AddCommand(psScriptPath + @"\DeleteMailContact.ps1");
            ps.AddParameter("Organization", mailContact.Organization);
            ps.AddParameter("PrimarySmtpAddress", mailContact.PrimarySmtpAddress);

            return this;
        }

        public CPOMyPowerShell DeleteDistributionGroup(CustomCPODistributionGroup distributionGroup)
        {
            ps.AddCommand(psScriptPath + @"\DeleteDistributionGroup.ps1");
            ps.AddParameter("Organization", distributionGroup.Organization);
            ps.AddParameter("PrimarySmtpAddress", distributionGroup.PrimarySmtpAddress);

            return this;
        }

        public CPOMyPowerShell GetDistributionGroups(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDistributionGroups.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell GetCalendarPermissions(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\Get-CalendarPermissions.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public CPOMyPowerShell GetMailbox(string organization, string name)
        {
            ps.AddCommand(psScriptPath + @"\GetMailbox.ps1");
            ps.AddParameter("Organization", organization);
            if (name != string.Empty)
            {
                ps.AddParameter("Name", name);
            }

            return this;
        }

        public CPOMyPowerShell SetCalendarPermissions(CustomCPOCalendarPermssions calendarPermssions)
        {
            ps.AddCommand(psScriptPath + @"\Set-CalendarPermissions.ps1");
            ps.AddParameter("Organization", calendarPermssions.Organization);
            ps.AddParameter("UserPrincipalName", calendarPermssions.UserPrincipalName);
            ps.AddParameter("User", calendarPermssions.User);
            ps.AddParameter("AccessRights", calendarPermssions.AccessRights);

            return this;
        }

        public CPOMyPowerShell RemoveCalendarPermissions(string organization, string userprincipalname, string[] users)
        {
            ps.AddCommand(psScriptPath + @"\Remove-CalendarPermissions.ps1");
            ps.AddParameter("Organization", organization);
            ps.AddParameter("UserPrincipalName", userprincipalname);
            ps.AddParameter("User", users);

            return this;
        }

        public CPOMyPowerShell SetAllMailboxPlans(CustomCPOMailboxPlan mailboxPlan)
        {
            ps.AddCommand(psScriptPath + @"\SetAllMailboxPlans.ps1");
            ps.AddParameter("Organization", mailboxPlan.Organization);
            ps.AddParameter("MailboxPlan", mailboxPlan.MailboxPlan);

            return this;
        }

        public CPOMyPowerShell RemoveMailbox(CustomCPOMailbox mailbox)
        {
            ps.AddCommand(psScriptPath + @"\Remove-Mailbox.ps1");
            ps.AddParameter("Organization", mailbox.Organization);
            ps.AddParameter("Identity", mailbox.UserPrincipalName);

            return this;
        }

        public CPOMyPowerShell CreateExtUser(CustomCPOExtUser extuser)
        {
            ps.AddCommand(psScriptPath + @"\CreateExtUser.ps1");
            ps.AddParameter("Organization", extuser.Organization);
            ps.AddParameter("Vendor", extuser.Name);
            ps.AddParameter("ExpirationDate", extuser.ExpirationDate);
            ps.AddParameter("Password", extuser.Password);

            return this;
        }

        public CPOMyPowerShell GetDefaultAcceptedDomain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetDefaultAcceptedDomain.ps1");
            ps.AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell AddMailboxPermissionFullAccess(CustomCPOMailboxPermissionFullAccess mailboxPermissionFullAccess)
        {
            ps.AddCommand(psScriptPath + @"\AddMailboxPermissionFullAccess.ps1");
            ps.AddParameter("Organization", mailboxPermissionFullAccess.Organization);
            ps.AddParameter("UserPrincipalName", mailboxPermissionFullAccess.UserPrincipalName);

            return this;
        }

        public CPOMyPowerShell EnableUser(CustomCPOUser enableUser)
        {
            ps.AddCommand(psScriptPath + @"\EnableUser.ps1");
            ps.AddParameter("Organization", enableUser.Organization);
            ps.AddParameter("UserPrincipalName", enableUser.UserPrincipalName);
            if (enableUser.Enable) { ps.AddParameter("Enable"); }
            if (enableUser.UnhideFromAddressList) { ps.AddParameter("UnhideFromAddressList"); }

            return this;
        }

        public CPOMyPowerShell CreateOrganization(string organization, string emaildomainname, string solution, string fileserver, string fileserverDriveLetter)
        {
            ps.AddCommand(psScriptPath + @"\CreateOrganization.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("EmailDomainName", emaildomainname)
                .AddParameter("Solution", solution)
                .AddParameter("FileServer", fileserver)
                .AddParameter("FileServerDriveLetter", fileserverDriveLetter);

            return this;
        }

        public CPOMyPowerShell SetNavCompanyName(string organization, string navcompanyname, bool nativedb, bool force)
        {
            ps.AddCommand(psScriptPath + @"\SetNavCompanyName.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("CompanyName", navcompanyname)
                .AddParameter("NativeDatabase", nativedb)
                .AddParameter("Force", force);

            return this;
        }

        public CPOMyPowerShell GetCustomerReportLive(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetCustomerReportLive.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell RemoveDummyDomain(string organization)
        {
            ps.AddCommand(psScriptPath + @"\RemoveDummyDomain.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell RemoveCustomer(string organization, bool removedata, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\RemoveCustomer.ps1")
                .AddParameter("Organization", organization)
                .AddParameter("RemoveData", removedata)
                .AddParameter("Confirm", confirm);


            return this;
        }

        public CPOMyPowerShell EnableCustomer(string organization)
        {
            ps.AddCommand(psScriptPath + @"\EnableCustomer.ps1")
              .AddParameter("Organization", organization);
            return this;
        }

        public CPOMyPowerShell DisableCustomer(string organization, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\DisableCustomer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Confirm", confirm);
            return this;
        }

        public CPOMyPowerShell AddUPN(string organization, string domain)
        {
            ps.AddCommand(psScriptPath + @"\AddUPNSuffix.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain);
            return this;
        }

        public CPOMyPowerShell EnableFederation(string organization, string domain)
        {
            ps.AddCommand(psScriptPath + @"\EnableFederation.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain);
            return this;
        }

        public CPOMyPowerShell Enable365Customer(string organization, string tenantid, string tenantadmin, string tenantpass)
        {
            ps.AddCommand(psScriptPath + @"\Enable365Customer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("TenantID", tenantid)
              .AddParameter("TenantAdmin", tenantadmin)
              .AddParameter("TenantPass", tenantpass);
            return this;
        }

        public CPOMyPowerShell ConvertCustomer(string organization, bool confirm)
        {
            ps.AddCommand(psScriptPath + @"\ConvertCustomer.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Confirm", confirm);
            return this;
        }

        public CPOMyPowerShell AddAcceptedDomain(string organization, string domain, bool setasupn)
        {
            ps.AddCommand(psScriptPath + @"\AddAcceptedDomain.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Domain", domain)
              .AddParameter("SetAsUPN", setasupn);
            return this;
        }

        public CPOMyPowerShell GetItemsReport(string organization, string mail, bool getall)
        {
            ps.AddCommand(psScriptPath + @"\GetItemsReport.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("Mail", mail)
              .AddParameter("GetALL", getall);
            return this;
        }

        public CPOMyPowerShell EnableSikkermail(string organization, string sendasgroup, string alias, bool remove, bool force, bool updateall)
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

        public CPOMyPowerShell GetSendAsGroups(string organization)
        {
            ps.AddCommand(psScriptPath + @"\GetSendAsGroups.ps1")
                .AddParameter("Organization", organization);

            return this;
        }

        public CPOMyPowerShell UpdateVersionConf(string organization, bool updateall)
        {
            ps.AddCommand(psScriptPath + @"\UpdateVersionConf.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("UpdateAll", updateall);
            return this;
        }

        public CPOMyPowerShell CreateAccount(string organization, string accountname, string shortname)
        {
            ps.AddCommand(psScriptPath + @"\CreateAccount.ps1")
              .AddParameter("Organization", organization)
              .AddParameter("AccountName", accountname)
              .AddParameter("Shortname", shortname);
            return this;
        }

        public CPOMyPowerShell CreateGoldenVM(string solution, bool test)
        {
            ps.AddCommand(psScriptPath + @"\CreateGoldenVM.ps1")
              .AddParameter("Solution", solution)
              .AddParameter("Test", test);
            return this;
        }

        public CPOMyPowerShell MCSUpdateImage(string solution, string vmname, bool test)
        {
            ps.AddCommand(psScriptPath + @"\MCSUpdateImage.ps1")
              .AddParameter("Solution", solution)
              .AddParameter("VMName", vmname);
            if (test) { ps.AddParameter("Test", true); }
            return this;
        }
        public CPOMyPowerShell MCSCreateCatalog(string solution, string name, string vmname, string ou, string namingscheme)
        {
            ps.AddCommand(psScriptPath + @"\NewMCSCatalog.ps1")
              .AddParameter("Solution", solution)
              .AddParameter("Name", name)
              .AddParameter("VMName", vmname)
              .AddParameter("OU", ou)
              .AddParameter("NamingScheme", namingscheme);
            return this;
        }


        public CPOMyPowerShell GetCTXGoldenServers(string solution, bool mcsenabled)
        {
            ps.AddCommand(psScriptPath + @"\GetCTXGoldenServers.ps1")
                .AddParameter("Solution", solution);
            if (mcsenabled) { ps.AddParameter("MCSEnabled", true); }
            return this;
        }

        public CPOMyPowerShell SetOOFMessage(CustomCPOOOF OOF)
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
        public CPOMyPowerShell GetOOFMessage(string organization, string userprincipalname)
        {
            ps.AddCommand(psScriptPath + @"\GetOOFMessage.ps1")
            .AddParameter("Organization", organization)
            .AddParameter("UserPrincipalName", userprincipalname);

            return this;
        }

        public CPOMyPowerShell RemoveOOFMessage(CustomCPOOOF OOF)
        {
            ps.AddCommand(psScriptPath + @"\RemoveOOFMessage.ps1")
            .AddParameter("Organization", OOF.Organization)
            .AddParameter("UserPrincipalName", OOF.UserPrincipalName);

            return this;
        }

    }
}