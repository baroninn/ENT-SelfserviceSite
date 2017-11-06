using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;
using ColumbusPortal.Logic;

namespace ColumbusPortal.Models
{
    // model for View display in the user controller
    public class CaptoModel : BaseModel
    {
        /// <summary>
        /// User
        /// </summary>
        public int CreatedCount { get { return CPOUserList.Count; } }
        public List<CustomCPOUser> CPOUserList = new List<CustomCPOUser>();
        public CustomCPOUser CPODisableUser = new CustomCPOUser();
        public CustomCPOUser CPOEnableUser = new CustomCPOUser();
        public CustomCPOUser CPORemoveUser = new CustomCPOUser();
        public string Path { get; set; }
        public CustomCPOServiceUser CPOServiceUser = new CustomCPOServiceUser();
        public CustomCPOUserMemberOf CPOMemberOf = new CustomCPOUserMemberOf();
        public CustomCPOExtUser CPOCreateExtUser = new CustomCPOExtUser();
        /// <summary>
        /// Mail
        /// </summary>
        public CustomCPOAlias CPOAlias;
        public CustomCPOMailboxPermission CPOMailboxPermission;
        public CustomCPOMailboxPermissionFullAccess CPOMailboxPermissionFullAccess = new CustomCPOMailboxPermissionFullAccess();
        public Dictionary<string, string> MailboxList;
        public CustomCPOMailbox CPOMailbox = new CustomCPOMailbox();
        public CustomCPODistributionGroup CPODistributionGroup = new CustomCPODistributionGroup();
        public CustomCPOMailforward CPOMailforward = new CustomCPOMailforward();
        public CustomCPOMailboxPlan CPOMailboxPlan = new CustomCPOMailboxPlan();
        public CustomCPODeviceReport CPODeviceReport = new CustomCPODeviceReport();
        public CustomCPOMailContact CPOMailContact = new CustomCPOMailContact();
        public CustomCPOCalendarPermssions CPOCalendarPermissions = new CustomCPOCalendarPermssions();
        public CustomCPOMailboxAutoResize CPOMailboxAutoResize = new CustomCPOMailboxAutoResize();
        public CustomCPOAcceptedDomain CPOAcceptedDomain = new CustomCPOAcceptedDomain();
        public CustomCPOItemsReport CPOItemsReport = new CustomCPOItemsReport();
        public CustomCPOSikkermail CPOSikkermail = new CustomCPOSikkermail();
        public CustomCPOOOF CPOOOF = new CustomCPOOOF();

        /// <summary>
        /// Organization
        /// </summary>
        public CustomCPOOrganization CPOOrganization = new CustomCPOOrganization();
        public CustomCPONavCompanyName CPONavCompanyName = new CustomCPONavCompanyName();
        public CustomCPORemoveDummyDomain CPORemoveDummyDomain = new CustomCPORemoveDummyDomain();
        public CustomCPORemoveCustomer CPORemoveCustomer = new CustomCPORemoveCustomer();
        public CustomCPODisableCustomer CPODisableCustomer = new CustomCPODisableCustomer();
        public CustomCPOEnableCustomer CPOEnableCustomer = new CustomCPOEnableCustomer();
        public CustomCPOConvertCustomer CPOConvertCustomer = new CustomCPOConvertCustomer();
        public CustomCPOCreateAccount CPOCreateAccount = new CustomCPOCreateAccount();
        public List<string> CPOFileServers = Directory.CPOGetFileServers();

        /// <summary>
        /// Office365
        /// </summary>
        public CustomCPOAddDomain CPOAddDomain = new CustomCPOAddDomain();
        public CustomCPOEnable365Customer CPOEnable365Customer = new CustomCPOEnable365Customer();
        public CustomCPOEnableFederation CPOEnableFederation = new CustomCPOEnableFederation();

        /// <summary>
        /// Service
        /// </summary>
        public CustomCPOCustomerReport CPOCustomerReport;

        /// <summary>
        /// Level30
        /// </summary>
        public CustomCPOUpdateVersionConf CPOUpdateVersionConf = new CustomCPOUpdateVersionConf();
        public CustomCPOCreateGoldenVM CPOCreateGoldenVM = new CustomCPOCreateGoldenVM();
        public CustomCPOMCSUpdateImage CPOMCSUpdateImage = new CustomCPOMCSUpdateImage();
        public CustomCPOMCSCreateCatalog CPOMCSCreateCatalog = new CustomCPOMCSCreateCatalog();

    }
    /// <summary>
    /// User
    /// </summary>
    public class CustomCPOUserMemberOf
    {
        public string UserPrincipalName { get; set; }
        public string Organization { get; set; }
        public List<string> Groups = new List<string>();
    }


