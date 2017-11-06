function Set-AzureIntuneDeviceConfiguration {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$true)]
        [string]$ID,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Android", "IOS", "Win10", "AFW", "macOS")]
        [string]$Platform,

        [string]$DisplayName,
        [string]$Description,
        ### Android Settings ###
        [string]$cameraBlocked,
        [string]$cellularBlockDataRoaming,
        [string]$cellularBlockVoiceRoaming,
        [string]$screenCaptureBlocked,
        [string]$voiceDialingBlocked,
        [string]$appsBlockClipboardSharing,
        [string]$appsBlockCopyPaste,
        [string]$appsBlockYouTube,
        [string]$bluetoothBlocked,
        [string]$cellularBlockMessaging,
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
        [string]$deviceSharingAllowed,
        [string]$storageBlockGoogleBackup,
        [string]$storageBlockRemovableStorage,
        [string]$storageRequireDeviceEncryption,
        [string]$storageRequireRemovableStorageEncryption,
        [string]$voiceAssistantBlocked,
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
        ### Win 10 Settings ###
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
        [string]$defenderScanArchiveFiles,
        [string]$defenderScanMaxCpu,
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
    

    Begin {

        $ErrorActionPreference = "Stop"
        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if ($Platform -eq "Android") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if ($Description) {$DeviceConfiguration.description = $Description}
            if ($BlueToothBlocked) {$DeviceConfiguration.bluetoothBlocked = $BlueToothBlocked.ToLower()}
            if ($CameraBlocked) {$DeviceConfiguration.cameraBlocked = $CameraBlocked.ToLower()}
            if ($NFCBlocked) {$DeviceConfiguration.nfcBlocked = $NFCBlocked.ToLower()}
            if ($appsBlockClipboardSharing) {$DeviceConfiguration.appsBlockClipboardSharing = $appsBlockClipboardSharing.ToLower()}
            if ($appsBlockCopyPaste) {$DeviceConfiguration.appsBlockCopyPaste = $appsBlockCopyPaste.ToLower()}
            if ($appsBlockYouTube) {$DeviceConfiguration.appsBlockYouTube = $appsBlockYouTube.ToLower()}
            if ($cellularBlockDataRoaming) {$DeviceConfiguration.cellularBlockDataRoaming = $cellularBlockDataRoaming.ToLower()}
            if ($cellularBlockMessaging) {$DeviceConfiguration.cellularBlockMessaging = $cellularBlockMessaging.ToLower()}
            if ($cellularBlockVoiceRoaming) {$DeviceConfiguration.cellularBlockVoiceRoaming = $cellularBlockVoiceRoaming.ToLower()}
            if ($cellularBlockWiFiTethering) {$DeviceConfiguration.cellularBlockWiFiTethering = $cellularBlockWiFiTethering.ToLower()}
            if ($locationServicesBlocked) {$DeviceConfiguration.locationServicesBlocked = $locationServicesBlocked.ToLower()}
            if ($googleAccountBlockAutoSync) {$DeviceConfiguration.googleAccountBlockAutoSync = $googleAccountBlockAutoSync.ToLower()}
            if ($googlePlayStoreBlocked) {$DeviceConfiguration.googlePlayStoreBlocked = $googlePlayStoreBlocked.ToLower()}
            if ($nfcBlocked) {$DeviceConfiguration.nfcBlocked = $nfcBlocked.ToLower()}
            if ($passwordRequired) {$DeviceConfiguration.passwordRequired = $passwordRequired.ToLower()}
            if ($passwordBlockFingerprintUnlock) {$DeviceConfiguration.passwordBlockFingerprintUnlock = $passwordBlockFingerprintUnlock.ToLower()}
            if ($passwordBlockTrustAgents) {$DeviceConfiguration.passwordBlockTrustAgents = $passwordBlockTrustAgents.ToLower()}
            if (-not $passwordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $passwordExpirationDays}
            if (-not $passwordMinimumLength){$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $passwordMinimumLength}
            if (-not $passwordMinutesOfInactivityBeforeScreenTimeout) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $passwordMinutesOfInactivityBeforeScreenTimeout}
            if (-not $passwordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $passwordPreviousPasswordBlockCount}
            if (-not $passwordSignInFailureCountBeforeFactoryReset) {$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $null}else{$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $passwordSignInFailureCountBeforeFactoryReset}
            if ($passwordRequiredType) {$DeviceConfiguration.passwordRequiredType = $passwordRequiredType}
            if ($powerOffBlocked) {$DeviceConfiguration.powerOffBlocked = $powerOffBlocked.ToLower()}
            if ($factoryResetBlocked) {$DeviceConfiguration.factoryResetBlocked = $factoryResetBlocked.ToLower()}
            if ($screenCaptureBlocked) {$DeviceConfiguration.screenCaptureBlocked = $screenCaptureBlocked.ToLower()}
            if ($deviceSharingAllowed) {$DeviceConfiguration.deviceSharingAllowed = $deviceSharingAllowed.ToLower()}
            if ($storageBlockGoogleBackup) {$DeviceConfiguration.storageBlockGoogleBackup = $storageBlockGoogleBackup.ToLower()}
            if ($storageBlockRemovableStorage) {$DeviceConfiguration.storageBlockRemovableStorage = $storageBlockRemovableStorage.ToLower()}
            if ($storageRequireDeviceEncryption) {$DeviceConfiguration.storageRequireDeviceEncryption = $storageRequireDeviceEncryption.ToLower()}
            if ($storageRequireRemovableStorageEncryption) {$DeviceConfiguration.storageRequireRemovableStorageEncryption = $storageRequireRemovableStorageEncryption.ToLower()}
            if ($voiceAssistantBlocked) {$DeviceConfiguration.voiceAssistantBlocked = $voiceAssistantBlocked.ToLower()}
            if ($voiceDialingBlocked) {$DeviceConfiguration.voiceDialingBlocked = $voiceDialingBlocked.ToLower()}
            if ($webBrowserBlockPopups) {$DeviceConfiguration.webBrowserBlockPopups = $webBrowserBlockPopups.ToLower()}
            if ($webBrowserBlockAutofill) {$DeviceConfiguration.webBrowserBlockAutofill = $webBrowserBlockAutofill.ToLower()}
            if ($webBrowserBlockJavaScript) {$DeviceConfiguration.webBrowserBlockJavaScript = $webBrowserBlockJavaScript.ToLower()}
            if ($webBrowserBlocked) {$DeviceConfiguration.webBrowserBlocked = $webBrowserBlocked.ToLower()}
            if ($webBrowserCookieSettings) {$DeviceConfiguration.webBrowserCookieSettings = $webBrowserCookieSettings.ToLower()}
            if ($wiFiBlocked) {$DeviceConfiguration.wiFiBlocked = $wiFiBlocked.ToLower()}

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "AFW") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if ($Description) {$DeviceConfiguration.description = $Description}
            if ($workProfileDataSharingType) {$DeviceConfiguration.workProfileDataSharingType = $workProfileDataSharingType}
            if ($workProfileBlockNotificationsWhileDeviceLocked) {$DeviceConfiguration.workProfileBlockNotificationsWhileDeviceLocked = $workProfileBlockNotificationsWhileDeviceLocked.ToLower()}
            if ($workProfileDefaultAppPermissionPolicy) {$DeviceConfiguration.workProfileDefaultAppPermissionPolicy = $workProfileDefaultAppPermissionPolicy}
            if ($workProfileRequirePassword) {$DeviceConfiguration.workProfileRequirePassword = $workProfileRequirePassword.ToLower()}

            if (-not $workProfilePasswordMinimumLength) {$DeviceConfiguration.workProfilePasswordMinimumLength = $null}else{$DeviceConfiguration.workProfilePasswordMinimumLength = $workProfilePasswordMinimumLength}
            if (-not $workProfilePasswordMinutesOfInactivityBeforeScreenTimeout){$DeviceConfiguration.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout = $workProfilePasswordMinutesOfInactivityBeforeScreenTimeout}
            if (-not $workProfilePasswordSignInFailureCountBeforeFactoryReset) {$DeviceConfiguration.workProfilePasswordSignInFailureCountBeforeFactoryReset = $null}else{$DeviceConfiguration.workProfilePasswordSignInFailureCountBeforeFactoryReset = $workProfilePasswordSignInFailureCountBeforeFactoryReset}
            if (-not $workProfilePasswordExpirationDays) {$DeviceConfiguration.workProfilePasswordExpirationDays = $null}else{$DeviceConfiguration.workProfilePasswordExpirationDays = $workProfilePasswordExpirationDays}
            if ($workProfilePasswordRequiredType) {$DeviceConfiguration.workProfilePasswordRequiredType = $workProfilePasswordRequiredType}
            if (-not $workProfilePasswordPreviousPasswordBlockCount) {$DeviceConfiguration.workProfilePasswordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.workProfilePasswordPreviousPasswordBlockCount = $workProfilePasswordPreviousPasswordBlockCount}

            if ($workProfilePasswordBlockFingerprintUnlock) {$DeviceConfiguration.workProfilePasswordBlockFingerprintUnlock = $workProfilePasswordBlockFingerprintUnlock.ToLower()}
            if ($workProfilePasswordBlockTrustAgents) {$DeviceConfiguration.workProfilePasswordBlockTrustAgents = $workProfilePasswordBlockTrustAgents.ToLower()}

            if (-not $afwpasswordMinimumLength) {$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $afwpasswordMinimumLength}
            if (-not $afwpasswordMinutesOfInactivityBeforeScreenTimeout){$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $afwpasswordMinutesOfInactivityBeforeScreenTimeout}
            if (-not $afwpasswordSignInFailureCountBeforeFactoryReset) {$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $null}else{$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $afwpasswordSignInFailureCountBeforeFactoryReset}
            if (-not $afwpasswordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $afwpasswordExpirationDays}
            if ($afwpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $afwpasswordRequiredType}
            if (-not $afwpasswordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $afwpasswordPreviousPasswordBlockCount}

            if ($afwpasswordBlockFingerprintUnlock) {$DeviceConfiguration.passwordBlockFingerprintUnlock = $afwpasswordBlockFingerprintUnlock.ToLower()}
            if ($afwpasswordBlockTrustAgents) {$DeviceConfiguration.passwordBlockTrustAgents = $afwpasswordBlockTrustAgents.ToLower()}

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "macOS") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if ($Description) {$DeviceConfiguration.description = $Description}
            if ($macpasswordBlockSimple) {$DeviceConfiguration.passwordBlockSimple = $macpasswordBlockSimple.ToLower()}
            if (-not $macpasswordMinimumLength) {$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $macpasswordMinimumLength}
            if (-not $macpasswordMinimumCharacterSetCount){$DeviceConfiguration.passwordMinimumCharacterSetCount = $null}else{$DeviceConfiguration.passwordMinimumCharacterSetCount = $macpasswordMinimumCharacterSetCount}
            if (-not $macpasswordMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $macpasswordMinutesOfInactivityBeforeLock}
            if (-not $macpasswordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $macpasswordExpirationDays}
            if ($macpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $macpasswordRequiredType}
            if (-not $macpasswordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $macpasswordPreviousPasswordBlockCount}
            if ($macpasswordRequired) {$DeviceConfiguration.passwordRequired = $macpasswordRequired.ToLower()}
            if (-not $macpasswordMinutesOfInactivityBeforeScreenTimeout) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $macpasswordMinutesOfInactivityBeforeScreenTimeout}

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "IOS") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if ($Description) {$DeviceConfiguration.description = $Description}
            if ($accountBlockModification) {$DeviceConfiguration.accountBlockModification = $accountBlockModification.ToLower()}
            if ($activationLockAllowWhenSupervised) {$DeviceConfiguration.activationLockAllowWhenSupervised = $activationLockAllowWhenSupervised.ToLower()}
            if ($airDropBlocked) {$DeviceConfiguration.airDropBlocked = $airDropBlocked.ToLower()}
            if ($airDropForceUnmanagedDropTarget) {$DeviceConfiguration.airDropForceUnmanagedDropTarget = $airDropForceUnmanagedDropTarget.ToLower()}
            if ($airPlayForcePairingPasswordForOutgoingRequests) {$DeviceConfiguration.airPlayForcePairingPasswordForOutgoingRequests = $airPlayForcePairingPasswordForOutgoingRequests.ToLower()}
            if ($appleWatchBlockPairing) {$DeviceConfiguration.appleWatchBlockPairing = $appleWatchBlockPairing.ToLower()}
            if ($appleWatchForceWristDetection) {$DeviceConfiguration.appleWatchForceWristDetection = $appleWatchForceWristDetection.ToLower()}
            if ($appleNewsBlocked) {$DeviceConfiguration.appleNewsBlocked = $appleNewsBlocked.ToLower()}
            if ($appStoreBlockAutomaticDownloads) {$DeviceConfiguration.appStoreBlockAutomaticDownloads = $appStoreBlockAutomaticDownloads.ToLower()}
            if ($appStoreBlocked) {$DeviceConfiguration.appStoreBlocked = $appStoreBlocked.ToLower()}
            if ($appStoreBlockInAppPurchases) {$DeviceConfiguration.appStoreBlockInAppPurchases = $appStoreBlockInAppPurchases.ToLower()}
            if ($appStoreBlockUIAppInstallation) {$DeviceConfiguration.appStoreBlockUIAppInstallation = $appStoreBlockUIAppInstallation.ToLower()}
            if ($appStoreRequirePassword) {$DeviceConfiguration.appStoreRequirePassword = $appStoreRequirePassword.ToLower()}
            if ($bluetoothBlockModification) {$DeviceConfiguration.bluetoothBlockModification = $bluetoothBlockModification.ToLower()}
            if ($ioscameraBlocked) {$DeviceConfiguration.cameraBlocked = $ioscameraBlocked.ToLower()}
            if ($ioscellularBlockDataRoaming) {$DeviceConfiguration.cellularBlockDataRoaming = $ioscellularBlockDataRoaming.ToLower()}
            if ($cellularBlockGlobalBackgroundFetchWhileRoaming) {$DeviceConfiguration.cellularBlockGlobalBackgroundFetchWhileRoaming = $cellularBlockGlobalBackgroundFetchWhileRoaming.ToLower()}
            if ($cellularBlockPerAppDataModification) {$DeviceConfiguration.cellularBlockPerAppDataModification = $cellularBlockPerAppDataModification}
            if ($cellularBlockPersonalHotspot) {$DeviceConfiguration.cellularBlockPersonalHotspot = $cellularBlockPersonalHotspot.ToLower()}
            if ($ioscellularBlockVoiceRoaming) {$DeviceConfiguration.cellularBlockVoiceRoaming = $ioscellularBlockVoiceRoaming.ToLower()}
            if ($certificatesBlockUntrustedTlsCertificates) {$DeviceConfiguration.certificatesBlockUntrustedTlsCertificates = $certificatesBlockUntrustedTlsCertificates.ToLower()}
            if ($classroomAppBlockRemoteScreenObservation) {$DeviceConfiguration.classroomAppBlockRemoteScreenObservation = $classroomAppBlockRemoteScreenObservation.ToLower()}
            if ($classroomAppForceUnpromptedScreenObservation) {$DeviceConfiguration.classroomAppForceUnpromptedScreenObservation = $classroomAppForceUnpromptedScreenObservation.ToLower()}
            if ($configurationProfileBlockChanges) {$DeviceConfiguration.configurationProfileBlockChanges = $configurationProfileBlockChanges.ToLower()}
            if ($definitionLookupBlocked) {$DeviceConfiguration.definitionLookupBlocked = $definitionLookupBlocked.ToLower()}
            if ($deviceBlockEnableRestrictions) {$DeviceConfiguration.deviceBlockEnableRestrictions = $deviceBlockEnableRestrictions.ToLower()}
            if ($deviceBlockEraseContentAndSettings) {$DeviceConfiguration.deviceBlockEraseContentAndSettings = $deviceBlockEraseContentAndSettings.ToLower()}
            if ($deviceBlockNameModification) {$DeviceConfiguration.deviceBlockNameModification = $deviceBlockNameModification.ToLower()}
            if ($diagnosticDataBlockSubmission) {$DeviceConfiguration.diagnosticDataBlockSubmission = $diagnosticDataBlockSubmission.ToLower()}
            if ($diagnosticDataBlockSubmissionModification) {$DeviceConfiguration.diagnosticDataBlockSubmissionModification = $diagnosticDataBlockSubmissionModification.ToLower()}
            if ($documentsBlockManagedDocumentsInUnmanagedApps) {$DeviceConfiguration.documentsBlockManagedDocumentsInUnmanagedApps = $documentsBlockManagedDocumentsInUnmanagedApps.ToLower()}
            if ($documentsBlockUnmanagedDocumentsInManagedApps) {$DeviceConfiguration.documentsBlockUnmanagedDocumentsInManagedApps = $documentsBlockUnmanagedDocumentsInManagedApps.ToLower()}
            if ($enterpriseAppBlockTrust) {$DeviceConfiguration.enterpriseAppBlockTrust = $enterpriseAppBlockTrust.ToLower()}
            if ($enterpriseAppBlockTrustModification) {$DeviceConfiguration.enterpriseAppBlockTrustModification = $enterpriseAppBlockTrustModification.ToLower()}
            if ($faceTimeBlocked) {$DeviceConfiguration.faceTimeBlocked = $faceTimeBlocked.ToLower()}
            if ($findMyFriendsBlocked) {$DeviceConfiguration.findMyFriendsBlocked = $findMyFriendsBlocked.ToLower()}
            if ($gamingBlockGameCenterFriends) {$DeviceConfiguration.gamingBlockGameCenterFriends = $gamingBlockGameCenterFriends.ToLower()}
            if ($gamingBlockMultiplayer) {$DeviceConfiguration.gamingBlockMultiplayer = $gamingBlockMultiplayer.ToLower()}
            if ($gameCenterBlocked) {$DeviceConfiguration.gameCenterBlocked = $gameCenterBlocked.ToLower()}
            if ($hostPairingBlocked) {$DeviceConfiguration.hostPairingBlocked = $hostPairingBlocked.ToLower()}
            if ($iBooksStoreBlocked) {$DeviceConfiguration.iBooksStoreBlocked = $iBooksStoreBlocked.ToLower()}
            if ($iBooksStoreBlockErotica) {$DeviceConfiguration.iBooksStoreBlockErotica = $iBooksStoreBlockErotica.ToLower()}
            if ($iCloudBlockActivityContinuation) {$DeviceConfiguration.iCloudBlockActivityContinuation = $iCloudBlockActivityContinuation.ToLower()}
            if ($iCloudBlockBackup) {$DeviceConfiguration.iCloudBlockBackup = $iCloudBlockBackup.ToLower()}
            if ($iCloudBlockDocumentSync) {$DeviceConfiguration.iCloudBlockDocumentSync = $iCloudBlockDocumentSync.ToLower()}
            if ($iCloudBlockManagedAppsSync) {$DeviceConfiguration.iCloudBlockManagedAppsSync = $iCloudBlockManagedAppsSync.ToLower()}
            if ($iCloudBlockPhotoLibrary) {$DeviceConfiguration.iCloudBlockPhotoLibrary = $iCloudBlockPhotoLibrary.ToLower()}
            if ($iCloudBlockPhotoStreamSync) {$DeviceConfiguration.iCloudBlockPhotoStreamSync = $iCloudBlockPhotoStreamSync.ToLower()}
            if ($iCloudBlockSharedPhotoStream) {$DeviceConfiguration.iCloudBlockSharedPhotoStream = $iCloudBlockSharedPhotoStream.ToLower()}
            if ($iCloudRequireEncryptedBackup) {$DeviceConfiguration.iCloudRequireEncryptedBackup = $iCloudRequireEncryptedBackup.ToLower()}
            if ($iTunesBlockExplicitContent) {$DeviceConfiguration.iTunesBlockExplicitContent = $iTunesBlockExplicitContent.ToLower()}
            if ($iTunesBlockMusicService) {$DeviceConfiguration.iTunesBlockMusicService = $iTunesBlockMusicService.ToLower()}
            if ($iTunesBlockRadio) {$DeviceConfiguration.iTunesBlockRadio = $iTunesBlockRadio.ToLower()}
            if ($keyboardBlockAutoCorrect) {$DeviceConfiguration.keyboardBlockAutoCorrect = $keyboardBlockAutoCorrect.ToLower()}
            if ($keyboardBlockDictation) {$DeviceConfiguration.keyboardBlockDictation = $keyboardBlockDictation.ToLower()}
            if ($keyboardBlockPredictive) {$DeviceConfiguration.keyboardBlockPredictive = $keyboardBlockPredictive.ToLower()}
            if ($keyboardBlockShortcuts) {$DeviceConfiguration.keyboardBlockShortcuts = $keyboardBlockShortcuts.ToLower()}
            if ($keyboardBlockSpellCheck) {$DeviceConfiguration.keyboardBlockSpellCheck = $keyboardBlockSpellCheck.ToLower()}
            if ($lockScreenBlockControlCenter) {$DeviceConfiguration.lockScreenBlockControlCenter = $lockScreenBlockControlCenter.ToLower()}
            if ($lockScreenBlockNotificationView) {$DeviceConfiguration.lockScreenBlockNotificationView = $lockScreenBlockNotificationView.ToLower()}
            if ($lockScreenBlockPassbook) {$DeviceConfiguration.lockScreenBlockPassbook = $lockScreenBlockPassbook.ToLower()}
            if ($lockScreenBlockTodayView) {$DeviceConfiguration.lockScreenBlockTodayView = $lockScreenBlockTodayView.ToLower()}
            if ($mediaContentRatingApps) {$DeviceConfiguration.mediaContentRatingApps = $mediaContentRatingApps}
            if ($messagesBlocked) {$DeviceConfiguration.messagesBlocked = $messagesBlocked.ToLower()}
            if ($notificationsBlockSettingsModification) {$DeviceConfiguration.notificationsBlockSettingsModification = $notificationsBlockSettingsModification.ToLower()}

            if ($passcodeBlockFingerprintUnlock) {$DeviceConfiguration.passcodeBlockFingerprintUnlock = $passcodeBlockFingerprintUnlock.ToLower()}
            if ($passcodeBlockSimple) {$DeviceConfiguration.passcodeBlockSimple = $passcodeBlockSimple.ToLower()}
            if ($passcodeBlockModification) {$DeviceConfiguration.passcodeBlockModification = $passcodeBlockModification.ToLower()}
            if ($passcodeBlockFingerprintModification) {$DeviceConfiguration.passcodeBlockFingerprintModification = $passcodeBlockFingerprintModification.ToLower()}
            if (-not $passcodeExpirationDays) {$DeviceConfiguration.passcodeExpirationDays = $null}else{$DeviceConfiguration.passcodeExpirationDays = $passcodeExpirationDays}
            if (-not $passcodeMinimumLength){$DeviceConfiguration.passcodeMinimumLength = $null}else{$DeviceConfiguration.passcodeMinimumLength = $passcodeMinimumLength}
            if (-not $passcodeMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passcodeMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passcodeMinutesOfInactivityBeforeLock = $passcodeMinutesOfInactivityBeforeLock}
            if (-not $passcodeMinutesOfInactivityBeforeScreenTimeout) {$DeviceConfiguration.passcodeMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.passcodeMinutesOfInactivityBeforeScreenTimeout = $passcodeMinutesOfInactivityBeforeScreenTimeout}
            if (-not $passcodeMinimumCharacterSetCount) {$DeviceConfiguration.passcodeMinimumCharacterSetCount = $null}else{$DeviceConfiguration.passcodeMinimumCharacterSetCount = $passcodeMinimumCharacterSetCount}
            if (-not $passcodePreviousPasscodeBlockCount) {$DeviceConfiguration.passcodePreviousPasscodeBlockCount = $null}else{$DeviceConfiguration.passcodePreviousPasscodeBlockCount = $passcodePreviousPasscodeBlockCount}
            if (-not $passcodeSignInFailureCountBeforeWipe) {$DeviceConfiguration.passcodeSignInFailureCountBeforeWipe = $null}else{$DeviceConfiguration.passcodeSignInFailureCountBeforeWipe = $passcodeSignInFailureCountBeforeWipe}
            if ($passcodeRequiredType) {$DeviceConfiguration.passcodeRequiredType = $passcodeRequiredType}
            if ($passcodeRequired) {$DeviceConfiguration.passcodeRequired = $passcodeRequired.ToLower()}

            if ($podcastsBlocked) {$DeviceConfiguration.podcastsBlocked = $podcastsBlocked.ToLower()}
            if ($safariBlockAutofill) {$DeviceConfiguration.safariBlockAutofill = $safariBlockAutofill.ToLower()}
            if ($safariBlockJavaScript) {$DeviceConfiguration.safariBlockJavaScript = $safariBlockJavaScript.ToLower()}
            if ($safariBlockPopups) {$DeviceConfiguration.safariBlockPopups = $safariBlockPopups.ToLower()}
            if ($safariBlocked) {$DeviceConfiguration.safariBlocked = $safariBlocked.ToLower()}
            if ($safariCookieSettings) {$DeviceConfiguration.safariCookieSettings = $safariCookieSettings}
            if ($safariRequireFraudWarning) {$DeviceConfiguration.safariRequireFraudWarning = $safariRequireFraudWarning.ToLower()}
            if ($iosscreenCaptureBlocked) {$DeviceConfiguration.screenCaptureBlocked = $iosscreenCaptureBlocked.ToLower()}
            if ($siriBlocked) {$DeviceConfiguration.siriBlocked = $siriBlocked.ToLower()}
            if ($siriBlockedWhenLocked) {$DeviceConfiguration.siriBlockedWhenLocked = $siriBlockedWhenLocked.ToLower()}
            if ($siriBlockUserGeneratedContent) {$DeviceConfiguration.siriBlockUserGeneratedContent = $siriBlockUserGeneratedContent.ToLower()}
            if ($siriRequireProfanityFilter) {$DeviceConfiguration.siriRequireProfanityFilter = $siriRequireProfanityFilter.ToLower()}
            if ($spotlightBlockInternetResults) {$DeviceConfiguration.spotlightBlockInternetResults = $spotlightBlockInternetResults.ToLower()}
            if ($iosvoiceDialingBlocked) {$DeviceConfiguration.voiceDialingBlocked = $iosvoiceDialingBlocked.ToLower()}
            if ($wallpaperBlockModification) {$DeviceConfiguration.wallpaperBlockModification = $wallpaperBlockModification.ToLower()}
            if ($wiFiConnectOnlyToConfiguredNetworks) {$DeviceConfiguration.wiFiConnectOnlyToConfiguredNetworks = $wiFiConnectOnlyToConfiguredNetworks.ToLower()}

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "Win10") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if ($Description) {$DeviceConfiguration.description = $Description}
            if ($winscreenCaptureBlocked) {$DeviceConfiguration.screenCaptureBlocked = $winscreenCaptureBlocked.ToLower()}
            if ($copyPasteBlocked) {$DeviceConfiguration.copyPasteBlocked = $copyPasteBlocked.ToLower()}
            if ($deviceManagementBlockManualUnenroll) {$DeviceConfiguration.deviceManagementBlockManualUnenroll = $deviceManagementBlockManualUnenroll.ToLower()}
            if ($certificatesBlockManualRootCertificateInstallation) {$DeviceConfiguration.certificatesBlockManualRootCertificateInstallation = $certificatesBlockManualRootCertificateInstallation.ToLower()}
            if ($wincameraBlocked) {$DeviceConfiguration.cameraBlocked = $wincameraBlocked.ToLower()}
            if ($oneDriveDisableFileSync) {$DeviceConfiguration.oneDriveDisableFileSync = $oneDriveDisableFileSync.ToLower()}
            if ($winstorageBlockRemovableStorage) {$DeviceConfiguration.storageBlockRemovableStorage = $winstorageBlockRemovableStorage.ToLower()}
            if ($winlocationServicesBlocked) {$DeviceConfiguration.locationServicesBlocked = $winlocationServicesBlocked.ToLower()}
            if ($internetSharingBlocked) {$DeviceConfiguration.internetSharingBlocked = $internetSharingBlocked.ToLower()}
            if ($deviceManagementBlockFactoryResetOnMobile) {$DeviceConfiguration.deviceManagementBlockFactoryResetOnMobile = $deviceManagementBlockFactoryResetOnMobile.ToLower()}
            if ($usbBlocked) {$DeviceConfiguration.usbBlocked = $usbBlocked.ToLower()}
            if ($antiTheftModeBlocked) {$DeviceConfiguration.antiTheftModeBlocked = $antiTheftModeBlocked.ToLower()}
            if ($cortanaBlocked) {$DeviceConfiguration.cortanaBlocked = $cortanaBlocked.ToLower()}
            if ($voiceRecordingBlocked) {$DeviceConfiguration.voiceRecordingBlocked = $voiceRecordingBlocked.ToLower()}
            if ($settingsBlockEditDeviceName) {$DeviceConfiguration.settingsBlockEditDeviceName = $settingsBlockEditDeviceName.ToLower()}
            if ($settingsBlockAddProvisioningPackage) {$DeviceConfiguration.settingsBlockAddProvisioningPackage = $settingsBlockAddProvisioningPackage.ToLower()}
            if ($settingsBlockRemoveProvisioningPackage) {$DeviceConfiguration.settingsBlockRemoveProvisioningPackage = $settingsBlockRemoveProvisioningPackage.ToLower()}
            if ($experienceBlockDeviceDiscovery) {$DeviceConfiguration.experienceBlockDeviceDiscovery = $experienceBlockDeviceDiscovery.ToLower()}
            if ($experienceBlockTaskSwitcher) {$DeviceConfiguration.experienceBlockTaskSwitcher = $experienceBlockTaskSwitcher.ToLower()}
            if ($experienceBlockErrorDialogWhenNoSIM) {$DeviceConfiguration.experienceBlockErrorDialogWhenNoSIM = $experienceBlockErrorDialogWhenNoSIM.ToLower()}
            if ($usbBlocked) {$DeviceConfiguration.usbBlocked = $usbBlocked.ToLower()}
            if ($antiTheftModeBlocked) {$DeviceConfiguration.antiTheftModeBlocked = $antiTheftModeBlocked.ToLower()}
            if ($cortanaBlocked) {$DeviceConfiguration.cortanaBlocked = $cortanaBlocked.ToLower()}
            if ($voiceRecordingBlocked) {$DeviceConfiguration.voiceRecordingBlocked = $voiceRecordingBlocked.ToLower()}
            if ($settingsBlockEditDeviceName) {$DeviceConfiguration.settingsBlockEditDeviceName = $settingsBlockEditDeviceName.ToLower()}
            if ($settingsBlockAddProvisioningPackage) {$DeviceConfiguration.settingsBlockAddProvisioningPackage = $settingsBlockAddProvisioningPackage.ToLower()}
            if ($settingsBlockRemoveProvisioningPackage) {$DeviceConfiguration.settingsBlockRemoveProvisioningPackage = $settingsBlockRemoveProvisioningPackage.ToLower()}
            if ($experienceBlockDeviceDiscovery) {$DeviceConfiguration.experienceBlockDeviceDiscovery = $experienceBlockDeviceDiscovery.ToLower()}
            if ($experienceBlockTaskSwitcher) {$DeviceConfiguration.experienceBlockTaskSwitcher = $experienceBlockTaskSwitcher.ToLower()}
            if ($experienceBlockErrorDialogWhenNoSIM) {$DeviceConfiguration.experienceBlockErrorDialogWhenNoSIM = $experienceBlockErrorDialogWhenNoSIM.ToLower()}
            if ($winpasswordRequired) {$DeviceConfiguration.passwordRequired = $winpasswordRequired.ToLower()}
            if ($winpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $winpasswordRequiredType}
            if (-not $winpasswordMinimumLength) {$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $winpasswordMinimumLength}
            if (-not $winpasswordMinutesOfInactivityBeforeScreenTimeout) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeScreenTimeout = $winpasswordMinutesOfInactivityBeforeScreenTimeout}
            if (-not $winpasswordSignInFailureCountBeforeFactoryReset) {$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $null}else{$DeviceConfiguration.passwordSignInFailureCountBeforeFactoryReset = $winpasswordSignInFailureCountBeforeFactoryReset}
            if (-not $winpasswordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $winpasswordExpirationDays}
            if (-not $winpasswordPreviousPasswordBlockCount){$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $winpasswordPreviousPasswordBlockCount}
            if ($winpasswordRequireWhenResumeFromIdleState) {$DeviceConfiguration.passwordRequireWhenResumeFromIdleState = $winpasswordRequireWhenResumeFromIdleState.ToLower()}
            if ($winpasswordBlockSimple) {$DeviceConfiguration.passwordBlockSimple = $winpasswordBlockSimple.ToLower()}
            if ($storageRequireMobileDeviceEncryption) {$DeviceConfiguration.storageRequireMobileDeviceEncryption = $storageRequireMobileDeviceEncryption.ToLower()}
            if (-not $personalizationDesktopImageUrl){$DeviceConfiguration.personalizationDesktopImageUrl = $null}else{$DeviceConfiguration.personalizationDesktopImageUrl = $personalizationDesktopImageUrl}
            if ($privacyBlockInputPersonalization) {$DeviceConfiguration.privacyBlockInputPersonalization = $privacyBlockInputPersonalization.ToLower()}
            if ($privacyAutoAcceptPairingAndConsentPrompts) {$DeviceConfiguration.privacyAutoAcceptPairingAndConsentPrompts = $privacyAutoAcceptPairingAndConsentPrompts.ToLower()}
            if (-not $personalizationLockScreenImageUrl){$DeviceConfiguration.personalizationLockScreenImageUrl = $null}else{$DeviceConfiguration.personalizationLockScreenImageUrl = $personalizationLockScreenImageUrl}
            if ($lockScreenBlockActionCenterNotifications) {$DeviceConfiguration.lockScreenBlockActionCenterNotifications = $lockScreenBlockActionCenterNotifications.ToLower()}
            if ($lockScreenAllowTimeoutConfiguration) {$DeviceConfiguration.lockScreenAllowTimeoutConfiguration = $lockScreenAllowTimeoutConfiguration.ToLower()}
            if ($lockScreenBlockCortana) {$DeviceConfiguration.lockScreenBlockCortana = $lockScreenBlockCortana.ToLower()}
            if ($lockScreenBlockToastNotifications) {$DeviceConfiguration.lockScreenBlockToastNotifications = $lockScreenBlockToastNotifications.ToLower()}
            if (-not $lockScreenTimeoutInSeconds){$DeviceConfiguration.lockScreenTimeoutInSeconds = $null}else{$DeviceConfiguration.lockScreenTimeoutInSeconds = $lockScreenTimeoutInSeconds}
            if ($windowsStoreBlocked) {$DeviceConfiguration.windowsStoreBlocked = $windowsStoreBlocked.ToLower()}
            if ($windowsStoreBlockAutoUpdate) {$DeviceConfiguration.windowsStoreBlockAutoUpdate = $windowsStoreBlockAutoUpdate.ToLower()}
            if ($appsAllowTrustedAppsSideloading) {$DeviceConfiguration.appsAllowTrustedAppsSideloading = $appsAllowTrustedAppsSideloading.ToLower()}
            if ($developerUnlockSetting) {$DeviceConfiguration.developerUnlockSetting = $developerUnlockSetting.ToLower()}
            if ($sharedUserAppDataAllowed) {$DeviceConfiguration.sharedUserAppDataAllowed = $sharedUserAppDataAllowed.ToLower()}
            if ($windowsStoreEnablePrivateStoreOnly) {$DeviceConfiguration.windowsStoreEnablePrivateStoreOnly = $windowsStoreEnablePrivateStoreOnly.ToLower()}
            if ($appsBlockWindowsStoreOriginatedApps) {$DeviceConfiguration.appsBlockWindowsStoreOriginatedApps = $appsBlockWindowsStoreOriginatedApps.ToLower()}
            if ($storageRestrictAppDataToSystemVolume) {$DeviceConfiguration.storageRestrictAppDataToSystemVolume = $storageRestrictAppDataToSystemVolume.ToLower()}
            if ($storageRestrictAppInstallToSystemVolume) {$DeviceConfiguration.storageRestrictAppInstallToSystemVolume = $storageRestrictAppInstallToSystemVolume.ToLower()}
            if ($gameDvrBlocked) {$DeviceConfiguration.gameDvrBlocked = $gameDvrBlocked.ToLower()}
            if ($smartScreenEnableAppInstallControl) {$DeviceConfiguration.smartScreenEnableAppInstallControl = $smartScreenEnableAppInstallControl.ToLower()}
            if ($edgeBlocked) {$DeviceConfiguration.edgeBlocked = $edgeBlocked.ToLower()}
            if ($edgeBlockAddressBarDropdown) {$DeviceConfiguration.edgeBlockAddressBarDropdown = $edgeBlockAddressBarDropdown.ToLower()}
            if ($edgeSyncFavoritesWithInternetExplorer) {$DeviceConfiguration.edgeSyncFavoritesWithInternetExplorer = $edgeSyncFavoritesWithInternetExplorer.ToLower()}
            if ($edgeClearBrowsingDataOnExit) {$DeviceConfiguration.edgeClearBrowsingDataOnExit = $edgeClearBrowsingDataOnExit.ToLower()}
            if ($edgeBlockSendingDoNotTrackHeader) {$DeviceConfiguration.edgeBlockSendingDoNotTrackHeader = $edgeBlockSendingDoNotTrackHeader.ToLower()}
            if ($edgeCookiePolicy) {$DeviceConfiguration.edgeCookiePolicy = $edgeCookiePolicy}
            if ($edgeBlockJavaScript) {$DeviceConfiguration.edgeBlockJavaScript = $edgeBlockJavaScript.ToLower()}
            if ($edgeBlockPopups) {$DeviceConfiguration.edgeBlockPopups = $edgeBlockPopups.ToLower()}
            if ($edgeBlockSearchSuggestions) {$DeviceConfiguration.edgeBlockSearchSuggestions = $edgeBlockSearchSuggestions.ToLower()}
            if ($edgeBlockSendingIntranetTrafficToInternetExplorer) {$DeviceConfiguration.edgeBlockSendingIntranetTrafficToInternetExplorer = $edgeBlockSendingIntranetTrafficToInternetExplorer.ToLower()}
            if ($edgeBlockAutofill) {$DeviceConfiguration.edgeBlockAutofill = $edgeBlockAutofill.ToLower()}
            if ($edgeBlockPasswordManager) {$DeviceConfiguration.edgeBlockPasswordManager = $edgeBlockPasswordManager.ToLower()}
            if (-not $edgeEnterpriseModeSiteListLocation){$DeviceConfiguration.edgeEnterpriseModeSiteListLocation = $null}else{$DeviceConfiguration.edgeEnterpriseModeSiteListLocation = $edgeEnterpriseModeSiteListLocation}
            if ($edgeBlockDeveloperTools) {$DeviceConfiguration.edgeBlockDeveloperTools = $edgeBlockDeveloperTools.ToLower()}
            if ($edgeBlockExtensions) {$DeviceConfiguration.edgeBlockExtensions = $edgeBlockExtensions.ToLower()}
            if ($edgeBlockInPrivateBrowsing) {$DeviceConfiguration.edgeBlockInPrivateBrowsing = $edgeBlockInPrivateBrowsing.ToLower()}
            if ($edgeDisableFirstRunPage) {$DeviceConfiguration.edgeDisableFirstRunPage = $edgeDisableFirstRunPage.ToLower()}
            if (-not $edgeFirstRunUrl){$DeviceConfiguration.edgeFirstRunUrl = $null}else{$DeviceConfiguration.edgeFirstRunUrl = $edgeFirstRunUrl}
            if ($edgeAllowStartPagesModification) {$DeviceConfiguration.edgeAllowStartPagesModification = $edgeAllowStartPagesModification.ToLower()}
            if ($edgeBlockAccessToAboutFlags) {$DeviceConfiguration.edgeBlockAccessToAboutFlags = $edgeBlockAccessToAboutFlags.ToLower()}
            if ($webRtcBlockLocalhostIpAddress) {$DeviceConfiguration.webRtcBlockLocalhostIpAddress = $webRtcBlockLocalhostIpAddress.ToLower()}

            ### Search Engine logic ###
            if (-not $edgeSearchEngine){
                $DeviceConfiguration.edgeSearchEngine = $null
            }
            elseif ($edgeSearchEngine -eq "default") {
                $customSearch = [pscustomobject]@{
                    '@odata.type' = "#microsoft.graph.edgeSearchEngine"
                    edgeSearchEngineType = $edgeSearchEngine
                }
                $DeviceConfiguration.edgeSearchEngine = $customSearch
            }
            elseif ($edgeSearchEngine -eq "bing") {
                $customSearch = [pscustomobject]@{
                    '@odata.type' = "#microsoft.graph.edgeSearchEngine"
                    edgeSearchEngineType = $edgeSearchEngine
                }
                $DeviceConfiguration.edgeSearchEngine = $customSearch
            }
            elseif ($edgeSearchEngine -like "*https://go.microsoft.com/fwlink/?linkid*") {
                $customSearch = [pscustomobject]@{
                    '@odata.type' = "#microsoft.graph.edgeSearchEngineCustom"
                    edgeSearchEngineOpenSearchXmlUrl = $edgeSearchEngine
                }
                $DeviceConfiguration.edgeSearchEngine = $customSearch
            }
            elseif ($edgeSearchEngine -eq "Custom") {
                $customSearch = [pscustomobject]@{
                    '@odata.type' = "#microsoft.graph.edgeSearchEngineCustom"
                    edgeSearchEngineOpenSearchXmlUrl = $edgeCustomURL
                }
                $DeviceConfiguration.edgeSearchEngine = $customSearch
            }
            ### Search Engine logic END ###

            if ($edgeBlockCompatibilityList) {$DeviceConfiguration.edgeBlockCompatibilityList = $edgeBlockCompatibilityList.ToLower()}
            if ($edgeBlockLiveTileDataCollection) {$DeviceConfiguration.edgeBlockLiveTileDataCollection = $edgeBlockLiveTileDataCollection.ToLower()}
            if ($edgeRequireSmartScreen) {$DeviceConfiguration.edgeRequireSmartScreen = $edgeRequireSmartScreen.ToLower()}
            if ($smartScreenBlockPromptOverride) {$DeviceConfiguration.smartScreenBlockPromptOverride = $smartScreenBlockPromptOverride.ToLower()}
            if ($smartScreenBlockPromptOverrideForFiles) {$DeviceConfiguration.smartScreenBlockPromptOverrideForFiles = $smartScreenBlockPromptOverrideForFiles.ToLower()}
            if ($safeSearchFilter) {$DeviceConfiguration.safeSearchFilter = $safeSearchFilter.ToLower()}
            if ($microsoftAccountBlocked) {$DeviceConfiguration.microsoftAccountBlocked = $microsoftAccountBlocked.ToLower()}
            if ($accountsBlockAddingNonMicrosoftAccountEmail) {$DeviceConfiguration.accountsBlockAddingNonMicrosoftAccountEmail = $accountsBlockAddingNonMicrosoftAccountEmail.ToLower()}
            if ($microsoftAccountBlockSettingsSync) {$DeviceConfiguration.microsoftAccountBlockSettingsSync = $microsoftAccountBlockSettingsSync.ToLower()}
            if ($cellularData) {$DeviceConfiguration.cellularData = $cellularData.ToLower()}
            if ($cellularBlockDataWhenRoaming) {$DeviceConfiguration.cellularBlockDataWhenRoaming = $cellularBlockDataWhenRoaming.ToLower()}
            if ($cellularBlockVpn) {$DeviceConfiguration.cellularBlockVpn = $cellularBlockVpn.ToLower()}
            if ($cellularBlockVpnWhenRoaming) {$DeviceConfiguration.cellularBlockVpnWhenRoaming = $cellularBlockVpnWhenRoaming.ToLower()}
            if ($winbluetoothBlocked) {$DeviceConfiguration.bluetoothBlocked = $winbluetoothBlocked.ToLower()}
            if ($bluetoothBlockDiscoverableMode) {$DeviceConfiguration.bluetoothBlockDiscoverableMode = $bluetoothBlockDiscoverableMode.ToLower()}
            if ($bluetoothBlockPrePairing) {$DeviceConfiguration.bluetoothBlockPrePairing = $bluetoothBlockPrePairing.ToLower()}
            if ($bluetoothBlockAdvertising) {$DeviceConfiguration.bluetoothBlockAdvertising = $bluetoothBlockAdvertising.ToLower()}
            if ($connectedDevicesServiceBlocked) {$DeviceConfiguration.connectedDevicesServiceBlocked = $connectedDevicesServiceBlocked.ToLower()}
            if ($winnfcBlocked) {$DeviceConfiguration.nfcBlocked = $winnfcBlocked.ToLower()}
            if ($winwiFiBlocked) {$DeviceConfiguration.wiFiBlocked = $winwiFiBlocked.ToLower()}
            if ($wiFiBlockAutomaticConnectHotspots) {$DeviceConfiguration.wiFiBlockAutomaticConnectHotspots = $wiFiBlockAutomaticConnectHotspots.ToLower()}
            if ($wiFiBlockManualConfiguration) {$DeviceConfiguration.wiFiBlockManualConfiguration = $wiFiBlockManualConfiguration.ToLower()}
            if (-not $wiFiScanInterval){$DeviceConfiguration.wiFiScanInterval = $null}else{$DeviceConfiguration.wiFiScanInterval = "$($wiFiScanInterval.ToString())"}
            if ($settingsBlockSettingsApp) {$DeviceConfiguration.settingsBlockSettingsApp = $settingsBlockSettingsApp.ToLower()}
            if ($settingsBlockSystemPage) {$DeviceConfiguration.settingsBlockSystemPage = $settingsBlockSystemPage.ToLower()}
            if ($settingsBlockChangePowerSleep) {$DeviceConfiguration.settingsBlockChangePowerSleep = $settingsBlockChangePowerSleep.ToLower()}
            if ($settingsBlockDevicesPage) {$DeviceConfiguration.settingsBlockDevicesPage = $settingsBlockDevicesPage.ToLower()}
            if ($settingsBlockNetworkInternetPage) {$DeviceConfiguration.settingsBlockNetworkInternetPage = $settingsBlockNetworkInternetPage.ToLower()}
            if ($settingsBlockPersonalizationPage) {$DeviceConfiguration.settingsBlockPersonalizationPage = $settingsBlockPersonalizationPage.ToLower()}
            if ($settingsBlockAppsPage) {$DeviceConfiguration.settingsBlockAppsPage = $settingsBlockAppsPage.ToLower()}
            if ($settingsBlockAccountsPage) {$DeviceConfiguration.settingsBlockAccountsPage = $settingsBlockAccountsPage.ToLower()}
            if ($settingsBlockTimeLanguagePage) {$DeviceConfiguration.settingsBlockTimeLanguagePage = $settingsBlockTimeLanguagePage.ToLower()}
            if ($settingsBlockChangeSystemTime) {$DeviceConfiguration.settingsBlockChangeSystemTime = $settingsBlockChangeSystemTime.ToLower()}
            if ($settingsBlockChangeRegion) {$DeviceConfiguration.settingsBlockChangeRegion = $settingsBlockChangeRegion.ToLower()}
            if ($settingsBlockChangeLanguage) {$DeviceConfiguration.settingsBlockChangeLanguage = $settingsBlockChangeLanguage.ToLower()}
            if ($settingsBlockGamingPage) {$DeviceConfiguration.settingsBlockGamingPage = $settingsBlockGamingPage.ToLower()}
            if ($settingsBlockEaseOfAccessPage) {$DeviceConfiguration.settingsBlockEaseOfAccessPage = $settingsBlockEaseOfAccessPage.ToLower()}
            if ($settingsBlockPrivacyPage) {$DeviceConfiguration.settingsBlockPrivacyPage = $settingsBlockPrivacyPage.ToLower()}
            if ($settingsBlockUpdateSecurityPage) {$DeviceConfiguration.settingsBlockUpdateSecurityPage = $settingsBlockUpdateSecurityPage.ToLower()}
            if ($defenderRequireRealTimeMonitoring) {$DeviceConfiguration.defenderRequireRealTimeMonitoring = $defenderRequireRealTimeMonitoring.ToLower()}
            if ($defenderRequireBehaviorMonitoring) {$DeviceConfiguration.defenderRequireBehaviorMonitoring = $defenderRequireBehaviorMonitoring.ToLower()}
            if ($defenderRequireNetworkInspectionSystem) {$DeviceConfiguration.defenderRequireNetworkInspectionSystem = $defenderRequireNetworkInspectionSystem.ToLower()}
            if ($defenderScanDownloads) {$DeviceConfiguration.defenderScanDownloads = $defenderScanDownloads.ToLower()}
            if ($defenderScanScriptsLoadedInInternetExplorer) {$DeviceConfiguration.defenderScanScriptsLoadedInInternetExplorer = $defenderScanScriptsLoadedInInternetExplorer.ToLower()}
            if ($defenderBlockEndUserAccess) {$DeviceConfiguration.defenderBlockEndUserAccess = $defenderBlockEndUserAccess.ToLower()}
            if (-not $defenderSignatureUpdateIntervalInHours){$DeviceConfiguration.defenderSignatureUpdateIntervalInHours = $null}else{$DeviceConfiguration.defenderSignatureUpdateIntervalInHours = $defenderSignatureUpdateIntervalInHours}
            if ($defenderMonitorFileActivity) {$DeviceConfiguration.defenderMonitorFileActivity = $defenderMonitorFileActivity.ToLower()}
            if (-not $defenderDaysBeforeDeletingQuarantinedMalware){$DeviceConfiguration.defenderDaysBeforeDeletingQuarantinedMalware = $null}else{$DeviceConfiguration.defenderDaysBeforeDeletingQuarantinedMalware = $defenderDaysBeforeDeletingQuarantinedMalware}
            if (-not $defenderScanMaxCpu){$DeviceConfiguration.defenderScanMaxCpu = $null}else{$DeviceConfiguration.defenderScanMaxCpu = $defenderScanMaxCpu}
            if ($defenderScanArchiveFiles) {$DeviceConfiguration.defenderScanArchiveFiles = $defenderScanArchiveFiles.ToLower()}
            if ($defenderScanIncomingMail) {$DeviceConfiguration.defenderScanIncomingMail = $defenderScanIncomingMail.ToLower()}
            if ($defenderScanRemovableDrivesDuringFullScan) {$DeviceConfiguration.defenderScanRemovableDrivesDuringFullScan = $defenderScanRemovableDrivesDuringFullScan.ToLower()}
            if ($defenderScanMappedNetworkDrivesDuringFullScan) {$DeviceConfiguration.defenderScanMappedNetworkDrivesDuringFullScan = $defenderScanMappedNetworkDrivesDuringFullScan.ToLower()}
            if ($defenderScanNetworkFiles) {$DeviceConfiguration.defenderScanNetworkFiles = $defenderScanNetworkFiles.ToLower()}
            if ($defenderRequireCloudProtection) {$DeviceConfiguration.defenderRequireCloudProtection = $defenderRequireCloudProtection.ToLower()}
            if ($defenderPromptForSampleSubmission) {$DeviceConfiguration.defenderPromptForSampleSubmission = $defenderPromptForSampleSubmission.ToLower()}
            if (-not $defenderScheduledQuickScanTime){$DeviceConfiguration.defenderScheduledQuickScanTime = $null}else{$DeviceConfiguration.defenderScheduledQuickScanTime = $defenderScheduledQuickScanTime}
            if ($defenderScanType) {$DeviceConfiguration.defenderScanType = $defenderScanType}
            if ($defenderSystemScanSchedule) {$DeviceConfiguration.defenderSystemScanSchedule = $defenderSystemScanSchedule}
            if ($defenderScheduledScanTime) {$DeviceConfiguration.defenderScheduledScanTime = $defenderScheduledScanTime}
            if ($defenderPotentiallyUnwantedAppAction) {$DeviceConfiguration.defenderPotentiallyUnwantedAppAction = $defenderPotentiallyUnwantedAppAction.ToLower()}

            if (-not $defenderDetectedMalwareActions -or $defenderDetectedMalwareActions -eq "False") {
                $custommalwareactions = [pscustomobject]@{
                    lowSeverity = "deviceDefault"
                    moderateSeverity = "deviceDefault"
                    highSeverity = "deviceDefault"
                    severeSeverity = "deviceDefault"
                }
                $DeviceConfiguration.defenderDetectedMalwareActions = $custommalwareactions
            }
            else {
                $custommalwareactions = [pscustomobject]@{
                    lowSeverity = $defenderlowseverity
                    moderateSeverity = $defendermoderateseverity
                    highSeverity = $defenderhighseverity
                    severeSeverity = $defendersevereseverity
                }
                $DeviceConfiguration.defenderDetectedMalwareActions = $custommalwareactions
            }

            if ($startBlockUnpinningAppsFromTaskbar) {$DeviceConfiguration.startBlockUnpinningAppsFromTaskbar = $startBlockUnpinningAppsFromTaskbar.ToLower()}
            if ($logonBlockFastUserSwitching) {$DeviceConfiguration.logonBlockFastUserSwitching = $logonBlockFastUserSwitching.ToLower()}
            if ($startMenuHideFrequentlyUsedApps) {$DeviceConfiguration.startMenuHideFrequentlyUsedApps = $startMenuHideFrequentlyUsedApps.ToLower()}
            if ($startMenuHideRecentlyAddedApps) {$DeviceConfiguration.startMenuHideRecentlyAddedApps = $startMenuHideRecentlyAddedApps.ToLower()}
            if ($startMenuMode) {$DeviceConfiguration.startMenuMode = $startMenuMode}
            if ($startMenuHideRecentJumpLists) {$DeviceConfiguration.startMenuHideRecentJumpLists = $startMenuHideRecentJumpLists.ToLower()}
            if ($startMenuAppListVisibility) {$DeviceConfiguration.startMenuAppListVisibility = $startMenuAppListVisibility}
            if ($startMenuHidePowerButton) {$DeviceConfiguration.startMenuHidePowerButton = $startMenuHidePowerButton.ToLower()}
            if ($startMenuHideUserTile) {$DeviceConfiguration.startMenuHideUserTile = $startMenuHideUserTile.ToLower()}
            if ($startMenuHideLock) {$DeviceConfiguration.startMenuHideLock = $startMenuHideLock.ToLower()}
            if ($startMenuHideSignOut) {$DeviceConfiguration.startMenuHideSignOut = $startMenuHideSignOut.ToLower()}
            if ($startMenuHideShutDown) {$DeviceConfiguration.startMenuHideShutDown = $startMenuHideShutDown.ToLower()}
            if ($startMenuHideSleep) {$DeviceConfiguration.startMenuHideSleep = $startMenuHideSleep.ToLower()}
            if ($startMenuHideHibernate) {$DeviceConfiguration.startMenuHideHibernate = $startMenuHideHibernate.ToLower()}
            if ($startMenuHideSwitchAccount) {$DeviceConfiguration.startMenuHideSwitchAccount = $startMenuHideSwitchAccount.ToLower()}
            if ($startMenuHideRestartOptions) {$DeviceConfiguration.startMenuHideRestartOptions = $startMenuHideRestartOptions.ToLower()}
            if ($startMenuPinnedFolderDocuments) {$DeviceConfiguration.startMenuPinnedFolderDocuments = $startMenuPinnedFolderDocuments}
            if ($startMenuPinnedFolderDownloads) {$DeviceConfiguration.startMenuPinnedFolderDownloads = $startMenuPinnedFolderDownloads}
            if ($startMenuPinnedFolderFileExplorer) {$DeviceConfiguration.startMenuPinnedFolderFileExplorer = $startMenuPinnedFolderFileExplorer}
            if ($startMenuPinnedFolderHomeGroup) {$DeviceConfiguration.startMenuPinnedFolderHomeGroup = $startMenuPinnedFolderHomeGroup}
            if ($startMenuPinnedFolderMusic) {$DeviceConfiguration.startMenuPinnedFolderMusic = $startMenuPinnedFolderMusic}
            if ($startMenuPinnedFolderNetwork) {$DeviceConfiguration.startMenuPinnedFolderNetwork = $startMenuPinnedFolderNetwork}
            if ($startMenuPinnedFolderPersonalFolder) {$DeviceConfiguration.startMenuPinnedFolderPersonalFolder = $startMenuPinnedFolderPersonalFolder}
            if ($startMenuPinnedFolderPictures) {$DeviceConfiguration.startMenuPinnedFolderPictures = $startMenuPinnedFolderPictures}
            if ($startMenuPinnedFolderSettings) {$DeviceConfiguration.startMenuPinnedFolderSettings = $startMenuPinnedFolderSettings}
            if ($startMenuPinnedFolderVideos) {$DeviceConfiguration.startMenuPinnedFolderVideos = $startMenuPinnedFolderVideos}
            
            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
    }
}