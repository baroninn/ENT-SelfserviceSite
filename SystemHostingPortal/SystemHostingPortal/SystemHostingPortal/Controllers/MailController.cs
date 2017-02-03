using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Web;
using System.Web.Mvc;
using SystemHostingPortal.Logic;
using SystemHostingPortal.Models;

namespace SystemHostingPortal.Controllers
{
    
    public class MailController : Controller
    {
        MailModel model = new MailModel();
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddAlias()
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
        public ActionResult AddAlias(FormCollection _POST)
        {
            try
            {
                CustomAlias addAlias = new CustomAlias()
                {
                    Organization = _POST["organization"],
                    UserPrincipalName = _POST["userprincipalname"],
                    EmailAddresses = _POST["emailaddresses"].Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>(),
                    SetFirstAsPrimary = _POST["setfirstasprimary"] == "on" ? true : false
                };
                for (int i = 0; i < addAlias.EmailAddresses.Count; i++) { addAlias.EmailAddresses[i] = addAlias.EmailAddresses[i].Trim(); }

                if (addAlias.EmailAddresses.Count == 0) { throw new Exception("No aliases specified"); }

                model.Alias = addAlias;

                Common.Log(string.Format("has run Mail/AddAlias() for user {0} to add alias {1}", addAlias.UserPrincipalName, string.Join(",", addAlias.EmailAddresses)));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddAlias(addAlias);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/AddAlias");

                model.OKMessage.Add("Successfully added alias for " + addAlias.UserPrincipalName + ":");
                foreach (string alias in addAlias.EmailAddresses)
                {
                    model.OKMessage.Add(alias);
                }

                return View("AddAlias", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddAcceptedDomain()
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
        public ActionResult AddAcceptedDomain(FormCollection _POST)
        {
            try
            {
                CustomAcceptedDomain AddAcceptedDomain = new CustomAcceptedDomain()
                {
                    Organization = _POST["organization"],
                    Domain = _POST["domain"],
                    SetAsUPN = _POST["setasupn"] == "on" ? true : false
                };

                model.AcceptedDomain = AddAcceptedDomain;

                Common.Log(string.Format("has run Mail/AddAcceptedDomain() for organization {0} to add domain {1}", AddAcceptedDomain.Organization, AddAcceptedDomain.Domain ));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddAcceptedDomain(AddAcceptedDomain.Organization, AddAcceptedDomain.Domain, AddAcceptedDomain.SetAsUPN);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/AddAcceptedDomain");

                model.OKMessage.Add(string.Format("'{0}' added for organization '{1}'.", model.AcceptedDomain.Domain, model.AcceptedDomain.Organization));

                return View("AddAcceptedDomain", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveAlias()
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
        public ActionResult RemoveAlias(FormCollection _POST)
        {
            try
            {
                CustomAlias removeAlias = new CustomAlias()
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

                model.Alias = removeAlias;

                Common.Log(string.Format("has run Mail/RemoveAlias() for user {0} to remove alias {1}", removeAlias.UserPrincipalName, string.Join(", ", removeAlias.EmailAddresses)));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveAlias(removeAlias);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/RemoveAlias");

                model.OKMessage.Add("Succesfully removed alias for " + removeAlias.UserPrincipalName);
                foreach (string alias in removeAlias.EmailAddresses)
                {
                    model.OKMessage.Add(alias);
                }

                return View("RemoveAlias", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateMailbox()
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
        public ActionResult CreateMailbox(FormCollection _POST)
        {
            try
            {
                CustomMailbox newMailbox = new CustomMailbox()
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

                model.Mailbox = newMailbox;

                Common.Log(string.Format("has run Mail/CreateMailbox() to create {0}", newMailbox.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateMailbox(newMailbox);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add("Successfully created mailbox " + newMailbox.UserPrincipalName);

                Common.Stats("Mail/CreateMailbox");

                return View("CreateMailbox", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateDistributionGroup()
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
        public ActionResult CreateDistributionGroup(FormCollection _POST)
        {
            try
            {

                model.DistributionGroup.Name = _POST["name"];
                model.DistributionGroup.UserPrincipalName = _POST["primarysmtpaddress"];
                model.DistributionGroup.ManagedBy = _POST["userprincipalname"];
                model.DistributionGroup.Organization = _POST["organization"];
                model.DistributionGroup.RequireSenderAuthentication = _POST["allowexternalemails"] == "on" ? false : true;


                Common.Log(string.Format("has run Mail/CreateDistributionGroup() on user {0}", model.DistributionGroup.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateDistributionGroup(model.DistributionGroup);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add("Succesfully created distribution group " + model.DistributionGroup.Name + " (" + model.DistributionGroup.UserPrincipalName + ")");
                 
                Common.Stats("Mail/CreateDistributionGroup");

                return View("CreateDistributionGroup", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddMailboxPermission()
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
        public ActionResult AddMailboxPermission(FormCollection _POST)
        {
            try
            {
                CustomMailboxPermission addMailboxPermission = new CustomMailboxPermission()
                {
                    Organization = _POST["organization"],
                    UserPrincipalName = _POST["userprincipalname"],
                    FullAccess = _POST["fullaccess"] == "on" ? true : false,
                    SendAs = _POST["sendas"] == "on" ? true : false
                };

                model.MailboxPermission = addMailboxPermission;

                Common.Log(string.Format("has run Mail/AddMailboxPermission() on user {0}", addMailboxPermission.UserPrincipalName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddMailboxPermission(addMailboxPermission);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/AddMailboxPermission");

                if (model.MailboxPermission.FullAccess)
                {
                    model.OKMessage.Add(string.Format("Successfully created FullAccess group for {0}.", model.MailboxPermission.UserPrincipalName));
                }
                
                if (model.MailboxPermission.SendAs)
                {
                    model.OKMessage.Add(string.Format("Successfully created SendAs group for {0}.", model.MailboxPermission.UserPrincipalName));
                }

                return View("AddMailboxPermission", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetMailforward()
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
        public ActionResult SetMailforward(FormCollection _POST)
        {
            try
            {
                model.Mailforward.UserPrincipalName = _POST["userprincipalname"];
                model.Mailforward.Organization = _POST["organization"];
                model.Mailforward.ForwardingSmtpAddress = _POST["forwardingaddress"];
                model.Mailforward.ForwardingType = _POST["forwardingtype"];
                model.Mailforward.DeliverToMailboxAndForward = _POST["delivertomailboxandforward"] == "on" ? true : false;

                if (model.Mailforward.ForwardingSmtpAddress == string.Empty)
                {
                    model.Mailforward.ForwardingSmtpAddress = "clear";
                }

                Common.Log(string.Format("has run Mail/SetMailforward(address: {1}) on user {0}", model.Mailforward.UserPrincipalName, model.Mailforward.ForwardingSmtpAddress));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetMailforward(model.Mailforward);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/SetMailforward");

                switch (model.Mailforward.ForwardingType.ToUpper())
                {
                    case "INTERNAL":
                        model.OKMessage.Add(string.Format("Successfully set mailforward for {0} to {1}.", model.Mailforward.UserPrincipalName, model.Mailforward.ForwardingSmtpAddress));
                        break;
                    case "EXTERNAL":
                        model.OKMessage.Add(string.Format("Successfully set mailforward for {0} to {1}.", model.Mailforward.UserPrincipalName, model.Mailforward.ForwardingSmtpAddress));
                        break;
                    case "CLEAR":
                        model.OKMessage.Add(string.Format("Successfully removed mailforward for {0}.", model.Mailforward.UserPrincipalName));
                        break;
                }

                return View("SetMailforward", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetMailboxPlan()
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
        public ActionResult SetMailboxPlan(FormCollection _POST)
        {
            try
            {
                model.MailboxPlan.Organization = _POST["organization"];
                model.MailboxPlan.UserPrincipalName = _POST["userprincipalname"];
                model.MailboxPlan.MailboxPlan = _POST["mailboxplan"];

                Common.Log(string.Format("has run Mail/SetMailboxPlan (user: {0}, plan: {1})", model.MailboxPlan.UserPrincipalName, model.MailboxPlan.MailboxPlan));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetMailboxPlan(model.MailboxPlan);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/SetMailboxPlan");

                model.OKMessage.Add("MailboxPlan successfully set.");

                return View("SetMailboxPlan", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetMailboxAutoResize()
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
        public ActionResult SetMailboxAutoResize(FormCollection _POST)
        {
            try
            {
                CustomMailboxAutoResize mailboxAutoResize = new CustomMailboxAutoResize()
                {
                    Organization = _POST["organization"],
                    ExcludeFromAutoResize = _POST["exclude"] == "true" ? true : false
                };

                model.MailboxAutoResize = mailboxAutoResize;

                Common.Log(string.Format("has run Mail/SetMailboxAutoResize() for organization {0} to set exclude to {1}", mailboxAutoResize.Organization, mailboxAutoResize.ExcludeFromAutoResize));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetMailboxAutoResize(mailboxAutoResize);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/SetMailboxAutoResize");

                if (mailboxAutoResize.ExcludeFromAutoResize)
                {
                    model.OKMessage.Add(string.Format("Excluded {0} from mailbox auto resizing", mailboxAutoResize.Organization));
                }
                else
                {
                    model.OKMessage.Add(string.Format("Enabled mailbox auto resizing for {0}", mailboxAutoResize.Organization));
                }

                return View("SetMailboxAutoResize", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult GetDeviceReport()
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
        public ActionResult GetDeviceReport(FormCollection _POST)
        {
            try
            {
                model.DeviceReport.Organization = _POST["organization"];
                model.DeviceReport.UserPrincipalName = _POST["userprincipalname"];

                Common.Log(string.Format("has run Mail/GetDeviceReport for user {0}", model.DeviceReport.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetDeviceReport(model.DeviceReport);
                    var result = ps.Invoke();

                    if (result.Count() > 2)
                    {
                        foreach (var item in result)
                        {
                            model.DeviceReport.ReportHtml += item.ToString();
                        }
                    }
                    else
                    {
                        throw new Exception(model.DeviceReport.UserPrincipalName + " does not have any mobile devices connected.");
                    }
                }

                Common.Stats("Mail/GetDeviceReport");

                return View("GetDeviceReportSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult DeleteMailContact()
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
        public ActionResult DeleteMailContact(FormCollection _POST)
        {
            try {
                model.MailContact.Organization = _POST["organization"];
                model.MailContact.PrimarySmtpAddress = _POST["primarysmtpaddress"];

                Common.Log(string.Format("has run Mail/DeleteMailContact for contact {0}\\{1}", model.MailContact.Organization, model.MailContact.PrimarySmtpAddress));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DeleteMailContact(model.MailContact).Invoke();
                }

                Common.Stats("Mail/DeleteMailContact");

                return View("DeleteMailContactSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult DeleteDistributionGroup()
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
        public ActionResult DeleteDistributionGroup(FormCollection _POST)
        {
            try
            {
                model.DistributionGroup.Organization = _POST["organization"];
                model.DistributionGroup.PrimarySmtpAddress = _POST["primarysmtpaddress"];

                Common.Log(string.Format("has run Mail/DeleteDistributionGroup for contact {0}\\{1}", model.DistributionGroup.Organization, model.DistributionGroup.PrimarySmtpAddress));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.DeleteDistributionGroup(model.DistributionGroup).Invoke();
                }

                Common.Stats("Mail/DeleteDistributionGroup");

                return View("DeleteDistributionGroupSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddDistributionGroupManager()
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
        public ActionResult AddDistributionGroupManager(FormCollection _POST)
        {
            try
            {
                model.DistributionGroup.Organization = _POST["organization"];
                model.DistributionGroup.PrimarySmtpAddress = _POST["primarysmtpaddress"];
                model.DistributionGroup.ManagedBy = _POST["upnselector"];

                Common.Log(string.Format("has run Mail/AddDistributionGroupManager for group {0}\\{1}", model.DistributionGroup.Organization, model.DistributionGroup.PrimarySmtpAddress));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddDistributionGroupManager(model.DistributionGroup).Invoke();
                }

                Common.Stats("Mail/AddDistributionGroupManager");

                return View("AddDistributionGroupManagerSuccess", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }


        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult GetCalendarPermissions()
        {
            try
            {
                return View("GetCalendarPermissions", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        public ActionResult SetCalendarPermissions()
        {
            return GetCalendarPermissions();
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetCalendarPermissions(FormCollection _POST)
        {
            try
            {
                model.CalendarPermissions.Organization = _POST["organization"];
                model.CalendarPermissions.UserPrincipalName = _POST["userprincipalname"];
                model.CalendarPermissions.User = _POST.GetValues("user[]");
                model.CalendarPermissions.AccessRights = _POST.GetValues("accessrights[]");

                Common.Log(string.Format("has run Mail/SetCalendarPermissions for user {0}\\{1}", model.CalendarPermissions.Organization, model.CalendarPermissions.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetCalendarPermissions(model.CalendarPermissions).Invoke();
                }

                Common.Stats("Mail/SetCalendarPermissions");

                model.OKMessage.Add(string.Format("Success, updated calendar permissions for '{0}' ", model.CalendarPermissions.UserPrincipalName));
                
                return View("GetCalendarPermissions", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("GetCalendarPermissions", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetAllMailboxPlans()
        {
            try
            {
                return View("SetAllMailboxPlans", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetAllMailboxPlans(FormCollection _POST)
        {
            try
            {
                model.MailboxPlan.Organization = _POST["organization"];
                model.MailboxPlan.MailboxPlan = _POST["mailboxplan"];

                Common.Log(string.Format("has run Mail/SetAllMailboxPlans({1}) for organization {0}", model.MailboxPlan.Organization, model.MailboxPlan.MailboxPlan));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetAllMailboxPlans(model.MailboxPlan).Invoke();
                }

                Common.Stats("Mail/SetAllMailboxPlans");

                //model.OKMessage = string.Format("Org: {0}, Plan: {1}", model.MailboxPlan.Organization, model.MailboxPlan.MailboxPlan);
                model.OKMessage.Add("Success");

                return View("SetAllMailboxPlans", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("SetAllMailboxPlans", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveMailbox()
        {
            try
            {
                return View("RemoveMailbox", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult RemoveMailbox(FormCollection _POST)
        {
            try
            {
                model.Mailbox.Organization = _POST["organization"];
                model.Mailbox.UserPrincipalName = _POST["identity"];

                Common.Log(string.Format("has run Mail/RemoveMailbox for {0}\\{1}", model.Mailbox.Organization, model.Mailbox.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.RemoveMailbox(model.Mailbox).Invoke();
                }

                Common.Stats("Mail/RemoveMailbox");

                model.OKMessage.Add(string.Format("{0}\\{1} was deleted successfully. It can take up to 30 seconds for the mailbox to disappear from SelfService.", model.Mailbox.Organization, model.Mailbox.UserPrincipalName));

                return View("RemoveMailbox", model);
            }
            catch(Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("RemoveMailbox", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddMailboxPermissionFullAccess()
        {
            try
            {
                return View("AddMailboxPermissionFullAccess", model);
            }
            catch (Exception exc)
            {
                return View("Error", exc);
            }
        }

        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AddMailboxPermissionFullAccess(FormCollection _POST)
        {
            try
            {
                model.MailboxPermissionFullAccess.Organization = _POST["organization"];
                model.MailboxPermissionFullAccess.UserPrincipalName = _POST["userprincipalname"];

                Common.Log(string.Format("has run Mail/AddMailboxPermissionFullAccess on {0}\\{1}", model.MailboxPermissionFullAccess.Organization, model.MailboxPermissionFullAccess.UserPrincipalName));

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.AddMailboxPermissionFullAccess(model.MailboxPermissionFullAccess).Invoke();
                }

                Common.Stats("Mail/AddMailboxPermissionFullAccess");

                model.OKMessage.Add("Success");

                return View("AddMailboxPermissionFullAccess", model);
            }
            catch(Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View("AddMailboxPermissionFullAccess", model);
            }
        }



        // Ajax function - returns a set of options for a select, containing all available mailbox plans
        public string GetMailboxPlans(string organization, string selectedvalue)
        {
            string ret = "";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetMailboxPlans(organization);
                var result = ps.Invoke();

                foreach (var item in result)
                {
                    if (selectedvalue == item.ToString()) { 
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
        public string GetMailboxPlan(string organization, string userprincipalname)
        {
            string ret = "";

            using (MyPowerShell ps = new MyPowerShell())
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
        public string GetAcceptedDomain(string organization)
        {
            string returnstr = "<ul>";

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetAcceptedDomain(organization);
                var result = ps.Invoke();
                
                // Returns PSObject with properties: Name, DomainName, DomainType, Default
                foreach (var item in result)
                {
                    returnstr += "<li>" + item.Members["DomainName"].Value.ToString() +"</li>";
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
        public string GetExistingAliases(string organization, string userprincipalname)
        {
            string returnstr = "<ul>";

            using (MyPowerShell ps = new MyPowerShell())
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
        public string GetMailboxes(string organization, string selectname = "upnselector", string inputname = "userprincipalname")
        {
            string returnstr = "<select name=\""+ selectname +"\"><option selected=\"selected\" value=\"\">... select a person</option>";

            using (MyPowerShell ps = new MyPowerShell())
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

            returnstr += "<script>$(\"select[name="+ selectname +"]\").change(function () { var upn = $(\"select[name="+selectname+"]\").val(); $(\"input[name="+inputname+"]\").val(upn); GetExistingAliases(); }); </script>";

            return returnstr;
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult GetItemsReport()
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
        public ActionResult GetItemsReport(FormCollection _POST)
        {
            try
            {
                CustomItemsReport GetItemsReport = new CustomItemsReport()
                {
                    Organization = _POST["organization"],
                    Mail = _POST["mail"],
                    GetALL = _POST["getall"] == "on" ? true : false
                };

                model.ItemsReport = GetItemsReport;

                Common.Log(string.Format("has run Mail/GetItemsReport() for organization {0} and sent the report to {1}", GetItemsReport.Organization, GetItemsReport.Mail));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetItemsReport(GetItemsReport.Organization, GetItemsReport.Mail, GetItemsReport.GetALL);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/GetItemsReport");

                model.OKMessage.Add(string.Format("'{0}' has been sent the report!...", model.ItemsReport.Mail));

                return View("GetItemsReport", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult EnableSikkerMail()
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
        public ActionResult EnableSikkerMail(FormCollection _POST)
        {
            try
            {
                CustomSikkermail enableSikkermail = new CustomSikkermail()
                {
                    Organization = _POST["organization"],
                    SendAsGroup = _POST["distinguishedname"],
                    Alias = _POST["alias"],
                    Remove = _POST["remove"] == "on" ? true : false,
                    Force = _POST["force"] == "on" ? true : false,
                    UpdateAll = _POST["updateall"] == "on" ? true : false
                };

                model.Sikkermail = enableSikkermail;

                Common.Log(string.Format("has run Mail/EnableSikkerMail() for Organization {0} to enable {1}", enableSikkermail.Organization, enableSikkermail.SendAsGroup));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.EnableSikkermail(enableSikkermail.Organization, enableSikkermail.SendAsGroup, enableSikkermail.Alias,  enableSikkermail.Remove, enableSikkermail.Force, enableSikkermail.UpdateAll);
                    var result = ps.Invoke();
                }

                Common.Stats("Mail/EnableSikkermail");
                if (enableSikkermail.UpdateAll == true)
                {
                    model.OKMessage.Add("Successfully enabled Sikkermail attributes for everyone!");
                }
                if (enableSikkermail.Force == true)
                {
                    model.OKMessage.Add("Successfully forced Sikkermail conf for " + enableSikkermail.Organization + " : " + enableSikkermail.SendAsGroup + "");
                }
                if (enableSikkermail.Remove == true)
                {
                    model.OKMessage.Add("Successfully removed Sikkermail conf for " + enableSikkermail.Organization + " : " + enableSikkermail.SendAsGroup + "");
                }
                if (enableSikkermail.Force == false & enableSikkermail.UpdateAll == false) {
                    model.OKMessage.Add("Successfully enabled Sikkermail conf for " + enableSikkermail.Organization + " : " + enableSikkermail.SendAsGroup + ""); 
                };

                return View("EnableSikkermail", model);
            }
            catch (Exception exc)
            {
                Common.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

    }
}