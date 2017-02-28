using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SystemHostingPortal.Logic;

namespace SystemHostingPortal.Models
{
    // Base model all models inherit from
    public class BaseModel
    {
        public List<string> Organizations = Directory.GetOrganizations4();
        public string Message { get; set; }
        public List<string> OKMessage = new List<string>();
        public string[] MessageArray { get; set; }
        public List<string> MessageList = new List<string>();
        public bool ActionFailed { get; set; }
    }
}