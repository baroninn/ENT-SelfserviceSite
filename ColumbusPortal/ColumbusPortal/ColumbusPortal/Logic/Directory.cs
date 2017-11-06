using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.IO;
using System.Linq;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Data.SqlClient;

namespace ColumbusPortal.Logic
{
    public class Directory
    {

        private static SearchResultCollection SearchDomain(string filter, params object[] args) {
            return SearchDomain(string.Format(filter, args));
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
        public static List<string> CPOGetFileServers()
        {
            List<string> fileserverList = new List<string>();

            DirectoryEntry de = new DirectoryEntry("LDAP://OU=FILE,OU=Servers,OU=Backend,OU=SYSTEMHOSTING," + DomainDN);

            foreach (DirectoryEntry child in de.Children)
            {
                fileserverList.Add(child.Properties["name"].Value.ToString());
            }

            return fileserverList;
        }
        public static List<string> CPOGetMCSou()
        {
            List<string> mcsouList = new List<string>();
            DirectoryEntry de = new DirectoryEntry("LDAP://OU=CITRIX,OU=Servers,OU=Backend,OU=SYSTEMHOSTING," + DomainDN);

            // return ou list as list<string>
            foreach (DirectoryEntry child in de.Children)
            {
                mcsouList.Add(child.Properties["Name"].Value.ToString().ToUpper());
            }

            return mcsouList;
        }
        /// <summary>
        /// Capto organization logic
        /// </summary>
        static string DomainDN = WebConfigurationManager.AppSettings["DomainDN"].ToString();
        public static List<string> GetCPOOrganizations()
        {
            List<string> organizationList = new List<string>();
            DirectoryEntry de = new DirectoryEntry("LDAP://OU=Customer,OU=SYSTEMHOSTING," + DomainDN);

            // return organization list as list<string>
            foreach (DirectoryEntry child in de.Children) organizationList.Add(child.Properties["name"].Value.ToString().ToUpper());

            return organizationList;
        }

        public static List<string> GetOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select * from [dbo].[Organizations] WHERE [Platform] NOT LIKE 'Cloud'";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }

        public static List<string> GetCloudOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select * from [dbo].[Organizations] WHERE ([Platform] LIKE 'Cloud' OR [Platform] LIKE 'Hybrid')";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }


        public static List<string> GetALLOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select * from [dbo].[Organizations]";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }

        public static List<string> GetCASOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select Organization, Name from [dbo].[CASOrganizations]";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }

        public static List<string> GetALLCASOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select Organization, Name from [dbo].[CASOrganizations] UNION select Organization, Name from [dbo].[Organizations] WHERE [Platform] NOT LIKE 'Cloud'";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }
        public static List<string> Get365Organizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select Organization, Name from [dbo].[Organizations] WHERE [Service365] = 'True'";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }
        public static List<string> GetAZComputeOrganizations()
        {
            List<string> organizationList = new List<string>();

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select Organization, Name from [dbo].[Organizations] WHERE [ServiceCompute] = 'True'";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [ " + (read["Name"].ToString()) + " ]");
                    }
                }
            }
            finally
            {
                con.Close();
            }
            return organizationList.OrderBy(x => x).ToList();
        }

    }
}