    public class CustomCPOServiceUser
    {
        public string Service { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public string Password { get; set; }
        public bool Management { get; set; }
    }


    // Custom User type containing relevant user information
    public class CustomCPOUser
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string Password { get; set; }
        public string DomainName { get; set; }

        public List<string> EmailAddresses;
        public bool Disable { get; set; }
        public bool Enable { get; set; }
        public bool HideFromAddressList { get; set; }
        public bool UnhideFromAddressList { get; set; }
        public bool TestUser { get; set; }
        public bool Remove { get; set; }
        public bool PasswordNeverExpires { get; set; }
        public bool StudJur { get; set; }
        public bool MailOnly { get; set; }
    }

    public class CustomCPOExtUser
    {

        public string Name { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public string ExpirationDate { get; set; }
        public string Password { get; set; }

        public string UserPrincipalName { get; set; }
    }
    /// <summary>
    /// Mail
    /// </summary>
    public class CustomCPOMailboxPermissionFullAccess
    {
        public string UserPrincipalName { get; set; }
        public string Organization { get; set; }
    }

    public class CustomCPOCalendarPermssions
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string[] User { get; set; }
        public string[] AccessRights { get; set; }
    }

    public class CustomCPODeviceReport
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string ReportHtml { get; set; }
    }

    public class CustomCPOMailContact
    {
        public string Organization { get; set; }
        public string PrimarySmtpAddress { get; set; }
    }


    public class CustomCPOMailforward
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string ForwardingSmtpAddress { get; set; }
        public string ForwardingType { get; set; }
        public bool DeliverToMailboxAndForward { get; set; }
    }

    public class CustomCPOAlias
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public List<string> EmailAddresses;
        public bool SetFirstAsPrimary { get; set; }
    }

    public class CustomCPOMailboxPermission
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public bool FullAccess { get; set; }
        public bool SendAs { get; set; }
    }

    public class CustomCPOMailbox
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public List<string> EmailAddresses;
        public string Type { get; set; }
        public bool FullAccess { get; set; }
        public bool SendAs { get; set; }
        public string Name { get; set; }
    }

    public class CustomCPODistributionGroup
    {
        public string Organization { get; set; }
        public string Name { get; set; }
        public string UserPrincipalName { get; set; }
        public string ManagedBy { get; set; }
        public string PrimarySmtpAddress { get; set; }
        public bool RequireSenderAuthentication { get; set; }
    }

    public class CustomCPOMailboxPlan
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string MailboxPlan { get; set; }
    }

    public class CustomCPOMailboxAutoResize
    {
        public string Organization { get; set; }
        public bool ExcludeFromAutoResize { get; set; }
    }

    public class CustomCPOAcceptedDomain
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
        public bool SetAsUPN { get; set; }
    }

    public class CustomCPOItemsReport
    {
        public string Organization { get; set; }
        public string Mail { get; set; }
        public bool GetALL { get; set; }
    }

    public class CustomCPOSikkermail
    {
        public string Organization { get; set; }
        public string SendAsGroup { get; set; }
        public string Alias { get; set; }
        public bool Remove { get; set; }
        public bool Force { get; set; }
        public bool UpdateAll { get; set; }

    }

    public class CustomCPOOOF
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        [AllowHtml]
        [UIHint("tinymce_full_compressed")]
        public string Internal { get; set; }
        [AllowHtml]
        [UIHint("tinymce_full_compressed")]
        public string External { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }

    }
    /// <summary>
    /// Organization
    /// </summary>
    public class CustomCPOOrganization
    {
        public string Name { get; set; }
        public string EmailDomainName { get; set; }
        public string FileServer { get; set; }
        public string FileServerDriveLetter { get; set; }
        public string Solution { get; set; }
    }

    public class CustomCPONavCompanyName
    {
        public string Organization { get; set; }
        public string CompanyName { get; set; }
        public bool NativeDatabase { get; set; }
        public bool Force { get; set; }
    }

    public class CustomCPORemoveDummyDomain
    {
        public string Organization { get; set; }
    }
    public class CustomCPORemoveCustomer
    {
        public string Organization { get; set; }

        public bool RemoveData { get; set; }

        public bool Confirm { get; set; }
    }

    public class CustomCPODisableCustomer
    {
        public string Organization { get; set; }

        public bool Confirm { get; set; }
    }

    public class CustomCPOEnableCustomer
    {
        public string Organization { get; set; }
    }
    public class CustomCPOConvertCustomer
    {
        public string Organization { get; set; }

        public bool Confirm { get; set; }
    }
    public class CustomCPOCreateAccount
    {
        public string Organization { get; set; }

        public string AccountName { get; set; }
        public string ShortName { get; set; }
    }

    /// <summary>
    /// Office365
    /// </summary>
    public class CustomCPOAddDomain
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
    }
    public class CustomCPOEnable365Customer
    {
        public string Organization { get; set; }
        public string TenantID { get; set; }
        public string TenantAdmin { get; set; }
        public string TenantPass { get; set; }
        public string Admin { get; set; }
        public string PartnerName { get; set; }
        public string License { get; set; }

    }

    public class CustomCPOEnableFederation
    {
        public string Organization { get; set; }
        public string Domain { get; set; }
    }

    public class CustomCPOCustomerReport
    {
        public string Organization { get; set; }
        public CPOSPLA Licenses;
        public string ExchangeQuota { get; set; }
        public double ExchangefQuota { get; set; }
        public string ExchangeUsage { get; set; }
        public double ExchangefUsage { get; set; }
        public List<CPOExchangeUser> ExchangeUsers;
        public List<CPOInfo365> Info365s;
        public int ExchangeUsersCount { get; set; }
        public string DiskQuota { get; set; }
        public string DiskUsage { get; set; }
        public List<CPOSikkermailGroup> SikkermailGroups;
        public int SikkermailGroupsCount { get; set; }
        public string DatabaseUsage { get; set; }
        public double DiskfUsage { get; set; }
        public double DiskfQuota { get; set; }
        public double DatabasefUsage { get; set; }
        public int DiskServers
        {
            get
            {
                int total = 0;
                foreach (CPOServer s in Servers)
                {
                    foreach (CPOServerDisk d in s.Disks)
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

        public int DiskTotalUsage
        {
            get
            {
                return (int)ExchangefUsage + (int)DiskfUsage + DiskServers;
            }
        }
        public int DiskTotalQuota
        {
            get
            {
                return (int)ExchangefQuota + (int)DiskfQuota + DiskServers;
            }
        }

        public List<CPOServer> Servers;

        public CustomCPOCustomerReport()
        {
            Licenses = new CPOSPLA();
            ExchangeUsers = new List<CPOExchangeUser>();
            Servers = new List<CPOServer>();
            Info365s = new List<CPOInfo365>();
        }
    }

    public class CPOSPLA
    {
        public List<string> Windows = new List<string>();
        public List<string> OfficeStandard = new List<string>();
        public List<string> OfficeProfessional = new List<string>();
        public List<string> Outlook = new List<string>();
        public List<string> Unknown = new List<string>();
        public List<string> StudJur = new List<string>();
        public List<string> Sikkermail = new List<string>();
        public List<string> MailOnly = new List<string>();
    }


    public class CPOExchangeUser
    {
        public string Name { get; set; }
        public string Usage { get; set; }
        public string Quota { get; set; }
        public string Email { get; set; }
    }

    public class CPOSikkermailGroup
    {
        public string Name { get; set; }
        public string Description { get; set; }

    }

    public class CPOServer
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public List<CPOServerDisk> Disks = new List<CPOServerDisk>();
    }

    public class CPOServerDisk
    {
        public string DeviceID { get; set; }
        public string Size { get; set; }
    }

    public class CPOInfo365
    {
        public string PartnerName { get; set; }
        public string License { get; set; }
        public string ActiveUnits { get; set; }
        public string ConsumedUnits { get; set; }
        public string FreeUnits { get; set; }
    }

    /// <summary>
    /// Level30
    /// </summary>
    public class CustomCPOUpdateVersionConf
    {
        public string Organization { get; set; }
        public bool UpdateAll { get; set; }
    }

    public class CustomCPOCreateGoldenVM
    {
        public string Solution { get; set; }
        public bool Test { get; set; }

    }

    public class CustomCPOMCSUpdateImage
    {
        public string Solution { get; set; }
        public string VMName { get; set; }
        public bool Test { get; set; }

    }

    public class CustomCPOMCSCreateCatalog
    {
        public string Solution { get; set; }
        public string Name { get; set; }
        public string VMName { get; set; }
        public string OU { get; set; }
        public string NamingScheme { get; set; }

    }

}