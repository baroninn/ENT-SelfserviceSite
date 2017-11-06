using System.Collections.Generic;
using ColumbusPortal.Logic;

namespace ColumbusPortal.Models
{
    // Base model all models inherit from
    public class BaseModel
    {
        /// <summary>
        /// Get different organizations from DB. See Directory for code..
        /// </summary>
        public List<string> CPOOrganizations = Directory.GetCPOOrganizations();
        public List<string> CPOMCSOUs = Directory.CPOGetMCSou();

        public List<string> Organizations = Directory.GetOrganizations();

        public List<string> CloudOrganizations = Directory.GetCloudOrganizations();

        public List<string> CASOrganizations = Directory.GetCASOrganizations();

        public List<string> ALLOrganizations = Directory.GetALLOrganizations();

        public List<string> ALLCASOrganizations = Directory.GetALLCASOrganizations();

        public List<string> Office365Organizations = Directory.Get365Organizations();

        public List<string> AzureComputeOrganizations = Directory.GetAZComputeOrganizations();

        public string Message { get; set; }
        public List<string> OKMessage = new List<string>();
        public string[] MessageArray { get; set; }
        public List<string> MessageList = new List<string>();
        public bool ActionFailed { get; set; }

    }
}