using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.Configuration;
using System.Web.Mvc;

namespace SystemHostingPortal.Logic
{
    public static class Common
    {
        static string LOGPATH = WebConfigurationManager.AppSettings["LogPath"].ToString();
        static string LOGFILE = string.Format(@"{0}\WebLog.txt", LOGPATH);
        static string STATSFILE = string.Format(@"{0}\WebStats.txt", LOGPATH);
        static int LOGSIZE = int.Parse(WebConfigurationManager.AppSettings["LogSize"].ToString());
        static bool DEBUG = bool.Parse(WebConfigurationManager.AppSettings["Debug"]);

        //Azure log
        static string AZURELOGPATH = WebConfigurationManager.AppSettings["AzureLogPath"].ToString();
        static string AZURELOGFILE = string.Format(@"{0}\AzureWebLog.txt", AZURELOGPATH);

        public static bool DebugMode
        {
            get
            {
                try
                {
                    return DEBUG;
                }
                catch { return true; }
            }
        }

        public static List<string> GetLog()
        {
            // Check/create logfile
            if (!File.Exists(LOGFILE)) { File.Create(LOGFILE).Close(); }

            // Read LOGSIZE entries and return
            return File.ReadAllLines(LOGFILE).ToList<string>();
        }

        public static List<string> GetAzureLog()
        {
            // Check/create logfile
            if (!File.Exists(AZURELOGFILE)) { File.Create(AZURELOGFILE).Close(); }

            // Read LOGSIZE entries and return
            return File.ReadAllLines(AZURELOGFILE).ToList<string>();
        }
        private static void SaveLog(List<string> log)
        {
            // Check/create logfile
            if (!File.Exists(LOGFILE)) { File.Create(LOGFILE).Close(); }

            // Write logfile
            File.WriteAllLines(LOGFILE, log.Take(LOGSIZE));
        }

        public static void Log(string entry)
        {
            try
            {
                // Insert new entry on top of log
                List<string> log = GetLog();
                log.Insert(0, DateTime.Now.ToString() + " :: " + HttpContext.Current.User.Identity.Name + " :: " + entry);
                SaveLog(log);
            }
            catch (Exception exc)
            {
                throw new Exception("Command failed to execute - Failed to write to the logfile: " + exc.Message);
            }
        }
        
        public static void Log(string entry, FormCollection data)
        {
            // Generates string "a - b - c - d"
            string dataEntry = string.Join(" - ", data);

            // Logs dataEntry first to get main entry on top
            Log(dataEntry);
            Log(entry);
        }

        public static void Stats(string functionName)
        {
            try
            {
                if (!File.Exists(STATSFILE)) { File.Create(STATSFILE).Close(); }
                StreamWriter sw = File.AppendText(STATSFILE);
                sw.WriteLine("{0};;{1}", DateTime.Now, functionName);
                sw.Flush();
                sw.Close();
            }
            catch (Exception exc)
            {
                throw new Exception("Command completed successfully, but failed to write to the statistics file: " + exc.Message);
            }
        }

        public static string GeneratePassword(int passwordLength = 17)
        {
            string password = "";

            string[] characters = new string[] { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "!", "@", "#", "$", "%" };
            Random rand = new Random();

            for (int i = 0; i < passwordLength; i++)
            {
                string nextChar = characters[rand.Next(0, characters.Length - 1)];
                if (i % 4 == 0)
                {
                    nextChar = nextChar.ToUpper();
                }

                password += nextChar;
            }

            password += string.Format("{0:d4}", rand.Next(0, 9999));

            return password;
        }

        public static Dictionary<string, object> GetPSObjectProperties(PSObject item)
        {
            Dictionary<string, object> properties = new Dictionary<string,object>();

            foreach(PSPropertyInfo property in item.Properties)
            {
                //Common.debug.Add(string.Format("Found Name: {0}, Value: {1}", property.Name, property.Value));
                properties.Add(property.Name, property.Value);
            }

            return properties;
        }

        public static List<string> debug = new List<string>();


        public static string GetDefaultAcceptedDomain(string organization)
        {
            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetDefaultAcceptedDomain(organization);
                IEnumerable<PSObject> result = ps.Invoke();

                foreach (PSObject item in result)
                {
                    Dictionary<string, object> properties = Common.GetPSObjectProperties(item);
                    
                    return properties["DomainName"].ToString();
                }

                throw new Exception("Unable to find default accepted domain");
            }
        }
    }
}