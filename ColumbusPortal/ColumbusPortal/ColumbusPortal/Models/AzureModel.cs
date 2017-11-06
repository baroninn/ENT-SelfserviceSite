using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ColumbusPortal.Models
{
    // model for View display in the Azure controller
    public class AzureModel : BaseModel
    {
        public List<CustomAzureVM> AzureVM = new List<CustomAzureVM>();
        public CustomOverView OverView = new CustomOverView();
        public CustomCreateVM CreateVM = new CustomCreateVM();
        public CustomCreateAzurePIP CreateAzurePIP = new CustomCreateAzurePIP();
        public CustomAzureOrganization AzureOrganization = new CustomAzureOrganization();
        public CustomAzureDeviceConfiguration AzureDeviceConfiguration = new CustomAzureDeviceConfiguration();
        public CustomAzureDeviceComplianceSetting AzureDeviceComplianceSetting = new CustomAzureDeviceComplianceSetting();
        public CustomCreateDefaultIntuneConfiguration CreateDefaultIntuneConfiguration = new CustomCreateDefaultIntuneConfiguration();
        public CustomIntuneOverview IntuneOverview = new CustomIntuneOverview();
        public List<CustomCustconf> Configuration = new List<CustomCustconf>();
        public List<CustomAzureSecurity> AzureSecurity = new List<CustomAzureSecurity>();
        public List<CustomIntuneDevice> IntuneDevice = new List<CustomIntuneDevice>();
        public List<CustomComplianceOverview> ComplianceOverview = new List<CustomComplianceOverview>();
        public CustomAzureSetup AzureSetup = new CustomAzureSetup();
    }

    public class CustomAzureOrganization
    {
        public string Name { get; set; }
        public string Platform { get; set; }
        public string Initials { get; set; }
        public string EmailDomainName { get; set; }
        public bool createcrayon { get; set; }
        public string InvoiceProfile { get; set; }
        public string CrayonDomainPrefix { get; set; }
        public string CrayonFirstName { get; set; }
        public string CrayonLastName { get; set; }
        public string CrayonEmail { get; set; }
        public string CrayonPhoneNumber { get; set; }
        public string CrayonCustomerFirstName { get; set; }
        public string CrayonCustomerLastName { get; set; }
        public string CrayonAddressLine1 { get; set; }
        public string CrayonCity { get; set; }
        public string CrayonRegion { get; set; }
        public string CrayonPostalCode { get; set; }

    }
    public class CustomCustconf
    {
        public string Platform { get; set; }
        public string ServiceCompute { get; set; }
        public string Service365 { get; set; }
        public string ServiceIntune { get; set; }
        public string AdminRDS { get; set; }
        public string AdminRDSPort { get; set; }
    }

    public class CustomOverView
    {
        public string Organization { get; set; }
    }
    public class CustomCreateVM
    {
        public string Organization { get; set; }
        public string RessourceGroupName { get; set; }
        public string StorageAccount { get; set; }
        public string VirtualNetwork { get; set; }
        public string AvailabilitySet { get; set; }
        public string VmSize { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public string NetworkInterface { get; set; }
        public string PublicIP { get; set; }
        public string Subnet { get; set; }

    }
    public class CustomCreateAzurePIP
    {
        public string Organization { get; set; }
        public string RessourceGroupName { get; set; }
        public string AllocationMethod { get; set; }
        public string Version { get; set; }
        public string Location { get; set; }
        public string Name { get; set; }

    }

    public class CustomAzureVM
    {
        public string Organization { get; set; }
        public string ResourceGroupName { get; set; }
        public string Name { get; set; }
        public string VmId { get; set; }
        public string Location { get; set; }
        public string VmSize { get; set; }
        public string ProvisioningState { get; set; }
        public string PowerState { get; set; }
        public string CPU { get; set; }
        public string RAM { get; set; }
        public string IPAddress { get; set; }

    }

    public class CustomAzureSecurity
    {
        public string Organization { get; set; }
        public string Name { get; set; }
        public string PatchesSecurityState { get; set; }
        public string securityState { get; set; }
        public string MalwaresecurityState { get; set; }
        public List<CustomAzureSecurityPatches> Patches { get; set; }
        public List<CustomAzureSecuritymalware> Malware { get; set; }
        public List<CustomAzureSecurityRecommendations> Recommendations { get; set; }

    }
    public class CustomAzureSecurityPatches
    {
        public string patchId { get; set; }
        public string title { get; set; }
        public string severity { get; set; }
        public string linksToMsDocumentation { get; set; }
    }

    public class CustomAzureSecuritymalware
    {
        public string componentName { get; set; }
        public string description { get; set; }
        public string severity { get; set; }
        public string eventTimestamp { get; set; }
        public string message { get; set; }
    }
    public class CustomAzureSecurityRecommendations
    {
        public string vmName { get; set; }
        public string name { get; set; }
    }

    public class CustomIntuneDevice
    {
        public string Organization { get; set; }
        public string id { get; set; }
        public string deviceName { get; set; }
        public string ownerType { get; set; }
        public string enrolledDateTime { get; set; }
        public string lastSyncDateTime { get; set; }
        public string chassisType { get; set; }
        public string operatingSystem { get; set; }
        public string deviceType { get; set; }
        public string complianceState { get; set; }
        public string jailBroken { get; set; }
        public string osVersion { get; set; }
        public string deviceEnrollmentType { get; set; }
        public string model { get; set; }
        public string manufacturer { get; set; }
        public string serialNumber { get; set; }
        public string userPrincipalName { get; set; }

    }
    public class CustomComplianceOverview
    {
        public string Organization { get; set; }
        public string name { get; set; }
        public string id { get; set; }
        public string pendingCount { get; set; }
        public string notApplicableCount { get; set; }
        public string successCount { get; set; }
        public string errorCount { get; set; }
        public string failedCount { get; set; }
        public string lastUpdateDateTime { get; set; }

    }

    public class CustomAzureSetup
    {
        public string Organization { get; set; }
        public string TenantId { get; set; }
        public string Name { get; set; }
        public string KeySecret { get; set; }
        public string AppId { get; set; }
        public string AdminUser { get; set; }
        public string AdminPass { get; set; }
    }

    public class CustomAzureDeviceConfiguration
    {
        public string organization { get; set; }
        public string platform { get; set; }
        public string displayName { get; set; }
        public string id { get; set; }
        public string description { get; set; }
        /// <summary>
        /// Android Device Configuration
        /// </summary>
        public string appsBlockClipboardSharing { get; set; }
        public string appsBlockCopyPaste { get; set; }
        public string appsBlockYouTube { get; set; }
        public string bluetoothBlocked { get; set; }
        public string cameraBlocked { get; set; }
        public string cellularBlockDataRoaming { get; set; }
        public string cellularBlockMessaging { get; set; }
        public string cellularBlockVoiceRoaming { get; set; }
        public string cellularBlockWiFiTethering { get; set; }
        public string locationServicesBlocked { get; set; }
        public string googleAccountBlockAutoSync { get; set; }
        public string googlePlayStoreBlocked { get; set; }
        public string nfcBlocked { get; set; }
        public string passwordBlockFingerprintUnlock { get; set; }
        public string passwordBlockTrustAgents { get; set; }
        public string passwordExpirationDays { get; set; }
        public string passwordMinimumLength { get; set; }
        public string passwordMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string passwordPreviousPasswordBlockCount { get; set; }
        public string passwordSignInFailureCountBeforeFactoryReset { get; set; }
        public string passwordRequiredType { get; set; }
        public string passwordRequired { get; set; }
        public string powerOffBlocked { get; set; }
        public string factoryResetBlocked { get; set; }
        public string screenCaptureBlocked { get; set; }
        public string deviceSharingAllowed { get; set; }
        public string storageBlockGoogleBackup { get; set; }
        public string storageBlockRemovableStorage { get; set; }
        public string storageRequireDeviceEncryption { get; set; }
        public string storageRequireRemovableStorageEncryption { get; set; }
        public string voiceAssistantBlocked { get; set; }
        public string voiceDialingBlocked { get; set; }
        public string webBrowserBlockPopups { get; set; }
        public string webBrowserBlockAutofill { get; set; }
        public string webBrowserBlockJavaScript { get; set; }
        public string webBrowserBlocked { get; set; }
        public string webBrowserCookieSettings { get; set; }
        public string wiFiBlocked { get; set; }
        /// <summary>
        /// Android for work Device Configuration
        /// </summary>
        public string workProfileDataSharingType { get; set; }
        public string workProfileBlockNotificationsWhileDeviceLocked { get; set; }
        public string workProfileDefaultAppPermissionPolicy { get; set; }
        public string workProfileRequirePassword { get; set; }
        public string workProfilePasswordMinimumLength { get; set; }
        public string workProfilePasswordMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string workProfilePasswordSignInFailureCountBeforeFactoryReset { get; set; }
        public string workProfilePasswordExpirationDays { get; set; }
        public string workProfilePasswordRequiredType { get; set; }
        public string workProfilePasswordPreviousPasswordBlockCount { get; set; }
        public string workProfilePasswordBlockFingerprintUnlock { get; set; }
        public string workProfilePasswordBlockTrustAgents { get; set; }
        public string afwpasswordMinimumLength { get; set; }
        public string afwpasswordMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string afwpasswordSignInFailureCountBeforeFactoryReset { get; set; }
        public string afwpasswordExpirationDays { get; set; }
        public string afwpasswordRequiredType { get; set; }
        public string afwpasswordPreviousPasswordBlockCount { get; set; }
        public string afwpasswordBlockFingerprintUnlock { get; set; }
        public string afwpasswordBlockTrustAgents { get; set; }
        /// <summary>
        /// macOS Device Configuration
        /// </summary>
        public string macpasswordMinimumLength { get; set; }
        public string macpasswordBlockSimple { get; set; }
        public string macpasswordMinimumCharacterSetCount { get; set; }
        public string macpasswordMinutesOfInactivityBeforeLock { get; set; }
        public string macpasswordExpirationDays { get; set; }
        public string macpasswordRequiredType { get; set; }
        public string macpasswordPreviousPasswordBlockCount { get; set; }
        public string macpasswordMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string macpasswordRequired { get; set; }
        /// <summary>
        /// IOS Device Configuration
        /// </summary>
        /// 
        public string accountBlockModification { get; set; }
        public string activationLockAllowWhenSupervised { get; set; }
        public string airDropBlocked { get; set; }
        public string airDropForceUnmanagedDropTarget { get; set; }
        public string airPlayForcePairingPasswordForOutgoingRequests { get; set; }
        public string appleWatchBlockPairing { get; set; }
        public string appleWatchForceWristDetection { get; set; }
        public string appleNewsBlocked { get; set; }
        public string appStoreBlockAutomaticDownloads { get; set; }
        public string appStoreBlocked { get; set; }
        public string appStoreBlockInAppPurchases { get; set; }
        public string appStoreBlockUIAppInstallation { get; set; }
        public string appStoreRequirePassword { get; set; }
        public string bluetoothBlockModification { get; set; }
        public string ioscameraBlocked { get; set; }
        public string ioscellularBlockDataRoaming { get; set; }
        public string cellularBlockGlobalBackgroundFetchWhileRoaming { get; set; }
        public string cellularBlockPerAppDataModification { get; set; }
        public string cellularBlockPersonalHotspot { get; set; }
        public string ioscellularBlockVoiceRoaming { get; set; }
        public string certificatesBlockUntrustedTlsCertificates { get; set; }
        public string classroomAppBlockRemoteScreenObservation { get; set; }
        public string classroomAppForceUnpromptedScreenObservation { get; set; }
        public string configurationProfileBlockChanges { get; set; }
        public string definitionLookupBlocked { get; set; }
        public string deviceBlockEnableRestrictions { get; set; }
        public string deviceBlockEraseContentAndSettings { get; set; }
        public string deviceBlockNameModification { get; set; }
        public string diagnosticDataBlockSubmission { get; set; }
        public string diagnosticDataBlockSubmissionModification { get; set; }
        public string documentsBlockManagedDocumentsInUnmanagedApps { get; set; }
        public string documentsBlockUnmanagedDocumentsInManagedApps { get; set; }
        public string enterpriseAppBlockTrust { get; set; }
        public string enterpriseAppBlockTrustModification { get; set; }
        public string faceTimeBlocked { get; set; }
        public string findMyFriendsBlocked { get; set; }
        public string gamingBlockGameCenterFriends { get; set; }
        public string gamingBlockMultiplayer { get; set; }
        public string gameCenterBlocked { get; set; }
        public string hostPairingBlocked { get; set; }
        public string iBooksStoreBlocked { get; set; }
        public string iBooksStoreBlockErotica { get; set; }
        public string iCloudBlockActivityContinuation { get; set; }
        public string iCloudBlockBackup { get; set; }
        public string iCloudBlockDocumentSync { get; set; }
        public string iCloudBlockManagedAppsSync { get; set; }
        public string iCloudBlockPhotoLibrary { get; set; }
        public string iCloudBlockPhotoStreamSync { get; set; }
        public string iCloudBlockSharedPhotoStream { get; set; }
        public string iCloudRequireEncryptedBackup { get; set; }
        public string iTunesBlockExplicitContent { get; set; }
        public string iTunesBlockMusicService { get; set; }
        public string iTunesBlockRadio { get; set; }
        public string keyboardBlockAutoCorrect { get; set; }
        public string keyboardBlockDictation { get; set; }
        public string keyboardBlockPredictive { get; set; }
        public string keyboardBlockShortcuts { get; set; }
        public string keyboardBlockSpellCheck { get; set; }
        public string lockScreenBlockControlCenter { get; set; }
        public string lockScreenBlockNotificationView { get; set; }
        public string lockScreenBlockPassbook { get; set; }
        public string lockScreenBlockTodayView { get; set; }
        public string mediaContentRatingApps { get; set; }
        public string messagesBlocked { get; set; }
        public string notificationsBlockSettingsModification { get; set; }
        public string passcodeBlockFingerprintUnlock { get; set; }
        public string passcodeBlockFingerprintModification { get; set; }
        public string passcodeBlockModification { get; set; }
        public string passcodeBlockSimple { get; set; }
        public string passcodeExpirationDays { get; set; }
        public string passcodeMinimumLength { get; set; }
        public string passcodeMinutesOfInactivityBeforeLock { get; set; }
        public string passcodeMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string passcodeMinimumCharacterSetCount { get; set; }
        public string passcodePreviousPasscodeBlockCount { get; set; }
        public string passcodeSignInFailureCountBeforeWipe { get; set; }
        public string passcodeRequiredType { get; set; }
        public string passcodeRequired { get; set; }
        public string podcastsBlocked { get; set; }
        public string safariBlockAutofill { get; set; }
        public string safariBlockJavaScript { get; set; }
        public string safariBlockPopups { get; set; }
        public string safariBlocked { get; set; }
        public string safariCookieSettings { get; set; }
        public string safariRequireFraudWarning { get; set; }
        public string iosscreenCaptureBlocked { get; set; }
        public string siriBlocked { get; set; }
        public string siriBlockedWhenLocked { get; set; }
        public string siriBlockUserGeneratedContent { get; set; }
        public string siriRequireProfanityFilter { get; set; }
        public string spotlightBlockInternetResults { get; set; }
        public string iosvoiceDialingBlocked { get; set; }
        public string wallpaperBlockModification { get; set; }
        public string wiFiConnectOnlyToConfiguredNetworks { get; set; }

        /// <summary>
        /// Win10 Device Configuration
        /// </summary>
        /// 
        public string winscreenCaptureBlocked { get; set; }
        public string copyPasteBlocked { get; set; }
        public string deviceManagementBlockManualUnenroll { get; set; }
        public string certificatesBlockManualRootCertificateInstallation { get; set; }
        public string wincameraBlocked { get; set; }
        public string oneDriveDisableFileSync { get; set; }
        public string winstorageBlockRemovableStorage { get; set; }
        public string winlocationServicesBlocked { get; set; }
        public string internetSharingBlocked { get; set; }
        public string deviceManagementBlockFactoryResetOnMobile { get; set; }
        public string usbBlocked { get; set; }
        public string antiTheftModeBlocked { get; set; }
        public string cortanaBlocked { get; set; }
        public string voiceRecordingBlocked { get; set; }
        public string settingsBlockEditDeviceName { get; set; }
        public string settingsBlockAddProvisioningPackage { get; set; }
        public string settingsBlockRemoveProvisioningPackage { get; set; }
        public string experienceBlockDeviceDiscovery { get; set; }
        public string experienceBlockTaskSwitcher { get; set; }
        public string experienceBlockErrorDialogWhenNoSIM { get; set; }
        public string experiencwinpasswordRequiredeBlockErrorDialogWhenNoSIM { get; set; }
        public string winpasswordRequired { get; set; }
        public string winpasswordRequiredType { get; set; }
        public string winpasswordMinimumLength { get; set; }
        public string winpasswordMinutesOfInactivityBeforeScreenTimeout { get; set; }
        public string winpasswordSignInFailureCountBeforeFactoryReset { get; set; }
        public string winpasswordExpirationDays { get; set; }
        public string winpasswordPreviousPasswordBlockCount { get; set; }
        public string winpasswordRequireWhenResumeFromIdleState { get; set; }
        public string winpasswordBlockSimple { get; set; }
        public string storageRequireMobileDeviceEncryption { get; set; }
        public string personalizationDesktopImageUrl { get; set; }
        public string privacyBlockInputPersonalization { get; set; }
        public string privacyAutoAcceptPairingAndConsentPrompts { get; set; }
        public string lockScreenBlockActionCenterNotifications { get; set; }
        public string personalizationLockScreenImageUrl { get; set; }
        public string lockScreenAllowTimeoutConfiguration { get; set; }
        public string lockScreenBlockCortana { get; set; }
        public string lockScreenBlockToastNotifications { get; set; }
        public string lockScreenTimeoutInSeconds { get; set; }
        public string windowsStoreBlocked { get; set; }
        public string windowsStoreBlockAutoUpdate { get; set; }
        public string appsAllowTrustedAppsSideloading { get; set; }
        public string developerUnlockSetting { get; set; }
        public string sharedUserAppDataAllowed { get; set; }
        public string windowsStoreEnablePrivateStoreOnly { get; set; }
        public string appsBlockWindowsStoreOriginatedApps { get; set; }
        public string storageRestrictAppDataToSystemVolume { get; set; }
        public string storageRestrictAppInstallToSystemVolume { get; set; }
        public string gameDvrBlocked { get; set; }
        public string smartScreenEnableAppInstallControl { get; set; }
        public string edgeBlocked { get; set; }
        public string edgeBlockAddressBarDropdown { get; set; }
        public string edgeSyncFavoritesWithInternetExplorer { get; set; }
        public string edgeClearBrowsingDataOnExit { get; set; }
        public string edgeBlockSendingDoNotTrackHeader { get; set; }
        public string edgeCookiePolicy { get; set; }
        public string edgeBlockJavaScript { get; set; }
        public string edgeBlockPopups { get; set; }
        public string edgeBlockSearchSuggestions { get; set; }
        public string edgeBlockSendingIntranetTrafficToInternetExplorer { get; set; }
        public string edgeBlockAutofill { get; set; }
        public string edgeBlockPasswordManager { get; set; }
        public string edgeEnterpriseModeSiteListLocation { get; set; }
        public string edgeBlockDeveloperTools { get; set; }
        public string edgeBlockExtensions { get; set; }
        public string edgeBlockInPrivateBrowsing { get; set; }
        public string edgeDisableFirstRunPage { get; set; }
        public string edgeFirstRunUrl { get; set; }
        public string edgeAllowStartPagesModification { get; set; }
        public string edgeBlockAccessToAboutFlags { get; set; }
        public string webRtcBlockLocalhostIpAddress { get; set; }
        public string edgeSearchEngine { get; set; }
        public string edgeCustomURL { get; set; }
        public string edgeBlockCompatibilityList { get; set; }
        public string edgeBlockLiveTileDataCollection { get; set; }
        public string edgeRequireSmartScreen { get; set; }
        public string smartScreenBlockPromptOverride { get; set; }
        public string smartScreenBlockPromptOverrideForFiles { get; set; }
        public string safeSearchFilter { get; set; }
        public string microsoftAccountBlocked { get; set; }
        public string accountsBlockAddingNonMicrosoftAccountEmail { get; set; }
        public string microsoftAccountBlockSettingsSync { get; set; }
        public string cellularData { get; set; }
        public string cellularBlockDataWhenRoaming { get; set; }
        public string cellularBlockVpn { get; set; }
        public string cellularBlockVpnWhenRoaming { get; set; }
        public string winbluetoothBlocked { get; set; }
        public string bluetoothBlockDiscoverableMode { get; set; }
        public string bluetoothBlockPrePairing { get; set; }
        public string bluetoothBlockAdvertising { get; set; }
        public string connectedDevicesServiceBlocked { get; set; }
        public string winnfcBlocked { get; set; }
        public string winwiFiBlocked { get; set; }
        public string wiFiBlockAutomaticConnectHotspots { get; set; }
        public string wiFiBlockManualConfiguration { get; set; }
        public string wiFiScanInterval { get; set; }
        public string settingsBlockSettingsApp { get; set; }
        public string settingsBlockSystemPage { get; set; }
        public string settingsBlockChangePowerSleep { get; set; }
        public string settingsBlockDevicesPage { get; set; }
        public string settingsBlockNetworkInternetPage { get; set; }
        public string settingsBlockPersonalizationPage { get; set; }
        public string settingsBlockAppsPage { get; set; }
        public string settingsBlockAccountsPage { get; set; }
        public string settingsBlockTimeLanguagePage { get; set; }
        public string settingsBlockChangeSystemTime { get; set; }
        public string settingsBlockChangeRegion { get; set; }
        public string settingsBlockChangeLanguage { get; set; }
        public string settingsBlockGamingPage { get; set; }
        public string settingsBlockEaseOfAccessPage { get; set; }
        public string settingsBlockPrivacyPage { get; set; }
        public string settingsBlockUpdateSecurityPage { get; set; }
        public string defenderRequireRealTimeMonitoring { get; set; }
        public string defenderRequireBehaviorMonitoring { get; set; }
        public string defenderRequireNetworkInspectionSystem { get; set; }
        public string defenderScanDownloads { get; set; }
        public string defenderScanScriptsLoadedInInternetExplorer { get; set; }
        public string defenderBlockEndUserAccess { get; set; }
        public string defenderSignatureUpdateIntervalInHours { get; set; }
        public string defenderMonitorFileActivity { get; set; }
        public string defenderDaysBeforeDeletingQuarantinedMalware { get; set; }
        public string defenderScanArchiveFiles { get; set; }
        public string defenderScanMaxCpu { get; set; }
        public string defenderScanIncomingMail { get; set; }
        public string defenderScanRemovableDrivesDuringFullScan { get; set; }
        public string defenderScanMappedNetworkDrivesDuringFullScan { get; set; }
        public string defenderScanNetworkFiles { get; set; }
        public string defenderRequireCloudProtection { get; set; }
        public string defenderPromptForSampleSubmission { get; set; }
        public string defenderScheduledQuickScanTime { get; set; }
        public string defenderScanType { get; set; }
        public string defenderSystemScanSchedule { get; set; }
        public string defenderScheduledScanTime { get; set; }
        public string defenderPotentiallyUnwantedAppAction { get; set; }
        public string defenderDetectedMalwareActions { get; set; }
        public string defenderlowseverity { get; set; }
        public string defendermoderateseverity { get; set; }
        public string defenderhighseverity { get; set; }
        public string defendersevereseverity { get; set; }

        public string startBlockUnpinningAppsFromTaskbar { get; set; }
        public string logonBlockFastUserSwitching { get; set; }
        public string startMenuHideFrequentlyUsedApps { get; set; }
        public string startMenuHideRecentlyAddedApps { get; set; }
        public string startMenuMode { get; set; }
        public string startMenuHideRecentJumpLists { get; set; }
        public string startMenuAppListVisibility { get; set; }
        public string startMenuHidePowerButton { get; set; }
        public string startMenuHideUserTile { get; set; }
        public string startMenuHideLock { get; set; }
        public string startMenuHideSignOut { get; set; }
        public string startMenuHideShutDown { get; set; }
        public string startMenuHideSleep { get; set; }
        public string startMenuHideHibernate { get; set; }
        public string startMenuHideSwitchAccount { get; set; }
        public string startMenuHideRestartOptions { get; set; }
        public string startMenuPinnedFolderDocuments { get; set; }
        public string startMenuPinnedFolderDownloads { get; set; }
        public string startMenuPinnedFolderFileExplorer { get; set; }
        public string startMenuPinnedFolderHomeGroup { get; set; }
        public string startMenuPinnedFolderMusic { get; set; }
        public string startMenuPinnedFolderNetwork { get; set; }
        public string startMenuPinnedFolderPersonalFolder { get; set; }
        public string startMenuPinnedFolderPictures { get; set; }
        public string startMenuPinnedFolderSettings { get; set; }
        public string startMenuPinnedFolderVideos { get; set; }

    }

    public class CustomCreateDefaultIntuneConfiguration
    {
        public string Organization { get; set; }
    }

    public class CustomIntuneOverview
    {
        public string Organization { get; set; }
        public int enrolledDeviceCount { get; set; }
        public int mdmEnrolledCount { get; set; }
        public int dualEnrolledDeviceCount { get; set; }
        public int androidCount { get; set; }
        public int iosCount { get; set; }
        public int macOSCount { get; set; }
        public int windowsMobileCount { get; set; }
        public int windowsCount { get; set; }
        public int unknownCount { get; set; }
        public int exchallowedDeviceCount { get; set; }
        public int exchblockedDeviceCount { get; set; }
        public int exchquarantinedDeviceCount { get; set; }
        public int exchunknownDeviceCount { get; set; }
        public int exchunavailableDeviceCount { get; set; }
        public int unknownDeviceCount { get; set; }
        public int inGracePeriodCount { get; set; }
        public int notApplicableDeviceCount { get; set; }
        public int compliantDeviceCount { get; set; }
        public int remediatedDeviceCount { get; set; }
        public int nonCompliantDeviceCount { get; set; }
        public int errorDeviceCount { get; set; }
        public int conflictDeviceCount { get; set; }

    }

    public class CustomAzureDeviceComplianceSetting
    {
        public string organization { get; set; }
        public string platform { get; set; }
        public string displayName { get; set; }
        public string id { get; set; }
        public string description { get; set; }
        /// <summary>
        /// Android compliance
        /// </summary>
        public string securityBlockJailbrokenDevices { get; set; }
        public string deviceThreatProtectionRequiredSecurityLevel { get; set; }
        public string osMinimumVersion { get; set; }
        public string osMaximumVersion { get; set; }
        public string passwordRequired { get; set; }
        public string passwordMinimumLength { get; set; }
        public string passwordRequiredType { get; set; }
        public string passwordMinutesOfInactivityBeforeLock { get; set; }
        public string passwordExpirationDays { get; set; }
        public string passwordPreviousPasswordBlockCount { get; set; }
        public string storageRequireEncryption { get; set; }
        public string securityPreventInstallAppsFromUnknownSources { get; set; }
        public string securityDisableUsbDebugging { get; set; }
        public string minAndroidSecurityPatchLevel { get; set; }
        /// <summary>
        /// Android for work compliance
        /// </summary>
        public string afwsecurityBlockJailbrokenDevices { get; set; }
        public string afwdeviceThreatProtectionRequiredSecurityLevel { get; set; }
        public string afwosMinimumVersion { get; set; }
        public string afwosMaximumVersion { get; set; }
        public string afwpasswordRequired { get; set; }
        public string afwpasswordMinimumLength { get; set; }
        public string afwpasswordRequiredType { get; set; }
        public string afwpasswordMinutesOfInactivityBeforeLock { get; set; }
        public string afwpasswordExpirationDays { get; set; }
        public string afwpasswordPreviousPasswordBlockCount { get; set; }
        public string afwstorageRequireEncryption { get; set; }
        public string afwsecurityPreventInstallAppsFromUnknownSources { get; set; }
        public string afwsecurityDisableUsbDebugging { get; set; }
        public string afwminAndroidSecurityPatchLevel { get; set; }
        /// <summary>
        /// Windows 10 Compliance
        /// </summary>
        public string bitLockerEnabled { get; set; }
        public string secureBootEnabled { get; set; }
        public string codeIntegrityEnabled { get; set; }
        public string winosMinimumVersion { get; set; }
        public string winosMaximumVersion { get; set; }
        public string mobileOsMinimumVersion { get; set; }
        public string mobileOsMaximumVersion { get; set; }
        public string winpasswordRequired { get; set; }
        public string passwordBlockSimple { get; set; }
        public string winpasswordRequiredType { get; set; }
        public string winpasswordMinimumLength { get; set; }
        public string winpasswordMinutesOfInactivityBeforeLock { get; set; }
        public string winpasswordExpirationDays { get; set; }
        public string winpasswordPreviousPasswordBlockCount { get; set; }
        public string winpasswordRequiredToUnlockFromIdle { get; set; }
        public string winstorageRequireEncryption { get; set; }
        /// <summary>
        /// IOS Settings
        /// </summary>
        public string managedEmailProfileRequired { get; set; }
        public string iossecurityBlockJailbrokenDevices { get; set; }
        public string iosdeviceThreatProtectionRequiredSecurityLevel { get; set; }
        public string iososMinimumVersion { get; set; }
        public string iososMaximumVersion { get; set; }
        public string passcodeRequired { get; set; }
        public string passcodeBlockSimple { get; set; }
        public string passcodeMinimumLength { get; set; }
        public string passcodeRequiredType { get; set; }
        public string passcodeMinimumCharacterSetCount { get; set; }
        public string passcodeMinutesOfInactivityBeforeLock { get; set; }
        public string passcodeExpirationDays { get; set; }
        public string passcodePreviousPasscodeBlockCount { get; set; }
        /// <summary>
        /// Mac OS Compliance
        /// </summary>
        public string systemIntegrityProtectionEnabled { get; set; }
        public string macosMinimumVersion { get; set; }
        public string macosMaximumVersion { get; set; }
        public string macpasswordRequired { get; set; }
        public string macpasswordBlockSimple { get; set; }
        public string macpasswordMinimumLength { get; set; }
        public string macpasswordRequiredType { get; set; }
        public string macpasswordMinimumCharacterSetCount { get; set; }
        public string macpasswordMinutesOfInactivityBeforeLock { get; set; }
        public string macpasswordExpirationDays { get; set; }
        public string macpasswordPreviousPasswordBlockCount { get; set; }
        public string macstorageRequireEncryption { get; set; }
    }
}