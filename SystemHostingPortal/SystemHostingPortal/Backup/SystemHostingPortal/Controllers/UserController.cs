using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;
using System.Management.Automation;

namespace SystemHostingPortal.Controllers
{
    [Authorize(Roles = "Access_SelfService_FullAccess")]
    public class UserController : Controller
    {
        UserModel model = new UserModel();
        
        // Display create view
        public ActionResult Create()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed user and display create view
        [HttpPost]
        public ActionResult Create(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomUser newUser = new CustomUser()
                {
                    EmailAddresses = _POST["emailaddresses"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>(),
                    FirstName = _POST["firstname"],
                    LastName = _POST["lastname"],
                    Organization = _POST["organization"],
                    Password = _POST["password"],
                    UserPrincipalName = _POST["userprincipalname"],
                    DomainName = _POST["domainname"],
                    TestUser = _POST["testuser"] == "on" ? true : false,
                    PasswordNeverExpires = _POST["passwordneverexpires"] == "on" ? true : false,
                    StudJur = _POST["studjur"] == "on" ? true : false,
                    MailOnly = _POST["mailonly"] == "on" ? true : false
                };
                for (int i = 0; i < newUser.EmailAddresses.Count; i++) { newUser.EmailAddresses[i] = newUser.EmailAddresses[i].Trim(); }

                model.UserList.Add(newUser);

                Common.Log(string.Format("has run User/CreateUser() to create {0}", newUser.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateUser(newUser);
                    var result = ps.Invoke();
                }

                Common.Stats("User/Create");

                return View("CreateSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display disable user page
        public ActionResult Disable()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Disable POSTed user and display result page
        [HttpPost]
        public ActionResult Disable(FormCollection _POST)
        {
            try
            {
                CustomUser disableUser = new CustomUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    Disable = _POST["disable"] == "on" ? true : false,
                    HideFromAddressList = _POST["hidefromaddresslist"] == "on" ? true : false,
                    Remove = _POST["delete"] == "on" ? true : false
                };

                model.DisableUser = disableUser;

                Common.Log(string.Format("has run User/DisableUser(disable={1}, hidefromaddresslist={2}, delete={3}) for user {0}", disableUser.UserPrincipalName, disableUser.Disable, disableUser.HideFromAddressList, disableUser.Remove));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DisableUser(disableUser);
                    var result = ps.Invoke();
                }

                if (model.DisableUser.Disable)
                {
                    model.OKMessage.Add("User disabled.");
                }
                if (model.DisableUser.HideFromAddressList)
                {
                    model.OKMessage.Add("User hidden from address lists.");
                }

                Common.Stats("User/Disable");

                return View("Disable", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        public ActionResult Remove()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        [HttpPost]
        public ActionResult Remove(FormCollection _POST)
        {
            try
            {
                CustomUser removeUser = new CustomUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    Remove = _POST["confirm"] == "on" ? true : false
                };

                model.RemoveUser = removeUser;

                if (!model.RemoveUser.Remove)
                {
                    throw new Exception("You must confirm the action.");
                }

                Common.Log(string.Format("has run User/Remove for user {0}", removeUser.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveUser(removeUser);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("User successfully deleted.");
                    }
                    else
                    {
                        model.OKMessage.Add("User deleted with warnings."); 

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                Common.Stats("User/Remove");

                return View("Remove", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        public ActionResult CreateBatch()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }
        [HttpPost]
        public ActionResult CreateBatchVerify(FormCollection _POST)
        {
            try
            {
                List<CustomUser> newUsers = new List<CustomUser>();

                string[] newUserStrings = _POST["input"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
                bool passwordNeverExpires = _POST["passwordneverexpires"] == "on" ? true : false;
                Session.Add("PasswordNeverExpires", passwordNeverExpires);

                int count = 1;
                foreach (string newUserString in newUserStrings)
                {
                    try
                    {
                        //user entry is empty, skip. happens when you add an empty newline at the end.
                        if (newUserString.Trim() == "") { continue; }

                        string[] newUserStringSplit = newUserString.Split(';');
                        CustomUser newUser = new CustomUser()
                        {
                            FirstName = newUserStringSplit[0].Trim(),
                            LastName = newUserStringSplit[1].Trim(),
                            UserPrincipalName = newUserStringSplit[2].Trim(),
                            Password = newUserStringSplit[3].Trim(),
                            Organization = _POST["organization"],
                            PasswordNeverExpires = passwordNeverExpires,
                        };

                        if (newUserStringSplit.Length == 5)
                        {
                            newUser.EmailAddresses = newUserStringSplit[4].Trim().Split(',').ToList<string>();
                            for (int i = 0; i < newUser.EmailAddresses.Count; i++)
                            {
                                newUser.EmailAddresses[i] = newUser.EmailAddresses[i].Trim();
                            }
                        }
                        else
                        {
                            newUser.EmailAddresses = new List<string>();
                        }

                        newUsers.Add(newUser);
                    }
                    catch(IndexOutOfRangeException)
                    {
                        throw new Exception("Incorrect CSV format on line " + count.ToString() + ": " + newUserString);
                    }

                    count++;
                }

                model.UserList = newUsers;

                Session.Add("CreateBatch_UserList", newUsers);

                return View(model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateBatch", model);
            }
        }
        [HttpPost]
        public ActionResult CreateBatch(FormCollection _POST)
        {

            try
            {
                model.UserList = (List<CustomUser>)Session["CreateBatch_UserList"];
                Session.Remove("CreateBatch_UserList");
                bool passwordNeverExpires = (bool)Session["PasswordNeverExpires"];
                Session.Remove("PasswordNeverExpires");

                //extract comma seperated list of users for the log entry
                var userList = from user in model.UserList select user.UserPrincipalName;
                string userListLog = string.Join(", ", userList);

                Common.Log(string.Format("has run User/CreateBatch() for users {0}", userListLog));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateBatch(model.UserList, passwordNeverExpires);
                    var result = ps.Invoke();
                    model.MessageArray = string.Join(";;;", result).Split(new string[] { ";;;" }, StringSplitOptions.RemoveEmptyEntries);
                }

                Common.Stats("User/CreateBatch");

                return View("CreateBatchSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateBatch", model);
            }
        }


        public ActionResult CreateServiceUser()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [HttpPost]
        public ActionResult CreateServiceUser(FormCollection _POST)
        {
            try
            {
                model.ServiceUser.Organization = _POST["organization"];
                model.ServiceUser.Service = _POST["service"];
                model.ServiceUser.Description = _POST["description"];
                model.ServiceUser.Password = Common.GeneratePassword();
                model.ServiceUser.Management = _POST["management"] == "on" ? true : false;

                Common.Log(string.Format("has run User/CreateServiceUser() to create service user {0}_svc_{1}", model.ServiceUser.Organization, model.ServiceUser.Service));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateServiceUser(model.ServiceUser);
                    var result = ps.Invoke();
                }

                Common.Stats("User/CreateServiceUser");

                return View("CreateServiceUserSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateServiceUser", model);
            }
        }



        public ActionResult GetUserMemberOf()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [HttpPost]
        public ActionResult GetUserMemberOf(FormCollection _POST)
        {
            try
            {
                model.MemberOf.Organization = _POST["organization"];
                model.MemberOf.UserPrincipalName = _POST["userprincipalname"];

                Common.Log(string.Format("has run User/GetUserMemberOf() on user {0}\\{1}", model.MemberOf.Organization, model.MemberOf.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetUserMemberOf(model.MemberOf);
                    var result = ps.Invoke();

                    foreach (var item in result)
                    {
                        model.MemberOf.Groups.Add(item.ToString());
                    }
                }

                Common.Stats("User/GetUserMemberOf");

                return View("GetUserMemberOfSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        public ActionResult CreateNav2goUser()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [HttpPost]
        public ActionResult CreateNav2goUser(FormCollection _POST)
        {
            try
            {
                model.Nav2goUser.Username = _POST["username"];
                model.Nav2goUser.Password = _POST["password"];
                model.Nav2goUser.NoExpiry = _POST["noexpiry"] == "on" ? true : false;
               
                Common.Log(string.Format("has run User/CreateNav2goUser() to create user {0}@nav2go.dk", model.Nav2goUser.Username));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateNav2goUser(model.Nav2goUser);
                    var result = ps.Invoke();
                }

                Common.Stats("User/CreateNav2goUser");

                return View("CreateNav2goUserSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        public ActionResult CreateExtUser()
        {
            try
            {
                return View("CreateExtUser", model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateExtUser", model);
            }
        }

        [HttpPost]
        public ActionResult CreateExtUser(FormCollection _POST)
        {
            try
            {
                model.CreateExtUser.Organization = _POST["organization"];
                model.CreateExtUser.Name = _POST["name"];
                
                model.CreateExtUser.Password = Common.GeneratePassword();
                model.CreateExtUser.ExpirationDate = DateTime.Now.AddMonths(1).ToString("yyyy-MM-dd");

                Common.Log(string.Format("has run User/CreateExtUser() to create ext user {0}_ext_{1}", model.CreateExtUser.Organization, model.CreateExtUser.Name));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateExtUser(model.CreateExtUser).Invoke();
                }

                string defaultDomain = Common.GetDefaultAcceptedDomain(model.CreateExtUser.Organization);

                model.CreateExtUser.UserPrincipalName = string.Format("{0}_ext_{1}@{2}", model.CreateExtUser.Organization, model.CreateExtUser.Name, defaultDomain);

                Common.Stats("User/CreateExtUser");

                return View("CreateExtUserSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateExtUser", model);
            }
        }


        public ActionResult Enable()
        {
            try
            {
                return View("Enable", model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("Enable", model);
            }
        }

        [HttpPost]
        public ActionResult Enable(FormCollection _POST)
        {
            try
            {
                // property is disable but means enable
                model.EnableUser.Organization = _POST["organization"];
                model.EnableUser.UserPrincipalName = _POST["userprincipalname"];
                model.EnableUser.Enable = _POST["removedisable"] == "on" ? true : false;
                model.EnableUser.UnhideFromAddressList = _POST["removehidefromaddresslist"] == "on" ? true : false;

                if (!model.EnableUser.Enable && !model.EnableUser.UnhideFromAddressList)
                {
                    model.OKMessage.Add("No changes");
                    return View("Enable", model);
                }

                Common.Log(string.Format("has run User/Enable(hidden: {0}, enable: {1}) on user {2}", model.EnableUser.UnhideFromAddressList, model.EnableUser.Enable, model.EnableUser.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.EnableUser(model.EnableUser).Invoke();
                }

                Common.Stats("User/EnableUser");

                if (model.EnableUser.Enable)
                {
                    model.OKMessage.Add("User enabled.");
                }
                if (model.EnableUser.UnhideFromAddressList)
                {
                    model.OKMessage.Add("User shown in address lists.");
                }

                return View("Enable", model);

            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("Enable", model);
            }
        }



        // Ajax method, search for users by name
        public string Disable_Search(string organization, string name)
        {
            SearchResultCollection results = Directory.SearchUserByName(name, organization);

            if (results.Count == 0) { return ""; }

            string returnString = "";

            foreach (SearchResult user in results)
            {
                string username = user.GetDirectoryEntry().Properties["name"].Value.ToString();
                returnString += "<li><a href=\"javascript:SetName('" + username + "')\">" + username + "</a></li>";
            }

            return "<ul>" + returnString + "</ul>";
        }
    }
}
