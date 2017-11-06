using System;
using System.Linq;
using System.Web.Mvc;
using ColumbusPortal.Logic;
using ColumbusPortal.Models;
using System.Management.Automation;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.DataVisualization.Charting;
using System.Drawing;

namespace ColumbusPortal.Controllers
{
    public class AzureController : Controller
    {
        AzureModel model = new AzureModel();

        public ActionResult AndroidSettings()
        {
            return View("_AndroidSettings", "Azure");
        }
        public ActionResult AndroidAFWSettings()
        {
            return View("_AndroidAFWSettings", "Azure");
        }
        public ActionResult IOSSettings()
        {
            return View("_IOSSettings", "Azure");
        }
        public ActionResult Win10Settings()
        {
            return View("_Win10Settings", "Azure");
        }
        public ActionResult macOSSettings()
        {
            return View("_macOSSettings", "Azure");
        }
        public ActionResult AzureIntuneDevice()
        {
            return View("_AzureIntuneDevice", "Azure");
        }
        public ActionResult AzureIntuneComplianceOverview()
        {
            return View("_IntuneComplianceOverview", "Azure");
        }


        [Authorize]
        public string GetCustomerConf(string organization)
        {

            string conString = "Server=sht004;Integrated Security=true;Database=SSS";
            SqlConnection con = new SqlConnection(conString);

            string selectSql = "select * from [dbo].[Organizations] WHERE ([Organization] LIKE '" + organization + "')";
            SqlCommand cmd = new SqlCommand(selectSql, con);

            List<CustomCustconf> Configuration = new List<CustomCustconf>();

            try
            {
                con.Open();

                using (SqlDataReader read = cmd.ExecuteReader())
                {
                    while (read.Read())
                    {
                        Configuration.Add(new CustomCustconf()
                        {
                            Platform = (read["Platform"].ToString()),
                            ServiceCompute = (read["ServiceCompute"].ToString()),
                            Service365 = (read["Service365"].ToString()),
                            ServiceIntune = (read["ServiceIntune"].ToString()),
                            AdminRDS = (read["AdminRDS"].ToString()),
                            AdminRDSPort = (read["AdminRDSPort"].ToString())
                        });
                    }
                }

                con.Close();
                return new JavaScriptSerializer().Serialize(Configuration);
            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        // Create and download RDP
        public FileStreamResult CreateRDPFile(string organization, string vm, string ip)
        {
            //todo: add some data from your database into that string:
            var FileName = organization + vm + ".rdp";
            var RDPContent = "full address:s:" + ip;

            var byteArray = Encoding.ASCII.GetBytes(RDPContent);
            var stream = new MemoryStream(byteArray);

            return File(stream, "text/plain", FileName);
        }

        // Display Verifydomain view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult AzureOverView()
        {
            try
            {
                return View(model);
            }
            catch (Exception exc) { return View("Error", exc); }
        }

        /// <summary>
        /// Ajax function for aquiring security center
        /// </summary>
        /// <param name="organization"></param>
        /// <returns></returns>
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public virtual ActionResult GetAzureSecurityCenter(string organization)
        {
            List<CustomAzureSecurity> Security = new List<CustomAzureSecurity>();

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetAzureSecurity(organization);
                var result = ps.Invoke();

                if (result.Count() == 0)
                {
                    return null;
                }
                else
                {
                    // Returns string with properties..
                    foreach (PSObject Object in result)
                    {
                        var vms = (PSObject)Object.Properties["vms"].Value;
                        var info = (Object[])vms.Properties["info"].Value;
                        

                        ///Item in below foreach is a new PSObject (hashtable), and not just an Object..
                        foreach (PSObject item in info)
                        {
                            ///Patch lists needs to be generated pr info item !Important
                            List<CustomAzureSecurityPatches> SecurityPatches = new List<CustomAzureSecurityPatches>();
                            List<CustomAzureSecuritymalware> SecurityMalware = new List<CustomAzureSecuritymalware>();
                            List<CustomAzureSecurityRecommendations> SecurityRecommendations = new List<CustomAzureSecurityRecommendations>();
                            /// Handle Patch object
                            if (item.Members["Patches"].Value.ToString() == "No patches needed..")
                            {
                                SecurityPatches.Add(new CustomAzureSecurityPatches()
                                {

                                    patchId = "No patches needed..",
                                    title = "No patches needed..",
                                    severity = "No patches needed..",
                                    linksToMsDocumentation = "No patches needed.."
                                });
                            }
                            else
                            {
                                var Patches = (Object[])item.Properties["Patches"].Value;
                                foreach (PSObject patch in Patches)
                                {
                                    SecurityPatches.Add(new CustomAzureSecurityPatches()
                                    {
                                        patchId = "KB" + patch.Members["patchId"].Value.ToString(),
                                        title = patch.Members["title"].Value.ToString(),
                                        severity = patch.Members["severity"].Value.ToString(),
                                        linksToMsDocumentation = patch.Members["linksToMsDocumentation"].Value.ToString()
                                    });
                                }
                            }
                            /// Handle Malware object
                            if (item.Members["MalWareErrors"].Value.ToString() == "Nothing to report..")
                            {
                                SecurityMalware.Add(new CustomAzureSecuritymalware()
                                {
                                    componentName = "Nothing to report..",
                                    description = "Nothing to report..",
                                    severity = "Nothing to report..",
                                    eventTimestamp = "Nothing to report..",
                                    message = "Nothing to report.."
                                });
                            }
                            else
                            {
                                var Malware = (Object[])item.Properties["MalWareErrors"].Value;
                                foreach (PSObject malwareitem in Malware)
                                {
                                    var events = (Object[])malwareitem.Properties["events"].Value;
                                    foreach (PSObject eventitem in events)
                                    {
                                        SecurityMalware.Add(new CustomAzureSecuritymalware()
                                        {
                                            componentName = eventitem.Members["componentName"].Value.ToString(),
                                            description = eventitem.Members["description"].Value.ToString(),
                                            severity = eventitem.Members["severity"].Value.ToString(),
                                            eventTimestamp = eventitem.Members["eventTimestamp"].Value.ToString(),
                                            message = eventitem.Members["message"].Value.ToString()
                                        });
                                    }
                                }
                            }
                            /// Handle recommendation object
                            if (item.Members["VMRecommendations"].Value == null)
                            {
                                SecurityRecommendations.Add(new CustomAzureSecurityRecommendations()
                                {
                                    vmName = "Nothing to report..",
                                    name = "Nothing to report.."
                                });
                            }
                            else
                            {
                                /*
                                SecurityRecommendations.Add(new CustomAzureSecurityRecommendations()
                                {
                                    vmName = "TEST",
                                    name = "TEST"
                                });
                                */
                                var Recommendations = (PSObject)item.Properties["VMRecommendations"].Value;

                                    SecurityRecommendations.Add(new CustomAzureSecurityRecommendations()
                                    {
                                        vmName = Recommendations.Members["vmName"].Value.ToString(),
                                        name = Recommendations.Members["name"].Value.ToString()
                                    });
                                    
                            }
                            /// Create overall Security object
                            Security.Add(new CustomAzureSecurity()
                            {
                                Organization = organization,
                                Name = item.Members["Name"].Value.ToString().ToUpper(),
                                PatchesSecurityState = item.Members["PatchesSecurityState"].Value.ToString(),
                                securityState = item.Members["securityState"].Value.ToString(),
                                MalwaresecurityState = item.Members["MalwaresecurityState"].Value.ToString(),
                                Patches = SecurityPatches,
                                Malware = SecurityMalware,
                                Recommendations = SecurityRecommendations
                                
                            });

                        }
                        
                    }
                    model.AzureSecurity = Security;
                }
                
                return PartialView("_AzureSecurity", model);
            }
        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public virtual ActionResult GetAzureVM(string organization)
        {
            try
            {
                List<CustomAzureVM> vmElement = new List<CustomAzureVM>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureVMs(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject vmobject in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(vmobject);

                        vmElement.Add(new CustomAzureVM()
                        {
                            Organization = organization,
                            Name = properties["Name"].ToString(),
                            ResourceGroupName = properties["ResourceGroupName"].ToString(),
                            Location = properties["Location"].ToString(),
                            ProvisioningState = properties["ProvisioningState"].ToString(),
                            PowerState = properties["PowerState"].ToString(),
                            VmSize = properties["VmSize"].ToString(),
                            IPAddress = properties["IPAddress"].ToString(),
                            CPU = properties["CPU"].ToString(),
                            RAM = properties["RAM"].ToString()
                            
                        });
                    }

                    model.AzureVM = vmElement;
                }
                return PartialView("_AzureVMs", model);

            }
            catch
            {
                throw new Exception();
            }

        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public virtual ActionResult GetAzureIntuneDevice(string organization)
        {
            try
            {
                List<CustomIntuneDevice> IntuneDevice = new List<CustomIntuneDevice>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureIntuneDevice(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject vmobject in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(vmobject);

                        IntuneDevice.Add(new CustomIntuneDevice()
                        {
                            Organization = organization,
                            id = properties["id"].ToString(),
                            deviceName = Convert.ToString(properties["deviceName"]),
                            ownerType = Convert.ToString(properties["ownerType"]),
                            enrolledDateTime = Convert.ToString(properties["enrolledDateTime"]),
                            lastSyncDateTime = Convert.ToString(properties["lastSyncDateTime"]),
                            chassisType = Convert.ToString(properties["chassisType"]),
                            operatingSystem = Convert.ToString(properties["operatingSystem"]),
                            deviceType = Convert.ToString(properties["deviceType"]),
                            complianceState = Convert.ToString(properties["complianceState"]),
                            jailBroken = Convert.ToString(properties["jailBroken"]),
                            osVersion = Convert.ToString(properties["osVersion"]),
                            deviceEnrollmentType = Convert.ToString(properties["deviceEnrollmentType"]),
                            model = Convert.ToString(properties["model"]),
                            manufacturer = Convert.ToString(properties["manufacturer"]),
                            serialNumber = Convert.ToString(properties["serialNumber"]),
                            userPrincipalName = Convert.ToString(properties["userPrincipalName"])

                        });
                    }

                    model.IntuneDevice = IntuneDevice;
                }
                return PartialView("_AzureIntuneDevice", model);

            }
            catch (Exception exc)
            {
                throw new Exception(exc.ToString());
            }

        }

        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public virtual ActionResult GetAzureIntunePolicyOverview(string organization)
        {
            try
            {
                List<CustomComplianceOverview> ComplianceOverview = new List<CustomComplianceOverview>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureIntuneComplianceOverview(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject overview in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(overview);

                        ComplianceOverview.Add(new CustomComplianceOverview()
                        {
                            Organization = organization,
                            id = properties["id"].ToString(),
                            name = properties["name"].ToString(),
                            pendingCount = properties["pendingCount"].ToString(),
                            notApplicableCount = properties["notApplicableCount"].ToString(),
                            successCount = properties["successCount"].ToString(),
                            errorCount = properties["errorCount"].ToString(),
                            failedCount = properties["failedCount"].ToString(),
                            lastUpdateDateTime = properties["lastUpdateDateTime"].ToString()
                        });
                    }
                    model.ComplianceOverview = ComplianceOverview;
                }
                return PartialView("_IntuneComplianceOverview", model);
            }
            catch (Exception exc)
            {
                throw new Exception(exc.ToString());
            }
        }

