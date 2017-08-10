using System.Collections.Generic;
using ColumbusPortal.Logic;

namespace ColumbusPortal.Models
{
    // Base model all models inherit from
    public class BaseModel
    {
        public List<string> Organizations = Directory.GetOrganizations5();

        public List<string> CASOrganizations = Directory.GetCASOrganizations();

        public List<string> ALLOrganizations = Directory.GetALLOrganizations();

        public string Message { get; set; }
        public List<string> OKMessage = new List<string>();
        public string[] MessageArray { get; set; }
        public List<string> MessageList = new List<string>();
        public bool ActionFailed { get; set; }
    }
}