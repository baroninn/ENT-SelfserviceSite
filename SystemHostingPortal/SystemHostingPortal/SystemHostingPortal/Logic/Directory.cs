using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Web;
using System.Web.Configuration;

namespace SystemHostingPortal.Logic
{
    public class Directory
    {
        static string DomainDN = WebConfigurationManager.AppSettings["DomainDN"].ToString();

        /// <summary>
        /// Returns all objects found in Exchange domain
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="args"></param>
        /// <returns></returns>
        private static SearchResultCollection SearchDomain(string filter, params object[] args) {
            return SearchDomain(string.Format(filter, args));
        }
        /// <summary>
        /// Returns all objects found in Exchange domain
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        private static SearchResultCollection SearchDomain(string filter) 
        {
            // Performs directory search
            DirectorySearcher ds = new DirectorySearcher("LDAP://" + DomainDN);
            ds.Filter = filter;
            return ds.FindAll();
        }

        private static SearchResultCollection SearchIn(DirectoryEntry root, string filter, params object[] args) {
            return SearchIn(root, string.Format(filter, args));
        }
        private static SearchResultCollection SearchIn(DirectoryEntry root, string filter)
        {
            //TODO: Test
            // perform a targeted search
            DirectorySearcher ds = new DirectorySearcher(root);
            ds.Filter = filter;
            return ds.FindAll();
        }

        public static SearchResult GetGroupByName(string groupName)
        {
            // clean up parameter
            groupName = groupName.Trim();

            // search for group name
            SearchResultCollection results = SearchDomain("(&(objectClass=group)(name={0}))", groupName);
            if (results.Count != 1)
            {
                // not found
                if (results.Count == 0) throw new Exception(groupName + " not found");

                // not unique
                throw new Exception("Ambiguous name " + groupName);
            }

            return results[0];
        }

        public static SearchResultCollection SearchUserByName(string name, string organization)
        {
            name = name.Trim();

            return SearchIn(new DirectoryEntry("LDAP://OU=" + organization + ", OU=Microsoft Exchange Hosted Organizations," + DomainDN), "(&(objectClass=user)(name=*" + name + "*))");
        }
        public static SearchResultCollection SearchUserByName(string name)
        {
            // Clean up name
            name = name.Trim();

            //TODO: Test if name attribute is accurate
            // Search for user by name
            return SearchDomain("(&(objectClass=user)(name={0}))", name);
        }
        public static SearchResult GetUserByUPN(string userPrincipalName)
        {
            // clean up parameter
            userPrincipalName = userPrincipalName.Trim();

            // search for group name
            SearchResultCollection results = SearchDomain("(&(objectClass=user)(userPrincipalName={0}))", userPrincipalName);
            if (results.Count != 1)
            {
                // not found
                if (results.Count == 0) throw new Exception(userPrincipalName + " not found");

                // not unique
                throw new Exception("Ambiguous UPN " + userPrincipalName);
            }

            return results[0];
        }

        public static List<string> GetOrganizations()
        {
            List<string> organizationList = new List<string>();
            DirectoryEntry de = new DirectoryEntry("LDAP://OU=Customer,OU=SYSTEMHOSTING," + DomainDN);

            // return organization list as list<string>
            foreach (DirectoryEntry child in de.Children) organizationList.Add(child.Properties["name"].Value.ToString().ToUpper());

            return organizationList;
        }

        public static List<string> GetOrganizations2()
        {
            List<string> organizationList = new List<string>();

            organizationList.Add("ICE");
            organizationList.Add("BOH");
            organizationList.Add("SGC");
            organizationList.Add("PRV");


            return organizationList.OrderBy(x => x).ToList();
        }

       /* public static List<string> GetOrganizations3()
        {
            List<string> organizationList = new List<string>(Directory.EnumerateDirectories("~/Organizations.txt"));

            organizationList.Add("ICE");
            organizationList.Add("BOH");
            organizationList.Add("SGC");
            organizationList.Add("PRV");


            return organizationList.OrderBy(x => x).ToList();
        }
        */

        public static List<string> GetFileServers()
        {
            List<string> fileserverList = new List<string>();

            DirectoryEntry de = new DirectoryEntry("LDAP://OU=FILE,OU=Servers,OU=Backend,OU=SYSTEMHOSTING," + DomainDN);

            foreach (DirectoryEntry child in de.Children)
            {
                fileserverList.Add(child.Properties["name"].Value.ToString());
            }

            return fileserverList;
        }

        /// <summary>
        /// Get a list of groups
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public static List<string> GetExistingGroups(string organization)
        {
            List<string> groupList = new List<string>();
            Dictionary<string, DirectoryEntry> groups = new Dictionary<string, DirectoryEntry>();

            groups.Add("Custom", new DirectoryEntry(string.Format("LDAP://OU=Custom,OU=Groups,OU={0},OU=Customers,OU=SystemHosting," + DomainDN, organization)));
            groups.Add("Files", new DirectoryEntry(string.Format("LDAP://OU=Files,OU=Groups,OU={0},OU=Customers,OU=SystemHosting," + DomainDN, organization)));
            groups.Add("Programs", new DirectoryEntry(string.Format("LDAP://OU=Programs,OU=Groups,OU={0},OU=Customers,OU=SystemHosting," + DomainDN, organization)));

            foreach (KeyValuePair<string, DirectoryEntry> organizationalUnit in groups)
            {
                foreach (DirectoryEntry de in organizationalUnit.Value.Children)
                {
                    groupList.Add(organizationalUnit.Key + "\\" + de.Properties["name"].Value);
                }
            }

            // clean up directoryentry connections
            foreach (KeyValuePair<string, DirectoryEntry> organizationalUnit in groups)
            {
                organizationalUnit.Value.Close();
            }

            return groupList;
        }


        /// <summary>
        /// Get a list of SendAsgroups
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public static List<string> GetSendAsGrouplist(string organization)
        {
            List<string> groupList = new List<string>();
            Dictionary<string, DirectoryEntry> groups = new Dictionary<string, DirectoryEntry>();

            groups.Add("Mailbox", new DirectoryEntry(string.Format("LDAP://OU=Mailbox,OU=Groups,OU={0},OU=Customers,OU=SystemHosting," + DomainDN, organization)));

            foreach (KeyValuePair<string, DirectoryEntry> group in groups)
            {
                foreach (DirectoryEntry de in group.Value.Children)
                {
                    groupList.Add(group.Key + "\\" + de.Properties["name"].Value);
                }
            }

            // clean up directoryentry connections
            foreach (KeyValuePair<string, DirectoryEntry> group in groups)
            {
                group.Value.Close();
            }

            return groupList;
        }
    }
}