﻿using System;
using System.Linq;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Management.Automation;

namespace ColumbusPortal.Controllers
{
    
    public class UserController : Controller
    {
        UserModel model = new UserModel();

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
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
        
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult Create(FormCollection _POST)
        {
            try
            {
                // set up a user account for display in view
                CustomUser newUser = new CustomUser()
                {
                    CopyFrom = _POST["userprincipalname"],
                    FirstName = _POST["firstname"],
                    LastName = _POST["lastname"],
                    Organization = _POST["organization"],
                    Password = _POST["password"],
                    UserName = _POST["username"],
                    DomainName = _POST["domainname"],
                    TestUser = _POST["testuser"] == "on" ? true : false,
                    PasswordNeverExpires = _POST["passwordneverexpires"] == "on" ? true : false,
                };

                model.UserList.Add(newUser);

                CommonCAS.Log(string.Format("has run User/CreateUser() to create {0}", newUser.UserName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateUser(newUser);
                    var result = ps.Invoke();

                    if (result.Count() > 0)
                    {
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }

                    }
                }

                CommonCAS.Stats("User/Create");

                return View("CreateSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display disable user page
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult Disable(FormCollection _POST)
        {

            try
            {
                CustomUser disableUser = new CustomUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                model.DisableUser = disableUser;

                if (!model.DisableUser.Confirm)
                {
                    throw new Exception("You must confirm the action.");
                }

                CommonCAS.Log(string.Format("has run User/DisableUser(confirm={1}, for user {0}", disableUser.UserPrincipalName, disableUser.Confirm));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DisableUser(disableUser);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("User successfully disabled.");
                    }
                    else
                    {
                        model.OKMessage.Add("User disabled with following info.");

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("User/Disable");

                return View("Disable", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult Remove()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }
        [HttpPost]
        
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult Remove(FormCollection _POST)
        {
            try
            {
                CustomUser removeUser = new CustomUser()
                {
                    UserPrincipalName = _POST["userprincipalname"],
                    Organization = _POST["organization"],
                    DelData = _POST["deldata"] == "on" ? true : false,
                    Confirm = _POST["confirm"] == "on" ? true : false
                };

                model.RemoveUser = removeUser;

                if (!model.RemoveUser.Confirm)
                {
                    throw new Exception("You must confirm the action.");
                }

                CommonCAS.Log(string.Format("has run User/Remove for user {0}", removeUser.UserPrincipalName));

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
                        model.OKMessage.Add("User deleted with info."); 

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("User/Remove");

                return View("Remove", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult CreateServiceUser(FormCollection _POST)
        {
            try
            {
                model.ServiceUser.Organization = _POST["organization"];
                model.ServiceUser.Service = _POST["service"];
                model.ServiceUser.Description = _POST["description"];
                model.ServiceUser.Password = CommonCAS.GeneratePassword();
                model.ServiceUser.Management = _POST["management"] == "on" ? true : false;

                CommonCAS.Log(string.Format("has run User/CreateServiceUser() to create service user {0}_svc_{1}", model.ServiceUser.Organization, model.ServiceUser.Service));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateServiceUser(model.ServiceUser);
                    var result = ps.Invoke();
                }

                CommonCAS.Stats("User/CreateServiceUser");

                return View("CreateServiceUserSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateServiceUser", model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult GetUserMemberOf(FormCollection _POST)
        {
            try
            {
                model.MemberOf.Organization = _POST["organization"];
                model.MemberOf.UserPrincipalName = _POST["userprincipalname"];

                CommonCAS.Log(string.Format("has run User/GetUserMemberOf() on user {0}\\{1}", model.MemberOf.Organization, model.MemberOf.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetUserMemberOf(model.MemberOf);
                    var result = ps.Invoke();

                    foreach (var item in result)
                    {
                        model.MemberOf.Groups.Add(item.ToString());
                    }
                }

                CommonCAS.Stats("User/GetUserMemberOf");

                return View("GetUserMemberOfSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult CreateExtUser(FormCollection _POST)
        {
            try
            {
                model.CreateExtUser.Organization = _POST["organization"];
                model.CreateExtUser.UserName = _POST["username"];
                model.CreateExtUser.Description = _POST["description"];
                model.CreateExtUser.DisplayName = _POST["displayname"];
                model.CreateExtUser.DomainName = _POST["domainname"];

                model.CreateExtUser.Password = CommonCAS.GeneratePassword();
                model.CreateExtUser.ExpirationDate = _POST["datetime"];

                CommonCAS.Log(string.Format("has run User/CreateExtUser() to create ext user {0}_ext_{1}", model.CreateExtUser.Organization, model.CreateExtUser.UserName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateExtUser(model.CreateExtUser).Invoke();
                }

                CommonCAS.Stats("User/CreateExtUser");

                return View("CreateExtUserSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("CreateExtUser", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
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
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult Enable(FormCollection _POST)
        {
            try
            {
                // property is disable but means enable
                model.EnableUser.Organization = _POST["organization"];
                model.EnableUser.UserPrincipalName = _POST["userprincipalname"];
                model.EnableUser.Confirm = _POST["confirm"] == "on" ? true : false;

                if (!model.EnableUser.Confirm)
                {
                    throw new Exception("You must confirm the action.");
                }

                CommonCAS.Log(string.Format("has run User/Enable(Confirmed: {0}) on user {1}", model.EnableUser.Confirm, model.EnableUser.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.EnableUser(model.EnableUser).Invoke();
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add("User successfully enabled.");
                    }
                    else
                    {
                        model.OKMessage.Add("User enabled with following info:");

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("User/EnableUser");

                return View("Enable", model);

            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("Enable", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        
        public ActionResult ResetPWD()
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
        
        public ActionResult ResetPWD(FormCollection _POST)
        {
            try
            {
                model.ResetPWD.Organization = _POST["organization"];
                model.ResetPWD.UserPrincipalName = _POST["userprincipalname"];
                model.ResetPWD.Password = _POST["password"];
                model.ResetPWD.PasswordNeverExpires = _POST["passwordneverexpires"] == "on" ? true : false;

                CommonCAS.Log(string.Format("has run User/ResetPWD() for {0}, to reset password for user {1}", model.ResetPWD.Organization, model.ResetPWD.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetPassword(model.ResetPWD.Organization, model.ResetPWD.UserPrincipalName, model.ResetPWD.Password, model.ResetPWD.PasswordNeverExpires);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Reset password success for '{1}', from Organization : '{0}' ", model.ResetPWD.Organization, model.ResetPWD.UserPrincipalName));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("Reset password success for '{1}', from Organization : '{0}' ", model.ResetPWD.Organization, model.ResetPWD.UserPrincipalName));

                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("User/ResetPWD");

                return View("ResetPWD", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("ResetPWD", model);
            }
        }
    }
}
