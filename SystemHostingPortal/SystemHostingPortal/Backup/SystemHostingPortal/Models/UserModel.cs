using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SystemHostingPortal.Models
{
    // model for View display in the user controller
    public class UserModel : BaseModel
    {
        public int CreatedCount { get { return UserList.Count; } }
        public List<CustomUser> UserList = new List<CustomUser>();
        public CustomUser DisableUser = new CustomUser();
        public CustomUser EnableUser = new CustomUser();
        public CustomUser RemoveUser = new CustomUser();
        public string Path { get; set; }
        public CustomServiceUser ServiceUser = new CustomServiceUser();
        public CustomUserMemberOf MemberOf = new CustomUserMemberOf();
        public CustomNav2goUser Nav2goUser = new CustomNav2goUser();
        public CustomExtUser CreateExtUser = new CustomExtUser();

    }

    public class CustomNav2goUser
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public bool NoExpiry { get; set; }
    }

    public class CustomUserMemberOf
    {
        public string UserPrincipalName { get; set; }
        public string Organization { get; set; }
        public List<string> Groups = new List<string>();
    }


    public class CustomServiceUser
    {
        public string Service { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public string Password { get; set; }
        public bool Management { get; set; }
    }


    // Custom User type containing relevant user information
    public class CustomUser
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

    public class CustomExtUser
    {
        /*  [Parameter(Mandatory=$true)][string]$Organization,
    [Parameter(Mandatory=$true)][string]$Vendor,
    [Parameter(Mandatory=$true)][string]$Description,
    [Parameter(Mandatory=$true)]$ExpirationDate,
    [Parameter(Mandatory=$true)]$Password
         * 
         * 
         * */

        public string Name { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public string ExpirationDate { get; set; }
        public string Password { get; set; }

        public string UserPrincipalName { get; set; }
    }
}