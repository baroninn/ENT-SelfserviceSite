using System.Collections.Generic;

namespace ColumbusPortal.Models
{
    public class MailModel : BaseModel
    {
        public CustomAlias Alias;
        public CustomMailboxPermission MailboxPermission;
        public CustomMailboxPermissionFullAccess MailboxPermissionFullAccess = new CustomMailboxPermissionFullAccess();
        public Dictionary<string, string> MailboxList;
        public CustomMailbox Mailbox = new CustomMailbox();
        public CustomDistributionGroup DistributionGroup = new CustomDistributionGroup();
        public CustomMailforward Mailforward = new CustomMailforward();
        public CustomMailboxPlan MailboxPlan = new CustomMailboxPlan();
        public CustomDeviceReport DeviceReport = new CustomDeviceReport();
        public CustomMailContact MailContact = new CustomMailContact();
        public CustomCalendarPermissions CalendarPermissions = new CustomCalendarPermissions();
        public CustomMailboxAutoResize MailboxAutoResize = new CustomMailboxAutoResize();
        public CustomItemsReport ItemsReport = new CustomItemsReport();
        public CustomSikkermail Sikkermail = new CustomSikkermail();


    }

    public class CustomMailboxPermissionFullAccess
    {
        public string UserPrincipalName { get; set; }
        public string Organization { get; set; }
    }

    public class CustomCalendarPermissions
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string[] User { get; set; }
        public string[] AccessRights { get; set; }
    }

    public class CustomDeviceReport
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string ReportHtml { get; set; }
    }

    public class CustomMailContact
    {
        public string Organization { get; set; }
        public string PrimarySmtpAddress { get; set; }
    }


    public class CustomMailforward {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string ForwardingSmtpAddress { get; set; }
        public string ForwardingType { get; set; }
        public bool DeliverToMailboxAndForward { get; set; }
    }

    public class CustomAlias
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public List<string> EmailAddresses;
        public bool SetFirstAsPrimary { get; set; }
    }

    public class CustomMailboxPermission
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public bool FullAccess { get; set; }
        public bool SendAs { get; set; }
    }

    public class CustomMailbox
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public List<string> EmailAddresses;
        public string Type { get; set; }
        public bool FullAccess { get; set; }
        public bool SendAs { get; set; }
        public string UserName { get; set; }
        public string DisplayName { get; set; }
        public string DomainName { get; set; }
        public string Password { get; set; }

    }

    public class CustomDistributionGroup
    {
        public string Organization { get; set; }
        public string Name { get; set; }
        public string UserName { get; set; }
        public string ManagedBy { get; set; }
        public string DomainName { get; set; }
        public bool RequireSenderAuthentication { get; set; }
    }

    public class CustomMailboxPlan
    {
        public string Organization { get; set; }
        public string UserPrincipalName { get; set; }
        public string MailboxPlan { get; set; }
    }

    public class CustomMailboxAutoResize
    {
        public string Organization { get; set; }
        public bool ExcludeFromAutoResize { get; set; }
    }

    public class CustomItemsReport
    {
        public string Organization { get; set; }
        public string Mail { get; set; }
        public bool GetALL { get; set; }
    }

    public class CustomSikkermail
    {
        public string Organization { get; set; }
        public string SendAsGroup { get; set; }
        public string Alias { get; set; }
        public bool Remove { get; set; }
        public bool Force { get; set; }
        public bool UpdateAll { get; set; }

    }
}