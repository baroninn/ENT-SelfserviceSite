using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Helpers;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Management.Automation;
using System.ComponentModel.DataAnnotations;
using System.Web.Script.Serialization;
using System.Data.SqlClient;

namespace ColumbusPortal.Controllers
{
    public class CaptoController : Controller
    {
        CaptoModel model = new CaptoModel();

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateUser()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed user and display create view
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateUser(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomCPOUser newUser = new CustomCPOUser()
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

                model.CPOUserList.Add(newUser);

                CommonCAS.CPOLog(string.Format("has run Capto/CPOCreateUser() to create {0}", newUser.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateUser(newUser);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOCreateUser");

                return View("CPOCreateSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display disable user page
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODisableUser()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Disable POSTed user and display result page
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODisableUser(FormCollection _POST)
        {
            try
            {
                CustomCPOUser disableUser = new CustomCPOUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    Disable = _POST["disable"] == "on" ? true : false,
                    HideFromAddressList = _POST["hidefromaddresslist"] == "on" ? true : false,
                    Remove = _POST["delete"] == "on" ? true : false
                };

                model.CPODisableUser = disableUser;

                CommonCAS.CPOLog(string.Format("has run User/DisableUser(disable={1}, hidefromaddresslist={2}, delete={3}) for user {0}", disableUser.UserPrincipalName, disableUser.Disable, disableUser.HideFromAddressList, disableUser.Remove));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.DisableUser(disableUser);
                    var result = ps.Invoke();
                }

                if (model.CPODisableUser.Disable)
                {
                    model.OKMessage.Add("User disabled.");
                }
                if (model.CPODisableUser.HideFromAddressList)
                {
                    model.OKMessage.Add("User hidden from address lists.");
                }

                CommonCAS.Stats("Capto/CPODisableUser");

                return View("CPODisableUser", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveUser()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveUser(FormCollection _POST)
        {
            try
            {
                CustomCPOUser removeUser = new CustomCPOUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    Remove = _POST["confirm"] == "on" ? true : false
                };

                model.CPORemoveUser = removeUser;

                if (!model.CPORemoveUser.Remove)
                {
                    throw new Exception("You must confirm the action.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPORemove for user {0}", removeUser.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveUser(removeUser);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("User successfully deleted.");
                    }
                    else
                    {
                        model.OKMessage.Add("User deleted with following info.");

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("Capto/CPORemoveUser");

                return View("CPORemoveUser", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateUserBatch()
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateUserBatchVerify(FormCollection _POST)
        {
            try
            {
                List<CustomCPOUser> newUsers = new List<CustomCPOUser>();

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
                        CustomCPOUser newUser = new CustomCPOUser()
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
                    catch (IndexOutOfRangeException)
                    {
                        throw new Exception("Incorrect CSV format on line " + count.ToString() + ": " + newUserString);
                    }

                    count++;
                }

                model.CPOUserList = newUsers;

                Session.Add("CreateBatch_UserList", newUsers);

                return View(model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOCreateUserBatch", model);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateUserBatch(FormCollection _POST)
        {

            try
            {
                model.CPOUserList = (List<CustomCPOUser>)Session["CreateBatch_UserList"];
                Session.Remove("CreateBatch_UserList");
                bool passwordNeverExpires = (bool)Session["PasswordNeverExpires"];
                Session.Remove("PasswordNeverExpires");

                //extract comma seperated list of users for the log entry
                var userList = from user in model.CPOUserList select user.UserPrincipalName;
                string userListLog = string.Join(", ", userList);

                CommonCAS.CPOLog(string.Format("has run User/CreateBatch() for users {0}", userListLog));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateBatch(model.CPOUserList, passwordNeverExpires);
                    var result = ps.Invoke();
                    model.MessageArray = string.Join(";;;", result).Split(new string[] { ";;;" }, StringSplitOptions.RemoveEmptyEntries);
                }

                CommonCAS.Stats("Capto/CPOCreateUserBatch");

                return View("CPOCreateUserBatchSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOCreateUserBatch", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateServiceUser()
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateServiceUser(FormCollection _POST)
        {
            try
            {
                model.CPOServiceUser.Organization = _POST["organization"];
                model.CPOServiceUser.Service = _POST["service"];
                model.CPOServiceUser.Description = _POST["description"];
                model.CPOServiceUser.Password = CommonCAS.GeneratePassword();
                model.CPOServiceUser.Management = _POST["management"] == "on" ? true : false;

                CommonCAS.CPOLog(string.Format("has run User/CreateServiceUser() to create service user {0}_svc_{1}", model.CPOServiceUser.Organization, model.CPOServiceUser.Service));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateServiceUser(model.CPOServiceUser);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOCreateServiceUser");

                return View("CPOCreateServiceUserSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOCreateServiceUser", model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetUserMemberOf()
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetUserMemberOf(FormCollection _POST)
        {
            try
            {
                model.CPOMemberOf.Organization = _POST["organization"];
                model.CPOMemberOf.UserPrincipalName = _POST["userprincipalname"];

                CommonCAS.CPOLog(string.Format("has run User/GetUserMemberOf() on user {0}\\{1}", model.CPOMemberOf.Organization, model.CPOMemberOf.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetUserMemberOf(model.CPOMemberOf);
                    var result = ps.Invoke();

                    foreach (var item in result)
                    {
                        model.CPOMemberOf.Groups.Add(item.ToString());
                    }
                }

                CommonCAS.Stats("User/GetUserMemberOf");

                return View("GetUserMemberOfSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateExtUser()
        {
            try
            {
                return View("CPOCreateExtUser", model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOCreateExtUser", model);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateExtUser(FormCollection _POST)
        {
            try
            {
                model.CPOCreateExtUser.Organization = _POST["organization"];
                model.CPOCreateExtUser.Name = _POST["name"];

                model.CPOCreateExtUser.Password = CommonCAS.GeneratePassword();
                model.CPOCreateExtUser.ExpirationDate = DateTime.Now.AddMonths(1).ToString("yyyy-MM-dd");

                CommonCAS.CPOLog(string.Format("has run User/CreateExtUser() to create ext user {0}_ext_{1}", model.CPOCreateExtUser.Organization, model.CPOCreateExtUser.Name));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateExtUser(model.CPOCreateExtUser).Invoke();
                }

                string defaultDomain = CommonCAS.GetDefaultAcceptedDomain(model.CPOCreateExtUser.Organization);

                model.CPOCreateExtUser.UserPrincipalName = string.Format("{0}_ext_{1}@{2}", model.CPOCreateExtUser.Organization, model.CPOCreateExtUser.Name, defaultDomain);

                CommonCAS.Stats("Capto/CPOCreateExtUser");

                return View("CPOCreateExtUserSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOCreateExtUser", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableUser()
        {
            try
            {
                return View("CPOEnableUser", model);
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOEnableUser", model);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnable(FormCollection _POST)
        {
            try
            {
                // property is disable but means enable
                model.CPOEnableUser.Organization = _POST["organization"];
                model.CPOEnableUser.UserPrincipalName = _POST["userprincipalname"];
                model.CPOEnableUser.Enable = _POST["removedisable"] == "on" ? true : false;
                model.CPOEnableUser.UnhideFromAddressList = _POST["removehidefromaddresslist"] == "on" ? true : false;

                if (!model.CPOEnableUser.Enable && !model.CPOEnableUser.UnhideFromAddressList)
                {
                    model.OKMessage.Add("No changes");
                    return View("CPOEnable", model);
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOEnable(hidden: {0}, enable: {1}) on user {2}", model.CPOEnableUser.UnhideFromAddressList, model.CPOEnableUser.Enable, model.CPOEnableUser.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.EnableUser(model.CPOEnableUser).Invoke();
                }

                CommonCAS.Stats("Capto/CPOEnableUser");

                if (model.CPOEnableUser.Enable)
                {
                    model.OKMessage.Add("User enabled.");
                }
                if (model.CPOEnableUser.UnhideFromAddressList)
                {
                    model.OKMessage.Add("User shown in address lists.");
                }

                return View("CPOEnableUser", model);

            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOEnableUser", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddAlias()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddAlias(FormCollection _POST)
        {
            try
            {
                CustomCPOAlias addAlias = new CustomCPOAlias()
                {
                    Organization = _POST["organization"],
                    UserPrincipalName = _POST["userprincipalname"],
                    EmailAddresses = _POST["emailaddresses"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>(),
                    SetFirstAsPrimary = _POST["setfirstasprimary"] == "on" ? true : false
                };
                for (int i = 0; i < addAlias.EmailAddresses.Count; i++) { addAlias.EmailAddresses[i] = addAlias.EmailAddresses[i].Trim(); }

                if (addAlias.EmailAddresses.Count == 0) { throw new Exception("No aliases specified"); }

                model.CPOAlias = addAlias;

                CommonCAS.CPOLog(string.Format("has run Capto/AddAlias() for user {0} to add alias {1}", addAlias.UserPrincipalName, string.Join(",", addAlias.EmailAddresses)));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddAlias(addAlias);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOAddAlias");

                model.OKMessage.Add("Successfully added alias for " + addAlias.UserPrincipalName + ":");
                foreach (string alias in addAlias.EmailAddresses)
                {
                    model.OKMessage.Add(alias);
                }

                return View("CPOAddAlias", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddAcceptedDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddAcceptedDomain(FormCollection _POST)
        {
            try
            {
                CustomCPOAcceptedDomain AddAcceptedDomain = new CustomCPOAcceptedDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"],
                    SetAsUPN = _POST["setasupn"] == "on" ? true : false
                };

                model.CPOAcceptedDomain = AddAcceptedDomain;

                CommonCAS.CPOLog(string.Format("has run Capto/AddAcceptedDomain() for organization {0} to add domain {1}", AddAcceptedDomain.Organization, AddAcceptedDomain.Domain));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddAcceptedDomain(AddAcceptedDomain.Organization, AddAcceptedDomain.Domain, AddAcceptedDomain.SetAsUPN);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/AddAcceptedDomain");

                model.OKMessage.Add(string.Format("'{0}' added for organization '{1}'.", model.CPOAcceptedDomain.Domain, model.CPOAcceptedDomain.Organization));

                return View("CPOAddAcceptedDomain", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveAlias()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveAlias(FormCollection _POST)
        {
            try
            {
                CustomCPOAlias removeAlias = new CustomCPOAlias()
                {
                    Organization = _POST["organization"],
                    UserPrincipalName = _POST["userprincipalname"],
                    EmailAddresses = _POST["emailaddresses"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>()
                };
                for (int i = 0; i < removeAlias.EmailAddresses.Count; i++) { removeAlias.EmailAddresses[i] = removeAlias.EmailAddresses[i].Trim(); }

                if (removeAlias.EmailAddresses.Count == 0)
                {
                    throw new Exception("No aliases specified");
                }

                model.CPOAlias = removeAlias;

                CommonCAS.CPOLog(string.Format("has run Capto/CPORemoveAlias() for user {0} to remove alias {1}", removeAlias.UserPrincipalName, string.Join(", ", removeAlias.EmailAddresses)));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveAlias(removeAlias);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPRemoveAlias");

                model.OKMessage.Add("Succesfully removed alias for " + removeAlias.UserPrincipalName);
                foreach (string alias in removeAlias.EmailAddresses)
                {
                    model.OKMessage.Add(alias);
                }

                return View("CPORemoveAlias", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateMailbox()
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateMailbox(FormCollection _POST)
        {
            try
            {
                CustomCPOMailbox newMailbox = new CustomCPOMailbox()
                {
                    Name = _POST["name"].Trim(),
                    UserPrincipalName = _POST["userprincipalname"].Trim(),
                    Organization = _POST["organization"],
                    Type = _POST["type"],
                };

                if (_POST["emailaddresses"] != null)
                {
                    newMailbox.EmailAddresses = _POST["emailaddresses"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>();
                }
                else
                {
                    newMailbox.EmailAddresses = new List<string>();
                }

                model.CPOMailbox = newMailbox;

                CommonCAS.CPOLog(string.Format("has run Capto/CreateMailbox() to create {0}", newMailbox.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateMailbox(newMailbox);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add("Successfully created mailbox " + newMailbox.UserPrincipalName);

                CommonCAS.Stats("Capto/CreateMailbox");

                return View("CPOCreateMailbox", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateDistributionGroup()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateDistributionGroup(FormCollection _POST)
        {
            try
            {

                model.CPODistributionGroup.Name = _POST["name"];
                model.CPODistributionGroup.UserPrincipalName = _POST["primarysmtpaddress"];
                model.CPODistributionGroup.ManagedBy = _POST["userprincipalname"];
                model.CPODistributionGroup.Organization = _POST["organization"];
                model.CPODistributionGroup.RequireSenderAuthentication = _POST["allowexternalemails"] == "on" ? false : true;


                CommonCAS.CPOLog(string.Format("has run Capto/CreateDistributionGroup() on user {0}", model.CPODistributionGroup.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateDistributionGroup(model.CPODistributionGroup);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add("Succesfully created distribution group " + model.CPODistributionGroup.Name + " (" + model.CPODistributionGroup.UserPrincipalName + ")");

                CommonCAS.Stats("Capto/CPOCreateDistributionGroup");

                return View("CPOCreateDistributionGroup", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddMailboxPermission()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddMailboxPermission(FormCollection _POST)
        {
            try
            {
                CustomCPOMailboxPermission addMailboxPermission = new CustomCPOMailboxPermission()
                {
                    Organization = _POST["organization"],
                    UserPrincipalName = _POST["userprincipalname"],
                    FullAccess = _POST["fullaccess"] == "on" ? true : false,
                    SendAs = _POST["sendas"] == "on" ? true : false
                };

                model.CPOMailboxPermission = addMailboxPermission;

                CommonCAS.CPOLog(string.Format("has run Capto/AddMailboxPermission() on user {0}", addMailboxPermission.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddMailboxPermission(addMailboxPermission);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOAddMailboxPermission");

                if (model.CPOMailboxPermission.FullAccess)
                {
                    model.OKMessage.Add(string.Format("Successfully created FullAccess group for {0}.", model.CPOMailboxPermission.UserPrincipalName));
                }

                if (model.CPOMailboxPermission.SendAs)
                {
                    model.OKMessage.Add(string.Format("Successfully created SendAs group for {0}.", model.CPOMailboxPermission.UserPrincipalName));
                }

                return View("CPOAddMailboxPermission", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailforward()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailforward(FormCollection _POST)
        {
            try
            {
                model.CPOMailforward.UserPrincipalName = _POST["userprincipalname"];
                model.CPOMailforward.Organization = _POST["organization"];
                model.CPOMailforward.ForwardingSmtpAddress = _POST["forwardingaddress"];
                model.CPOMailforward.ForwardingType = _POST["forwardingtype"];
                model.CPOMailforward.DeliverToMailboxAndForward = _POST["delivertomailboxandforward"] == "on" ? true : false;

                if (model.CPOMailforward.ForwardingSmtpAddress == string.Empty)
                {
                    model.CPOMailforward.ForwardingSmtpAddress = "clear";
                }

                CommonCAS.CPOLog(string.Format("has run Capto/SetMailforward(address: {1}) on user {0}", model.CPOMailforward.UserPrincipalName, model.CPOMailforward.ForwardingSmtpAddress));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetMailforward(model.CPOMailforward);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/SetMailforward");

                switch (model.CPOMailforward.ForwardingType.ToUpper())
                {
                    case "INTERNAL":
                        model.OKMessage.Add(string.Format("Successfully set mailforward for {0} to {1}.", model.CPOMailforward.UserPrincipalName, model.CPOMailforward.ForwardingSmtpAddress));
                        break;
                    case "EXTERNAL":
                        model.OKMessage.Add(string.Format("Successfully set mailforward for {0} to {1}.", model.CPOMailforward.UserPrincipalName, model.CPOMailforward.ForwardingSmtpAddress));
                        break;
                    case "CLEAR":
                        model.OKMessage.Add(string.Format("Successfully removed mailforward for {0}.", model.CPOMailforward.UserPrincipalName));
                        break;
                }

                return View("CPOSetMailforward", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailboxPlan()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailboxPlan(FormCollection _POST)
        {
            try
            {
                model.CPOMailboxPlan.Organization = _POST["organization"];
                model.CPOMailboxPlan.UserPrincipalName = _POST["userprincipalname"];
                model.CPOMailboxPlan.MailboxPlan = _POST["mailboxplan"];

                CommonCAS.CPOLog(string.Format("has run Capto/SetMailboxPlan (user: {0}, plan: {1})", model.CPOMailboxPlan.UserPrincipalName, model.CPOMailboxPlan.MailboxPlan));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetMailboxPlan(model.CPOMailboxPlan);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOSetMailboxPlan");

                model.OKMessage.Add("MailboxPlan successfully set.");

                return View("CPOSetMailboxPlan", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailboxAutoResize()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetMailboxAutoResize(FormCollection _POST)
        {
            try
            {
                CustomCPOMailboxAutoResize mailboxAutoResize = new CustomCPOMailboxAutoResize()
                {
                    Organization = _POST["organization"],
                    ExcludeFromAutoResize = _POST["exclude"] == "true" ? true : false
                };

                model.CPOMailboxAutoResize = mailboxAutoResize;

                CommonCAS.CPOLog(string.Format("has run Capto/SetMailboxAutoResize() for organization {0} to set exclude to {1}", mailboxAutoResize.Organization, mailboxAutoResize.ExcludeFromAutoResize));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetMailboxAutoResize(mailboxAutoResize);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOSetMailboxAutoResize");

                if (mailboxAutoResize.ExcludeFromAutoResize)
                {
                    model.OKMessage.Add(string.Format("Excluded {0} from mailbox auto resizing", mailboxAutoResize.Organization));
                }
                else
                {
                    model.OKMessage.Add(string.Format("Enabled mailbox auto resizing for {0}", mailboxAutoResize.Organization));
                }

                return View("CPOSetMailboxAutoResize", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetDeviceReport()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetDeviceReport(FormCollection _POST)
        {
            try
            {
                model.CPODeviceReport.Organization = _POST["organization"];
                model.CPODeviceReport.UserPrincipalName = _POST["userprincipalname"];

                CommonCAS.CPOLog(string.Format("has run Capto/GetDeviceReport for user {0}", model.CPODeviceReport.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetDeviceReport(model.CPODeviceReport);
                    var result = ps.Invoke();

                    if (result.Count() > 2)
                    {
                        foreach (var item in result)
                        {
                            model.CPODeviceReport.ReportHtml += item.ToString();
                        }
                    }
                    else
                    {
                        throw new Exception(model.CPODeviceReport.UserPrincipalName + " does not have any mobile devices connected.");
                    }
                }

                CommonCAS.Stats("Capto/CPOGetDeviceReport");

                return View("CPOGetDeviceReportSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODeleteMailContact()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODeleteMailContact(FormCollection _POST)
        {
            try
            {
                model.CPOMailContact.Organization = _POST["organization"];
                model.CPOMailContact.PrimarySmtpAddress = _POST["primarysmtpaddress"];

                CommonCAS.CPOLog(string.Format("has run Capto/DeleteMailContact for contact {0}\\{1}", model.CPOMailContact.Organization, model.CPOMailContact.PrimarySmtpAddress));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.DeleteMailContact(model.CPOMailContact).Invoke();
                }

                CommonCAS.Stats("Capto/CPODeleteMailContact");

                return View("CPODeleteMailContactSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODeleteDistributionGroup()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODeleteDistributionGroup(FormCollection _POST)
        {
            try
            {
                model.CPODistributionGroup.Organization = _POST["organization"];
                model.CPODistributionGroup.PrimarySmtpAddress = _POST["primarysmtpaddress"];

                CommonCAS.CPOLog(string.Format("has run Capto/DeleteDistributionGroup for contact {0}\\{1}", model.CPODistributionGroup.Organization, model.CPODistributionGroup.PrimarySmtpAddress));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.DeleteDistributionGroup(model.CPODistributionGroup).Invoke();
                }

                CommonCAS.Stats("Capto/CPODeleteDistributionGroup");

                return View("CPODeleteDistributionGroupSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddDistributionGroupManager()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddDistributionGroupManager(FormCollection _POST)
        {
            try
            {
                model.CPODistributionGroup.Organization = _POST["organization"];
                model.CPODistributionGroup.PrimarySmtpAddress = _POST["primarysmtpaddress"];
                model.CPODistributionGroup.ManagedBy = _POST["upnselector"];

                CommonCAS.CPOLog(string.Format("has run Capto/AddDistributionGroupManager for group {0}\\{1}", model.CPODistributionGroup.Organization, model.CPODistributionGroup.PrimarySmtpAddress));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddDistributionGroupManager(model.CPODistributionGroup).Invoke();
                }

                CommonCAS.Stats("Capto/CPOAddDistributionGroupManager");

                return View("CPOAddDistributionGroupManagerSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetCalendarPermissions()
        {
            try
            {
                return View("CPOGetCalendarPermissions", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        public ActionResult CPOSetCalendarPermissions()
        {
            return CPOGetCalendarPermissions();
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetCalendarPermissions(FormCollection _POST)
        {
            try
            {
                model.CPOCalendarPermissions.Organization = _POST["organization"];
                model.CPOCalendarPermissions.UserPrincipalName = _POST["userprincipalname"];
                model.CPOCalendarPermissions.User = _POST.GetValues("user[]");
                model.CPOCalendarPermissions.AccessRights = _POST.GetValues("accessrights[]");

                CommonCAS.CPOLog(string.Format("has run Capto/SetCalendarPermissions for user {0}\\{1}", model.CPOCalendarPermissions.Organization, model.CPOCalendarPermissions.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetCalendarPermissions(model.CPOCalendarPermissions).Invoke();
                }

                CommonCAS.Stats("Capto/CPOSetCalendarPermissions");

                model.OKMessage.Add(string.Format("Success, updated calendar permissions for '{0}' ", model.CPOCalendarPermissions.UserPrincipalName));

                return View("CPOGetCalendarPermissions", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOGetCalendarPermissions", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetAllMailboxPlans()
        {
            try
            {
                return View("CPOSetAllMailboxPlans", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetAllMailboxPlans(FormCollection _POST)
        {
            try
            {
                model.CPOMailboxPlan.Organization = _POST["organization"];
                model.CPOMailboxPlan.MailboxPlan = _POST["mailboxplan"];

                CommonCAS.CPOLog(string.Format("has run Capto/SetAllMailboxPlans({1}) for organization {0}", model.CPOMailboxPlan.Organization, model.CPOMailboxPlan.MailboxPlan));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetAllMailboxPlans(model.CPOMailboxPlan).Invoke();
                }

                CommonCAS.Stats("Capto/CPOSetAllMailboxPlans");

                //model.OKMessage = string.Format("Org: {0}, Plan: {1}", model.MailboxPlan.Organization, model.MailboxPlan.MailboxPlan);
                model.OKMessage.Add("Success");

                return View("CPOSetAllMailboxPlans", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOSetAllMailboxPlans", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveMailbox()
        {
            try
            {
                return View("CPORemoveMailbox", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveMailbox(FormCollection _POST)
        {
            try
            {
                model.CPOMailbox.Organization = _POST["organization"];
                model.CPOMailbox.UserPrincipalName = _POST["identity"];

                CommonCAS.CPOLog(string.Format("has run Capto/RemoveMailbox for {0}\\{1}", model.CPOMailbox.Organization, model.CPOMailbox.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveMailbox(model.CPOMailbox).Invoke();
                }

                CommonCAS.Stats("Capto/CPORemoveMailbox");

                model.OKMessage.Add(string.Format("{0}\\{1} was deleted successfully. It can take up to 30 seconds for the mailbox to disappear from SelfService.", model.CPOMailbox.Organization, model.CPOMailbox.UserPrincipalName));

                return View("CPORemoveMailbox", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPORemoveMailbox", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddMailboxPermissionFullAccess()
        {
            try
            {
                return View("CPOAddMailboxPermissionFullAccess", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddMailboxPermissionFullAccess(FormCollection _POST)
        {
            try
            {
                model.CPOMailboxPermissionFullAccess.Organization = _POST["organization"];
                model.CPOMailboxPermissionFullAccess.UserPrincipalName = _POST["userprincipalname"];

                CommonCAS.CPOLog(string.Format("has run Capto/CPOAddMailboxPermissionFullAccess on {0}\\{1}", model.CPOMailboxPermissionFullAccess.Organization, model.CPOMailboxPermissionFullAccess.UserPrincipalName));

                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddMailboxPermissionFullAccess(model.CPOMailboxPermissionFullAccess).Invoke();
                }

                CommonCAS.Stats("Capto/CPOAddMailboxPermissionFullAccess");

                model.OKMessage.Add("Success");

                return View("CPOAddMailboxPermissionFullAccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CPOAddMailboxPermissionFullAccess", model);
            }
        }



        // Ajax function - returns a set of options for a select, containing all available mailbox plans
        public string CPOGetMailboxPlans(string organization, string selectedvalue)
        {
            string ret = "";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetMailboxPlans(organization);
                var result = ps.Invoke();

                foreach (var item in result)
                {
                    if (selectedvalue == item.ToString())
                    {
                        ret += "<option selected=\"selected\">" + item.ToString() + "</option>";
                    }
                    else
                    {
                        ret += "<option>" + item.ToString() + "</option>";
                    }
                }
            }

            return ret;
        }


        // Ajax function - returns currently active mailbox plan set on a mailbox
        public string CPOGetMailboxPlan(string organization, string userprincipalname)
        {
            string ret = "";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetMailboxPlan(organization, userprincipalname);
                var result = ps.Invoke();

                foreach (var item in result)
                {
                    ret += item.ToString();
                }
            }

            return ret;
        }

        /// <summary>
        /// Ajax function for aquiring domains tied to an organization
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        public string CPOGetAcceptedDomain(string organization)
        {
            string returnstr = "<ul>";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetAcceptedDomain(organization);
                var result = ps.Invoke();

                // Returns PSObject with properties: Name, DomainName, DomainType, Default
                foreach (var item in result)
                {
                    returnstr += "<li>" + item.Members["DomainName"].Value.ToString() + "</li>";
                }
            }

            returnstr += "</ul>";

            return returnstr;
        }

        /// <summary>
        /// Gets existing email aliases on a user
        /// </summary>
        /// <param name="organization"></param>
        /// <param name="userprincipalname"></param>
        /// <returns></returns>
        public string CPOGetExistingAliases(string organization, string userprincipalname)
        {
            string returnstr = "<ul>";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetExistingAliases(organization, userprincipalname);
                var result = ps.Invoke();

                // Returns simple string array
                foreach (var item in result)
                {
                    returnstr += "<li>" + item.ToString() + "</li>";
                }
            }

            returnstr += "</ul>";

            return returnstr;
        }

        // ajax function - returns a <select> with the specified select name, and sets up a script to update the specified input field
        public string CPOGetMailboxes(string organization, string selectname = "upnselector", string inputname = "userprincipalname")
        {
            string returnstr = "<select name=\"" + selectname + "\"><option selected=\"selected\" value=\"\">... select a person</option>";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetMailboxes(organization);
                var result = ps.Invoke();

                foreach (var item in result)
                {
                    string upn = item.ToString().Split(';')[0];
                    string name = item.ToString().Split(';')[1];
                    string disabled = item.ToString().Split(';')[2];
                    string hidden = item.ToString().Split(';')[3];

                    returnstr += string.Format("<option value=\"{0}\">{1}{2}{3}</option>",
                        upn, //0
                        name, //1
                        disabled == "True" ? "(disabled)" : "", //2
                        hidden == "True" ? "(hidden)" : ""//3
                    );
                }
            }

            returnstr += "</select>";

            returnstr += "<script>$(\"select[name=" + selectname + "]\").change(function () { var upn = $(\"select[name=" + selectname + "]\").val(); $(\"input[name=" + inputname + "]\").val(upn); GetExistingAliases(); }); </script>";

            return returnstr;
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetItemsReport()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOGetItemsReport(FormCollection _POST)
        {
            try
            {
                CustomCPOItemsReport CPOGetItemsReport = new CustomCPOItemsReport()
                {
                    Organization = _POST["organization"],
                    Mail = _POST["mail"],
                    GetALL = _POST["getall"] == "on" ? true : false
                };

                model.CPOItemsReport = CPOGetItemsReport;

                CommonCAS.CPOLog(string.Format("has run Capto/GetItemsReport() for organization {0} and sent the report to {1}", CPOGetItemsReport.Organization, CPOGetItemsReport.Mail));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.GetItemsReport(CPOGetItemsReport.Organization, CPOGetItemsReport.Mail, CPOGetItemsReport.GetALL);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOGetItemsReport");

                model.OKMessage.Add(string.Format("'{0}' has been sent the report!...", model.CPOItemsReport.Mail));

                return View("CPOGetItemsReport", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableSikkerMail()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableSikkerMail(FormCollection _POST)
        {
            try
            {
                CustomCPOSikkermail CPOenableSikkermail = new CustomCPOSikkermail()
                {
                    Organization = _POST["organization"],
                    SendAsGroup = _POST["distinguishedname"],
                    Alias = _POST["alias"],
                    Remove = _POST["remove"] == "on" ? true : false,
                    Force = _POST["force"] == "on" ? true : false,
                    UpdateAll = _POST["updateall"] == "on" ? true : false
                };

                model.CPOSikkermail = CPOenableSikkermail;

                CommonCAS.CPOLog(string.Format("has run Capto/EnableSikkerMail() for Organization {0} to enable {1}", CPOenableSikkermail.Organization, CPOenableSikkermail.SendAsGroup));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.EnableSikkermail(CPOenableSikkermail.Organization, CPOenableSikkermail.SendAsGroup, CPOenableSikkermail.Alias, CPOenableSikkermail.Remove, CPOenableSikkermail.Force, CPOenableSikkermail.UpdateAll);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/EnableSikkermail");
                if (CPOenableSikkermail.UpdateAll == true)
                {
                    model.OKMessage.Add("Successfully enabled Sikkermail attributes for everyone!");
                }
                if (CPOenableSikkermail.Force == true)
                {
                    model.OKMessage.Add("Successfully forced Sikkermail conf for " + CPOenableSikkermail.Organization + " : " + CPOenableSikkermail.SendAsGroup + "");
                }
                if (CPOenableSikkermail.Remove == true)
                {
                    model.OKMessage.Add("Successfully removed Sikkermail conf for " + CPOenableSikkermail.Organization + " : " + CPOenableSikkermail.SendAsGroup + "");
                }
                if (CPOenableSikkermail.Force == false & CPOenableSikkermail.UpdateAll == false)
                {
                    model.OKMessage.Add("Successfully enabled Sikkermail conf for " + CPOenableSikkermail.Organization + " : " + CPOenableSikkermail.SendAsGroup + "");
                };

                return View("CPOEnableSikkermail", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetOOFMessage()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        [AcceptVerbs(HttpVerbs.Post)]
        [ValidateInput(false)]
        public ActionResult CPOSetOOFMessage(FormCollection _POST)
        {
            try
            {
                CustomCPOOOF CPOOOF = new CustomCPOOOF()
                {
                    Organization = _POST["organization"].ToString(),
                    UserPrincipalName = _POST["userprincipalname"].ToString()
                };

                if (_POST["StartTime"] != null)
                {
                    CPOOOF.StartTime = _POST["starttime"].ToString();
                }
                if (_POST["EndTime"] != null)
                {
                    CPOOOF.EndTime = _POST["endtime"].ToString();
                }
                if (_POST["Internal"] != null)
                {
                    CPOOOF.Internal = _POST["internal"].ToString();
                }
                if (_POST["External"] != null)
                {
                    CPOOOF.External = _POST["external"].ToString();
                };

                CommonCAS.CPOLog(string.Format("has run Capto/SetOOFMessage() for organization {0} and mailbox {1}", CPOOOF.Organization, CPOOOF.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetOOFMessage(CPOOOF);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPOSetOOFMessage");

                model.OKMessage.Add(string.Format("'{0}' OOF has been updated...", CPOOOF.UserPrincipalName));

                return View("CPOSetOOFMessage", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveOOFMessage()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        [AcceptVerbs(HttpVerbs.Post)]
        [ValidateInput(false)]
        public ActionResult CPORemoveOOFMessage(FormCollection _POST)
        {
            try
            {
                CustomCPOOOF CPOOOF = new CustomCPOOOF()
                {
                    Organization = _POST["organization"].ToString(),
                    UserPrincipalName = _POST["userprincipalname"].ToString()
                };

                CommonCAS.CPOLog(string.Format("has run Capto/RemoveOOFMessage() for organization {0} and mailbox {1}", CPOOOF.Organization, CPOOOF.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveOOFMessage(CPOOOF);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("Capto/CPORemoveOOFMessage");

                model.OKMessage.Add(string.Format("'{0}' OOF has been removed...", CPOOOF.UserPrincipalName));

                return View("CPORemoveOOFMessage", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreate()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreate(FormCollection _POST)
        {
            try
            {

                // set up organization for display in view
                CustomCPOOrganization organization = new CustomCPOOrganization()
                {
                    Name = _POST["name"].ToUpper(),
                    EmailDomainName = _POST["emaildomainname"].ToLower(),
                    FileServer = _POST["fileserver"],
                    FileServerDriveLetter = _POST["driveletter"],
                    Solution = _POST["solution"].ToUpper()
                };

                model.CPOOrganization = organization;

                if (model.Organizations.Contains(model.CPOOrganization.Name))
                {
                    throw new ArgumentException(string.Format("The organizaton '{0}' already exists.", model.CPOOrganization.Name));
                }

                switch (model.CPOOrganization.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "MEMBER2015":
                        break;
                    case "LEGAL":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.CPOOrganization.Solution));
                }

                if (model.CPOOrganization.Name.Length < 2 || model.CPOOrganization.Name.Length > 5)
                {
                    throw new ArgumentException("The organizaton name must be between 2 and 5 characters.");
                }

                if (!model.CPOOrganization.EmailDomainName.Contains(".") || model.CPOOrganization.EmailDomainName.Contains("@"))
                {
                    throw new ArgumentException(string.Format("'{0}' is not a valid email domain name.", model.CPOOrganization.EmailDomainName));
                }

                if (!model.CPOOrganization.EmailDomainName.StartsWith("dummy."))
                {
                    model.CPOOrganization.EmailDomainName = "dummy." + model.CPOOrganization.EmailDomainName;
                }

                CommonCAS.CPOLog(string.Format("has run Organization/Create() to create {0}", model.CPOOrganization.Name));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateOrganization(model.CPOOrganization.Name, model.CPOOrganization.EmailDomainName, model.CPOOrganization.Solution, model.CPOOrganization.FileServer, model.CPOOrganization.FileServerDriveLetter);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}' created with solution '{1}'.", model.CPOOrganization.Name, model.CPOOrganization.Solution));

                CommonCAS.Stats("Capto/CPOCreate");

                return View("CPOCreate", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetNavCompanyName()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOSetNavCompanyName(FormCollection _POST)
        {
            try
            {
                model.CPONavCompanyName = new CustomCPONavCompanyName()
                {
                    Organization = _POST["organization"],
                    CompanyName = _POST["navcompanyname"],
                    NativeDatabase = _POST["nativedb"] == "on" ? true : false,
                    Force = _POST["force"] == "on" ? true : false
                };

                if (!model.CPOOrganizations.Contains(model.CPONavCompanyName.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOSetNavCompanyName() to set CompanyName '{0}' for '{1}'", model.CPONavCompanyName.CompanyName, model.CPONavCompanyName.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.SetNavCompanyName(model.CPONavCompanyName.Organization, model.CPONavCompanyName.CompanyName, model.CPONavCompanyName.NativeDatabase, model.CPONavCompanyName.Force);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("CompanyName '{0}' set for organization '{1}'.", model.CPONavCompanyName.CompanyName, model.CPONavCompanyName.Organization));

                CommonCAS.Stats("Capto/CPOSetNavCompanyName");

                return View("CPOSetNavCompanyName", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveDummyDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveDummyDomain(FormCollection _POST)
        {
            try
            {
                model.CPORemoveDummyDomain = new CustomCPORemoveDummyDomain()
                {
                    Organization = _POST["organization"]
                };

                if (!model.CPOOrganizations.Contains(model.CPORemoveDummyDomain.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Organization/CPORemoveDummyDomain().", model.CPORemoveDummyDomain.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveDummyDomain(model.CPORemoveDummyDomain.Organization);
                    var result = ps.Invoke();

                    foreach (PSObject message in result)
                    {
                        model.OKMessage.Add(message.ToString());
                    }
                }

                //model.OKMessage.Add(string.Format("CompanyName '{0}' set for organization '{1}'.", model.CPORemoveDummyDomain.CompanyName, model.CPORemoveDummyDomain.Organization));

                CommonCAS.Stats("Capto/CPORemoveDummyDomain");

                return View("CPORemoveDummyDomain", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPORemoveCustomer(FormCollection _POST)
        {
            try
            {
                model.CPORemoveCustomer = new CustomCPORemoveCustomer()
                {
                    Organization = _POST["organization"],
                    RemoveData = _POST["removedata"] == "on" ? true : false,
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.CPOOrganizations.Contains(model.CPORemoveCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPORemoveCustomer() to remove customer '{0}'", model.CPORemoveCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.RemoveCustomer(model.CPORemoveCustomer.Organization, model.CPORemoveCustomer.RemoveData, model.CPORemoveCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Customer '{0}' removed, Check manual steps.", model.CPORemoveCustomer.Organization));

                CommonCAS.Stats("Capto/CPORemoveCustomer");

                return View("CPORemoveCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODisableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPODisableCustomer(FormCollection _POST)
        {
            try
            {
                model.CPODisableCustomer = new CustomCPODisableCustomer()
                {
                    Organization = _POST["organization"],
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.CPOOrganizations.Contains(model.CPODisableCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPODisableCustomer()", model.CPODisableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.DisableCustomer(model.CPODisableCustomer.Organization, model.CPODisableCustomer.Confirm);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been disabled and Activesync is disabled on mailbox.", model.CPODisableCustomer.Organization));

                CommonCAS.Stats("Capto/CPODisableCustomer");

                return View("CPODisableCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableCustomer(FormCollection _POST)
        {
            try
            {
                model.CPOEnableCustomer = new CustomCPOEnableCustomer()
                {
                    Organization = _POST["organization"],
                };

                if (!model.CPOOrganizations.Contains(model.CPOEnableCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }
                CommonCAS.CPOLog(string.Format("has run Capto/CPOEnableCustomer()", model.CPOEnableCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.EnableCustomer(model.CPOEnableCustomer.Organization);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Organization '{0}', ADUsers has been enabled and Activesync is enabled on mailbox.", model.CPOEnableCustomer.Organization));

                CommonCAS.Stats("Capto/CPOEnableCustomer");

                return View("CPOEnableCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display convert view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOConvertCustomer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOConvertCustomer(FormCollection _POST)
        {
            try
            {
                model.CPOConvertCustomer = new CustomCPOConvertCustomer()
                {
                    Organization = _POST["organization"],
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                if (!model.CPOOrganizations.Contains(model.CPOConvertCustomer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOConvertCustomer()", model.CPOConvertCustomer.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.ConvertCustomer(model.CPOConvertCustomer.Organization, model.CPOConvertCustomer.Confirm);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("Customer has been converted successfully.");
                    }
                    else
                    {
                        model.OKMessage.Add("Customer has been converted, but with the following info:");

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                        CommonCAS.CPOLog(string.Format("Customer converted with info:", model.OKMessage));
                    }
                }

                model.OKMessage.Add(string.Format("Organization '{0}', has been convertet.", model.CPOConvertCustomer.Organization));

                CommonCAS.Stats("Capto/CPOConvertCustomer");

                return View("CPOConvertCustomer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        // Display account view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateAccount()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateAccount(FormCollection _POST)
        {
            try
            {
                model.CPOCreateAccount = new CustomCPOCreateAccount()
                {
                    Organization = _POST["organization"],
                    AccountName = _POST["accountname"],
                    ShortName = _POST["shortname"]
                };

                if (!model.CPOOrganizations.Contains(model.CPOCreateAccount.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOCreateAccount()", model.CPOCreateAccount.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateAccount(model.CPOCreateAccount.Organization, model.CPOCreateAccount.AccountName, model.CPOCreateAccount.ShortName);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Extra NAV Instance (with account, SPN and SVC), has been created for Organization '{0}'.", model.CPOCreateAccount.Organization));

                CommonCAS.Stats("Capto/CPOCreateAccount");

                return View("CPOCreateAccount", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddDomain()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOAddDomain(FormCollection _POST)
        {
            try
            {
                model.CPOAddDomain = new CustomCPOAddDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"]
                };

                if (!model.CPOOrganizations.Contains(model.CPOAddDomain.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOAddDomain() to add '{0}' for '{1}'", model.CPOAddDomain.Domain, model.CPOAddDomain.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.AddUPN(model.CPOAddDomain.Organization, model.CPOAddDomain.Domain);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Domain '{0}' added for organization '{1}'.", model.CPOAddDomain.Domain, model.CPOAddDomain.Organization));

                CommonCAS.Stats("Capto/CPOAddDomain");

                return View("CPOAddDomain", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display Enable365Customer view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnable365Customer()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnable365Customer(FormCollection _POST)
        {
            try
            {
                model.CPOEnable365Customer = new CustomCPOEnable365Customer()
                {
                    Organization = _POST["organization"],
                    TenantID = _POST["tenantid"],
                    TenantAdmin = _POST["tenantadmin"],
                    TenantPass = _POST["tenantpass"]
                };

                if (!model.CPOOrganizations.Contains(model.CPOEnable365Customer.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOEnable365Customer() to add ID '{0}' for '{1}'", model.CPOEnable365Customer.TenantID, model.CPOEnable365Customer.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.Enable365Customer(model.CPOEnable365Customer.Organization, model.CPOEnable365Customer.TenantID, model.CPOEnable365Customer.TenantAdmin, model.CPOEnable365Customer.TenantPass);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("TenantID '{0}' added for organization '{1}'.", model.CPOEnable365Customer.TenantID, model.CPOEnable365Customer.Organization));

                CommonCAS.Stats("Capto/CPOEnable365Customer");

                return View("CPOEnable365Customer", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        /// <summary>
        /// Ajax function for aquiring TenantIDs
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string CPOGetTenantInformation(string organization)
        {
            string returnstr = "<table>";

            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetTenantInformation(organization);
                var result = ps.Invoke();

                // Returns string with properties..
                foreach (var item in result)
                {
                    returnstr += "<tr><td><b>Office 365 PartnerName : </b></td><td>" + item.Members["PartnerName"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 TenantID    : </b></td><td>" + item.Members["Id"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 Admin       : </b></td><td>" + item.Members["Admin"].Value.ToString() + "</td></tr>";
                    returnstr += "<tr><td><b>Office 365 License     : </b></td><td>" + item.Members["License"].Value.ToString() + "</td></tr>";
                }
            }

            returnstr += "</table>";

            return returnstr;
        }

        // Display EnableFederation view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableFederation()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }



        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOEnableFederation(FormCollection _POST)
        {
            try
            {
                model.CPOEnableFederation = new CustomCPOEnableFederation()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"]
                };

                if (!model.CPOOrganizations.Contains(model.CPOEnableFederation.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOEnableFederation() to enable federation on '{0}' for '{1}'", model.CPOEnableFederation.Domain, model.CPOEnableFederation.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.EnableFederation(model.CPOEnableFederation.Organization, model.CPOEnableFederation.Domain);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Domain '{0}' added for organization '{1}'.", model.CPOEnableFederation.Domain, model.CPOEnableFederation.Organization));

                CommonCAS.Stats("Capto/CPOEnableFederation");

                return View("CPOEnableFederation", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCustomerReport()
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCustomerReport(FormCollection _POST)
        {
            try
            {
                model.CPOCustomerReport = new CustomCPOCustomerReport();
                model.CPOCustomerReport.Organization = _POST["organization"];

                CommonCAS.CPOLog(string.Format("has run Capto/CPOCustomerReport/{0}", model.CPOCustomerReport.Organization));

                CPOCustomerReportGenerateLive();
                //CustomerReportGenerate();

                CommonCAS.Stats("Capto/CPOCustomerReport/" + model.CPOCustomerReport.Organization);

                return View("CPOCustomerReportSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public string CPOCustomerReportCSV(string organization)
        {
            try
            {
                model.CPOCustomerReport = new CustomCPOCustomerReport();
                model.CPOCustomerReport.Organization = organization;

                CPOCustomerReportGenerateLive();

                string retStr = "<pre>";

                retStr += string.Format("<table><tr><td>Disk usage:</td><td>{0}</td></tr><tr><td>Disk quota:</td><td>{1}</td></tr><tr><td>Exchange usage:</td><td>{2} GB</td></tr><tr><td>Exchange quota:</td><td>{3:0.00} GB</td></tr><tr><td>Total disk usage:</td><td>{4} GB</td></tr><tr><td>Total disk quota:</td><td>{5} GB</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td></table>", model.CPOCustomerReport.DiskUsage, model.CPOCustomerReport.DiskQuota, model.CPOCustomerReport.ExchangefUsage, model.CPOCustomerReport.ExchangefQuota, model.CPOCustomerReport.DiskTotalUsage, model.CPOCustomerReport.DiskTotalQuota);

                retStr += "<table><tr><td>Name</td><td>Email</td><td>Usage</td><td>Quota</td></tr>";
                foreach (CPOExchangeUser user in model.CPOCustomerReport.ExchangeUsers)
                {
                    retStr += string.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>", user.Name, user.Email, user.Usage, user.Quota);
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Windows Licenses (" + model.CPOCustomerReport.Licenses.Windows.Count + ")</td></tr>";
                foreach (string user in model.CPOCustomerReport.Licenses.Windows)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office Standard Licenses (" + model.CPOCustomerReport.Licenses.OfficeStandard.Count + ")</td></tr>";
                foreach (string user in model.CPOCustomerReport.Licenses.OfficeStandard)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Mail Only (" + model.CPOCustomerReport.Licenses.MailOnly.Count + ")</td></tr>";
                foreach (string user in model.CPOCustomerReport.Licenses.MailOnly)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }
                retStr += "</table>";

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office Standard Licenses (" + model.CPOCustomerReport.Licenses.StudJur.Count + ")</td></tr>";
                foreach (string user in model.CPOCustomerReport.Licenses.StudJur)
                {
                    retStr += "<tr><td>" + user + "</td></tr>";
                }

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Sikkermail enabled groups (" + model.CPOCustomerReport.Licenses.Sikkermail.Count + ")</td></tr>";
                foreach (string sikkermail in model.CPOCustomerReport.Licenses.Sikkermail)
                {
                    retStr += "<tr><td>" + sikkermail + "</td></tr>";
                }

                retStr += "<table><tr><td>&nbsp;</td></tr><tr><td>Office 365 information: </td></tr>";
                retStr += "<table><tr><td>PartnerName </td><td>License </td><td>ActiveUnits </td><td>ConsumedUnits </td><td>FreeUnits </td></tr>";
                foreach (CPOInfo365 info in model.CPOCustomerReport.Info365s)
                {
                    retStr += string.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>", info.PartnerName, info.License, info.ActiveUnits, info.ConsumedUnits, info.FreeUnits);
                }
                retStr += "</table>";


                return retStr + "</pre>";
            }
            catch (Exception exc)
            {
                model.ActionFailed = true;
                model.Message = exc.Message;
                return model.Message + string.Join("<br />", model.MessageList);
            }
        }

        private void CPOCustomerReportGenerateLive()
        {
            using (CPOMyPowerShell ps = new CPOMyPowerShell())
            {
                ps.GetCustomerReportLive(model.CPOCustomerReport.Organization);
                var result = ps.Invoke().Single();
                var mailbox = (PSObject)result.Properties["Mailbox"].Value;
                var files = (PSObject)result.Properties["Files"].Value;
                var users = (Object[])mailbox.Properties["Users"].Value;
                var database = (PSObject)result.Properties["Database"].Value;
                var office365 = (PSObject)result.Properties["Office365"].Value;
                var info365s = (Object[])office365.Properties["Info"].Value;
                var sikkermail = (PSObject)result.Properties["Sikkermail"].Value;
                var groups = (Object[])sikkermail.Properties["Groups"].Value;

                model.CPOCustomerReport.DatabasefUsage = double.Parse(database.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CPOCustomerReport.DatabaseUsage = model.CPOCustomerReport.DatabasefUsage.ToString("F1") + " GB";

                model.CPOCustomerReport.DiskfUsage = double.Parse(files.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CPOCustomerReport.DiskUsage = model.CPOCustomerReport.DiskfUsage.ToString("F1") + " GB";
                model.CPOCustomerReport.DiskfQuota = double.Parse(files.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CPOCustomerReport.DiskQuota = model.CPOCustomerReport.DiskfQuota.ToString("F1") + " GB";

                model.CPOCustomerReport.ExchangefQuota = double.Parse(mailbox.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CPOCustomerReport.ExchangeQuota = model.CPOCustomerReport.ExchangefQuota.ToString("F1");
                model.CPOCustomerReport.ExchangefUsage = double.Parse(mailbox.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024;
                model.CPOCustomerReport.ExchangeUsage = model.CPOCustomerReport.ExchangefUsage.ToString("F1");
                model.CPOCustomerReport.ExchangeUsersCount = 0;

                model.CPOCustomerReport.SikkermailGroupsCount = 0;

                foreach (PSObject user in users)
                {
                    model.CPOCustomerReport.ExchangeUsers.Add(new CPOExchangeUser
                    {
                        Email = user.Properties["PrimarySmtpAddress"].Value.ToString(),
                        Name = user.Properties["DisplayName"].Value.ToString(),
                        Quota = (double.Parse(user.Properties["TotalAllocated"].Value.ToString()) / 1024 / 1024 / 1024).ToString("F0") + " GB",
                        Usage = (double.Parse(user.Properties["TotalUsage"].Value.ToString()) / 1024 / 1024 / 1024).ToString("F1") + " GB"
                    });

                    string testUser = user.Properties["TestUser"].Value.ToString();
                    string type = user.Properties["Type"].Value.ToString();
                    string disabled = user.Properties["Disabled"].Value.ToString();
                    string displayName = user.Properties["DisplayName"].Value.ToString();
                    string studJur = user.Properties["StudJur"].Value.ToString();
                    string mailOnly = user.Properties["MailOnly"].Value.ToString();

                    if (testUser != "True" && (type == "UserMailbox" && disabled != "True"))
                    {
                        model.CPOCustomerReport.ExchangeUsersCount++;

                        // Do not add MailOnly accounts to Windows nor Office.
                        if (mailOnly == "True")
                        {
                            model.CPOCustomerReport.Licenses.MailOnly.Add(displayName);
                        }
                        else
                        {
                            model.CPOCustomerReport.Licenses.Windows.Add(displayName);
                            model.CPOCustomerReport.Licenses.OfficeStandard.Add(displayName);
                        }

                        if (studJur == "True")
                        {
                            model.CPOCustomerReport.Licenses.StudJur.Add(displayName);
                        }
                    }
                }

                foreach (PSObject group in groups)
                {

                    string name = group.Properties["Name"].Value.ToString();
                    string description = group.Properties["Description"].Value.ToString();

                    model.CPOCustomerReport.SikkermailGroupsCount++;

                    model.CPOCustomerReport.Licenses.Sikkermail.Add(name);
                }

                foreach (PSObject info in info365s)
                {
                    model.CPOCustomerReport.Info365s.Add(new CPOInfo365
                    {
                        License = info.Properties["License"].Value.ToString(),
                        PartnerName = info.Properties["PartnerName"].Value.ToString(),
                        ActiveUnits = info.Properties["ActiveUnits"].Value.ToString(),
                        ConsumedUnits = info.Properties["ConsumedUnits"].Value.ToString(),
                        FreeUnits = info.Properties["FreeUnits"].Value.ToString(),
                    });

                }
            }
        }
        /*
        private void CPOCustomerReportGenerate()
        {
            using (SqlConnection sqlConnection = new SqlConnection("Data Source=DMZ027C1B\\SQLEXPRESS;Initial Catalog=CustomerReport;User ID=CustomerReport;Password=Systemhosting Customer Report SQL Password"))
            {
                sqlConnection.Open();

                //model.MessageList.Add("SPLA");
                #region SPLA
                using (SqlCommand command = new SqlCommand("SELECT u.name AS Name, t.[description] AS Type FROM users AS u, splatypes AS t, spla AS s WHERE s.orgid = (SELECT id FROM organization WHERE name = @Organization) AND u.id = s.userid AND s.typeid = t.id", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CPOCustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string name = sqlReader["Name"].ToString();
                        string type = sqlReader["Type"].ToString();

                        switch (type)
                        {
                            case "Windows License":
                                model.CPOCustomerReport.Licenses.Windows.Add(name);
                                break;
                            case "Office Standard":
                                model.CPOCustomerReport.Licenses.OfficeStandard.Add(name);
                                break;
                            case "Office Professional":
                                model.CPOCustomerReport.Licenses.OfficeProfessional.Add(name);
                                break;
                            case "Outlook":
                                model.CPOCustomerReport.Licenses.Outlook.Add(name);
                                break;
                            default:
                                model.CPOCustomerReport.Licenses.Unknown.Add(name);
                                break;
                        }
                    }

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Exchange");
                #region Exchange
                using (SqlCommand command = new SqlCommand("SELECT name, primarysmtp, exchusage, exchquota FROM users WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CPOCustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string name = sqlReader["name"].ToString();
                        string email = sqlReader["primarysmtp"].ToString();
                        string quota = sqlReader["exchquota"].ToString().Replace('.', ','); // doubleingpoint conversion is fucked up due to localization hi!~
                        string usage = sqlReader["exchusage"].ToString().Replace('.', ',');

                        try
                        {
                            usage = string.Format("{0:0.00} {1}", double.Parse(usage.Split(' ')[0]), usage.Split(' ')[1]);
                        }
                        catch { }

                        try
                        {
                            double fQuota = double.Parse(quota.Split(' ')[0]);
                            switch (quota.Split(' ')[1])
                            {
                                case "GB":
                                    // gb is good
                                    break;
                                case "MB":
                                    fQuota = fQuota / 1024; // upgrade to gb
                                    break;
                                case "KB":
                                    fQuota = fQuota / (1024 * 1024); // upgrade to gb
                                    break;
                                case "B":
                                    fQuota = 0;
                                    break;
                            }

                            model.CPOCustomerReport.ExchangefQuota += fQuota;

                            double fUsage = double.Parse(usage.Split(' ')[0]);
                            switch (usage.Split(' ')[1])
                            {
                                case "GB":
                                    // gb is good
                                    break;
                                case "MB":
                                    fUsage = fUsage / 1024;
                                    break;
                                case "KB":
                                    fUsage = fUsage / (1024 * 1024);
                                    break;
                                case "B":
                                    fUsage = 0;
                                    break;
                            }

                            model.CPOCustomerReport.ExchangefUsage += fUsage;
                        }
                        catch (Exception exc)
                        {
                            model.MessageList.Add("Exception : " + exc.Message);
                        }

                        model.CPOCustomerReport.ExchangeUsers.Add(new CPOExchangeUser() { Name = name, Quota = quota, Usage = usage, Email = email });
                    }

                    //convert to int for pretty, instead of 123,18327481414141 GB
                    model.CPOCustomerReport.ExchangeQuota = model.CPOCustomerReport.ExchangefQuota.ToString() + " GB";

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Disk");
                #region Disk
                using (SqlCommand command = new SqlCommand("SELECT usage, quota FROM [disk] WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CPOCustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {
                        string quota = sqlReader["quota"].ToString();
                        string usage = sqlReader["usage"].ToString();

                        // disk usage and quota has , as doubleing point seperator instead of . so it needs replacing before it can be parsed properly
                        model.CPOCustomerReport.DiskQuota = quota;
                        model.CPOCustomerReport.DiskUsage = usage;

                        double fQuota = 0;
                        double.TryParse(model.CPOCustomerReport.DiskQuota.Split(' ')[0], out fQuota);
                        switch (model.CPOCustomerReport.DiskQuota.Split(' ')[1])
                        {
                            case "GB":
                                // gb is good
                                break;
                            case "MB":
                                fQuota = fQuota / 1024; // upgrade to gb
                                break;
                            case "KB":
                                fQuota = fQuota / (1024 * 1024); // upgrade to gb
                                break;
                            case "B":
                                fQuota = 0;
                                break;
                            default:
                                fQuota = 0;
                                break;
                        }

                        double fUsage = 0;
                        double.TryParse(model.CPOCustomerReport.DiskUsage.Split(' ')[0], out fUsage);
                        switch (model.CPOCustomerReport.DiskUsage.Split(' ')[1])
                        {
                            case "GB":
                                // gb is good
                                break;
                            case "MB":
                                fUsage = fUsage / 1024;
                                break;
                            case "KB":
                                fUsage = fUsage / (1024 * 1024);
                                break;
                            case "B":
                                fUsage = 0;
                                break;
                            default:
                                fUsage = 0;
                                break;
                        }

                        //model.MessageList.Add(string.Format("Quota: {0} Usage: {1}", model.CustomerReport2.DiskQuota, model.CustomerReport2.DiskUsage));

                        model.CPOCustomerReport.DiskfUsage = fUsage;
                        model.CPOCustomerReport.DiskfQuota = fQuota;
                    }

                    sqlReader.Close();
                }
                #endregion

                //model.MessageList.Add("Servers");
                #region Servers
                using (SqlCommand command = new SqlCommand("SELECT id, name FROM servers WHERE orgid = (SELECT id FROM organization WHERE name = @Organization)", sqlConnection))
                {
                    command.Parameters.Add("@Organization", SqlDbType.VarChar, 250).Value = model.CPOCustomerReport.Organization;

                    SqlDataReader sqlReader = command.ExecuteReader();

                    while (sqlReader.Read())
                    {

                        string name = sqlReader["name"].ToString();
                        int id = (int)sqlReader["id"];
                        //model.MessageList.Add(string.Format("id: {0} name: {1}", id, name));

                        CPOServer s = new CPOServer() { Name = name, Id = id };

                        model.CPOCustomerReport.Servers.Add(s);

                    }

                    sqlReader.Close();
                }

                foreach (CPOServer s in model.CPOCustomerReport.Servers)
                {
                    using (SqlCommand command = new SqlCommand("SELECT deviceid, size FROM serverdisks WHERE serverid = @ServerID", sqlConnection))
                    {
                        command.Parameters.Add("@ServerID", SqlDbType.Int).Value = s.Id;

                        SqlDataReader sqlReader = command.ExecuteReader();

                        while (sqlReader.Read())
                        {
                            string deviceid = sqlReader["deviceid"].ToString();
                            string size = sqlReader["size"].ToString();
                            //model.MessageList.Add(string.Format("id: {0} size: {1}", deviceid, size));

                            s.Disks.Add(new CPOServerDisk() { DeviceID = deviceid, Size = size });
                        }

                        sqlReader.Close();
                    }
                }
                #endregion


                // and now to make pretty the numbers
                model.CPOCustomerReport.ExchangefQuota = Math.Round(model.CPOCustomerReport.ExchangefQuota, 2);
                model.CPOCustomerReport.ExchangefUsage = Math.Round(model.CPOCustomerReport.ExchangefUsage, 2);

                model.CPOCustomerReport.DiskfUsage = Math.Round(model.CPOCustomerReport.DiskfUsage, 2);
                model.CPOCustomerReport.DiskfQuota = Math.Round(model.CPOCustomerReport.DiskfQuota, 2);
            }
        }
        */
        public ActionResult CPOCustomerReportPieChartDisk(string iUsage, string iQuota)
        {
            //iUsage = iUsage.Replace(',', '.');
            //iQuota = iQuota.Replace(',', '.');

            double usage = double.Parse(iUsage);
            double quota = double.Parse(iQuota);

            double usagePct = usage / quota * 100;
            double quotaPct = 100 - usagePct;

            var key = new Chart(width: 100, height: 100).AddSeries(
                chartType: "pie",
                legend: "Space utulization",
                xValue: new[] { "Used", "Free" },
                yValues: new[] { usagePct, quotaPct }).Write("png");

            return null;
        }


        // Display UpdateVersionConf
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOUpdateVersionConf()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOUpdateVersionConf(FormCollection _POST)
        {
            try
            {
                model.CPOUpdateVersionConf = new CustomCPOUpdateVersionConf()
                {
                    Organization = _POST["organization"],
                    UpdateAll = _POST["updateall"] == "on" ? true : false
                };

                if (!model.CPOOrganizations.Contains(model.CPOUpdateVersionConf.Organization))
                {
                    throw new Exception("Organization does not exist.");
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOUpdateVersionConf() for '{1}'", model.CPOUpdateVersionConf.UpdateAll, model.CPOUpdateVersionConf.Organization));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.UpdateVersionConf(model.CPOUpdateVersionConf.Organization, model.CPOUpdateVersionConf.UpdateAll);
                    var result = ps.Invoke();
                }

                if (model.CPOUpdateVersionConf.UpdateAll == true)
                {
                    model.OKMessage.Add(string.Format("Version Conf updated for all organizations.."));
                }
                else
                {
                    model.OKMessage.Add(string.Format("Version Conf updated for organization '{0}'.", model.CPOUpdateVersionConf.Organization));
                }

                CommonCAS.Stats("Capto/CPOUpdateVersionConf");

                return View("CPOUpdateVersionConf", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display CreateGoldenVM
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateGoldenVM()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOCreateGoldenVM(FormCollection _POST)
        {
            try
            {
                model.CPOCreateGoldenVM = new CustomCPOCreateGoldenVM()
                {
                    Solution = _POST["solution"].ToUpper(),
                    Test = _POST["test"] == "on" ? true : false,
                };


                switch (model.CPOCreateGoldenVM.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "LEGAL":
                        break;
                    case "MEMBER2015":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.CPOCreateGoldenVM.Solution));
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOCreateGoldenVM() for '{0}'", model.CPOCreateGoldenVM.Solution));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.CreateGoldenVM(model.CPOCreateGoldenVM.Solution, model.CPOCreateGoldenVM.Test);
                    var result = ps.Invoke();
                }

                if (model.CPOCreateGoldenVM.Test == true)
                {
                    model.OKMessage.Add(string.Format("GoldenVM TEST, has been deployed for '{0}'.. ", model.CPOCreateGoldenVM.Solution));
                }
                else
                {
                    model.OKMessage.Add(string.Format("GoldenVM for Solution: '{0}' has been created. When VM state is Shutdown, it can be used for Citrix..", model.CPOCreateGoldenVM.Solution));
                }

                CommonCAS.Stats("Capto/CPOCreateGoldenVM");

                return View("CPOCreateGoldenVM", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display Update MCS Image
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOMCSUpdateImage()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOMCSUpdateImage(FormCollection _POST)
        {
            try
            {
                model.CPOMCSUpdateImage = new CustomCPOMCSUpdateImage()
                {
                    Solution = _POST["solution"].ToUpper(),
                    VMName = _POST["server"],
                    Test = _POST["test"] == "on" ? true : false,
                };


                switch (model.CPOMCSUpdateImage.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "LEGAL":
                        break;
                    case "MEMBER2015":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.CPOMCSUpdateImage.Solution));
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOMCSUpdateImage() for '{0}'", model.CPOMCSUpdateImage.Solution));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.MCSUpdateImage(model.CPOMCSUpdateImage.Solution, model.CPOMCSUpdateImage.VMName, model.CPOMCSUpdateImage.Test);
                    var result = ps.Invoke();
                }

                if (model.CPOMCSUpdateImage.Test == true)
                {
                    model.OKMessage.Add(string.Format("MCS Image TEST, id being updated for solution '{0}'.. ", model.CPOMCSUpdateImage.Solution));
                }
                else
                {
                    model.OKMessage.Add(string.Format("MCS Image for Solution: '{0}' is being updated. Please check progress in Citrix Studio for the status..", model.CPOMCSUpdateImage.Solution));
                }

                CommonCAS.Stats("Capto/CPOMCSUpdateImage");

                return View("CPOMCSUpdateImage", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display Create MCS Image Catalog
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOMCSCreateCatalog()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CPOMCSCreateCatalog(FormCollection _POST)
        {
            try
            {
                model.CPOMCSCreateCatalog = new CustomCPOMCSCreateCatalog()
                {
                    Solution = _POST["solution"].ToUpper(),
                    Name = _POST["name"],
                    VMName = _POST["server"],
                    OU = _POST["ou"],
                    NamingScheme = _POST["namingscheme"].ToUpper(),
                };


                switch (model.CPOMCSCreateCatalog.Solution.ToUpper())
                {
                    case "ADVOPLUS":
                        break;
                    case "LEGAL":
                        break;
                    case "MEMBER2015":
                        break;
                    default:
                        throw new ArgumentException(string.Format("The value '{0}' is not a valid solution type.", model.CPOMCSUpdateImage.Solution));
                }

                CommonCAS.CPOLog(string.Format("has run Capto/CPOMCSCreateCatalog() for '{0}'", model.CPOMCSCreateCatalog.Solution));

                // execute powershell script and dispose powershell object
                using (CPOMyPowerShell ps = new CPOMyPowerShell())
                {
                    ps.MCSCreateCatalog(model.CPOMCSCreateCatalog.Solution, model.CPOMCSCreateCatalog.Name, model.CPOMCSCreateCatalog.VMName, model.CPOMCSCreateCatalog.OU, model.CPOMCSCreateCatalog.NamingScheme);
                    var result = ps.Invoke();
                }

                if (model.CPOMCSCreateCatalog.NamingScheme.Length > 15)
                {
                    throw new ArgumentException(string.Format("The value '{0}' is not a valid namingscheme type.", model.CPOMCSCreateCatalog.NamingScheme));
                }
                else
                {
                    model.OKMessage.Add(string.Format("MCS Catalog {0} for Solution: '{1}' is being created. Please check progress in Citrix Studio for the status..", model.CPOMCSCreateCatalog.Name, model.CPOMCSCreateCatalog.Solution));
                }

                CommonCAS.Stats("Capto/CPOMCSCreateCatalog");

                return View("CPOMCSCreateCatalog", model);
            }
            catch (Exception exc)
            {
                CommonCAS.CPOLog("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }
    }
}