[Cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    [Parameter(Mandatory=$true)]
    [string]$ID,
    [string]$DisplayName,
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Android", "IOS", "Win10", "AFW", "macOS")]
    [string]$Platform,

    ### Android Settings ###
    [string]$appsBlockClipboardSharing,
    [string]$appsBlockCopyPaste,
    [string]$appsBlockYouTube,
    [string]$bluetoothBlocked,
    [string]$cameraBlocked,
    [string]$cellularBlockDataRoaming,
    [string]$cellularBlockMessaging,
    [string]$cellularBlockVoiceRoaming,
    [string]$cellularBlockWiFiTethering,
    [string]$locationServicesBlocked,
    [string]$googleAccountBlockAutoSync,
    [string]$googlePlayStoreBlocked,
    [string]$nfcBlocked,
    [string]$passwordBlockFingerprintUnlock,
    [string]$passwordBlockTrustAgents,
    [string]$passwordExpirationDays,
    [string]$passwordMinimumLength,
    [string]$passwordMinutesOfInactivityBeforeScreenTimeout,
    [string]$passwordPreviousPasswordBlockCount,
    [string]$passwordSignInFailureCountBeforeFactoryReset,
    [string]$passwordRequiredType,
    [string]$passwordRequired,
    [string]$powerOffBlocked,
    [string]$factoryResetBlocked,
    [string]$screenCaptureBlocked,
    [string]$deviceSharingAllowed,
    [string]$storageBlockGoogleBackup,
    [string]$storageBlockRemovableStorage,
    [string]$storageRequireDeviceEncryption,
    [string]$storageRequireRemovableStorageEncryption,
    [string]$voiceAssistantBlocked,
    [string]$voiceDialingBlocked,
    [string]$webBrowserBlockPopups,
    [string]$webBrowserBlockAutofill,
    [string]$webBrowserBlockJavaScript,
    [string]$webBrowserBlocked,
    [string]$webBrowserCookieSettings,
    [string]$wiFiBlocked,
    ### AFW Settings ###
    [string]$workProfileDataSharingType,
    [string]$workProfileBlockNotificationsWhileDeviceLocked,
    [string]$workProfileDefaultAppPermissionPolicy,
    [string]$workProfileRequirePassword,
    [string]$workProfilePasswordMinimumLength,
    [string]$workProfilePasswordMinutesOfInactivityBeforeScreenTimeout,
    [string]$workProfilePasswordSignInFailureCountBeforeFactoryReset,
    [string]$workProfilePasswordExpirationDays,
    [string]$workProfilePasswordRequiredType,
    [string]$workProfilePasswordPreviousPasswordBlockCount,
    [string]$workProfilePasswordBlockFingerprintUnlock,
    [string]$workProfilePasswordBlockTrustAgents,
    [string]$afwpasswordMinimumLength,
    [string]$afwpasswordMinutesOfInactivityBeforeScreenTimeout,
    [string]$afwpasswordSignInFailureCountBeforeFactoryReset,
    [string]$afwpasswordExpirationDays,
    [string]$afwpasswordRequiredType,
    [string]$afwpasswordPreviousPasswordBlockCount,
    [string]$afwpasswordBlockFingerprintUnlock,
    [string]$afwpasswordBlockTrustAgents,
    ### macOS Settings ###
    [string]$macpasswordMinimumLength,
    [string]$macpasswordBlockSimple,
    [string]$macpasswordMinimumCharacterSetCount,
    [string]$macpasswordMinutesOfInactivityBeforeLock,
    [string]$macpasswordExpirationDays,
    [string]$macpasswordRequiredType,
    [string]$macpasswordPreviousPasswordBlockCount,
    [string]$macpasswordMinutesOfInactivityBeforeScreenTimeout,
    [string]$macpasswordRequired,
    ### IOS Settings ###
    [string]$accountBlockModification,
    [string]$activationLockAllowWhenSupervised,
    [string]$airDropBlocked,
    [string]$airDropForceUnmanagedDropTarget,
    [string]$airPlayForcePairingPasswordForOutgoingRequests,
    [string]$appleWatchBlockPairing,
    [string]$appleWatchForceWristDetection,
    [string]$appleNewsBlocked,
    [string]$appStoreBlockAutomaticDownloads,
    [string]$appStoreBlocked,
    [string]$appStoreBlockInAppPurchases,
    [string]$appStoreBlockUIAppInstallation,
    [string]$appStoreRequirePassword,
    [string]$bluetoothBlockModification,
    [string]$ioscameraBlocked,
    [string]$cellularBlockGlobalBackgroundFetchWhileRoaming,
    [string]$ioscellularBlockDataRoaming,
    [string]$cellularBlockPerAppDataModification,
    [string]$cellularBlockPersonalHotspot,
    [string]$ioscellularBlockVoiceRoaming,
    [string]$certificatesBlockUntrustedTlsCertificates,
    [string]$classroomAppBlockRemoteScreenObservation,
    [string]$classroomAppForceUnpromptedScreenObservation,
    [string]$configurationProfileBlockChanges,
    [string]$definitionLookupBlocked,
    [string]$deviceBlockEnableRestrictions,
    [string]$deviceBlockEraseContentAndSettings,
    [string]$deviceBlockNameModification,
    [string]$diagnosticDataBlockSubmission,
    [string]$diagnosticDataBlockSubmissionModification,
    [string]$documentsBlockManagedDocumentsInUnmanagedApps,
    [string]$documentsBlockUnmanagedDocumentsInManagedApps,
    [string]$enterpriseAppBlockTrust,
    [string]$enterpriseAppBlockTrustModification,
    [string]$faceTimeBlocked,
    [string]$findMyFriendsBlocked,
    [string]$gamingBlockGameCenterFriends,
    [string]$gamingBlockMultiplayer,
    [string]$gameCenterBlocked,
    [string]$hostPairingBlocked,
    [string]$iBooksStoreBlocked,
    [string]$iBooksStoreBlockErotica,
    [string]$iCloudBlockActivityContinuation,
    [string]$iCloudBlockBackup,
    [string]$iCloudBlockDocumentSync,
    [string]$iCloudBlockManagedAppsSync,
    [string]$iCloudBlockPhotoLibrary,
    [string]$iCloudBlockPhotoStreamSync,
    [string]$iCloudBlockSharedPhotoStream,
    [string]$iCloudRequireEncryptedBackup,
    [string]$iTunesBlockExplicitContent,
    [string]$iTunesBlockMusicService,
    [string]$iTunesBlockRadio,
    [string]$keyboardBlockAutoCorrect,
    [string]$keyboardBlockDictation,
    [string]$keyboardBlockPredictive,
    [string]$keyboardBlockShortcuts,
    [string]$keyboardBlockSpellCheck,
    [string]$lockScreenBlockControlCenter,
    [string]$lockScreenBlockNotificationView,
    [string]$lockScreenBlockPassbook,
    [string]$lockScreenBlockTodayView,
    [string]$mediaContentRatingApps,
    [string]$messagesBlocked,
    [string]$notificationsBlockSettingsModification,
    [string]$passcodeBlockFingerprintUnlock,
    [string]$passcodeBlockFingerprintModification,
    [string]$passcodeBlockModification,
    [string]$passcodeBlockSimple,
    [string]$passcodeExpirationDays,
    [string]$passcodeMinimumLength,
    [string]$passcodeMinutesOfInactivityBeforeLock,
    [string]$passcodeMinutesOfInactivityBeforeScreenTimeout,
    [string]$passcodeMinimumCharacterSetCount,
    [string]$passcodePreviousPasscodeBlockCount,
    [string]$passcodeSignInFailureCountBeforeWipe,
    [string]$passcodeRequiredType,
    [string]$passcodeRequired,
    [string]$podcastsBlocked,
    [string]$safariBlockAutofill,
    [string]$safariBlockJavaScript,
    [string]$safariBlockPopups,
    [string]$safariBlocked,
    [string]$safariCookieSettings,
    [string]$safariRequireFraudWarning,
    [string]$iosscreenCaptureBlocked,
    [string]$siriBlocked,
    [string]$siriBlockedWhenLocked,
    [string]$siriBlockUserGeneratedContent,
    [string]$siriRequireProfanityFilter,
    [string]$spotlightBlockInternetResults,
    [string]$iosvoiceDialingBlocked,
    [string]$wallpaperBlockModification,
    [string]$wiFiConnectOnlyToConfiguredNetworks,

    ### Win 10 settings ###
    [string]$winscreenCaptureBlocked,
    [string]$copyPasteBlocked,
    [string]$deviceManagementBlockManualUnenroll,
    [string]$certificatesBlockManualRootCertificateInstallation,
    [string]$wincameraBlocked,
    [string]$oneDriveDisableFileSync,
    [string]$winstorageBlockRemovableStorage,
    [string]$winlocationServicesBlocked,
    [string]$internetSharingBlocked,
    [string]$deviceManagementBlockFactoryResetOnMobile,
    [string]$usbBlocked,
    [string]$antiTheftModeBlocked,
    [string]$cortanaBlocked,
    [string]$voiceRecordingBlocked,
    [string]$settingsBlockEditDeviceName,
    [string]$settingsBlockAddProvisioningPackage,
    [string]$settingsBlockRemoveProvisioningPackage,
    [string]$experienceBlockDeviceDiscovery,
    [string]$experienceBlockTaskSwitcher,
    [string]$experienceBlockErrorDialogWhenNoSIM,
    [string]$winpasswordRequired,
    [string]$winpasswordRequiredType,
    [string]$winpasswordMinimumLength,
    [string]$winpasswordMinutesOfInactivityBeforeScreenTimeout,
    [string]$winpasswordSignInFailureCountBeforeFactoryReset,
    [string]$winpasswordExpirationDays,
    [string]$winpasswordPreviousPasswordBlockCount,
    [string]$winpasswordRequireWhenResumeFromIdleState,
    [string]$winpasswordBlockSimple,
    [string]$storageRequireMobileDeviceEncryption,
    [string]$personalizationDesktopImageUrl,
    [string]$privacyBlockInputPersonalization,
    [string]$privacyAutoAcceptPairingAndConsentPrompts,
    [string]$lockScreenBlockActionCenterNotifications,
    [string]$personalizationLockScreenImageUrl,
    [string]$lockScreenAllowTimeoutConfiguration,
    [string]$lockScreenBlockCortana,
    [string]$lockScreenBlockToastNotifications,
    [string]$lockScreenTimeoutInSeconds,
    [string]$windowsStoreBlocked,
    [string]$windowsStoreBlockAutoUpdate,
    [string]$appsAllowTrustedAppsSideloading,
    [string]$developerUnlockSetting,
    [string]$sharedUserAppDataAllowed,
    [string]$windowsStoreEnablePrivateStoreOnly,
    [string]$appsBlockWindowsStoreOriginatedApps,
    [string]$storageRestrictAppDataToSystemVolume,
    [string]$storageRestrictAppInstallToSystemVolume,
    [string]$gameDvrBlocked,
    [string]$smartScreenEnableAppInstallControl,
    [string]$edgeBlocked,
    [string]$edgeBlockAddressBarDropdown,
    [string]$edgeSyncFavoritesWithInternetExplorer,
    [string]$edgeClearBrowsingDataOnExit,
    [string]$edgeBlockSendingDoNotTrackHeader,
    [string]$edgeCookiePolicy,
    [string]$edgeBlockJavaScript,
    [string]$edgeBlockPopups,
    [string]$edgeBlockSearchSuggestions,
    [string]$edgeBlockSendingIntranetTrafficToInternetExplorer,
    [string]$edgeBlockAutofill,
    [string]$edgeBlockPasswordManager,
    [string]$edgeEnterpriseModeSiteListLocation,
    [string]$edgeBlockDeveloperTools,
    [string]$edgeBlockExtensions,
    [string]$edgeBlockInPrivateBrowsing,
    [string]$edgeDisableFirstRunPage,
    [string]$edgeFirstRunUrl,
    [string]$edgeAllowStartPagesModification,
    [string]$edgeBlockAccessToAboutFlags,
    [string]$webRtcBlockLocalhostIpAddress,
    [string]$edgeSearchEngine,
    [string]$edgeCustomURL,
    [string]$edgeBlockCompatibilityList,
    [string]$edgeBlockLiveTileDataCollection,
    [string]$edgeRequireSmartScreen,
    [string]$smartScreenBlockPromptOverride,
    [string]$smartScreenBlockPromptOverrideForFiles,
    [string]$safeSearchFilter,
    [string]$microsoftAccountBlocked,
    [string]$accountsBlockAddingNonMicrosoftAccountEmail,
    [string]$microsoftAccountBlockSettingsSync,
    [string]$cellularData,
    [string]$cellularBlockDataWhenRoaming,
    [string]$cellularBlockVpn,
    [string]$cellularBlockVpnWhenRoaming,
    [string]$winbluetoothBlocked,
    [string]$bluetoothBlockDiscoverableMode,
    [string]$bluetoothBlockPrePairing,
    [string]$bluetoothBlockAdvertising,
    [string]$connectedDevicesServiceBlocked,
    [string]$winnfcBlocked,
    [string]$winwiFiBlocked,
    [string]$wiFiBlockAutomaticConnectHotspots,
    [string]$wiFiBlockManualConfiguration,
    [string]$wiFiScanInterval,
    [string]$settingsBlockSettingsApp,
    [string]$settingsBlockSystemPage,
    [string]$settingsBlockChangePowerSleep,
    [string]$settingsBlockDevicesPage,
    [string]$settingsBlockNetworkInternetPage,
    [string]$settingsBlockPersonalizationPage,
    [string]$settingsBlockAppsPage,
    [string]$settingsBlockAccountsPage,
    [string]$settingsBlockTimeLanguagePage,
    [string]$settingsBlockChangeSystemTime,
    [string]$settingsBlockChangeRegion,
    [string]$settingsBlockChangeLanguage,
    [string]$settingsBlockGamingPage,
    [string]$settingsBlockEaseOfAccessPage,
    [string]$settingsBlockPrivacyPage,
    [string]$settingsBlockUpdateSecurityPage,
    [string]$defenderRequireRealTimeMonitoring,
    [string]$defenderRequireBehaviorMonitoring,
    [string]$defenderRequireNetworkInspectionSystem,
    [string]$defenderScanDownloads,
    [string]$defenderScanScriptsLoadedInInternetExplorer,
    [string]$defenderBlockEndUserAccess,
    [string]$defenderSignatureUpdateIntervalInHours,
    [string]$defenderMonitorFileActivity,
    [string]$defenderDaysBeforeDeletingQuarantinedMalware,
    [string]$defenderScanMaxCpu,
    [string]$defenderScanArchiveFiles,
    [string]$defenderScanIncomingMail,
    [string]$defenderScanRemovableDrivesDuringFullScan,
    [string]$defenderScanMappedNetworkDrivesDuringFullScan,
    [string]$defenderScanNetworkFiles,
    [string]$defenderRequireCloudProtection,
    [string]$defenderPromptForSampleSubmission,
    [string]$defenderScheduledQuickScanTime,
    [string]$defenderScanType,
    [string]$defenderSystemScanSchedule,
    [string]$defenderScheduledScanTime,
    [string]$defenderPotentiallyUnwantedAppAction,
    [string]$defenderDetectedMalwareActions,
    [string]$defenderlowseverity,
    [string]$defendermoderateseverity,
    [string]$defenderhighseverity,
    [string]$defendersevereseverity,
    [string]$startBlockUnpinningAppsFromTaskbar,
    [string]$logonBlockFastUserSwitching,
    [string]$startMenuHideFrequentlyUsedApps,
    [string]$startMenuHideRecentlyAddedApps,
    [string]$startMenuMode,
    [string]$startMenuHideRecentJumpLists,
    [string]$startMenuAppListVisibility,
    [string]$startMenuHidePowerButton,
    [string]$startMenuHideUserTile,
    [string]$startMenuHideLock,
    [string]$startMenuHideSignOut,
    [string]$startMenuHideShutDown,
    [string]$startMenuHideSleep,
    [string]$startMenuHideHibernate,
    [string]$startMenuHideSwitchAccount,
    [string]$startMenuHideRestartOptions,
    [string]$startMenuPinnedFolderDocuments,
    [string]$startMenuPinnedFolderDownloads,
    [string]$startMenuPinnedFolderFileExplorer,
    [string]$startMenuPinnedFolderHomeGroup,
    [string]$startMenuPinnedFolderMusic,
    [string]$startMenuPinnedFolderNetwork,
    [string]$startMenuPinnedFolderPersonalFolder,
    [string]$startMenuPinnedFolderPictures,
    [string]$startMenuPinnedFolderSettings,
    [string]$startMenuPinnedFolderVideos
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization -GraphAPI

if ($Platform -eq "Android") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        appsBlockClipboardSharing = $appsBlockClipboardSharing.ToLower()
        appsBlockCopyPaste = $appsBlockCopyPaste.ToLower()
        appsBlockYouTube = $appsBlockYouTube.ToLower()
        bluetoothBlocked = $BlueToothBlocked.ToLower()
        cameraBlocked = $CameraBlocked.ToLower()
        cellularBlockDataRoaming = $cellularBlockDataRoaming.ToLower()
        cellularBlockMessaging = $cellularBlockMessaging.ToLower()
        cellularBlockVoiceRoaming = $cellularBlockVoiceRoaming.ToLower()
        cellularBlockWiFiTethering = $cellularBlockWiFiTethering.ToLower()
        locationServicesBlocked = $locationServicesBlocked.ToLower()
        googleAccountBlockAutoSync = $googleAccountBlockAutoSync.ToLower()
        googlePlayStoreBlocked = $googlePlayStoreBlocked.ToLower()
        nfcBlocked = $NFCBlocked.ToLower()
        passwordBlockFingerprintUnlock = $passwordBlockFingerprintUnlock.ToLower()
        passwordBlockTrustAgents = $passwordBlockTrustAgents.ToLower()
        passwordExpirationDays = $passwordExpirationDays.ToLower()
        passwordMinimumLength = $passwordMinimumLength.ToLower()
        passwordMinutesOfInactivityBeforeScreenTimeout = $passwordMinutesOfInactivityBeforeScreenTimeout.ToLower()
        passwordPreviousPasswordBlockCount = $passwordPreviousPasswordBlockCount.ToLower()
        passwordSignInFailureCountBeforeFactoryReset = $passwordSignInFailureCountBeforeFactoryReset.ToLower()
        passwordRequiredType = $passwordRequiredType.ToLower()
        passwordRequired = $passwordRequired.ToLower()
        powerOffBlocked = $powerOffBlocked.ToLower()
        factoryResetBlocked = $factoryResetBlocked.ToLower()
        screenCaptureBlocked = $screenCaptureBlocked.ToLower()
        deviceSharingAllowed = $deviceSharingAllowed.ToLower()
        storageBlockGoogleBackup = $storageBlockGoogleBackup.ToLower()
        storageBlockRemovableStorage = $storageBlockRemovableStorage.ToLower()
        storageRequireDeviceEncryption = $storageRequireDeviceEncryption.ToLower()
        storageRequireRemovableStorageEncryption = $storageRequireRemovableStorageEncryption.ToLower()
        voiceAssistantBlocked = $voiceAssistantBlocked.ToLower()
        voiceDialingBlocked = $voiceDialingBlocked.ToLower()
        webBrowserBlockPopups = $webBrowserBlockPopups.ToLower()
        webBrowserBlockAutofill = $webBrowserBlockAutofill.ToLower()
        webBrowserBlockJavaScript = $webBrowserBlockJavaScript.ToLower()
        webBrowserBlocked = $webBrowserBlocked.ToLower()
        webBrowserCookieSettings = $webBrowserCookieSettings.ToLower()
        wiFiBlocked = $wiFiBlocked.ToLower()
    }
}
if ($Platform -eq "AFW") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        workProfileDataSharingType = $workProfileDataSharingType
        workProfileBlockNotificationsWhileDeviceLocked = $workProfileBlockNotificationsWhileDeviceLocked
        workProfileDefaultAppPermissionPolicy = $workProfileDefaultAppPermissionPolicy
        workProfileRequirePassword = $workProfileRequirePassword
        workProfilePasswordMinimumLength = $workProfilePasswordMinimumLength
        workProfilePasswordMinutesOfInactivityBeforeScreenTimeout = $workProfilePasswordMinutesOfInactivityBeforeScreenTimeout
        workProfilePasswordSignInFailureCountBeforeFactoryReset = $workProfilePasswordSignInFailureCountBeforeFactoryReset
        workProfilePasswordExpirationDays = $workProfilePasswordExpirationDays
        workProfilePasswordRequiredType = $workProfilePasswordRequiredType
        workProfilePasswordPreviousPasswordBlockCount = $workProfilePasswordPreviousPasswordBlockCount
        workProfilePasswordBlockFingerprintUnlock = $workProfilePasswordBlockFingerprintUnlock
        workProfilePasswordBlockTrustAgents = $workProfilePasswordBlockTrustAgents
        afwpasswordMinimumLength = $afwpasswordMinimumLength
        afwpasswordMinutesOfInactivityBeforeScreenTimeout = $afwpasswordMinutesOfInactivityBeforeScreenTimeout
        afwpasswordSignInFailureCountBeforeFactoryReset = $afwpasswordSignInFailureCountBeforeFactoryReset
        afwpasswordExpirationDays = $afwpasswordExpirationDays
        afwpasswordRequiredType = $afwpasswordRequiredType
        afwpasswordPreviousPasswordBlockCount = $afwpasswordPreviousPasswordBlockCount
        afwpasswordBlockFingerprintUnlock = $afwpasswordBlockFingerprintUnlock
        afwpasswordBlockTrustAgents = $afwpasswordBlockTrustAgents
    }
}
if ($Platform -eq "macOS") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        macpasswordMinimumLength = $macpasswordMinimumLength
        macpasswordBlockSimple = $macpasswordBlockSimple
        macpasswordMinimumCharacterSetCount = $macpasswordMinimumCharacterSetCount
        macpasswordMinutesOfInactivityBeforeLock = $macpasswordMinutesOfInactivityBeforeLock
        macpasswordExpirationDays = $macpasswordExpirationDays
        macpasswordRequiredType = $macpasswordRequiredType
        macpasswordPreviousPasswordBlockCount = $macpasswordPreviousPasswordBlockCount
        macpasswordMinutesOfInactivityBeforeScreenTimeout = $macpasswordMinutesOfInactivityBeforeScreenTimeout
        macpasswordRequired = $macpasswordRequired
    }
}
if ($Platform -eq "Win10") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        winscreenCaptureBlocked = $winscreenCaptureBlocked
        copyPasteBlocked = $copyPasteBlocked
        deviceManagementBlockManualUnenroll = $deviceManagementBlockManualUnenroll
        certificatesBlockManualRootCertificateInstallation = $certificatesBlockManualRootCertificateInstallation
        wincameraBlocked = $wincameraBlocked
        oneDriveDisableFileSync = $oneDriveDisableFileSync
        winstorageBlockRemovableStorage = $winstorageBlockRemovableStorage
        winlocationServicesBlocked = $winlocationServicesBlocked
        internetSharingBlocked = $internetSharingBlocked
        deviceManagementBlockFactoryResetOnMobile = $deviceManagementBlockFactoryResetOnMobile
        usbBlocked = $usbBlocked
        antiTheftModeBlocked = $antiTheftModeBlocked
        cortanaBlocked = $cortanaBlocked
        voiceRecordingBlocked = $voiceRecordingBlocked
        settingsBlockEditDeviceName = $settingsBlockEditDeviceName
        settingsBlockAddProvisioningPackage = $settingsBlockAddProvisioningPackage
        settingsBlockRemoveProvisioningPackage = $settingsBlockRemoveProvisioningPackage
        experienceBlockDeviceDiscovery = $experienceBlockDeviceDiscovery
        experienceBlockTaskSwitcher = $experienceBlockTaskSwitcher
        experienceBlockErrorDialogWhenNoSIM = $experienceBlockErrorDialogWhenNoSIM
        winpasswordRequired = $winpasswordRequired
        winpasswordRequiredType = $winpasswordRequiredType
        winpasswordMinimumLength = $winpasswordMinimumLength
        winpasswordMinutesOfInactivityBeforeScreenTimeout = $winpasswordMinutesOfInactivityBeforeScreenTimeout
        winpasswordSignInFailureCountBeforeFactoryReset = $winpasswordSignInFailureCountBeforeFactoryReset
        winpasswordExpirationDays = $winpasswordExpirationDays
        winpasswordPreviousPasswordBlockCount = $winpasswordPreviousPasswordBlockCount
        winpasswordRequireWhenResumeFromIdleState = $winpasswordRequireWhenResumeFromIdleState
        winpasswordBlockSimple = $winpasswordBlockSimple
        storageRequireMobileDeviceEncryption = $storageRequireMobileDeviceEncryption
        personalizationDesktopImageUrl = $personalizationDesktopImageUrl
        privacyBlockInputPersonalization = $privacyBlockInputPersonalization
        privacyAutoAcceptPairingAndConsentPrompts = $privacyAutoAcceptPairingAndConsentPrompts
        lockScreenBlockActionCenterNotifications = $lockScreenBlockActionCenterNotifications
        personalizationLockScreenImageUrl = $personalizationLockScreenImageUrl
        lockScreenAllowTimeoutConfiguration = $lockScreenAllowTimeoutConfiguration
        lockScreenBlockCortana = $lockScreenBlockCortana
        lockScreenBlockToastNotifications = $lockScreenBlockToastNotifications
        lockScreenTimeoutInSeconds = $lockScreenTimeoutInSeconds
        windowsStoreBlocked = $windowsStoreBlocked
        windowsStoreBlockAutoUpdate = $windowsStoreBlockAutoUpdate
        appsAllowTrustedAppsSideloading = $appsAllowTrustedAppsSideloading
        developerUnlockSetting = $developerUnlockSetting
        sharedUserAppDataAllowed = $sharedUserAppDataAllowed
        windowsStoreEnablePrivateStoreOnly = $windowsStoreEnablePrivateStoreOnly
        appsBlockWindowsStoreOriginatedApps = $appsBlockWindowsStoreOriginatedApps
        storageRestrictAppDataToSystemVolume = $storageRestrictAppDataToSystemVolume
        storageRestrictAppInstallToSystemVolume = $storageRestrictAppInstallToSystemVolume
        gameDvrBlocked = $gameDvrBlocked
        smartScreenEnableAppInstallControl = $smartScreenEnableAppInstallControl
        edgeBlocked = $edgeBlocked
        edgeBlockAddressBarDropdown = $edgeBlockAddressBarDropdown
        edgeSyncFavoritesWithInternetExplorer = $edgeSyncFavoritesWithInternetExplorer
        edgeClearBrowsingDataOnExit = $edgeClearBrowsingDataOnExit
        edgeBlockSendingDoNotTrackHeader = $edgeBlockSendingDoNotTrackHeader
        edgeCookiePolicy = $edgeCookiePolicy
        edgeBlockJavaScript = $edgeBlockJavaScript
        edgeBlockPopups = $edgeBlockPopups
        edgeBlockSearchSuggestions = $edgeBlockSearchSuggestions
        edgeBlockSendingIntranetTrafficToInternetExplorer = $edgeBlockSendingIntranetTrafficToInternetExplorer
        edgeBlockAutofill = $edgeBlockAutofill
        edgeBlockPasswordManager = $edgeBlockPasswordManager
        edgeEnterpriseModeSiteListLocation = $edgeEnterpriseModeSiteListLocation
        edgeBlockDeveloperTools = $edgeBlockDeveloperTools
        edgeBlockExtensions = $edgeBlockExtensions
        edgeBlockInPrivateBrowsing = $edgeBlockInPrivateBrowsing
        edgeDisableFirstRunPage = $edgeDisableFirstRunPage
        edgeFirstRunUrl = $edgeFirstRunUrl
        edgeAllowStartPagesModification = $edgeAllowStartPagesModification
        edgeBlockAccessToAboutFlags = $edgeBlockAccessToAboutFlags
        webRtcBlockLocalhostIpAddress = $webRtcBlockLocalhostIpAddress
        edgeSearchEngine = $edgeSearchEngine
        edgeCustomURL = $edgeCustomURL
        edgeBlockCompatibilityList = $edgeBlockCompatibilityList
        edgeBlockLiveTileDataCollection = $edgeBlockLiveTileDataCollection
        edgeRequireSmartScreen = $edgeRequireSmartScreen
        smartScreenBlockPromptOverride = $smartScreenBlockPromptOverride
        smartScreenBlockPromptOverrideForFiles = $smartScreenBlockPromptOverrideForFiles
        safeSearchFilter = $safeSearchFilter
        microsoftAccountBlocked = $microsoftAccountBlocked
        accountsBlockAddingNonMicrosoftAccountEmail = $accountsBlockAddingNonMicrosoftAccountEmail
        microsoftAccountBlockSettingsSync = $microsoftAccountBlockSettingsSync
        cellularData = $cellularData
        cellularBlockDataWhenRoaming = $cellularBlockDataWhenRoaming
        cellularBlockVpn = $cellularBlockVpn
        cellularBlockVpnWhenRoaming = $cellularBlockVpnWhenRoaming
        winbluetoothBlocked = $microsoftAccountBlockSettingsSync
        bluetoothBlockDiscoverableMode = $bluetoothBlockDiscoverableMode
        bluetoothBlockPrePairing = $bluetoothBlockPrePairing
        bluetoothBlockAdvertising = $bluetoothBlockAdvertising
        connectedDevicesServiceBlocked = $connectedDevicesServiceBlocked
        winnfcBlocked = $winnfcBlocked
        winwiFiBlocked = $winwiFiBlocked
        wiFiBlockAutomaticConnectHotspots = $wiFiBlockAutomaticConnectHotspots
        wiFiBlockManualConfiguration = $wiFiBlockManualConfiguration
        wiFiScanInterval = $wiFiScanInterval
        settingsBlockSettingsApp = $settingsBlockSettingsApp
        settingsBlockSystemPage = $settingsBlockSystemPage
        settingsBlockChangePowerSleep = $settingsBlockChangePowerSleep
        settingsBlockDevicesPage = $settingsBlockDevicesPage
        settingsBlockNetworkInternetPage = $settingsBlockNetworkInternetPage
        settingsBlockPersonalizationPage = $settingsBlockPersonalizationPage
        settingsBlockAppsPage = $settingsBlockAppsPage
        settingsBlockAccountsPage = $settingsBlockAccountsPage
        settingsBlockTimeLanguagePage = $settingsBlockTimeLanguagePage
        settingsBlockChangeSystemTime = $settingsBlockChangeSystemTime
        settingsBlockChangeRegion = $settingsBlockChangeRegion
        settingsBlockChangeLanguage = $settingsBlockChangeLanguage
        settingsBlockGamingPage = $settingsBlockGamingPage
        settingsBlockEaseOfAccessPage = $settingsBlockEaseOfAccessPage
        settingsBlockPrivacyPage = $settingsBlockPrivacyPage
        settingsBlockUpdateSecurityPage = $settingsBlockUpdateSecurityPage
        defenderRequireRealTimeMonitoring = $defenderRequireRealTimeMonitoring
        defenderRequireBehaviorMonitoring = $defenderRequireBehaviorMonitoring
        defenderRequireNetworkInspectionSystem = $defenderRequireNetworkInspectionSystem
        defenderScanDownloads = $defenderScanDownloads
        defenderScanScriptsLoadedInInternetExplorer = $defenderScanScriptsLoadedInInternetExplorer
        defenderBlockEndUserAccess = $defenderBlockEndUserAccess
        defenderSignatureUpdateIntervalInHours = $defenderSignatureUpdateIntervalInHours
        defenderMonitorFileActivity = $defenderMonitorFileActivity
        defenderDaysBeforeDeletingQuarantinedMalware = $defenderDaysBeforeDeletingQuarantinedMalware
        defenderScanMaxCpu = $defenderScanMaxCpu
        defenderScanArchiveFiles = $defenderScanArchiveFiles
        defenderScanIncomingMail = $defenderScanIncomingMail
        defenderScanRemovableDrivesDuringFullScan = $defenderScanRemovableDrivesDuringFullScan
        defenderScanMappedNetworkDrivesDuringFullScan = $defenderScanMappedNetworkDrivesDuringFullScan
        defenderScanNetworkFiles = $defenderScanNetworkFiles
        defenderRequireCloudProtection = $defenderRequireCloudProtection
        defenderPromptForSampleSubmission = $defenderPromptForSampleSubmission
        defenderScheduledQuickScanTime = $defenderScheduledQuickScanTime
        defenderScanType = $defenderScanType
        defenderSystemScanSchedule = $defenderSystemScanSchedule
        defenderScheduledScanTime = $defenderScheduledScanTime
        defenderPotentiallyUnwantedAppAction = $defenderPotentiallyUnwantedAppAction
        defenderDetectedMalwareActions = $defenderDetectedMalwareActions
        defenderlowseverity = $defenderlowseverity
        defendermoderateseverity = $defendermoderateseverity
        defenderhighseverity = $defenderhighseverity
        defendersevereseverity = $defendersevereseverity
        startBlockUnpinningAppsFromTaskbar = $startBlockUnpinningAppsFromTaskbar
        logonBlockFastUserSwitching = $logonBlockFastUserSwitching
        startMenuHideFrequentlyUsedApps = $startMenuHideFrequentlyUsedApps
        startMenuHideRecentlyAddedApps = $startMenuHideRecentlyAddedApps
        startMenuMode = $startMenuMode
        startMenuHideRecentJumpLists = $startMenuHideRecentJumpLists
        startMenuAppListVisibility = $startMenuAppListVisibility
        startMenuHidePowerButton = $startMenuHidePowerButton
        startMenuHideUserTile = $startMenuHideUserTile
        startMenuHideLock = $startMenuHideLock
        startMenuHideSignOut = $startMenuHideSignOut
        startMenuHideShutDown = $startMenuHideShutDown
        startMenuHideSleep = $startMenuHideSleep
        startMenuHideHibernate = $startMenuHideHibernate
        startMenuHideSwitchAccount = $startMenuHideSwitchAccount
        startMenuHideRestartOptions = $startMenuHideRestartOptions
        startMenuPinnedFolderDocuments = $startMenuPinnedFolderDocuments
        startMenuPinnedFolderDownloads = $startMenuPinnedFolderDownloads
        startMenuPinnedFolderFileExplorer = $startMenuPinnedFolderFileExplorer
        startMenuPinnedFolderHomeGroup = $startMenuPinnedFolderHomeGroup
        startMenuPinnedFolderMusic = $startMenuPinnedFolderMusic
        startMenuPinnedFolderNetwork = $startMenuPinnedFolderNetwork
        startMenuPinnedFolderPersonalFolder = $startMenuPinnedFolderPersonalFolder
        startMenuPinnedFolderPictures = $startMenuPinnedFolderPictures
        startMenuPinnedFolderSettings = $startMenuPinnedFolderSettings
        startMenuPinnedFolderVideos = $startMenuPinnedFolderVideos
    }
}
if ($Platform -eq "IOS") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        accountBlockModification = $accountBlockModification
        activationLockAllowWhenSupervised = $activationLockAllowWhenSupervised
        airDropBlocked = $airDropBlocked
        airDropForceUnmanagedDropTarget = $airDropForceUnmanagedDropTarget
        airPlayForcePairingPasswordForOutgoingRequests = $airPlayForcePairingPasswordForOutgoingRequests
        appleWatchBlockPairing = $appleWatchBlockPairing
        appleWatchForceWristDetection = $appleWatchForceWristDetection
        appleNewsBlocked = $appleNewsBlocked
        appStoreBlockAutomaticDownloads = $appStoreBlockAutomaticDownloads
        appStoreBlocked = $appStoreBlocked
        appStoreBlockInAppPurchases = $appStoreBlockInAppPurchases
        appStoreBlockUIAppInstallation = $appStoreBlockUIAppInstallation
        appStoreRequirePassword = $appStoreRequirePassword
        bluetoothBlockModification = $bluetoothBlockModification
        ioscameraBlocked = $ioscameraBlocked
        ioscellularBlockDataRoaming = $ioscellularBlockDataRoaming
        cellularBlockGlobalBackgroundFetchWhileRoaming = $cellularBlockGlobalBackgroundFetchWhileRoaming
        cellularBlockPerAppDataModification = $cellularBlockPerAppDataModification
        cellularBlockPersonalHotspot = $cellularBlockPersonalHotspot
        ioscellularBlockVoiceRoaming = $ioscellularBlockVoiceRoaming
        certificatesBlockUntrustedTlsCertificates = $certificatesBlockUntrustedTlsCertificates
        classroomAppBlockRemoteScreenObservation = $classroomAppBlockRemoteScreenObservation
        classroomAppForceUnpromptedScreenObservation = $classroomAppForceUnpromptedScreenObservation
        configurationProfileBlockChanges = $configurationProfileBlockChanges
        definitionLookupBlocked = $definitionLookupBlocked
        deviceBlockEnableRestrictions = $deviceBlockEnableRestrictions
        deviceBlockEraseContentAndSettings = $deviceBlockEraseContentAndSettings
        deviceBlockNameModification = $deviceBlockNameModification
        diagnosticDataBlockSubmission = $diagnosticDataBlockSubmission
        diagnosticDataBlockSubmissionModification = $diagnosticDataBlockSubmissionModification
        documentsBlockManagedDocumentsInUnmanagedApps = $documentsBlockManagedDocumentsInUnmanagedApps
        documentsBlockUnmanagedDocumentsInManagedApps = $documentsBlockUnmanagedDocumentsInManagedApps
        enterpriseAppBlockTrust = $enterpriseAppBlockTrust
        enterpriseAppBlockTrustModification = $enterpriseAppBlockTrustModification
        faceTimeBlocked = $faceTimeBlocked
        findMyFriendsBlocked = $findMyFriendsBlocked
        gamingBlockGameCenterFriends = $gamingBlockGameCenterFriends
        gamingBlockMultiplayer = $gamingBlockMultiplayer
        gameCenterBlocked = $gameCenterBlocked
        hostPairingBlocked = $hostPairingBlocked
        iBooksStoreBlocked = $iBooksStoreBlocked
        iBooksStoreBlockErotica = $iBooksStoreBlockErotica
        iCloudBlockActivityContinuation = $iCloudBlockActivityContinuation
        iCloudBlockBackup = $iCloudBlockBackup
        iCloudBlockDocumentSync = $iCloudBlockDocumentSync
        iCloudBlockManagedAppsSync = $iCloudBlockManagedAppsSync
        iCloudBlockPhotoLibrary = $iCloudBlockPhotoLibrary
        iCloudBlockPhotoStreamSync = $iCloudBlockPhotoStreamSync
        iCloudBlockSharedPhotoStream = $iCloudBlockSharedPhotoStream
        iCloudRequireEncryptedBackup = $iCloudRequireEncryptedBackup
        iTunesBlockExplicitContent = $iTunesBlockExplicitContent
        iTunesBlockMusicService = $iTunesBlockMusicService
        iTunesBlockRadio = $iTunesBlockRadio
        keyboardBlockAutoCorrect = $keyboardBlockAutoCorrect
        keyboardBlockDictation = $keyboardBlockDictation
        keyboardBlockPredictive = $keyboardBlockPredictive
        keyboardBlockShortcuts = $keyboardBlockShortcuts
        keyboardBlockSpellCheck = $keyboardBlockSpellCheck
        lockScreenBlockControlCenter = $lockScreenBlockControlCenter
        lockScreenBlockNotificationView = $lockScreenBlockNotificationView
        lockScreenBlockPassbook = $lockScreenBlockPassbook
        lockScreenBlockTodayView = $lockScreenBlockTodayView
        mediaContentRatingApps = $mediaContentRatingApps
        messagesBlocked = $messagesBlocked
        notificationsBlockSettingsModification = $notificationsBlockSettingsModification
        passcodeBlockFingerprintUnlock = $passcodeBlockFingerprintUnlock
        passcodeBlockFingerprintModification = $passcodeBlockFingerprintModification
        passcodeBlockModification = $passcodeBlockModification
        passcodeBlockSimple = $passcodeBlockSimple
        passcodeExpirationDays = $passcodeExpirationDays
        passcodeMinimumLength = $passcodeMinimumLength
        passcodeMinutesOfInactivityBeforeLock = $passcodeMinutesOfInactivityBeforeLock
        passcodeMinutesOfInactivityBeforeScreenTimeout = $passcodeMinutesOfInactivityBeforeScreenTimeout
        passcodeMinimumCharacterSetCount = $passcodeMinimumCharacterSetCount
        passcodePreviousPasscodeBlockCount = $passcodePreviousPasscodeBlockCount
        passcodeSignInFailureCountBeforeWipe = $passcodeSignInFailureCountBeforeWipe
        passcodeRequiredType = $passcodeRequiredType
        passcodeRequired = $passcodeRequired
        podcastsBlocked = $podcastsBlocked
        safariBlockAutofill = $safariBlockAutofill
        safariBlockJavaScript = $safariBlockJavaScript
        safariBlockPopups = $safariBlockPopups
        safariBlocked = $safariBlocked
        safariCookieSettings = $safariCookieSettings
        safariRequireFraudWarning = $safariRequireFraudWarning
        iosscreenCaptureBlocked = $iosscreenCaptureBlocked
        siriBlocked = $siriBlocked
        siriBlockedWhenLocked = $siriBlockedWhenLocked
        siriBlockUserGeneratedContent = $siriBlockUserGeneratedContent
        siriRequireProfanityFilter = $siriRequireProfanityFilter
        spotlightBlockInternetResults = $spotlightBlockInternetResults
        iosvoiceDialingBlocked = $iosvoiceDialingBlocked
        wallpaperBlockModification = $wallpaperBlockModification
        wiFiConnectOnlyToConfiguredNetworks = $wiFiConnectOnlyToConfiguredNetworks
    }
}

Set-AzureIntuneDeviceConfiguration @params