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

        public static List<string> GetOrganizations5()
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
                        organizationList.Add((read["Organization"].ToString()));
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

            string selectSql = "select Organization, Name from [dbo].[CASOrganizations] UNION select Organization, Name from [dbo].[Organizations]";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        organizationList.Add((read["Organization"].ToString()) + " - [" + (read["Name"].ToString()) + "]");
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
                        organizationList.Add((read["Organization"].ToString()) + " - [" + (read["Name"].ToString()) + "]");
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