        class AzureRessourceGroup
        {
            public string Name { get; set; }
            public string Location { get; set; }

        }
        public string GetAzureRessourceGroups(string organization)
        {
            try
            {
                List<AzureRessourceGroup> RessourceGroup = new List<AzureRessourceGroup>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureRessourceGroups(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject group in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(group);

                        RessourceGroup.Add(new AzureRessourceGroup()
                        {
                            Name = properties["Name"].ToString(),
                            Location = properties["Location"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(RessourceGroup);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzureStorageAccount
        {
            public string Name { get; set; }
            public string Location { get; set; }

        }
        public string GetAzureStorageAccounts(string organization, string ressourcegroupname)
        {
            try
            {
                List<AzureStorageAccount> StorageAccounts = new List<AzureStorageAccount>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureStorageAccounts(organization, ressourcegroupname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject storageaccount in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(storageaccount);

                        StorageAccounts.Add(new AzureStorageAccount()
                        {
                            Name = properties["name"].ToString(),
                            Location = properties["location"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(StorageAccounts);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzureVirtualNetwork
        {
            public string Name { get; set; }
            public string Location { get; set; }

        }
        public string GetAzureVirtualNetworks(string organization, string ressourcegroupname)
        {
            try
            {
                List<AzureVirtualNetwork> VirtualNetworks = new List<AzureVirtualNetwork>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureVirtualNetworks(organization, ressourcegroupname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject network in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(network);

                        VirtualNetworks.Add(new AzureVirtualNetwork()
                        {
                            Name = properties["name"].ToString(),
                            Location = properties["location"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(VirtualNetworks);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzureAvailabilitySet
        {
            public string Name { get; set; }
            public string Location { get; set; }
            public string Sku { get; set; }

        }
        public string GetAzureAvailabilitySets(string organization, string ressourcegroupname)
        {
            try
            {
                List<AzureAvailabilitySet> AvailabilitySets = new List<AzureAvailabilitySet>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureAvailabilitySets(organization, ressourcegroupname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject set in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(set);

                        var SKUMembers = "";
                        var skuobject = (PSObject)set.Properties["sku"].Value;

                        SKUMembers = skuobject.Members["name"].Value.ToString();

                        AvailabilitySets.Add(new AzureAvailabilitySet()
                        {
                            Name = properties["name"].ToString(),
                            Location = properties["location"].ToString(),
                            Sku = SKUMembers
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(AvailabilitySets);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzureVMSize
        {
            public string name { get; set; }
            public string numberOfCores { get; set; }
            public string osDiskSizeInMB { get; set; }
            public string resourceDiskSizeInMB { get; set; }
            public string memoryInMB { get; set; }

        }
        public string GetAzureVMSizes(string organization)
        {
            try
            {
                List<AzureVMSize> VMSizes = new List<AzureVMSize>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureVMSizes(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject size in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(size);

                        VMSizes.Add(new AzureVMSize()
                        {
                            name = properties["name"].ToString(),
                            numberOfCores = properties["numberOfCores"].ToString(),
                            osDiskSizeInMB = properties["osDiskSizeInMB"].ToString(),
                            resourceDiskSizeInMB = properties["resourceDiskSizeInMB"].ToString(),
                            memoryInMB = properties["memoryInMB"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(VMSizes);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzureLocation
        {
            public string name { get; set; }
            public string displayName { get; set; }
            public string id { get; set; }

        }
        public string GetAzureLocations(string organization)
        {
            try
            {
                List<AzureLocation> Locations = new List<AzureLocation>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureLocations(organization);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject location in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(location);

                        Locations.Add(new AzureLocation()
                        {
                            name = properties["name"].ToString(),
                            displayName = properties["displayName"].ToString(),
                            id = properties["id"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(Locations);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }
        class AzureVirtualSubnet
        {
            public string Name { get; set; }
            public string Id { get; set; }
            public string AddressPrefix { get; set; }


        }
        public string GetAzureVirtualSubnets(string organization, string name, string ressourcegroupname)
        {
            try
            {
                List<AzureVirtualSubnet> VirtualSubnets = new List<AzureVirtualSubnet>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureVirtualSubnets(organization, name, ressourcegroupname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject subnet in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(subnet);

                        VirtualSubnets.Add(new AzureVirtualSubnet()
                        {
                            Name = properties["name"].ToString(),
                            Id = properties["id"].ToString(),
                            AddressPrefix = properties["addressPrefix"].ToString(),
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(VirtualSubnets);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        class AzurePublicIP
        {
            public string Name { get; set; }
            public string Id { get; set; }
            public string Location { get; set; }
            public string AllocationMethod { get; set; }
            public string Version { get; set; }
            public string IdleTimeOutInMinutes { get; set; }


        }
        public string GetAzurePublicIPs(string organization, string location)
        {
            try
            {
                List<AzurePublicIP> PublicIPs = new List<AzurePublicIP>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzurePublicIPs(organization, location);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject ip in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(ip);

                        PublicIPs.Add(new AzurePublicIP()
                        {
                            Name = properties["name"].ToString(),
                            Id = properties["id"].ToString(),
                            Location = properties["location"].ToString(),
                            Version = properties["version"].ToString(),
                            AllocationMethod = properties["allocationMethod"].ToString(),
                            IdleTimeOutInMinutes = properties["idleTimeoutInMinutes"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(PublicIPs);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }
        class AzureNetworkInterface
        {
            public string Name { get; set; }
            public string Id { get; set; }
            public string Location { get; set; }
            public string AllocationMethod { get; set; }
            public string Version { get; set; }
            public string IdleTimeOutInMinutes { get; set; }


        }
        public string GetAzureNetworkInterfaces(string organization, string ressourcegroupname)
        {
            try
            {
                List<AzureNetworkInterface> NetInterfaces = new List<AzureNetworkInterface>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureNetworkInterfaces(organization, ressourcegroupname);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject netinterface in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(netinterface);

                        NetInterfaces.Add(new AzureNetworkInterface()
                        {
                            Name = properties["name"].ToString(),
                            Id = properties["id"].ToString(),
                            Location = properties["location"].ToString()
                        });
                    }
                }

                return new JavaScriptSerializer().Serialize(NetInterfaces);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }

        public string GetAzureIntuneDeviceConfiguration(string organization, string id)
        {
            try
            {
                List<CustomAzureDeviceConfiguration> IntuneDeviceConfiguration = new List<CustomAzureDeviceConfiguration>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureIntuneDeviceConfiguration(organization, id);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject deviceconfiguration in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(deviceconfiguration);

                        //foreach (var item in properties)
                        //{
                        //    if (item.Value == null) { throw new Exception(item.Key); }
                        //}

                        if (properties["platform"].ToString() == "Android")
                        {
                            IntuneDeviceConfiguration.Add(new CustomAzureDeviceConfiguration()
                            {
                                
                                platform = properties["platform"].ToString(),
                                displayName = Convert.ToString(properties["displayName"]),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                appsBlockClipboardSharing = properties["appsBlockClipboardSharing"].ToString(),
                                appsBlockCopyPaste = properties["appsBlockCopyPaste"].ToString(),
                                appsBlockYouTube = properties["appsBlockYouTube"].ToString(),
                                bluetoothBlocked = properties["bluetoothBlocked"].ToString(),
                                cameraBlocked = properties["cameraBlocked"].ToString(),
                                cellularBlockDataRoaming = properties["cellularBlockDataRoaming"].ToString(),
                                cellularBlockMessaging = properties["cellularBlockMessaging"].ToString(),
                                cellularBlockVoiceRoaming = properties["cellularBlockVoiceRoaming"].ToString(),
                                cellularBlockWiFiTethering = properties["cellularBlockWiFiTethering"].ToString(),
                                locationServicesBlocked = properties["locationServicesBlocked"].ToString(),
                                googleAccountBlockAutoSync = properties["googleAccountBlockAutoSync"].ToString(),
                                googlePlayStoreBlocked = properties["googlePlayStoreBlocked"].ToString(),
                                nfcBlocked = properties["nfcBlocked"].ToString(),
                                passwordRequired = properties["passwordRequired"].ToString(),
                                passwordMinimumLength = Convert.ToString(properties["passwordMinimumLength"]),
                                passwordBlockFingerprintUnlock = Convert.ToString(properties["passwordBlockFingerprintUnlock"]),
                                passwordBlockTrustAgents = Convert.ToString(properties["passwordBlockTrustAgents"]),
                                passwordExpirationDays = Convert.ToString(properties["passwordExpirationDays"]),
                                passwordMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["passwordMinutesOfInactivityBeforeScreenTimeout"]),
                                passwordPreviousPasswordBlockCount = Convert.ToString(properties["passwordPreviousPasswordBlockCount"]),
                                passwordSignInFailureCountBeforeFactoryReset = Convert.ToString(properties["passwordSignInFailureCountBeforeFactoryReset"]),
                                passwordRequiredType = properties["passwordRequiredType"].ToString(),
                                factoryResetBlocked = properties["factoryResetBlocked"].ToString(),
                                powerOffBlocked = properties["powerOffBlocked"].ToString(),
                                screenCaptureBlocked = properties["screenCaptureBlocked"].ToString(),
                                deviceSharingAllowed = properties["deviceSharingAllowed"].ToString(),
                                storageBlockGoogleBackup = properties["storageBlockGoogleBackup"].ToString(),
                                storageBlockRemovableStorage = properties["storageBlockRemovableStorage"].ToString(),
                                storageRequireDeviceEncryption = properties["storageRequireDeviceEncryption"].ToString(),
                                storageRequireRemovableStorageEncryption = properties["storageRequireRemovableStorageEncryption"].ToString(),
                                voiceAssistantBlocked = properties["voiceAssistantBlocked"].ToString(),
                                voiceDialingBlocked = properties["voiceDialingBlocked"].ToString(),
                                webBrowserBlockPopups = properties["webBrowserBlockPopups"].ToString(),
                                webBrowserBlockAutofill = properties["webBrowserBlockAutofill"].ToString(),
                                webBrowserBlockJavaScript = properties["webBrowserBlockJavaScript"].ToString(),
                                webBrowserBlocked = properties["webBrowserBlocked"].ToString(),
                                webBrowserCookieSettings = properties["webBrowserCookieSettings"].ToString(),
                                wiFiBlocked = properties["wiFiBlocked"].ToString()
                            });
                        }
                        if (properties["platform"].ToString() == "AFW")
                        {
                            IntuneDeviceConfiguration.Add(new CustomAzureDeviceConfiguration()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                workProfileDataSharingType = properties["workProfileDataSharingType"].ToString(),
                                workProfileBlockNotificationsWhileDeviceLocked = properties["workProfileBlockNotificationsWhileDeviceLocked"].ToString(),
                                workProfileDefaultAppPermissionPolicy = properties["workProfileDefaultAppPermissionPolicy"].ToString(),
                                workProfileRequirePassword = properties["workProfileRequirePassword"].ToString(),
                                workProfilePasswordMinimumLength = Convert.ToString(properties["workProfilePasswordMinimumLength"]),
                                workProfilePasswordMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["workProfilePasswordMinutesOfInactivityBeforeScreenTimeout"]),
                                workProfilePasswordSignInFailureCountBeforeFactoryReset = Convert.ToString(properties["workProfilePasswordSignInFailureCountBeforeFactoryReset"]),
                                workProfilePasswordExpirationDays = Convert.ToString(properties["workProfilePasswordExpirationDays"]),
                                workProfilePasswordRequiredType = properties["workProfilePasswordRequiredType"].ToString(),
                                workProfilePasswordPreviousPasswordBlockCount = Convert.ToString(properties["workProfilePasswordPreviousPasswordBlockCount"]),
                                workProfilePasswordBlockFingerprintUnlock = properties["workProfilePasswordBlockFingerprintUnlock"].ToString(),
                                workProfilePasswordBlockTrustAgents = properties["workProfilePasswordBlockTrustAgents"].ToString(),
                                afwpasswordMinimumLength = Convert.ToString(properties["passwordMinimumLength"]),
                                afwpasswordMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["passwordMinutesOfInactivityBeforeScreenTimeout"]),
                                afwpasswordSignInFailureCountBeforeFactoryReset = Convert.ToString(properties["passwordSignInFailureCountBeforeFactoryReset"]),
                                afwpasswordExpirationDays = Convert.ToString(properties["passwordExpirationDays"]),
                                afwpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                afwpasswordPreviousPasswordBlockCount = Convert.ToString(properties["passwordPreviousPasswordBlockCount"]),
                                afwpasswordBlockFingerprintUnlock = properties["passwordBlockFingerprintUnlock"].ToString(),
                                afwpasswordBlockTrustAgents = properties["passwordBlockTrustAgents"].ToString()
                            });
                        }

                        if (properties["platform"].ToString() == "Win10")
                        {
                            IntuneDeviceConfiguration.Add(new CustomAzureDeviceConfiguration()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                winscreenCaptureBlocked = properties["screenCaptureBlocked"].ToString(),
                                copyPasteBlocked = properties["copyPasteBlocked"].ToString(),
                                deviceManagementBlockManualUnenroll = properties["deviceManagementBlockManualUnenroll"].ToString(),
                                certificatesBlockManualRootCertificateInstallation = properties["certificatesBlockManualRootCertificateInstallation"].ToString(),
                                wincameraBlocked = properties["cameraBlocked"].ToString(),
                                oneDriveDisableFileSync = properties["oneDriveDisableFileSync"].ToString(),
                                winstorageBlockRemovableStorage = properties["storageBlockRemovableStorage"].ToString(),
                                winlocationServicesBlocked = properties["locationServicesBlocked"].ToString(),
                                internetSharingBlocked = properties["internetSharingBlocked"].ToString(),
                                deviceManagementBlockFactoryResetOnMobile = properties["deviceManagementBlockFactoryResetOnMobile"].ToString(),
                                usbBlocked = properties["usbBlocked"].ToString(),
                                antiTheftModeBlocked = properties["antiTheftModeBlocked"].ToString(),
                                cortanaBlocked = properties["cortanaBlocked"].ToString(),
                                voiceRecordingBlocked = properties["voiceRecordingBlocked"].ToString(),
                                settingsBlockEditDeviceName = properties["settingsBlockEditDeviceName"].ToString(),
                                settingsBlockAddProvisioningPackage = properties["settingsBlockAddProvisioningPackage"].ToString(),
                                settingsBlockRemoveProvisioningPackage = properties["settingsBlockRemoveProvisioningPackage"].ToString(),
                                experienceBlockDeviceDiscovery = properties["experienceBlockDeviceDiscovery"].ToString(),
                                experienceBlockTaskSwitcher = properties["experienceBlockTaskSwitcher"].ToString(),
                                experienceBlockErrorDialogWhenNoSIM = properties["experienceBlockErrorDialogWhenNoSIM"].ToString(),
                                winpasswordRequired = properties["passwordRequired"].ToString(),
                                winpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                winpasswordMinimumLength = Convert.ToString(properties["passwordMinimumLength"]),
                                winpasswordMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["passwordMinutesOfInactivityBeforeScreenTimeout"]),
                                winpasswordSignInFailureCountBeforeFactoryReset = Convert.ToString(properties["passwordSignInFailureCountBeforeFactoryReset"]),
                                winpasswordExpirationDays = Convert.ToString(properties["passwordExpirationDays"]),
                                winpasswordPreviousPasswordBlockCount = Convert.ToString(properties["passwordPreviousPasswordBlockCount"]),
                                winpasswordRequireWhenResumeFromIdleState = properties["passwordRequireWhenResumeFromIdleState"].ToString(),
                                winpasswordBlockSimple = properties["passwordBlockSimple"].ToString(),
                                storageRequireMobileDeviceEncryption = properties["storageRequireMobileDeviceEncryption"].ToString(),
                                personalizationDesktopImageUrl = Convert.ToString(properties["personalizationDesktopImageUrl"]),
                                privacyBlockInputPersonalization = properties["privacyBlockInputPersonalization"].ToString(),
                                privacyAutoAcceptPairingAndConsentPrompts = properties["privacyAutoAcceptPairingAndConsentPrompts"].ToString(),
                                lockScreenBlockActionCenterNotifications = properties["lockScreenBlockActionCenterNotifications"].ToString(),
                                personalizationLockScreenImageUrl = Convert.ToString(properties["personalizationLockScreenImageUrl"]),
                                lockScreenAllowTimeoutConfiguration = properties["lockScreenAllowTimeoutConfiguration"].ToString(),
                                lockScreenBlockCortana = properties["lockScreenBlockCortana"].ToString(),
                                lockScreenBlockToastNotifications = properties["lockScreenBlockToastNotifications"].ToString(),
                                lockScreenTimeoutInSeconds = Convert.ToString(properties["lockScreenTimeoutInSeconds"]),
                                windowsStoreBlocked = properties["windowsStoreBlocked"].ToString(),
                                windowsStoreBlockAutoUpdate = properties["windowsStoreBlockAutoUpdate"].ToString(),
                                appsAllowTrustedAppsSideloading = properties["appsAllowTrustedAppsSideloading"].ToString(),
                                developerUnlockSetting = properties["developerUnlockSetting"].ToString(),
                                sharedUserAppDataAllowed = properties["sharedUserAppDataAllowed"].ToString(),
                                windowsStoreEnablePrivateStoreOnly = properties["windowsStoreEnablePrivateStoreOnly"].ToString(),
                                appsBlockWindowsStoreOriginatedApps = properties["appsBlockWindowsStoreOriginatedApps"].ToString(),
                                storageRestrictAppDataToSystemVolume = properties["storageRestrictAppDataToSystemVolume"].ToString(),
                                storageRestrictAppInstallToSystemVolume = properties["storageRestrictAppInstallToSystemVolume"].ToString(),
                                gameDvrBlocked = properties["gameDvrBlocked"].ToString(),
                                smartScreenEnableAppInstallControl = properties["smartScreenEnableAppInstallControl"].ToString(),
                                edgeBlocked = properties["edgeBlocked"].ToString(),
                                edgeBlockAddressBarDropdown = properties["edgeBlockAddressBarDropdown"].ToString(),
                                edgeSyncFavoritesWithInternetExplorer = properties["edgeSyncFavoritesWithInternetExplorer"].ToString(),
                                edgeClearBrowsingDataOnExit = properties["edgeClearBrowsingDataOnExit"].ToString(),
                                edgeBlockSendingDoNotTrackHeader = properties["edgeBlockSendingDoNotTrackHeader"].ToString(),
                                edgeCookiePolicy = properties["edgeCookiePolicy"].ToString(),
                                edgeBlockJavaScript = properties["edgeBlockJavaScript"].ToString(),
                                edgeBlockPopups = properties["edgeBlockPopups"].ToString(),
                                edgeBlockSearchSuggestions = properties["edgeBlockSearchSuggestions"].ToString(),
                                edgeBlockSendingIntranetTrafficToInternetExplorer = properties["edgeBlockSendingIntranetTrafficToInternetExplorer"].ToString(),
                                edgeBlockAutofill = properties["edgeBlockAutofill"].ToString(),
                                edgeBlockPasswordManager = properties["edgeBlockPasswordManager"].ToString(),
                                edgeEnterpriseModeSiteListLocation = Convert.ToString(properties["edgeEnterpriseModeSiteListLocation"]),
                                edgeBlockDeveloperTools = properties["edgeBlockDeveloperTools"].ToString(),
                                edgeBlockExtensions = properties["edgeBlockExtensions"].ToString(),
                                edgeBlockInPrivateBrowsing = properties["edgeBlockInPrivateBrowsing"].ToString(),
                                edgeDisableFirstRunPage = properties["edgeDisableFirstRunPage"].ToString(),
                                edgeFirstRunUrl = Convert.ToString(properties["edgeFirstRunUrl"]),
                                edgeAllowStartPagesModification = properties["edgeAllowStartPagesModification"].ToString(),
                                edgeBlockAccessToAboutFlags = properties["edgeBlockAccessToAboutFlags"].ToString(),
                                webRtcBlockLocalhostIpAddress = properties["webRtcBlockLocalhostIpAddress"].ToString(),
                                edgeSearchEngine = Convert.ToString(properties["edgeSearchEngine"]),
                                edgeCustomURL = Convert.ToString(properties["edgeCustomURL"]),
                                edgeBlockCompatibilityList = properties["edgeBlockCompatibilityList"].ToString(),
                                edgeBlockLiveTileDataCollection = properties["edgeBlockLiveTileDataCollection"].ToString(),
                                edgeRequireSmartScreen = properties["edgeRequireSmartScreen"].ToString(),
                                smartScreenBlockPromptOverride = properties["smartScreenBlockPromptOverride"].ToString(),
                                smartScreenBlockPromptOverrideForFiles = properties["smartScreenBlockPromptOverrideForFiles"].ToString(),
                                safeSearchFilter = properties["safeSearchFilter"].ToString(),
                                microsoftAccountBlocked = properties["microsoftAccountBlocked"].ToString(),
                                accountsBlockAddingNonMicrosoftAccountEmail = properties["accountsBlockAddingNonMicrosoftAccountEmail"].ToString(),
                                microsoftAccountBlockSettingsSync = properties["microsoftAccountBlockSettingsSync"].ToString(),
                                cellularData = properties["cellularData"].ToString(),
                                cellularBlockDataWhenRoaming = properties["cellularBlockDataWhenRoaming"].ToString(),
                                cellularBlockVpn = properties["cellularBlockVpn"].ToString(),
                                cellularBlockVpnWhenRoaming = properties["cellularBlockVpnWhenRoaming"].ToString(),
                                winbluetoothBlocked = properties["bluetoothBlocked"].ToString(),
                                bluetoothBlockDiscoverableMode = properties["bluetoothBlockDiscoverableMode"].ToString(),
                                bluetoothBlockPrePairing = properties["bluetoothBlockPrePairing"].ToString(),
                                bluetoothBlockAdvertising = properties["bluetoothBlockAdvertising"].ToString(),
                                connectedDevicesServiceBlocked = properties["connectedDevicesServiceBlocked"].ToString(),
                                winnfcBlocked = properties["nfcBlocked"].ToString(),
                                winwiFiBlocked = properties["wiFiBlocked"].ToString(),
                                wiFiBlockAutomaticConnectHotspots = properties["wiFiBlockAutomaticConnectHotspots"].ToString(),
                                wiFiBlockManualConfiguration = properties["wiFiBlockManualConfiguration"].ToString(),
                                wiFiScanInterval = Convert.ToString(properties["wiFiScanInterval"]),
                                settingsBlockSettingsApp = properties["settingsBlockSettingsApp"].ToString(),
                                settingsBlockSystemPage = properties["settingsBlockSystemPage"].ToString(),
                                settingsBlockChangePowerSleep = properties["settingsBlockChangePowerSleep"].ToString(),
                                settingsBlockDevicesPage = properties["settingsBlockDevicesPage"].ToString(),
                                settingsBlockNetworkInternetPage = properties["settingsBlockNetworkInternetPage"].ToString(),
                                settingsBlockPersonalizationPage = properties["settingsBlockPersonalizationPage"].ToString(),
                                settingsBlockAppsPage = properties["settingsBlockAppsPage"].ToString(),
                                settingsBlockAccountsPage = properties["settingsBlockAccountsPage"].ToString(),
                                settingsBlockTimeLanguagePage = properties["settingsBlockTimeLanguagePage"].ToString(),
                                settingsBlockChangeSystemTime = properties["settingsBlockChangeSystemTime"].ToString(),
                                settingsBlockChangeRegion = properties["settingsBlockChangeRegion"].ToString(),
                                settingsBlockChangeLanguage = properties["settingsBlockChangeLanguage"].ToString(),
                                settingsBlockGamingPage = properties["settingsBlockGamingPage"].ToString(),
                                settingsBlockEaseOfAccessPage = properties["settingsBlockEaseOfAccessPage"].ToString(),
                                settingsBlockPrivacyPage = properties["settingsBlockPrivacyPage"].ToString(),
                                settingsBlockUpdateSecurityPage = properties["settingsBlockUpdateSecurityPage"].ToString(),
                                defenderRequireRealTimeMonitoring = properties["defenderRequireRealTimeMonitoring"].ToString(),
                                defenderRequireBehaviorMonitoring = properties["defenderRequireBehaviorMonitoring"].ToString(),
                                defenderRequireNetworkInspectionSystem = properties["defenderRequireNetworkInspectionSystem"].ToString(),
                                defenderScanDownloads = properties["defenderScanDownloads"].ToString(),
                                defenderScanScriptsLoadedInInternetExplorer = properties["defenderScanScriptsLoadedInInternetExplorer"].ToString(),
                                defenderBlockEndUserAccess = properties["defenderBlockEndUserAccess"].ToString(),
                                defenderSignatureUpdateIntervalInHours = Convert.ToString(properties["defenderSignatureUpdateIntervalInHours"]),
                                defenderMonitorFileActivity = properties["defenderMonitorFileActivity"].ToString(),
                                defenderDaysBeforeDeletingQuarantinedMalware = Convert.ToString(properties["defenderDaysBeforeDeletingQuarantinedMalware"]),
                                defenderScanMaxCpu = Convert.ToString(properties["defenderScanMaxCpu"]),
                                defenderScanArchiveFiles = properties["defenderScanArchiveFiles"].ToString(),
                                defenderScanIncomingMail = properties["defenderScanIncomingMail"].ToString(),
                                defenderScanRemovableDrivesDuringFullScan = properties["defenderScanRemovableDrivesDuringFullScan"].ToString(),
                                defenderScanMappedNetworkDrivesDuringFullScan = properties["defenderScanMappedNetworkDrivesDuringFullScan"].ToString(),
                                defenderScanNetworkFiles = properties["defenderScanNetworkFiles"].ToString(),
                                defenderRequireCloudProtection = properties["defenderRequireCloudProtection"].ToString(),
                                defenderPromptForSampleSubmission = properties["defenderPromptForSampleSubmission"].ToString(),
                                defenderScheduledQuickScanTime = Convert.ToString(properties["defenderScheduledQuickScanTime"]),
                                defenderScanType = properties["defenderScanType"].ToString(),
                                defenderSystemScanSchedule = properties["defenderSystemScanSchedule"].ToString(),
                                defenderScheduledScanTime = Convert.ToString(properties["defenderScheduledScanTime"]),
                                defenderPotentiallyUnwantedAppAction = Convert.ToString(properties["defenderPotentiallyUnwantedAppAction"]),
                                defenderDetectedMalwareActions = Convert.ToString(properties["defenderDetectedMalwareActions"]),
                                defenderlowseverity = Convert.ToString(properties["defenderlowseverity"]),
                                defendermoderateseverity = Convert.ToString(properties["defendermoderateseverity"]),
                                defenderhighseverity = Convert.ToString(properties["defenderhighseverity"]),
                                defendersevereseverity = Convert.ToString(properties["defendersevereseverity"]),
                                startBlockUnpinningAppsFromTaskbar = properties["startBlockUnpinningAppsFromTaskbar"].ToString(),
                                logonBlockFastUserSwitching = properties["logonBlockFastUserSwitching"].ToString(),
                                startMenuHideFrequentlyUsedApps = properties["startMenuHideFrequentlyUsedApps"].ToString(),
                                startMenuHideRecentlyAddedApps = properties["startMenuHideRecentlyAddedApps"].ToString(),
                                startMenuMode = properties["startMenuMode"].ToString(),
                                startMenuHideRecentJumpLists = properties["startMenuHideRecentJumpLists"].ToString(),
                                startMenuAppListVisibility = properties["startMenuAppListVisibility"].ToString(),
                                startMenuHidePowerButton = properties["startMenuHidePowerButton"].ToString(),
                                startMenuHideUserTile = properties["startMenuHideUserTile"].ToString(),
                                startMenuHideLock = properties["startMenuHideLock"].ToString(),
                                startMenuHideSignOut = properties["startMenuHideSignOut"].ToString(),
                                startMenuHideShutDown = properties["startMenuHideShutDown"].ToString(),
                                startMenuHideSleep = properties["startMenuHideSleep"].ToString(),
                                startMenuHideHibernate = properties["startMenuHideHibernate"].ToString(),
                                startMenuHideSwitchAccount = properties["startMenuHideSwitchAccount"].ToString(),
                                startMenuHideRestartOptions = properties["startMenuHideRestartOptions"].ToString(),
                                startMenuPinnedFolderDocuments = properties["startMenuPinnedFolderDocuments"].ToString(),
                                startMenuPinnedFolderDownloads = properties["startMenuPinnedFolderDownloads"].ToString(),
                                startMenuPinnedFolderFileExplorer = properties["startMenuPinnedFolderFileExplorer"].ToString(),
                                startMenuPinnedFolderHomeGroup = properties["startMenuPinnedFolderHomeGroup"].ToString(),
                                startMenuPinnedFolderMusic = properties["startMenuPinnedFolderMusic"].ToString(),
                                startMenuPinnedFolderNetwork = properties["startMenuPinnedFolderNetwork"].ToString(),
                                startMenuPinnedFolderPersonalFolder = properties["startMenuPinnedFolderPersonalFolder"].ToString(),
                                startMenuPinnedFolderPictures = properties["startMenuPinnedFolderPictures"].ToString(),
                                startMenuPinnedFolderSettings = properties["startMenuPinnedFolderSettings"].ToString(),
                                startMenuPinnedFolderVideos = properties["startMenuPinnedFolderVideos"].ToString(),
                            });
                            
                        }

                        if (properties["platform"].ToString() == "IOS")
                        {
                            IntuneDeviceConfiguration.Add(new CustomAzureDeviceConfiguration()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                accountBlockModification = properties["accountBlockModification"].ToString(),
                                activationLockAllowWhenSupervised = properties["activationLockAllowWhenSupervised"].ToString(),
                                airDropBlocked = properties["airDropBlocked"].ToString(),
                                airDropForceUnmanagedDropTarget = properties["airDropForceUnmanagedDropTarget"].ToString(),
                                airPlayForcePairingPasswordForOutgoingRequests = properties["airPlayForcePairingPasswordForOutgoingRequests"].ToString(),
                                appleWatchBlockPairing = properties["appleWatchBlockPairing"].ToString(),
                                appleWatchForceWristDetection = properties["appleWatchForceWristDetection"].ToString(),
                                appleNewsBlocked = properties["appleNewsBlocked"].ToString(),
                                appStoreBlockAutomaticDownloads = properties["appStoreBlockAutomaticDownloads"].ToString(),
                                appStoreBlocked = properties["appStoreBlocked"].ToString(),
                                appStoreBlockInAppPurchases = properties["appStoreBlockInAppPurchases"].ToString(),
                                appStoreBlockUIAppInstallation = properties["appStoreBlockUIAppInstallation"].ToString(),
                                appStoreRequirePassword = properties["appStoreRequirePassword"].ToString(),
                                bluetoothBlockModification = properties["bluetoothBlockModification"].ToString(),
                                cameraBlocked = properties["cameraBlocked"].ToString(),
                                cellularBlockDataRoaming = properties["cellularBlockDataRoaming"].ToString(),
                                cellularBlockGlobalBackgroundFetchWhileRoaming = properties["cellularBlockGlobalBackgroundFetchWhileRoaming"].ToString(),
                                cellularBlockPerAppDataModification = properties["cellularBlockPerAppDataModification"].ToString(),
                                cellularBlockPersonalHotspot = properties["cellularBlockPersonalHotspot"].ToString(),
                                cellularBlockVoiceRoaming = properties["cellularBlockVoiceRoaming"].ToString(),
                                certificatesBlockUntrustedTlsCertificates = properties["certificatesBlockUntrustedTlsCertificates"].ToString(),
                                classroomAppBlockRemoteScreenObservation = properties["classroomAppBlockRemoteScreenObservation"].ToString(),
                                classroomAppForceUnpromptedScreenObservation = properties["classroomAppForceUnpromptedScreenObservation"].ToString(),
                                configurationProfileBlockChanges = properties["configurationProfileBlockChanges"].ToString(),
                                definitionLookupBlocked = properties["definitionLookupBlocked"].ToString(),
                                deviceBlockEnableRestrictions = properties["deviceBlockEnableRestrictions"].ToString(),
                                deviceBlockEraseContentAndSettings = properties["deviceBlockEraseContentAndSettings"].ToString(),
                                deviceBlockNameModification = properties["deviceBlockNameModification"].ToString(),
                                diagnosticDataBlockSubmission = properties["diagnosticDataBlockSubmission"].ToString(),
                                diagnosticDataBlockSubmissionModification = properties["diagnosticDataBlockSubmissionModification"].ToString(),
                                documentsBlockManagedDocumentsInUnmanagedApps = properties["documentsBlockManagedDocumentsInUnmanagedApps"].ToString(),
                                documentsBlockUnmanagedDocumentsInManagedApps = properties["documentsBlockUnmanagedDocumentsInManagedApps"].ToString(),
                                enterpriseAppBlockTrust = properties["enterpriseAppBlockTrust"].ToString(),
                                enterpriseAppBlockTrustModification = properties["enterpriseAppBlockTrustModification"].ToString(),
                                faceTimeBlocked = properties["faceTimeBlocked"].ToString(),
                                findMyFriendsBlocked = properties["findMyFriendsBlocked"].ToString(),
                                gamingBlockGameCenterFriends = properties["gamingBlockGameCenterFriends"].ToString(),
                                gamingBlockMultiplayer = properties["gamingBlockMultiplayer"].ToString(),
                                gameCenterBlocked = properties["gameCenterBlocked"].ToString(),
                                hostPairingBlocked = properties["hostPairingBlocked"].ToString(),
                                iBooksStoreBlocked = properties["iBooksStoreBlocked"].ToString(),
                                iBooksStoreBlockErotica = properties["iBooksStoreBlockErotica"].ToString(),
                                iCloudBlockActivityContinuation = properties["iCloudBlockActivityContinuation"].ToString(),
                                iCloudBlockBackup = properties["iCloudBlockBackup"].ToString(),
                                iCloudBlockDocumentSync = properties["iCloudBlockDocumentSync"].ToString(),
                                iCloudBlockManagedAppsSync = properties["iCloudBlockManagedAppsSync"].ToString(),
                                iCloudBlockPhotoLibrary = properties["iCloudBlockPhotoLibrary"].ToString(),
                                iCloudBlockPhotoStreamSync = properties["iCloudBlockPhotoStreamSync"].ToString(),
                                iCloudBlockSharedPhotoStream = properties["iCloudBlockSharedPhotoStream"].ToString(),
                                iCloudRequireEncryptedBackup = properties["iCloudRequireEncryptedBackup"].ToString(),
                                iTunesBlockExplicitContent = properties["iTunesBlockExplicitContent"].ToString(),
                                iTunesBlockMusicService = properties["iTunesBlockMusicService"].ToString(),
                                iTunesBlockRadio = properties["iTunesBlockRadio"].ToString(),
                                keyboardBlockAutoCorrect = properties["keyboardBlockAutoCorrect"].ToString(),
                                keyboardBlockDictation = properties["keyboardBlockDictation"].ToString(),
                                keyboardBlockPredictive = properties["keyboardBlockPredictive"].ToString(),
                                keyboardBlockShortcuts = properties["keyboardBlockShortcuts"].ToString(),
                                keyboardBlockSpellCheck = properties["keyboardBlockSpellCheck"].ToString(),
                                lockScreenBlockControlCenter = properties["lockScreenBlockControlCenter"].ToString(),
                                lockScreenBlockNotificationView = properties["lockScreenBlockNotificationView"].ToString(),
                                lockScreenBlockPassbook = properties["lockScreenBlockPassbook"].ToString(),
                                lockScreenBlockTodayView = properties["lockScreenBlockTodayView"].ToString(),
                                mediaContentRatingApps = properties["mediaContentRatingApps"].ToString(),
                                messagesBlocked = properties["messagesBlocked"].ToString(),
                                notificationsBlockSettingsModification = properties["notificationsBlockSettingsModification"].ToString(),
                                passcodeBlockFingerprintUnlock = properties["passcodeBlockFingerprintUnlock"].ToString(),
                                passcodeBlockFingerprintModification = properties["passcodeBlockFingerprintModification"].ToString(),
                                passcodeBlockModification = properties["passcodeBlockModification"].ToString(),
                                passcodeBlockSimple = properties["passcodeBlockSimple"].ToString(),
                                passcodeExpirationDays = Convert.ToString(properties["passcodeExpirationDays"]),
                                passcodeMinimumLength = Convert.ToString(properties["passcodeMinimumLength"]),
                                passcodeMinutesOfInactivityBeforeLock = Convert.ToString(properties["passcodeMinutesOfInactivityBeforeLock"]),
                                passcodeMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["passcodeMinutesOfInactivityBeforeScreenTimeout"]),
                                passcodeMinimumCharacterSetCount = Convert.ToString(properties["passcodeMinimumCharacterSetCount"]),
                                passcodePreviousPasscodeBlockCount = Convert.ToString(properties["passcodePreviousPasscodeBlockCount"]),
                                passcodeSignInFailureCountBeforeWipe = Convert.ToString(properties["passcodeSignInFailureCountBeforeWipe"]),
                                passcodeRequiredType = properties["passcodeRequiredType"].ToString(),
                                passcodeRequired = properties["passcodeRequired"].ToString(),
                                podcastsBlocked = properties["podcastsBlocked"].ToString(),
                                safariBlockAutofill = properties["safariBlockAutofill"].ToString(),
                                safariBlockJavaScript = properties["safariBlockJavaScript"].ToString(),
                                safariBlockPopups = properties["safariBlockPopups"].ToString(),
                                safariBlocked = properties["safariBlocked"].ToString(),
                                safariCookieSettings = properties["safariCookieSettings"].ToString(),
                                safariRequireFraudWarning = properties["safariRequireFraudWarning"].ToString(),
                                screenCaptureBlocked = properties["screenCaptureBlocked"].ToString(),
                                siriBlocked = properties["siriBlocked"].ToString(),
                                siriBlockedWhenLocked = properties["siriBlockedWhenLocked"].ToString(),
                                siriBlockUserGeneratedContent = properties["siriBlockUserGeneratedContent"].ToString(),
                                siriRequireProfanityFilter = properties["siriRequireProfanityFilter"].ToString(),
                                spotlightBlockInternetResults = properties["spotlightBlockInternetResults"].ToString(),
                                voiceDialingBlocked = properties["voiceDialingBlocked"].ToString(),
                                wallpaperBlockModification = properties["wallpaperBlockModification"].ToString(),
                                wiFiConnectOnlyToConfiguredNetworks = properties["wiFiConnectOnlyToConfiguredNetworks"].ToString()
                            });
                        }

                        if (properties["platform"].ToString() == "macOS")
                        {
                            IntuneDeviceConfiguration.Add(new CustomAzureDeviceConfiguration()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                macpasswordMinimumLength = Convert.ToString(properties["passwordMinimumLength"]),
                                macpasswordBlockSimple = properties["passwordBlockSimple"].ToString(),
                                macpasswordMinimumCharacterSetCount = Convert.ToString(properties["passwordMinimumCharacterSetCount"]),
                                macpasswordMinutesOfInactivityBeforeLock = Convert.ToString(properties["passwordMinutesOfInactivityBeforeLock"]),
                                macpasswordExpirationDays = Convert.ToString(properties["passwordExpirationDays"]),
                                macpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                macpasswordPreviousPasswordBlockCount = Convert.ToString(properties["passwordPreviousPasswordBlockCount"]),
                                macpasswordMinutesOfInactivityBeforeScreenTimeout = Convert.ToString(properties["passwordMinutesOfInactivityBeforeScreenTimeout"]),
                                macpasswordRequired = properties["passwordRequired"].ToString()
                            });
                        }

                    }
                }

                return new JavaScriptSerializer().Serialize(IntuneDeviceConfiguration);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }
        // Display updatedeviceconf view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult UpdateAzureIntuneDeviceConfiguration()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult UpdateAzureIntuneDeviceConfiguration(FormCollection _POST)
        {
            try
            {
                CustomAzureDeviceConfiguration AzureDeviceConfiguration = new CustomAzureDeviceConfiguration();

                if (_POST["platform"] == "Android")
                {
                    AzureDeviceConfiguration.organization = _POST["organization"];
                    AzureDeviceConfiguration.platform = _POST["platform"];
                    AzureDeviceConfiguration.displayName = _POST["displayName"];
                    AzureDeviceConfiguration.id = _POST["deviceconf"];
                    AzureDeviceConfiguration.description = _POST["description"];
                    AzureDeviceConfiguration.appsBlockClipboardSharing = _POST["appsBlockClipboardSharing"];
                    AzureDeviceConfiguration.appsBlockCopyPaste = _POST["appsBlockCopyPaste"];
                    AzureDeviceConfiguration.appsBlockYouTube = _POST["appsBlockYouTube"];
                    AzureDeviceConfiguration.bluetoothBlocked = _POST["bluetoothBlocked"];
                    AzureDeviceConfiguration.cameraBlocked = _POST["cameraBlocked"];
                    AzureDeviceConfiguration.cellularBlockDataRoaming = _POST["cellularBlockDataRoaming"];
                    AzureDeviceConfiguration.cellularBlockMessaging = _POST["cellularBlockMessaging"];
                    AzureDeviceConfiguration.cellularBlockVoiceRoaming = _POST["cellularBlockVoiceRoaming"];
                    AzureDeviceConfiguration.cellularBlockWiFiTethering = _POST["cellularBlockWiFiTethering"];
                    AzureDeviceConfiguration.locationServicesBlocked = _POST["locationServicesBlocked"];
                    AzureDeviceConfiguration.googleAccountBlockAutoSync = _POST["googleAccountBlockAutoSync"];
                    AzureDeviceConfiguration.googlePlayStoreBlocked = _POST["googlePlayStoreBlocked"];
                    AzureDeviceConfiguration.nfcBlocked = _POST["nfcBlocked"];
                    AzureDeviceConfiguration.passwordRequired = _POST["passwordRequired"];
                    AzureDeviceConfiguration.passwordBlockFingerprintUnlock = _POST["passwordBlockFingerprintUnlock"];
                    AzureDeviceConfiguration.passwordBlockTrustAgents = _POST["passwordBlockTrustAgents"];
                    AzureDeviceConfiguration.passwordExpirationDays = _POST["passwordExpirationDays"];
                    AzureDeviceConfiguration.passwordMinimumLength = _POST["passwordMinimumLength"];
                    AzureDeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = _POST["passwordMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.passwordPreviousPasswordBlockCount = _POST["passwordPreviousPasswordBlockCount"];
                    AzureDeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = _POST["passwordSignInFailureCountBeforeFactoryReset"];
                    AzureDeviceConfiguration.passwordRequiredType = _POST["passwordRequiredType"];
                    AzureDeviceConfiguration.factoryResetBlocked = _POST["factoryResetBlocked"];
                    AzureDeviceConfiguration.powerOffBlocked = _POST["powerOffBlocked"];
                    AzureDeviceConfiguration.screenCaptureBlocked = _POST["screenCaptureBlocked"];
                    AzureDeviceConfiguration.deviceSharingAllowed = _POST["deviceSharingAllowed"];
                    AzureDeviceConfiguration.storageBlockGoogleBackup = _POST["storageBlockGoogleBackup"];
                    AzureDeviceConfiguration.storageBlockRemovableStorage = _POST["storageBlockRemovableStorage"];
                    AzureDeviceConfiguration.storageRequireDeviceEncryption = _POST["storageRequireDeviceEncryption"];
                    AzureDeviceConfiguration.storageRequireRemovableStorageEncryption = _POST["storageRequireRemovableStorageEncryption"];
                    AzureDeviceConfiguration.voiceAssistantBlocked = _POST["voiceAssistantBlocked"];
                    AzureDeviceConfiguration.voiceDialingBlocked = _POST["voiceDialingBlocked"];
                    AzureDeviceConfiguration.webBrowserBlockPopups = _POST["webBrowserBlockPopups"];
                    AzureDeviceConfiguration.webBrowserBlockAutofill = _POST["webBrowserBlockAutofill"];
                    AzureDeviceConfiguration.webBrowserBlockJavaScript = _POST["webBrowserBlockJavaScript"];
                    AzureDeviceConfiguration.webBrowserBlocked = _POST["webBrowserBlocked"];
                    AzureDeviceConfiguration.webBrowserCookieSettings = _POST["webBrowserCookieSettings"];
                    AzureDeviceConfiguration.wiFiBlocked = _POST["wiFiBlocked"];
                }
                if (_POST["platform"] == "AFW")
                {
                    AzureDeviceConfiguration.organization = _POST["organization"];
                    AzureDeviceConfiguration.platform = _POST["platform"];
                    AzureDeviceConfiguration.displayName = _POST["displayName"];
                    AzureDeviceConfiguration.id = _POST["deviceconf"];
                    AzureDeviceConfiguration.description = _POST["description"];
                    AzureDeviceConfiguration.workProfileDataSharingType = _POST["workProfileDataSharingType"];
                    AzureDeviceConfiguration.workProfileBlockNotificationsWhileDeviceLocked = _POST["workProfileBlockNotificationsWhileDeviceLocked"];
                    AzureDeviceConfiguration.workProfileDefaultAppPermissionPolicy = _POST["workProfileDefaultAppPermissionPolicy"];
                    AzureDeviceConfiguration.workProfileRequirePassword = _POST["workProfileRequirePassword"];
                    AzureDeviceConfiguration.workProfilePasswordMinimumLength = _POST["workProfilePasswordMinimumLength"];
                    AzureDeviceConfiguration.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout = _POST["workProfilePasswordMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.workProfilePasswordSignInFailureCountBeforeFactoryReset = _POST["workProfilePasswordSignInFailureCountBeforeFactoryReset"];
                    AzureDeviceConfiguration.workProfilePasswordExpirationDays = _POST["workProfilePasswordExpirationDays"];
                    AzureDeviceConfiguration.workProfilePasswordRequiredType = _POST["workProfilePasswordRequiredType"];
                    AzureDeviceConfiguration.workProfilePasswordPreviousPasswordBlockCount = _POST["workProfilePasswordPreviousPasswordBlockCount"];
                    AzureDeviceConfiguration.workProfilePasswordBlockFingerprintUnlock = _POST["workProfilePasswordBlockFingerprintUnlock"];
                    AzureDeviceConfiguration.workProfilePasswordBlockTrustAgents = _POST["workProfilePasswordBlockTrustAgents"];
                    AzureDeviceConfiguration.afwpasswordMinimumLength = _POST["afwpasswordMinimumLength"];
                    AzureDeviceConfiguration.afwpasswordMinutesOfInactivityBeforeScreenTimeout = _POST["afwpasswordMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.afwpasswordSignInFailureCountBeforeFactoryReset = _POST["afwpasswordSignInFailureCountBeforeFactoryReset"];
                    AzureDeviceConfiguration.afwpasswordExpirationDays = _POST["afwpasswordExpirationDays"];
                    AzureDeviceConfiguration.afwpasswordRequiredType = _POST["afwpasswordRequiredType"];
                    AzureDeviceConfiguration.afwpasswordPreviousPasswordBlockCount = _POST["afwpasswordPreviousPasswordBlockCount"];
                    AzureDeviceConfiguration.afwpasswordBlockFingerprintUnlock = _POST["afwpasswordBlockFingerprintUnlock"];
                    AzureDeviceConfiguration.afwpasswordBlockTrustAgents = _POST["afwpasswordBlockTrustAgents"];
                }
                if (_POST["platform"] == "macOS")
                {
                    AzureDeviceConfiguration.organization = _POST["organization"];
                    AzureDeviceConfiguration.platform = _POST["platform"];
                    AzureDeviceConfiguration.displayName = _POST["displayName"];
                    AzureDeviceConfiguration.id = _POST["deviceconf"];
                    AzureDeviceConfiguration.description = _POST["description"];
                    AzureDeviceConfiguration.macpasswordMinimumLength = _POST["macpasswordMinimumLength"];
                    AzureDeviceConfiguration.macpasswordBlockSimple = _POST["macpasswordBlockSimple"];
                    AzureDeviceConfiguration.macpasswordMinimumCharacterSetCount = _POST["macpasswordMinimumCharacterSetCount"];
                    AzureDeviceConfiguration.macpasswordMinutesOfInactivityBeforeLock = _POST["macpasswordMinutesOfInactivityBeforeLock"];
                    AzureDeviceConfiguration.macpasswordExpirationDays = _POST["macpasswordExpirationDays"];
                    AzureDeviceConfiguration.macpasswordRequiredType = _POST["macpasswordRequiredType"];
                    AzureDeviceConfiguration.macpasswordPreviousPasswordBlockCount = _POST["macpasswordPreviousPasswordBlockCount"];
                    AzureDeviceConfiguration.macpasswordMinutesOfInactivityBeforeScreenTimeout = _POST["macpasswordMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.macpasswordRequired = _POST["macpasswordRequired"];
                }
                if (_POST["platform"] == "IOS")
                {
                    AzureDeviceConfiguration.organization = _POST["organization"];
                    AzureDeviceConfiguration.platform = _POST["platform"];
                    AzureDeviceConfiguration.displayName = _POST["displayName"];
                    AzureDeviceConfiguration.id = _POST["deviceconf"];
                    AzureDeviceConfiguration.description = _POST["description"];
                    AzureDeviceConfiguration.accountBlockModification = _POST["accountBlockModification"];
                    AzureDeviceConfiguration.activationLockAllowWhenSupervised = _POST["activationLockAllowWhenSupervised"];
                    AzureDeviceConfiguration.airDropBlocked = _POST["airDropBlocked"];
                    AzureDeviceConfiguration.airDropForceUnmanagedDropTarget = _POST["airDropForceUnmanagedDropTarget"];
                    AzureDeviceConfiguration.airPlayForcePairingPasswordForOutgoingRequests = _POST["airPlayForcePairingPasswordForOutgoingRequests"];
                    AzureDeviceConfiguration.appleWatchBlockPairing = _POST["appleWatchBlockPairing"];
                    AzureDeviceConfiguration.appleWatchForceWristDetection = _POST["appleWatchForceWristDetection"];
                    AzureDeviceConfiguration.appleNewsBlocked = _POST["appleNewsBlocked"];
                    AzureDeviceConfiguration.appStoreBlockAutomaticDownloads = _POST["appStoreBlockAutomaticDownloads"];
                    AzureDeviceConfiguration.appStoreBlocked = _POST["appStoreBlocked"];
                    AzureDeviceConfiguration.appStoreBlockInAppPurchases = _POST["appStoreBlockInAppPurchases"];
                    AzureDeviceConfiguration.appStoreBlockUIAppInstallation = _POST["appStoreBlockUIAppInstallation"];
                    AzureDeviceConfiguration.appStoreRequirePassword = _POST["appStoreRequirePassword"];
                    AzureDeviceConfiguration.bluetoothBlockModification = _POST["bluetoothBlockModification"];
                    AzureDeviceConfiguration.ioscameraBlocked = _POST["ioscameraBlocked"];
                    AzureDeviceConfiguration.ioscellularBlockDataRoaming = _POST["ioscellularBlockDataRoaming"];
                    AzureDeviceConfiguration.cellularBlockGlobalBackgroundFetchWhileRoaming = _POST["cellularBlockGlobalBackgroundFetchWhileRoaming"];
                    AzureDeviceConfiguration.cellularBlockPerAppDataModification = _POST["cellularBlockPerAppDataModification"];
                    AzureDeviceConfiguration.cellularBlockPersonalHotspot = _POST["cellularBlockPersonalHotspot"];
                    AzureDeviceConfiguration.ioscellularBlockVoiceRoaming = _POST["ioscellularBlockVoiceRoaming"];
                    AzureDeviceConfiguration.certificatesBlockUntrustedTlsCertificates = _POST["certificatesBlockUntrustedTlsCertificates"];
                    AzureDeviceConfiguration.classroomAppBlockRemoteScreenObservation = _POST["classroomAppBlockRemoteScreenObservation"];
                    AzureDeviceConfiguration.classroomAppForceUnpromptedScreenObservation = _POST["classroomAppForceUnpromptedScreenObservation"];
                    AzureDeviceConfiguration.configurationProfileBlockChanges = _POST["configurationProfileBlockChanges"];
                    AzureDeviceConfiguration.definitionLookupBlocked = _POST["definitionLookupBlocked"];
                    AzureDeviceConfiguration.deviceBlockEnableRestrictions = _POST["deviceBlockEnableRestrictions"];
                    AzureDeviceConfiguration.deviceBlockEraseContentAndSettings = _POST["deviceBlockEraseContentAndSettings"];
                    AzureDeviceConfiguration.deviceBlockNameModification = _POST["deviceBlockNameModification"];
                    AzureDeviceConfiguration.diagnosticDataBlockSubmission = _POST["diagnosticDataBlockSubmission"];
                    AzureDeviceConfiguration.diagnosticDataBlockSubmissionModification = _POST["diagnosticDataBlockSubmissionModification"];
                    AzureDeviceConfiguration.documentsBlockManagedDocumentsInUnmanagedApps = _POST["documentsBlockManagedDocumentsInUnmanagedApps"];
                    AzureDeviceConfiguration.documentsBlockUnmanagedDocumentsInManagedApps = _POST["documentsBlockUnmanagedDocumentsInManagedApps"];
                    AzureDeviceConfiguration.enterpriseAppBlockTrust = _POST["enterpriseAppBlockTrust"];
                    AzureDeviceConfiguration.enterpriseAppBlockTrustModification = _POST["enterpriseAppBlockTrustModification"];
                    AzureDeviceConfiguration.faceTimeBlocked = _POST["faceTimeBlocked"];
                    AzureDeviceConfiguration.findMyFriendsBlocked = _POST["findMyFriendsBlocked"];
                    AzureDeviceConfiguration.gamingBlockGameCenterFriends = _POST["gamingBlockGameCenterFriends"];
                    AzureDeviceConfiguration.gamingBlockMultiplayer = _POST["gamingBlockMultiplayer"];
                    AzureDeviceConfiguration.gameCenterBlocked = _POST["gameCenterBlocked"];
                    AzureDeviceConfiguration.hostPairingBlocked = _POST["hostPairingBlocked"];
                    AzureDeviceConfiguration.iBooksStoreBlocked = _POST["iBooksStoreBlocked"];
                    AzureDeviceConfiguration.iBooksStoreBlockErotica = _POST["iBooksStoreBlockErotica"];
                    AzureDeviceConfiguration.iCloudBlockActivityContinuation = _POST["iCloudBlockActivityContinuation"];
                    AzureDeviceConfiguration.iCloudBlockBackup = _POST["iCloudBlockBackup"];
                    AzureDeviceConfiguration.iCloudBlockDocumentSync = _POST["iCloudBlockDocumentSync"];
                    AzureDeviceConfiguration.iCloudBlockManagedAppsSync = _POST["iCloudBlockManagedAppsSync"];
                    AzureDeviceConfiguration.iCloudBlockPhotoLibrary = _POST["iCloudBlockPhotoLibrary"];
                    AzureDeviceConfiguration.iCloudBlockPhotoStreamSync = _POST["iCloudBlockPhotoStreamSync"];
                    AzureDeviceConfiguration.iCloudBlockSharedPhotoStream = _POST["iCloudBlockSharedPhotoStream"];
                    AzureDeviceConfiguration.iCloudRequireEncryptedBackup = _POST["iCloudRequireEncryptedBackup"];
                    AzureDeviceConfiguration.iTunesBlockExplicitContent = _POST["iTunesBlockExplicitContent"];
                    AzureDeviceConfiguration.iTunesBlockMusicService = _POST["iTunesBlockMusicService"];
                    AzureDeviceConfiguration.iTunesBlockRadio = _POST["iTunesBlockRadio"];
                    AzureDeviceConfiguration.keyboardBlockAutoCorrect = _POST["keyboardBlockAutoCorrect"];
                    AzureDeviceConfiguration.keyboardBlockDictation = _POST["keyboardBlockDictation"];
                    AzureDeviceConfiguration.keyboardBlockPredictive = _POST["keyboardBlockPredictive"];
                    AzureDeviceConfiguration.keyboardBlockShortcuts = _POST["keyboardBlockShortcuts"];
                    AzureDeviceConfiguration.keyboardBlockSpellCheck = _POST["keyboardBlockSpellCheck"];
                    AzureDeviceConfiguration.lockScreenBlockControlCenter = _POST["lockScreenBlockControlCenter"];
                    AzureDeviceConfiguration.lockScreenBlockNotificationView = _POST["lockScreenBlockNotificationView"];
                    AzureDeviceConfiguration.lockScreenBlockPassbook = _POST["lockScreenBlockPassbook"];
                    AzureDeviceConfiguration.lockScreenBlockTodayView = _POST["lockScreenBlockTodayView"];
                    AzureDeviceConfiguration.mediaContentRatingApps = _POST["mediaContentRatingApps"];
                    AzureDeviceConfiguration.messagesBlocked = _POST["messagesBlocked"];
                    AzureDeviceConfiguration.notificationsBlockSettingsModification = _POST["notificationsBlockSettingsModification"];
                    AzureDeviceConfiguration.passcodeBlockFingerprintUnlock = _POST["passcodeBlockFingerprintUnlock"];
                    AzureDeviceConfiguration.passcodeBlockFingerprintModification = _POST["passcodeBlockFingerprintModification"];
                    AzureDeviceConfiguration.passcodeBlockModification = _POST["passcodeBlockModification"];
                    AzureDeviceConfiguration.passcodeBlockSimple = _POST["passcodeBlockSimple"];
                    AzureDeviceConfiguration.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceConfiguration.passcodeMinimumLength = _POST["passcodeMinimumLength"];
                    AzureDeviceConfiguration.passcodeMinutesOfInactivityBeforeLock = _POST["passcodeMinutesOfInactivityBeforeLock"];
                    AzureDeviceConfiguration.passcodeMinutesOfInactivityBeforeScreenTimeout = _POST["passcodeMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.passcodeMinimumCharacterSetCount = _POST["passcodeMinimumCharacterSetCount"];
                    AzureDeviceConfiguration.passcodePreviousPasscodeBlockCount = _POST["passcodePreviousPasscodeBlockCount"];
                    AzureDeviceConfiguration.passcodeSignInFailureCountBeforeWipe = _POST["passcodeSignInFailureCountBeforeWipe"];
                    AzureDeviceConfiguration.passcodeRequiredType = _POST["passcodeRequiredType"];
                    AzureDeviceConfiguration.passcodeRequired = _POST["passcodeRequired"];
                    AzureDeviceConfiguration.podcastsBlocked = _POST["podcastsBlocked"];
                    AzureDeviceConfiguration.safariBlockAutofill = _POST["safariBlockAutofill"];
                    AzureDeviceConfiguration.safariBlockJavaScript = _POST["safariBlockJavaScript"];
                    AzureDeviceConfiguration.safariBlockPopups = _POST["safariBlockPopups"];
                    AzureDeviceConfiguration.safariBlocked = _POST["safariBlocked"];
                    AzureDeviceConfiguration.safariCookieSettings = _POST["safariCookieSettings"];
                    AzureDeviceConfiguration.safariRequireFraudWarning = _POST["safariRequireFraudWarning"];
                    AzureDeviceConfiguration.iosscreenCaptureBlocked = _POST["iosscreenCaptureBlocked"];
                    AzureDeviceConfiguration.siriBlocked = _POST["siriBlocked"];
                    AzureDeviceConfiguration.siriBlockedWhenLocked = _POST["siriBlockedWhenLocked"];
                    AzureDeviceConfiguration.siriBlockUserGeneratedContent = _POST["siriBlockUserGeneratedContent"];
                    AzureDeviceConfiguration.siriRequireProfanityFilter = _POST["siriRequireProfanityFilter"];
                    AzureDeviceConfiguration.spotlightBlockInternetResults = _POST["spotlightBlockInternetResults"];
                    AzureDeviceConfiguration.iosvoiceDialingBlocked = _POST["iosvoiceDialingBlocked"];
                    AzureDeviceConfiguration.wallpaperBlockModification = _POST["wallpaperBlockModification"];
                    AzureDeviceConfiguration.wiFiConnectOnlyToConfiguredNetworks = _POST["wiFiConnectOnlyToConfiguredNetworks"];
                }
                if (_POST["platform"] == "Win10")
                {
                    AzureDeviceConfiguration.organization = _POST["organization"];
                    AzureDeviceConfiguration.platform = _POST["platform"];
                    AzureDeviceConfiguration.displayName = _POST["displayName"];
                    AzureDeviceConfiguration.id = _POST["deviceconf"];
                    AzureDeviceConfiguration.description = _POST["description"];
                    AzureDeviceConfiguration.winscreenCaptureBlocked = _POST["winscreenCaptureBlocked"];
                    AzureDeviceConfiguration.copyPasteBlocked = _POST["copyPasteBlocked"];
                    AzureDeviceConfiguration.deviceManagementBlockManualUnenroll = _POST["deviceManagementBlockManualUnenroll"];
                    AzureDeviceConfiguration.certificatesBlockManualRootCertificateInstallation = _POST["certificatesBlockManualRootCertificateInstallation"];
                    AzureDeviceConfiguration.wincameraBlocked = _POST["wincameraBlocked"];
                    AzureDeviceConfiguration.oneDriveDisableFileSync = _POST["oneDriveDisableFileSync"];
                    AzureDeviceConfiguration.winstorageBlockRemovableStorage = _POST["winstorageBlockRemovableStorage"];
                    AzureDeviceConfiguration.winlocationServicesBlocked = _POST["winlocationServicesBlocked"];
                    AzureDeviceConfiguration.internetSharingBlocked = _POST["internetSharingBlocked"];
                    AzureDeviceConfiguration.deviceManagementBlockFactoryResetOnMobile = _POST["deviceManagementBlockFactoryResetOnMobile"];
                    AzureDeviceConfiguration.usbBlocked = _POST["usbBlocked"];
                    AzureDeviceConfiguration.antiTheftModeBlocked = _POST["antiTheftModeBlocked"];
                    AzureDeviceConfiguration.cortanaBlocked = _POST["cortanaBlocked"];
                    AzureDeviceConfiguration.voiceRecordingBlocked = _POST["voiceRecordingBlocked"];
                    AzureDeviceConfiguration.settingsBlockEditDeviceName = _POST["settingsBlockEditDeviceName"];
                    AzureDeviceConfiguration.settingsBlockAddProvisioningPackage = _POST["settingsBlockAddProvisioningPackage"];
                    AzureDeviceConfiguration.settingsBlockRemoveProvisioningPackage = _POST["settingsBlockRemoveProvisioningPackage"];
                    AzureDeviceConfiguration.experienceBlockDeviceDiscovery = _POST["experienceBlockDeviceDiscovery"];
                    AzureDeviceConfiguration.experienceBlockTaskSwitcher = _POST["experienceBlockTaskSwitcher"];
                    AzureDeviceConfiguration.experienceBlockErrorDialogWhenNoSIM = _POST["experienceBlockErrorDialogWhenNoSIM"];
                    AzureDeviceConfiguration.winpasswordRequired = _POST["winpasswordRequired"];
                    AzureDeviceConfiguration.winpasswordRequiredType = _POST["winpasswordRequiredType"];
                    AzureDeviceConfiguration.winpasswordMinimumLength = _POST["winpasswordMinimumLength"];
                    AzureDeviceConfiguration.winpasswordMinutesOfInactivityBeforeScreenTimeout = _POST["winpasswordMinutesOfInactivityBeforeScreenTimeout"];
                    AzureDeviceConfiguration.winpasswordSignInFailureCountBeforeFactoryReset = _POST["winpasswordSignInFailureCountBeforeFactoryReset"];
                    AzureDeviceConfiguration.winpasswordExpirationDays = _POST["winpasswordExpirationDays"];
                    AzureDeviceConfiguration.winpasswordPreviousPasswordBlockCount = _POST["winpasswordPreviousPasswordBlockCount"];
                    AzureDeviceConfiguration.winpasswordRequireWhenResumeFromIdleState = _POST["winpasswordRequireWhenResumeFromIdleState"];
                    AzureDeviceConfiguration.winpasswordBlockSimple = _POST["winpasswordBlockSimple"];
                    AzureDeviceConfiguration.storageRequireMobileDeviceEncryption = _POST["storageRequireMobileDeviceEncryption"];
                    AzureDeviceConfiguration.personalizationDesktopImageUrl = _POST["personalizationDesktopImageUrl"];
                    AzureDeviceConfiguration.privacyBlockInputPersonalization = _POST["privacyBlockInputPersonalization"];
                    AzureDeviceConfiguration.privacyAutoAcceptPairingAndConsentPrompts = _POST["privacyAutoAcceptPairingAndConsentPrompts"];
                    AzureDeviceConfiguration.lockScreenBlockActionCenterNotifications = _POST["lockScreenBlockActionCenterNotifications"];
                    AzureDeviceConfiguration.personalizationLockScreenImageUrl = _POST["personalizationLockScreenImageUrl"];
                    AzureDeviceConfiguration.lockScreenAllowTimeoutConfiguration = _POST["lockScreenAllowTimeoutConfiguration"];
                    AzureDeviceConfiguration.lockScreenBlockCortana = _POST["lockScreenBlockCortana"];
                    AzureDeviceConfiguration.lockScreenBlockToastNotifications = _POST["lockScreenBlockToastNotifications"];
                    AzureDeviceConfiguration.lockScreenTimeoutInSeconds = _POST["lockScreenTimeoutInSeconds"];
                    AzureDeviceConfiguration.windowsStoreBlocked = _POST["windowsStoreBlocked"];
                    AzureDeviceConfiguration.windowsStoreBlockAutoUpdate = _POST["windowsStoreBlockAutoUpdate"];
                    AzureDeviceConfiguration.appsAllowTrustedAppsSideloading = _POST["appsAllowTrustedAppsSideloading"];
                    AzureDeviceConfiguration.developerUnlockSetting = _POST["developerUnlockSetting"];
                    AzureDeviceConfiguration.sharedUserAppDataAllowed = _POST["sharedUserAppDataAllowed"];
                    AzureDeviceConfiguration.windowsStoreEnablePrivateStoreOnly = _POST["windowsStoreEnablePrivateStoreOnly"];
                    AzureDeviceConfiguration.appsBlockWindowsStoreOriginatedApps = _POST["appsBlockWindowsStoreOriginatedApps"];
                    AzureDeviceConfiguration.storageRestrictAppDataToSystemVolume = _POST["storageRestrictAppDataToSystemVolume"];
                    AzureDeviceConfiguration.storageRestrictAppInstallToSystemVolume = _POST["storageRestrictAppInstallToSystemVolume"];
                    AzureDeviceConfiguration.gameDvrBlocked = _POST["gameDvrBlocked"];
                    AzureDeviceConfiguration.smartScreenEnableAppInstallControl = _POST["smartScreenEnableAppInstallControl"];
                    AzureDeviceConfiguration.edgeBlocked = _POST["edgeBlocked"];
                    AzureDeviceConfiguration.edgeBlockAddressBarDropdown = _POST["edgeBlockAddressBarDropdown"];
                    AzureDeviceConfiguration.edgeSyncFavoritesWithInternetExplorer = _POST["edgeSyncFavoritesWithInternetExplorer"];
                    AzureDeviceConfiguration.edgeClearBrowsingDataOnExit = _POST["edgeClearBrowsingDataOnExit"];
                    AzureDeviceConfiguration.edgeBlockSendingDoNotTrackHeader = _POST["edgeBlockSendingDoNotTrackHeader"];
                    AzureDeviceConfiguration.edgeCookiePolicy = _POST["edgeCookiePolicy"];
                    AzureDeviceConfiguration.edgeBlockJavaScript = _POST["edgeBlockJavaScript"];
                    AzureDeviceConfiguration.edgeBlockPopups = _POST["edgeBlockPopups"];
                    AzureDeviceConfiguration.edgeBlockSearchSuggestions = _POST["edgeBlockSearchSuggestions"];
                    AzureDeviceConfiguration.edgeBlockSendingIntranetTrafficToInternetExplorer = _POST["edgeBlockSendingIntranetTrafficToInternetExplorer"];
                    AzureDeviceConfiguration.edgeBlockAutofill = _POST["edgeBlockAutofill"];
                    AzureDeviceConfiguration.edgeBlockPasswordManager = _POST["edgeBlockPasswordManager"];
                    AzureDeviceConfiguration.edgeEnterpriseModeSiteListLocation = _POST["edgeEnterpriseModeSiteListLocation"];
                    AzureDeviceConfiguration.edgeBlockDeveloperTools = _POST["edgeBlockDeveloperTools"];
                    AzureDeviceConfiguration.edgeBlockExtensions = _POST["edgeBlockExtensions"];
                    AzureDeviceConfiguration.edgeBlockInPrivateBrowsing = _POST["edgeBlockInPrivateBrowsing"];
                    AzureDeviceConfiguration.edgeDisableFirstRunPage = _POST["edgeDisableFirstRunPage"];
                    AzureDeviceConfiguration.edgeFirstRunUrl = _POST["edgeFirstRunUrl"];
                    AzureDeviceConfiguration.edgeAllowStartPagesModification = _POST["edgeAllowStartPagesModification"];
                    AzureDeviceConfiguration.edgeBlockAccessToAboutFlags = _POST["edgeBlockAccessToAboutFlags"];
                    AzureDeviceConfiguration.webRtcBlockLocalhostIpAddress = _POST["webRtcBlockLocalhostIpAddress"];
                    AzureDeviceConfiguration.edgeSearchEngine = _POST["edgeSearchEngine"];
                    AzureDeviceConfiguration.edgeCustomURL = _POST["edgeCustomURL"];
                    AzureDeviceConfiguration.edgeBlockCompatibilityList = _POST["edgeBlockCompatibilityList"];
                    AzureDeviceConfiguration.edgeBlockLiveTileDataCollection = _POST["edgeBlockLiveTileDataCollection"];
                    AzureDeviceConfiguration.edgeRequireSmartScreen = _POST["edgeRequireSmartScreen"];
                    AzureDeviceConfiguration.smartScreenBlockPromptOverride = _POST["smartScreenBlockPromptOverride"];
                    AzureDeviceConfiguration.smartScreenBlockPromptOverrideForFiles = _POST["smartScreenBlockPromptOverrideForFiles"];
                    AzureDeviceConfiguration.safeSearchFilter = _POST["safeSearchFilter"];
                    AzureDeviceConfiguration.microsoftAccountBlocked = _POST["microsoftAccountBlocked"];
                    AzureDeviceConfiguration.accountsBlockAddingNonMicrosoftAccountEmail = _POST["accountsBlockAddingNonMicrosoftAccountEmail"];
                    AzureDeviceConfiguration.microsoftAccountBlockSettingsSync = _POST["microsoftAccountBlockSettingsSync"];
                    AzureDeviceConfiguration.cellularData = _POST["cellularData"];
                    AzureDeviceConfiguration.cellularBlockDataWhenRoaming = _POST["cellularBlockDataWhenRoaming"];
                    AzureDeviceConfiguration.cellularBlockVpn = _POST["cellularBlockVpn"];
                    AzureDeviceConfiguration.cellularBlockVpnWhenRoaming = _POST["cellularBlockVpnWhenRoaming"];
                    AzureDeviceConfiguration.winbluetoothBlocked = _POST["winbluetoothBlocked"];
                    AzureDeviceConfiguration.bluetoothBlockDiscoverableMode = _POST["bluetoothBlockDiscoverableMode"];
                    AzureDeviceConfiguration.bluetoothBlockPrePairing = _POST["bluetoothBlockPrePairing"];
                    AzureDeviceConfiguration.bluetoothBlockAdvertising = _POST["bluetoothBlockAdvertising"];
                    AzureDeviceConfiguration.connectedDevicesServiceBlocked = _POST["connectedDevicesServiceBlocked"];
                    AzureDeviceConfiguration.winnfcBlocked = _POST["winnfcBlocked"];
                    AzureDeviceConfiguration.winwiFiBlocked = _POST["winwiFiBlocked"];
                    AzureDeviceConfiguration.wiFiBlockAutomaticConnectHotspots = _POST["wiFiBlockAutomaticConnectHotspots"];
                    AzureDeviceConfiguration.wiFiBlockManualConfiguration = _POST["wiFiBlockManualConfiguration"];
                    AzureDeviceConfiguration.wiFiScanInterval = _POST["wiFiScanInterval"];
                    AzureDeviceConfiguration.settingsBlockSettingsApp = _POST["settingsBlockSettingsApp"];
                    AzureDeviceConfiguration.settingsBlockSystemPage = _POST["settingsBlockSystemPage"];
                    AzureDeviceConfiguration.settingsBlockChangePowerSleep = _POST["settingsBlockChangePowerSleep"];
                    AzureDeviceConfiguration.settingsBlockDevicesPage = _POST["settingsBlockDevicesPage"];
                    AzureDeviceConfiguration.settingsBlockNetworkInternetPage = _POST["settingsBlockNetworkInternetPage"];
                    AzureDeviceConfiguration.settingsBlockPersonalizationPage = _POST["settingsBlockPersonalizationPage"];
                    AzureDeviceConfiguration.settingsBlockAppsPage = _POST["settingsBlockAppsPage"];
                    AzureDeviceConfiguration.settingsBlockAccountsPage = _POST["settingsBlockAccountsPage"];
                    AzureDeviceConfiguration.settingsBlockTimeLanguagePage = _POST["settingsBlockTimeLanguagePage"];
                    AzureDeviceConfiguration.settingsBlockChangeSystemTime = _POST["settingsBlockChangeSystemTime"];
                    AzureDeviceConfiguration.settingsBlockChangeRegion = _POST["settingsBlockChangeRegion"];
                    AzureDeviceConfiguration.settingsBlockChangeLanguage = _POST["settingsBlockChangeLanguage"];
                    AzureDeviceConfiguration.settingsBlockGamingPage = _POST["settingsBlockGamingPage"];
                    AzureDeviceConfiguration.settingsBlockEaseOfAccessPage = _POST["settingsBlockEaseOfAccessPage"];
                    AzureDeviceConfiguration.settingsBlockPrivacyPage = _POST["settingsBlockPrivacyPage"];
                    AzureDeviceConfiguration.settingsBlockUpdateSecurityPage = _POST["settingsBlockUpdateSecurityPage"];
                    AzureDeviceConfiguration.defenderRequireRealTimeMonitoring = _POST["defenderRequireRealTimeMonitoring"];
                    AzureDeviceConfiguration.defenderRequireBehaviorMonitoring = _POST["defenderRequireBehaviorMonitoring"];
                    AzureDeviceConfiguration.defenderRequireNetworkInspectionSystem = _POST["defenderRequireNetworkInspectionSystem"];
                    AzureDeviceConfiguration.defenderScanDownloads = _POST["defenderScanDownloads"];
                    AzureDeviceConfiguration.defenderScanScriptsLoadedInInternetExplorer = _POST["defenderScanScriptsLoadedInInternetExplorer"];
                    AzureDeviceConfiguration.defenderBlockEndUserAccess = _POST["defenderBlockEndUserAccess"];
                    AzureDeviceConfiguration.defenderSignatureUpdateIntervalInHours = _POST["defenderSignatureUpdateIntervalInHours"];
                    AzureDeviceConfiguration.defenderMonitorFileActivity = _POST["defenderMonitorFileActivity"];
                    AzureDeviceConfiguration.defenderDaysBeforeDeletingQuarantinedMalware = _POST["defenderDaysBeforeDeletingQuarantinedMalware"];
                    AzureDeviceConfiguration.defenderScanMaxCpu = _POST["defenderScanMaxCpu"];
                    AzureDeviceConfiguration.defenderScanArchiveFiles = _POST["defenderScanArchiveFiles"];
                    AzureDeviceConfiguration.defenderScanIncomingMail = _POST["defenderScanIncomingMail"];
                    AzureDeviceConfiguration.defenderScanRemovableDrivesDuringFullScan = _POST["defenderScanRemovableDrivesDuringFullScan"];
                    AzureDeviceConfiguration.defenderScanMappedNetworkDrivesDuringFullScan = _POST["defenderScanMappedNetworkDrivesDuringFullScan"];
                    AzureDeviceConfiguration.defenderScanNetworkFiles = _POST["defenderScanNetworkFiles"];
                    AzureDeviceConfiguration.defenderRequireCloudProtection = _POST["defenderRequireCloudProtection"];
                    AzureDeviceConfiguration.defenderPromptForSampleSubmission = _POST["defenderPromptForSampleSubmission"];
                    AzureDeviceConfiguration.defenderScheduledQuickScanTime = _POST["defenderScheduledQuickScanTime"];
                    AzureDeviceConfiguration.defenderScanType = _POST["defenderScanType"];
                    AzureDeviceConfiguration.defenderSystemScanSchedule = _POST["defenderSystemScanSchedule"];
                    AzureDeviceConfiguration.defenderScheduledScanTime = _POST["defenderScheduledScanTime"];
                    AzureDeviceConfiguration.defenderPotentiallyUnwantedAppAction = _POST["defenderPotentiallyUnwantedAppAction"];
                    AzureDeviceConfiguration.defenderDetectedMalwareActions = _POST["defenderDetectedMalwareActions"];
                    AzureDeviceConfiguration.defenderlowseverity = _POST["defenderlowseverity"];
                    AzureDeviceConfiguration.defendermoderateseverity = _POST["defendermoderateseverity"];
                    AzureDeviceConfiguration.defenderhighseverity = _POST["defenderhighseverity"];
                    AzureDeviceConfiguration.defendersevereseverity = _POST["defendersevereseverity"];
                    AzureDeviceConfiguration.startBlockUnpinningAppsFromTaskbar = _POST["startBlockUnpinningAppsFromTaskbar"];
                    AzureDeviceConfiguration.logonBlockFastUserSwitching = _POST["logonBlockFastUserSwitching"];
                    AzureDeviceConfiguration.startMenuHideFrequentlyUsedApps = _POST["startMenuHideFrequentlyUsedApps"];
                    AzureDeviceConfiguration.startMenuHideRecentlyAddedApps = _POST["startMenuHideRecentlyAddedApps"];
                    AzureDeviceConfiguration.startMenuMode = _POST["startMenuMode"];
                    AzureDeviceConfiguration.startMenuHideRecentJumpLists = _POST["startMenuHideRecentJumpLists"];
                    AzureDeviceConfiguration.startMenuAppListVisibility = _POST["startMenuAppListVisibility"];
                    AzureDeviceConfiguration.startMenuHidePowerButton = _POST["startMenuHidePowerButton"];
                    AzureDeviceConfiguration.startMenuHideUserTile = _POST["startMenuHideUserTile"];
                    AzureDeviceConfiguration.startMenuHideLock = _POST["startMenuHideLock"];
                    AzureDeviceConfiguration.startMenuHideSignOut = _POST["startMenuHideSignOut"];
                    AzureDeviceConfiguration.startMenuHideShutDown = _POST["startMenuHideShutDown"];
                    AzureDeviceConfiguration.startMenuHideSleep = _POST["startMenuHideSleep"];
                    AzureDeviceConfiguration.startMenuHideHibernate = _POST["startMenuHideHibernate"];
                    AzureDeviceConfiguration.startMenuHideSwitchAccount = _POST["startMenuHideSwitchAccount"];
                    AzureDeviceConfiguration.startMenuHideRestartOptions = _POST["startMenuHideRestartOptions"];
                    AzureDeviceConfiguration.startMenuPinnedFolderDocuments = _POST["startMenuPinnedFolderDocuments"];
                    AzureDeviceConfiguration.startMenuPinnedFolderDownloads = _POST["startMenuPinnedFolderDownloads"];
                    AzureDeviceConfiguration.startMenuPinnedFolderFileExplorer = _POST["startMenuPinnedFolderFileExplorer"];
                    AzureDeviceConfiguration.startMenuPinnedFolderHomeGroup = _POST["startMenuPinnedFolderHomeGroup"];
                    AzureDeviceConfiguration.startMenuPinnedFolderMusic = _POST["startMenuPinnedFolderMusic"];
                    AzureDeviceConfiguration.startMenuPinnedFolderNetwork = _POST["startMenuPinnedFolderNetwork"];
                    AzureDeviceConfiguration.startMenuPinnedFolderPersonalFolder = _POST["startMenuPinnedFolderPersonalFolder"];
                    AzureDeviceConfiguration.startMenuPinnedFolderPictures = _POST["startMenuPinnedFolderPictures"];
                    AzureDeviceConfiguration.startMenuPinnedFolderSettings = _POST["startMenuPinnedFolderSettings"];
                    AzureDeviceConfiguration.startMenuPinnedFolderVideos = _POST["startMenuPinnedFolderVideos"];
                }

                model.AzureDeviceConfiguration = AzureDeviceConfiguration;

                CommonCAS.Log(string.Format("has run Azure/UpdateAzureIntuneDeviceConfiguration() to update {0}", AzureDeviceConfiguration.displayName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateAzureIntuneDeviceConfiguration(AzureDeviceConfiguration);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Device Configuration '{0}' updated with new settings. New Settings will take effect on next device sync.", AzureDeviceConfiguration.displayName));

                CommonCAS.Stats("Azure/UpdateAzureIntuneDeviceConfiguration");

                return View("UpdateAzureIntuneDeviceConfiguration", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateVM()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateVM(FormCollection _POST)
        {
            try
            {
                CustomCreateVM CreateVM = new CustomCreateVM()
                {
                    Organization = _POST["organization"],
                    Name = _POST["name"],
                    RessourceGroupName = _POST["ressourcegroup"].ToUpper(),
                    Location = _POST["location"],
                    StorageAccount = _POST["storageaccount"],
                    VirtualNetwork = _POST["virtualnetwork"],
                    NetworkInterface = _POST["networkinterface"],
                    Subnet = _POST["subnet"],
                    PublicIP = _POST["publicip"],
                    AvailabilitySet = _POST["availabilityset"],
                    VmSize = _POST["vmsize"],
                    

                };

                model.CreateVM = CreateVM;

                CommonCAS.Log(string.Format("has run Azure/CreateAzureVM() to create {0}", CreateVM.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateVM(CreateVM);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("AzureVM '{0}' created.", CreateVM.Name));

                CommonCAS.Stats("Azure/CreateVM");

                return View("CreateVM", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create public ip view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateAzurePIP()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateAzurePIP(FormCollection _POST)
        {
            try
            {
                CustomCreateAzurePIP CreateAzurePIP = new CustomCreateAzurePIP()
                {
                    Organization = _POST["organization"],
                    Name = _POST["name"],
                    RessourceGroupName = _POST["ressourcegroups"].ToUpper(),
                    AllocationMethod = _POST["allocationmethod"].ToUpper(),
                    Version = _POST["version"],
                    Location = _POST["locations"].ToLower(),
                };

                model.CreateAzurePIP = CreateAzurePIP;

                CommonCAS.Log(string.Format("has run Azure/CreateAzurePIP() to create {0}", CreateAzurePIP.Name));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateAzurePIP(CreateAzurePIP);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Public ip '{0}' created.", CreateAzurePIP.Name));

                CommonCAS.Stats("Azure/CreateAzurePIP");

                return View("CreateAzurePIP", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create public ip view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateDefaultIntuneConfiguration()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreateDefaultIntuneConfiguration(FormCollection _POST)
        {
            try
            {
                CustomCreateDefaultIntuneConfiguration CreateDefaultIntuneConfiguration = new CustomCreateDefaultIntuneConfiguration()
                {
                    Organization = _POST["organization"],
                };

                model.CreateDefaultIntuneConfiguration = CreateDefaultIntuneConfiguration;

                CommonCAS.Log(string.Format("has run Azure/CreateDefaultIntuneConfiguration() to create default intune configuration {0}", CreateDefaultIntuneConfiguration.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreateDefaultIntuneConfiguration(CreateDefaultIntuneConfiguration);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("Default Intune Conf for '{0}' created.", CreateDefaultIntuneConfiguration.Organization));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("Default Intune Conf for '{0}' created.", CreateDefaultIntuneConfiguration.Organization));
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }
                }

                CommonCAS.Stats("Azure/CreateDefaultIntuneConfiguration");

                return View("CreateDefaultIntuneConfiguration", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display Intune Overview
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult IntuneOverview()
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
        public ActionResult IntunePartialOverview()
        {
            return View("_IntuneOverview", "Azure");
        }

        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        public virtual ActionResult GetIntuneOverview(string organization)
        {
            //CustomGetIntuneEnrollmentOverview IntuneEnrollmentOverview = new CustomGetIntuneEnrollmentOverview();
            ///List<CustomGetmodel.IntuneEnrollmentOverviewJSON> model.IntuneEnrollmentOverviewJSON = new List<CustomGetmodel.IntuneEnrollmentOverviewJSON>();

            using (MyPowerShell ps = new MyPowerShell())
            {
                ps.GetIntuneOverview(organization);
                var result = ps.Invoke().Single();

                model.IntuneOverview.enrolledDeviceCount = int.Parse(result.Members["enrolledDeviceCount"].Value.ToString());
                model.IntuneOverview.mdmEnrolledCount = int.Parse(result.Members["mdmEnrolledCount"].Value.ToString());
                model.IntuneOverview.dualEnrolledDeviceCount = int.Parse(result.Members["dualEnrolledDeviceCount"].Value.ToString());

                var deviceOperatingSystemSummary = (PSObject)result.Properties["deviceOperatingSystemSummary"].Value;
                var deviceExchangeAccessStateSummary = (PSObject)result.Properties["deviceExchangeAccessStateSummary"].Value;
                var deviceCompliancePolicyDeviceStateSummary = (PSObject)result.Properties["deviceCompliancePolicyDeviceStateSummary"].Value;

                model.IntuneOverview.androidCount = int.Parse(deviceOperatingSystemSummary.Members["androidCount"].Value.ToString());
                model.IntuneOverview.iosCount = int.Parse(deviceOperatingSystemSummary.Members["iosCount"].Value.ToString());
                model.IntuneOverview.macOSCount = int.Parse(deviceOperatingSystemSummary.Members["macOSCount"].Value.ToString());
                model.IntuneOverview.windowsMobileCount = int.Parse(deviceOperatingSystemSummary.Members["windowsMobileCount"].Value.ToString());
                model.IntuneOverview.windowsCount = int.Parse(deviceOperatingSystemSummary.Members["windowsCount"].Value.ToString());
                model.IntuneOverview.unknownCount = int.Parse(deviceOperatingSystemSummary.Members["unknownCount"].Value.ToString());

                model.IntuneOverview.exchallowedDeviceCount = int.Parse(deviceExchangeAccessStateSummary.Members["allowedDeviceCount"].Value.ToString());
                model.IntuneOverview.exchblockedDeviceCount = int.Parse(deviceExchangeAccessStateSummary.Members["blockedDeviceCount"].Value.ToString());
                model.IntuneOverview.exchquarantinedDeviceCount = int.Parse(deviceExchangeAccessStateSummary.Members["quarantinedDeviceCount"].Value.ToString());
                model.IntuneOverview.exchunknownDeviceCount = int.Parse(deviceExchangeAccessStateSummary.Members["unknownDeviceCount"].Value.ToString());
                model.IntuneOverview.exchunavailableDeviceCount = int.Parse(deviceExchangeAccessStateSummary.Members["unavailableDeviceCount"].Value.ToString());

                model.IntuneOverview.inGracePeriodCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["inGracePeriodCount"].Value.ToString());
                model.IntuneOverview.unknownDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["unknownDeviceCount"].Value.ToString());
                model.IntuneOverview.notApplicableDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["notApplicableDeviceCount"].Value.ToString());
                model.IntuneOverview.compliantDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["compliantDeviceCount"].Value.ToString());
                model.IntuneOverview.remediatedDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["remediatedDeviceCount"].Value.ToString());
                model.IntuneOverview.nonCompliantDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["nonCompliantDeviceCount"].Value.ToString());
                model.IntuneOverview.errorDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["errorDeviceCount"].Value.ToString());
                model.IntuneOverview.conflictDeviceCount = int.Parse(deviceCompliancePolicyDeviceStateSummary.Members["conflictDeviceCount"].Value.ToString());

            }
            //return PartialView("_IntuneEnrollOverview", model.IntuneEnrollmentOverview);
            return PartialView("_IntuneOverview", model);

        }

        public string GetAzureIntuneComplianceSetting(string organization, string id)
        {
            try
            {
                List<CustomAzureDeviceComplianceSetting> AzureDeviceComplianceSetting = new List<CustomAzureDeviceComplianceSetting>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.GetAzureIntuneComplianceSetting(organization, id);
                    IEnumerable<PSObject> result = ps.Invoke();

                    foreach (PSObject compliancesetting in result)
                    {
                        Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(compliancesetting);

                        if (properties["platform"].ToString() == "Android")
                        {
                            AzureDeviceComplianceSetting.Add(new CustomAzureDeviceComplianceSetting()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                securityBlockJailbrokenDevices = properties["securityBlockJailbrokenDevices"].ToString(),
                                deviceThreatProtectionRequiredSecurityLevel = properties["deviceThreatProtectionRequiredSecurityLevel"].ToString(),
                                osMinimumVersion = properties["osMinimumVersion"].ToString(),
                                osMaximumVersion = properties["osMaximumVersion"].ToString(),
                                passwordRequired = properties["passwordRequired"].ToString(),
                                passwordMinimumLength = properties["passwordMinimumLength"].ToString(),
                                passwordRequiredType = properties["passwordRequiredType"].ToString(),
                                passwordMinutesOfInactivityBeforeLock = properties["passwordMinutesOfInactivityBeforeLock"].ToString(),
                                passwordExpirationDays = properties["passwordExpirationDays"].ToString(),
                                passwordPreviousPasswordBlockCount = properties["passwordPreviousPasswordBlockCount"].ToString(),
                                storageRequireEncryption = properties["storageRequireEncryption"].ToString(),
                                securityPreventInstallAppsFromUnknownSources = properties["securityPreventInstallAppsFromUnknownSources"].ToString(),
                                securityDisableUsbDebugging = properties["securityDisableUsbDebugging"].ToString(),
                                minAndroidSecurityPatchLevel = properties["minAndroidSecurityPatchLevel"].ToString()
                            });
                        }
                        if (properties["platform"].ToString() == "AFW")
                        {
                            AzureDeviceComplianceSetting.Add(new CustomAzureDeviceComplianceSetting()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                afwsecurityBlockJailbrokenDevices = properties["securityBlockJailbrokenDevices"].ToString(),
                                afwdeviceThreatProtectionRequiredSecurityLevel = properties["deviceThreatProtectionRequiredSecurityLevel"].ToString(),
                                afwosMinimumVersion = properties["osMinimumVersion"].ToString(),
                                afwosMaximumVersion = properties["osMaximumVersion"].ToString(),
                                afwpasswordRequired = properties["passwordRequired"].ToString(),
                                afwpasswordMinimumLength = properties["passwordMinimumLength"].ToString(),
                                afwpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                afwpasswordMinutesOfInactivityBeforeLock = properties["passwordMinutesOfInactivityBeforeLock"].ToString(),
                                afwpasswordExpirationDays = properties["passwordExpirationDays"].ToString(),
                                afwpasswordPreviousPasswordBlockCount = properties["passwordPreviousPasswordBlockCount"].ToString(),
                                afwstorageRequireEncryption = properties["storageRequireEncryption"].ToString(),
                                afwsecurityPreventInstallAppsFromUnknownSources = properties["securityPreventInstallAppsFromUnknownSources"].ToString(),
                                afwsecurityDisableUsbDebugging = properties["securityDisableUsbDebugging"].ToString(),
                                afwminAndroidSecurityPatchLevel = properties["minAndroidSecurityPatchLevel"].ToString()
                            });
                        }
                        if (properties["platform"].ToString() == "Win10")
                        {
                            AzureDeviceComplianceSetting.Add(new CustomAzureDeviceComplianceSetting()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                bitLockerEnabled = properties["bitLockerEnabled"].ToString(),
                                secureBootEnabled = properties["secureBootEnabled"].ToString(),
                                codeIntegrityEnabled = properties["codeIntegrityEnabled"].ToString(),
                                winosMinimumVersion = properties["osMinimumVersion"].ToString(),
                                winosMaximumVersion = properties["osMaximumVersion"].ToString(),
                                mobileOsMinimumVersion = properties["mobileOsMinimumVersion"].ToString(),
                                mobileOsMaximumVersion = properties["mobileOsMaximumVersion"].ToString(),
                                winpasswordRequired = properties["passwordRequired"].ToString(),
                                passwordBlockSimple = properties["passwordBlockSimple"].ToString(),
                                winpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                winpasswordMinimumLength = properties["passwordMinimumLength"].ToString(),
                                winpasswordMinutesOfInactivityBeforeLock = properties["passwordMinutesOfInactivityBeforeLock"].ToString(),
                                winpasswordExpirationDays = properties["passwordExpirationDays"].ToString(),
                                winpasswordPreviousPasswordBlockCount = properties["passwordPreviousPasswordBlockCount"].ToString(),
                                winpasswordRequiredToUnlockFromIdle = properties["passwordRequiredToUnlockFromIdle"].ToString(),
                                winstorageRequireEncryption = properties["storageRequireEncryption"].ToString()

                            });

                        }

                        if (properties["platform"].ToString() == "IOS")
                        {
                            AzureDeviceComplianceSetting.Add(new CustomAzureDeviceComplianceSetting()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                managedEmailProfileRequired = properties["managedEmailProfileRequired"].ToString(),
                                iossecurityBlockJailbrokenDevices = properties["securityBlockJailbrokenDevices"].ToString(),
                                iosdeviceThreatProtectionRequiredSecurityLevel = properties["deviceThreatProtectionRequiredSecurityLevel"].ToString(),
                                iososMinimumVersion = properties["osMinimumVersion"].ToString(),
                                iososMaximumVersion = properties["osMaximumVersion"].ToString(),
                                passcodeRequired = properties["passcodeRequired"].ToString(),
                                passcodeBlockSimple = properties["passcodeBlockSimple"].ToString(),
                                passcodeMinimumLength = properties["passcodeMinimumLength"].ToString(),
                                passcodeRequiredType = properties["passcodeRequiredType"].ToString(),
                                passcodeMinimumCharacterSetCount = properties["passcodeMinimumCharacterSetCount"].ToString(),
                                passcodeMinutesOfInactivityBeforeLock = properties["passcodeMinutesOfInactivityBeforeLock"].ToString(),
                                passcodeExpirationDays = properties["passcodeExpirationDays"].ToString(),
                                passcodePreviousPasscodeBlockCount = properties["passcodePreviousPasscodeBlockCount"].ToString()
                            });
                        }
                        
                        if (properties["platform"].ToString() == "macOS")
                        {
                            AzureDeviceComplianceSetting.Add(new CustomAzureDeviceComplianceSetting()
                            {
                                platform = properties["platform"].ToString(),
                                displayName = properties["displayName"].ToString(),
                                id = properties["id"].ToString(),
                                description = properties["description"].ToString(),
                                systemIntegrityProtectionEnabled = properties["systemIntegrityProtectionEnabled"].ToString(),
                                macosMinimumVersion = properties["osMinimumVersion"].ToString(),
                                macosMaximumVersion = properties["osMaximumVersion"].ToString(),
                                macpasswordRequired = properties["passwordRequired"].ToString(),
                                macpasswordBlockSimple = properties["passwordBlockSimple"].ToString(),
                                macpasswordMinimumLength = properties["passwordMinimumLength"].ToString(),
                                macpasswordRequiredType = properties["passwordRequiredType"].ToString(),
                                macpasswordMinimumCharacterSetCount = properties["passwordMinimumCharacterSetCount"].ToString(),
                                macpasswordMinutesOfInactivityBeforeLock = properties["passwordMinutesOfInactivityBeforeLock"].ToString(),
                                macpasswordExpirationDays = properties["passwordExpirationDays"].ToString(),
                                macpasswordPreviousPasswordBlockCount = properties["passwordPreviousPasswordBlockCount"].ToString(),
                                macstorageRequireEncryption = properties["storageRequireEncryption"].ToString()
                            });
                        }
                    }
                }

                return new JavaScriptSerializer().Serialize(AzureDeviceComplianceSetting);

            }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }

        }


        // Display compliance update view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult UpdateAzureIntuneComplianceSettings()
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
        // update compliance
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult UpdateAzureIntuneComplianceSettings(FormCollection _POST)
        {
            try
            {
                CustomAzureDeviceComplianceSetting AzureDeviceComplianceSetting = new CustomAzureDeviceComplianceSetting();

                if (_POST["platform"] == "Android")
                {
                    AzureDeviceComplianceSetting.organization = _POST["organization"];
                    AzureDeviceComplianceSetting.platform = _POST["platform"];
                    AzureDeviceComplianceSetting.displayName = _POST["displayName"];
                    AzureDeviceComplianceSetting.id = _POST["deviceconf"];
                    AzureDeviceComplianceSetting.description = _POST["description"];
                    AzureDeviceComplianceSetting.securityBlockJailbrokenDevices = _POST["securityBlockJailbrokenDevices"];
                    AzureDeviceComplianceSetting.deviceThreatProtectionRequiredSecurityLevel = _POST["deviceThreatProtectionRequiredSecurityLevel"];
                    AzureDeviceComplianceSetting.osMinimumVersion = _POST["osMinimumVersion"];
                    AzureDeviceComplianceSetting.osMaximumVersion = _POST["osMaximumVersion"];
                    AzureDeviceComplianceSetting.passwordRequired = _POST["passwordRequired"];
                    AzureDeviceComplianceSetting.passwordMinimumLength = _POST["passwordMinimumLength"];
                    AzureDeviceComplianceSetting.passwordRequiredType = _POST["passwordRequiredType"];
                    AzureDeviceComplianceSetting.passwordMinutesOfInactivityBeforeLock = _POST["passwordMinutesOfInactivityBeforeLock"];
                    AzureDeviceComplianceSetting.passwordExpirationDays = _POST["passwordExpirationDays"];
                    AzureDeviceComplianceSetting.passwordPreviousPasswordBlockCount = _POST["passwordPreviousPasswordBlockCount"];
                    AzureDeviceComplianceSetting.storageRequireEncryption = _POST["storageRequireEncryption"];
                    AzureDeviceComplianceSetting.securityPreventInstallAppsFromUnknownSources = _POST["securityPreventInstallAppsFromUnknownSources"];
                    AzureDeviceComplianceSetting.securityDisableUsbDebugging = _POST["securityDisableUsbDebugging"];
                    AzureDeviceComplianceSetting.minAndroidSecurityPatchLevel = _POST["minAndroidSecurityPatchLevel"];

                }
                if (_POST["platform"] == "AFW")
                {
                    AzureDeviceComplianceSetting.organization = _POST["organization"];
                    AzureDeviceComplianceSetting.platform = _POST["platform"];
                    AzureDeviceComplianceSetting.displayName = _POST["displayName"];
                    AzureDeviceComplianceSetting.id = _POST["deviceconf"];
                    AzureDeviceComplianceSetting.description = _POST["description"];
                    AzureDeviceComplianceSetting.afwsecurityBlockJailbrokenDevices = _POST["afwsecurityBlockJailbrokenDevices"];
                    AzureDeviceComplianceSetting.afwdeviceThreatProtectionRequiredSecurityLevel = _POST["afwdeviceThreatProtectionRequiredSecurityLevel"];
                    AzureDeviceComplianceSetting.afwosMinimumVersion = _POST["afwosMinimumVersion"];
                    AzureDeviceComplianceSetting.afwosMaximumVersion = _POST["afwosMaximumVersion"];
                    AzureDeviceComplianceSetting.afwpasswordRequired = _POST["afwpasswordRequired"];
                    AzureDeviceComplianceSetting.afwpasswordMinimumLength = _POST["afwpasswordMinimumLength"];
                    AzureDeviceComplianceSetting.afwpasswordRequiredType = _POST["afwpasswordRequiredType"];
                    AzureDeviceComplianceSetting.afwpasswordMinutesOfInactivityBeforeLock = _POST["afwpasswordMinutesOfInactivityBeforeLock"];
                    AzureDeviceComplianceSetting.afwpasswordExpirationDays = _POST["afwpasswordExpirationDays"];
                    AzureDeviceComplianceSetting.afwpasswordPreviousPasswordBlockCount = _POST["afwpasswordPreviousPasswordBlockCount"];
                    AzureDeviceComplianceSetting.afwstorageRequireEncryption = _POST["afwstorageRequireEncryption"];
                    AzureDeviceComplianceSetting.afwsecurityPreventInstallAppsFromUnknownSources = _POST["afwsecurityPreventInstallAppsFromUnknownSources"];
                    AzureDeviceComplianceSetting.afwsecurityDisableUsbDebugging = _POST["afwsecurityDisableUsbDebugging"];
                    AzureDeviceComplianceSetting.afwminAndroidSecurityPatchLevel = _POST["afwminAndroidSecurityPatchLevel"];

                }
                if (_POST["platform"] == "IOS")
                {
                    AzureDeviceComplianceSetting.organization = _POST["organization"];
                    AzureDeviceComplianceSetting.platform = _POST["platform"];
                    AzureDeviceComplianceSetting.displayName = _POST["displayName"];
                    AzureDeviceComplianceSetting.id = _POST["deviceconf"];
                    AzureDeviceComplianceSetting.description = _POST["description"];
                    AzureDeviceComplianceSetting.managedEmailProfileRequired = _POST["managedEmailProfileRequired"];
                    AzureDeviceComplianceSetting.iossecurityBlockJailbrokenDevices = _POST["iossecurityBlockJailbrokenDevices"];
                    AzureDeviceComplianceSetting.iosdeviceThreatProtectionRequiredSecurityLevel = _POST["iosdeviceThreatProtectionRequiredSecurityLevel"];
                    AzureDeviceComplianceSetting.iososMinimumVersion = _POST["iososMinimumVersion"];
                    AzureDeviceComplianceSetting.iososMaximumVersion = _POST["iososMaximumVersion"];
                    AzureDeviceComplianceSetting.passcodeRequired = _POST["passcodeRequired"];
                    AzureDeviceComplianceSetting.passcodeBlockSimple = _POST["passcodeBlockSimple"];
                    AzureDeviceComplianceSetting.passcodeMinimumLength = _POST["passcodeMinimumLength"];
                    AzureDeviceComplianceSetting.passcodeRequiredType = _POST["passcodeRequiredType"];
                    AzureDeviceComplianceSetting.passcodeMinimumCharacterSetCount = _POST["passcodeMinimumCharacterSetCount"];
                    AzureDeviceComplianceSetting.passcodeMinutesOfInactivityBeforeLock = _POST["passcodeMinutesOfInactivityBeforeLock"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceComplianceSetting.passcodePreviousPasscodeBlockCount = _POST["passcodePreviousPasscodeBlockCount"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                    AzureDeviceComplianceSetting.passcodeExpirationDays = _POST["passcodeExpirationDays"];
                }
                if (_POST["platform"] == "Win10")
                {
                    AzureDeviceComplianceSetting.organization = _POST["organization"];
                    AzureDeviceComplianceSetting.platform = _POST["platform"];
                    AzureDeviceComplianceSetting.displayName = _POST["displayName"];
                    AzureDeviceComplianceSetting.id = _POST["deviceconf"];
                    AzureDeviceComplianceSetting.description = _POST["description"];
                    AzureDeviceComplianceSetting.bitLockerEnabled = _POST["bitLockerEnabled"];
                    AzureDeviceComplianceSetting.secureBootEnabled = _POST["secureBootEnabled"];
                    AzureDeviceComplianceSetting.codeIntegrityEnabled = _POST["codeIntegrityEnabled"];
                    AzureDeviceComplianceSetting.winosMinimumVersion = _POST["winosMinimumVersion"];
                    AzureDeviceComplianceSetting.winosMaximumVersion = _POST["winosMaximumVersion"];
                    AzureDeviceComplianceSetting.mobileOsMinimumVersion = _POST["mobileOsMinimumVersion"];
                    AzureDeviceComplianceSetting.mobileOsMaximumVersion = _POST["mobileOsMaximumVersion"];
                    AzureDeviceComplianceSetting.winpasswordRequired = _POST["winpasswordRequired"];
                    AzureDeviceComplianceSetting.passwordBlockSimple = _POST["passwordBlockSimple"];
                    AzureDeviceComplianceSetting.winpasswordRequiredType = _POST["winpasswordRequiredType"];
                    AzureDeviceComplianceSetting.winpasswordMinimumLength = _POST["winpasswordMinimumLength"];
                    AzureDeviceComplianceSetting.winpasswordMinutesOfInactivityBeforeLock = _POST["winpasswordMinutesOfInactivityBeforeLock"];
                    AzureDeviceComplianceSetting.winpasswordExpirationDays = _POST["winpasswordExpirationDays"];
                    AzureDeviceComplianceSetting.winpasswordPreviousPasswordBlockCount = _POST["winpasswordPreviousPasswordBlockCount"];
                    AzureDeviceComplianceSetting.winpasswordRequiredToUnlockFromIdle = _POST["winpasswordRequiredToUnlockFromIdle"];
                    AzureDeviceComplianceSetting.winstorageRequireEncryption = _POST["winstorageRequireEncryption"];

                }
                if (_POST["platform"] == "macOS")
                {
                    AzureDeviceComplianceSetting.organization = _POST["organization"];
                    AzureDeviceComplianceSetting.platform = _POST["platform"];
                    AzureDeviceComplianceSetting.displayName = _POST["displayName"];
                    AzureDeviceComplianceSetting.id = _POST["deviceconf"];
                    AzureDeviceComplianceSetting.description = _POST["description"];
                    AzureDeviceComplianceSetting.systemIntegrityProtectionEnabled = _POST["systemIntegrityProtectionEnabled"];
                    AzureDeviceComplianceSetting.macosMinimumVersion = _POST["macosMinimumVersion"];
                    AzureDeviceComplianceSetting.macosMaximumVersion = _POST["macosMaximumVersion"];
                    AzureDeviceComplianceSetting.macpasswordRequired = _POST["macpasswordRequired"];
                    AzureDeviceComplianceSetting.macpasswordBlockSimple = _POST["macpasswordBlockSimple"];
                    AzureDeviceComplianceSetting.macpasswordMinimumLength = _POST["macpasswordMinimumLength"];
                    AzureDeviceComplianceSetting.macpasswordRequiredType = _POST["macpasswordRequiredType"];
                    AzureDeviceComplianceSetting.macpasswordMinimumCharacterSetCount = _POST["macpasswordMinimumCharacterSetCount"];
                    AzureDeviceComplianceSetting.macpasswordMinutesOfInactivityBeforeLock = _POST["macpasswordMinutesOfInactivityBeforeLock"];
                    AzureDeviceComplianceSetting.macpasswordExpirationDays = _POST["macpasswordExpirationDays"];
                    AzureDeviceComplianceSetting.macpasswordPreviousPasswordBlockCount = _POST["macpasswordPreviousPasswordBlockCount"];
                    AzureDeviceComplianceSetting.macstorageRequireEncryption = _POST["macstorageRequireEncryption"];
                }

                model.AzureDeviceComplianceSetting = AzureDeviceComplianceSetting;

                CommonCAS.Log(string.Format("has run Azure/UpdateAzureIntuneComplianceSettings() to update {0}", AzureDeviceComplianceSetting.displayName));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.UpdateAzureIntuneComplianceSetting(AzureDeviceComplianceSetting);
                    var result = ps.Invoke();
                }

                model.OKMessage.Add(string.Format("Compliance Policy '{0}' updated with new settings. New Settings will take effect on next device sync.", AzureDeviceComplianceSetting.displayName));

                CommonCAS.Stats("Azure/UpdateAzureIntuneComplianceSettings");

                return View("UpdateAzureIntuneComplianceSettings", model);
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
        public class AjaxIntuneDeviceTask
        {
            public string Status { get; set; }
            public string ID { get; set; }
        }
        public string StartIntuneDeviceTask(string organization, string task, string id, string name, string message, string phone, string footer)
        {
            try
            {
                List<AjaxIntuneDeviceTask> statusobjects = new List<AjaxIntuneDeviceTask>();

                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.StartIntuneDeviceTask(organization, task, id, message, phone, footer);
                    PSObject result = ps.Invoke().Single();

                    CommonCAS.Log(string.Format("has run Azure/IntuneDeviceTask() to start {0} on {1} for {2}", task, name, organization));

                    Dictionary<string, object> properties = CommonCAS.GetPSObjectProperties(result);
                    return new JavaScriptSerializer().Serialize(new AjaxIntuneDeviceTask()
                    {
                        Status = properties["Status"].ToString(),
                        ID = properties["Id"].ToString()
                    });
                }
          }
            catch (Exception exc)
            {
                return new JsonException(exc).ToString();
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreatePSAppRegistration()
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
        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreatePSAppRegistrationSuccessPermissions()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult CreatePSAppRegistration(FormCollection _POST)
        {
            try
            {
                CustomAzureSetup AzureSetup = new CustomAzureSetup()
                {
                    Organization = _POST["organization"]
                };

                model.AzureSetup = AzureSetup;

                CommonCAS.Log(string.Format("has run Azure/CreatePSAppRegistration() for {0}", AzureSetup.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.CreatePSAppRegistration(AzureSetup.Organization);
                    var result = ps.Invoke().Single();

                    model.AzureSetup.Organization = result.Members["Organization"].Value.ToString();
                    model.AzureSetup.TenantId = result.Members["TenantId"].Value.ToString();
                    model.AzureSetup.Name = result.Members["Name"].Value.ToString();
                    model.AzureSetup.AppId = result.Members["AppId"].Value.ToString();
                    model.AzureSetup.KeySecret = result.Members["KeySecret"].Value.ToString();
                    model.AzureSetup.AdminUser = result.Members["AdminUser"].Value.ToString();
                    model.AzureSetup.AdminPass = result.Members["AdminPass"].Value.ToString();
                }

                model.OKMessage.Add(string.Format("PSAppRegistration for '{0}' created.", AzureSetup.Organization));

                CommonCAS.Stats("Azure/CreatePSAppRegistration");

                return View("CreatePSAppRegistrationSuccess", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        // Display create view
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetCloudAdminPassword()
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
        // Create POSTed organization
        [HttpPost]
        [Authorize(Roles = "Access_SelfService_FullAccess")]
        public ActionResult SetCloudAdminPassword(FormCollection _POST)
        {
            try
            {
                CustomAzureSetup AzureSetup = new CustomAzureSetup()
                {
                    Organization = _POST["organization"]
                };

                model.AzureSetup = AzureSetup;

                CommonCAS.Log(string.Format("has run Azure/SetCloudAdminPassword() for {0}", AzureSetup.Organization));

                // execute powershell script and dispose powershell object
                using (MyPowerShell ps = new MyPowerShell())
                {
                    ps.SetCloudAdminPassword(AzureSetup.Organization);
                    var result = ps.Invoke();

                    if (result.Count() == 0)
                    {
                        model.OKMessage.Add(string.Format("SetCloudAdminPassword for '{0}'.", AzureSetup.Organization));
                    }
                    else
                    {
                        model.OKMessage.Add(string.Format("SetCloudAdminPassword for '{0}'.", AzureSetup.Organization));
                        foreach (PSObject message in result)
                        {
                            model.OKMessage.Add(message.ToString());
                        }
                    }

                }

                CommonCAS.Stats("Azure/SetCloudAdminPassword");

                return View("SetCloudAdminPassword", model);
            }
            catch (Exception exc)
            {
                CommonCAS.Log("Exception: " + exc.Message);
                model.ActionFailed = true;
                model.Message = exc.Message;
                return View(model);
            }
        }

        public class StatusNumber
        {
            public string Platform { get; set; }
            public string Number { get; set; }
        }
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        public ActionResult IntuneEnrollOverviewPieChartDisk(string androidCount, string iosCount, string macOSCount, string windowsMobileCount, string windowsCount, string unknownCount)
        {
            var statusNumbers = new List<StatusNumber>
            {
                new StatusNumber{Number=androidCount, Platform="Android"},
                new StatusNumber{Number=iosCount, Platform="IOS"},
                new StatusNumber{Number=windowsMobileCount, Platform="Windows Mobile"},
                new StatusNumber{Number=windowsCount, Platform="Windows"},
                new StatusNumber{Number=macOSCount, Platform="MacOS"},
                new StatusNumber{Number=unknownCount, Platform="Unknown"},
            };
            var chart = new Chart();
            chart.Width = 400;
            chart.Height = 300;
            chart.BackColor = Color.FromArgb(255, 221, 199);
            chart.BorderlineDashStyle = ChartDashStyle.Solid;
            chart.BackSecondaryColor = Color.White;
            chart.BackGradientStyle = GradientStyle.TopBottom;
            //chart.Palette = ChartColorPalette.BrightPastel;
            chart.BorderlineColor = Color.FromArgb(26, 59, 105);
            chart.RenderType = RenderType.BinaryStreaming;
            chart.BorderSkin.SkinStyle = BorderSkinStyle.Raised;
            chart.AntiAliasing = AntiAliasingStyles.All;
            chart.TextAntiAliasingQuality = TextAntiAliasingQuality.High;
            chart.Titles.Add(CreateEnrollTitle());
            chart.Legends.Add(CreateEnrollLegend());
            chart.Series.Add(CreateEnrollSeries(SeriesChartType.Doughnut, statusNumbers));
            chart.ChartAreas.Add(CreateEnrollChartArea());
            //foreach (var dp in chart.Series["# of devices pr platform"].Points) { dp["Exploded"] = "true"; }
            chart.Series["# of devices pr platform"]["DoughnutRadius"] = "45";
            chart.Series["# of devices pr platform"]["PieLabelStyle"] = "Inside";
            chart.Series["# of devices pr platform"]["PieDrawingStyle"] = "SoftEdge";
            //chart.Palette = ChartColorPalette.SemiTransparent;
            chart.Series["# of devices pr platform"].Points[0].Color = Color.FromArgb(200, 36, 109, 255); // Android
            chart.Series["# of devices pr platform"].Points[1].Color = Color.FromArgb(200, 27, 243, 236); // IOS
            chart.Series["# of devices pr platform"].Points[2].Color = Color.FromArgb(200, Color.Red); // Windows Mobile
            chart.Series["# of devices pr platform"].Points[3].Color = Color.FromArgb(200, 16, 188, 31); // Windows
            chart.Series["# of devices pr platform"].Points[4].Color = Color.FromArgb(200, 184, 10, 129); // MACos
            chart.Series["# of devices pr platform"].Points[5].Color = Color.FromArgb(200, Color.Black); // Unknown

            MemoryStream ms = new MemoryStream();
            chart.SaveImage(ms);
            return File(ms.GetBuffer(), @"image/png");
        }

        public Title CreateEnrollTitle()
        {
            Title title = new Title
            {
                Text = "Device Enrollment",
                ShadowColor = Color.FromArgb(32, 0, 0, 0),
                Font = new Font("Verdana", 10F, FontStyle.Bold),
                ShadowOffset = 0,
                ForeColor = Color.FromArgb(0, 0, 0)
            };
            return title;
        }
        public Series CreateEnrollSeries(SeriesChartType chartType, ICollection<StatusNumber> list)
        {
            var series = new Series
            {
                Name = "# of devices pr platform",
                IsValueShownAsLabel = true,
                //Color = Color.FromArgb(255, 102, 0, 1),
                //Color = Color.FromArgb(50, Color.Blue),
                ChartType = chartType,
                BorderWidth = 2,
                Font = new Font("Verdana", 11F, FontStyle.Regular)
                //Palette = ChartColorPalette.SemiTransparent,

            };
            foreach (var item in list)
            {
                var point = new DataPoint
                {
                    AxisLabel = item.Platform,
                    YValues = new double[] { double.Parse(item.Number) }
                };
                series.Points.Add(point);
            }
            return series;
        }
        public ChartArea CreateEnrollChartArea()
        {
            var chartArea = new ChartArea();
            chartArea.Name = "Device Enrollment";
            chartArea.BackColor = Color.Transparent;
            //chartArea.BorderDashStyle = ChartDashStyle.Solid;
            chartArea.Area3DStyle.Enable3D = true;
            chartArea.AxisX.IsLabelAutoFit = true;
            chartArea.AxisY.IsLabelAutoFit = true;
            chartArea.AxisX.TitleAlignment = StringAlignment.Far;
            chartArea.AxisX.LabelStyle.Font = new Font("Verdana, Arial, Helvetica, sans - serif", 10F, FontStyle.Bold);
            chartArea.AxisY.LabelStyle.Font = new Font("Verdana, Arial, Helvetica, sans - serif", 8F, FontStyle.Regular);
            chartArea.AxisY.Enabled = AxisEnabled.False;
            chartArea.AxisY.LineColor = Color.FromArgb(64, 64, 64, 64);
            chartArea.AxisX.LineColor = Color.FromArgb(64, 64, 64, 64);
            chartArea.AxisX.MajorGrid.Enabled = false;
            chartArea.AxisY.MajorGrid.Enabled = false;
            chartArea.Area3DStyle.WallWidth = 30;
            chartArea.Area3DStyle.LightStyle = LightStyle.Realistic;
            chartArea.Area3DStyle.Inclination = 20;
            chartArea.Area3DStyle.PointDepth = 100; //thickness
            chartArea.Area3DStyle.Perspective = 60;
            //chartArea.AxisY.MajorGrid.LineColor = Color.FromArgb(64, 64, 64, 64);
            //chartArea.AxisX.MajorGrid.LineColor = Color.FromArgb(64, 64, 64, 64);
            return chartArea;
        }
        public Legend CreateEnrollLegend()
        {
            var legend = new Legend
            {
                Name = "Device Enrollment",
                Docking = Docking.Bottom,
                Alignment = StringAlignment.Center,
                BackColor = Color.Transparent,
                Font = new Font(new FontFamily("Verdana"), 7),
                LegendStyle = LegendStyle.Table,
                LegendItemOrder = LegendItemOrder.ReversedSeriesOrder
            };
            return legend;
        }

        /// <summary>
        /// Compliance Chart
        /// </summary>
        public class ComplianceStatus
        {
            public string Platform { get; set; }
            public string Number { get; set; }
        }
        [Authorize(Roles = "Access_SelfService_FullAccess, Role_Level_5")]
        public ActionResult IntuneComplianceOverviewPieChartDisk(string compliantCount, string NotcompliantCount, string InGracePeriod, string DeviceNotSynced)
        {
            var ComplianceList = new List<ComplianceStatus>
            {
                new ComplianceStatus{Number=compliantCount, Platform="Compliant"},
                new ComplianceStatus{Number=NotcompliantCount, Platform="Not Compliant"},
                new ComplianceStatus{Number=InGracePeriod, Platform="In Grace Period"},
                new ComplianceStatus{Number=DeviceNotSynced, Platform="Device Not Synced"},
            };
            string name = "Compliance Overview";
            var chart = new Chart();
            chart.Width = 400;
            chart.Height = 300;
            chart.RenderType = RenderType.BinaryStreaming;
            chart.BackColor = Color.FromArgb(255, 221, 199);
            chart.BorderlineDashStyle = ChartDashStyle.Solid;
            chart.BackSecondaryColor = Color.White;
            chart.BackGradientStyle = GradientStyle.TopBottom;
            chart.BorderlineColor = Color.FromArgb(26, 59, 105);
            chart.BorderSkin.SkinStyle = BorderSkinStyle.Raised;
            //chart.BorderSkin.BorderColor = Color.FromArgb(200, 16, 188, 31);
            //chart.BorderSkin.BackColor = Color.FromArgb(50, 255, 221, 199);
            chart.AntiAliasing = AntiAliasingStyles.All;
            chart.TextAntiAliasingQuality = TextAntiAliasingQuality.High;
            chart.Titles.Add(CreateComplianceTitle(name));
            chart.Legends.Add(CreateComplianceLegend(Docking.Bottom, name));
            chart.Series.Add(CreateComplianceSeries(SeriesChartType.Doughnut, ComplianceList, name));
            chart.ChartAreas.Add(CreateEnrollChartArea());
            chart.Series[name]["DoughnutRadius"] = "45";
            chart.Series[name]["PieLabelStyle"] = "Inside";
            chart.Series[name]["PieDrawingStyle"] = "SoftEdge";
            //chart.Series[name].Points[0]["Exploded"] = "true";
            //foreach (var dp in chart.Series[name].Points) { dp["Exploded"] = "true"; }
            chart.Palette = ChartColorPalette.None;
            chart.PaletteCustomColors = new Color[] { Color.FromArgb(200, 16, 188, 31), Color.FromArgb(200, Color.Red), Color.FromArgb(200, 241, 114, 55), Color.FromArgb(200, 184, 10, 129), Color.FromArgb(200, Color.Black) };

            MemoryStream ms = new MemoryStream();
            chart.SaveImage(ms);
            return File(ms.GetBuffer(), @"image/png");
        }

        public Title CreateComplianceTitle(string name)
        {
            Title title = new Title
            {
                Text = name,
                ShadowColor = Color.FromArgb(32, 0, 0, 0),
                Font = new Font("Verdana", 10F, FontStyle.Bold),
                ShadowOffset = 0,
                ForeColor = Color.FromArgb(0, 0, 0)
            };
            return title;
        }
        public Series CreateComplianceSeries(SeriesChartType chartType, ICollection<ComplianceStatus> list, string name)
        {
            var series = new Series
            {
                Name = name,
                IsValueShownAsLabel = true,
                ChartType = chartType,
                BorderWidth = 2,
                Font = new Font("Verdana", 11F, FontStyle.Regular)

            };
            foreach (var item in list)
            {
                var point = new DataPoint
                {
                    AxisLabel = item.Platform,
                    YValues = new double[] { double.Parse(item.Number) }
                };
                series.Points.Add(point);
            }
            return series;
        }
        public ChartArea CreateComplianceChartArea(string name)
        {
            var chartArea = new ChartArea();
            chartArea.Name = name;
            chartArea.BackColor = Color.Transparent;
            chartArea.BorderDashStyle = ChartDashStyle.Solid;
            chartArea.Area3DStyle.Enable3D = true;
            chartArea.AxisX.IsLabelAutoFit = true;
            chartArea.AxisY.IsLabelAutoFit = true;
            chartArea.AxisX.TitleAlignment = StringAlignment.Far;
            chartArea.AxisX.LabelStyle.Font = new Font("Verdana", 10F, FontStyle.Bold);
            chartArea.AxisY.LabelStyle.Font = new Font("Verdana", 10F, FontStyle.Regular);
            chartArea.AxisY.Enabled = AxisEnabled.False;
            chartArea.AxisY.LineColor = Color.FromArgb(64, 64, 64, 64);
            chartArea.AxisX.LineColor = Color.FromArgb(64, 64, 64, 64);
            chartArea.AxisX.MajorGrid.Enabled = false;
            chartArea.AxisY.MajorGrid.Enabled = false;
            chartArea.Area3DStyle.WallWidth = 30;
            chartArea.Area3DStyle.LightStyle = LightStyle.Realistic;
            chartArea.Area3DStyle.Inclination = 20;
            chartArea.Area3DStyle.PointDepth = 100; //thickness
            chartArea.Area3DStyle.Perspective = 60;
            //chartArea.AxisY.MajorGrid.LineColor = Color.FromArgb(64, 64, 64, 64);
            //chartArea.AxisX.MajorGrid.LineColor = Color.FromArgb(64, 64, 64, 64);
            return chartArea;
        }
        public Legend CreateComplianceLegend(Docking docking, string name)
        {
            var legend = new Legend
            {
                Name = name,
                Docking = docking,
                Alignment = StringAlignment.Center,
                BackColor = Color.Transparent,
                Font = new Font(new FontFamily("Verdana"), 9),
                LegendStyle = LegendStyle.Table,
                LegendItemOrder = LegendItemOrder.ReversedSeriesOrder,
                TableStyle = LegendTableStyle.Wide
            };
            return legend;
        }

    }
}
