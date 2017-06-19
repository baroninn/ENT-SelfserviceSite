using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using SystemHostingPortal.Logic;
using System.Text.RegularExpressions;
using System.ComponentModel.DataAnnotations;

namespace SystemHostingPortal.Models
{
    public class HomeModel
    {
        public List<string> Log;
        public List<string> AzureLog;
    }
}