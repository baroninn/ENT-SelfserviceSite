[Cmdletbinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    [Parameter(Mandatory=$true)]
    [string]$ID,
    [string]$DisplayName,
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Android", "AFW", "IOS", "Win10", "macOS")]
    [string]$Platform,

    ### Android Settings ###
    [string]$securityBlockJailbrokenDevices,
    [string]$osMinimumVersion,
    [string]$osMaximumVersion,
    [string]$passwordRequired,
    [string]$passwordMinimumLength,
    [string]$passwordRequiredType,
    [string]$passwordMinutesOfInactivityBeforeLock,
    [string]$passwordPreviousPasswordBlockCount,
    [string]$passwordExpirationDays,
    [string]$storageRequireEncryption,
    [string]$securityPreventInstallAppsFromUnknownSources,
    [string]$securityDisableUsbDebugging,
    [string]$minAndroidSecurityPatchLevel,
    [string]$deviceThreatProtectionRequiredSecurityLevel,
    ### AFW Settings ###
    [string]$afwsecurityBlockJailbrokenDevices,
    [string]$afwdeviceThreatProtectionRequiredSecurityLevel,
    [string]$afwosMinimumVersion,
    [string]$afwosMaximumVersion,
    [string]$afwpasswordRequired,
    [string]$afwpasswordMinimumLength,
    [string]$afwpasswordRequiredType,
    [string]$afwpasswordMinutesOfInactivityBeforeLock,
    [string]$afwpasswordPreviousPasswordBlockCount,
    [string]$afwpasswordExpirationDays,
    [string]$afwstorageRequireEncryption,
    [string]$afwsecurityPreventInstallAppsFromUnknownSources,
    [string]$afwsecurityDisableUsbDebugging,
    [string]$afwminAndroidSecurityPatchLevel,
    ### IOS Settings ###
    [string]$managedEmailProfileRequired,
    [string]$iossecurityBlockJailbrokenDevices,
    [string]$iosdeviceThreatProtectionRequiredSecurityLevel,
    [string]$iososMinimumVersion,
    [string]$iososMaximumVersion,
    [string]$passcodeRequired,
    [string]$passcodeBlockSimple,
    [string]$passcodeMinimumLength,
    [string]$passcodeRequiredType,
    [string]$passcodeMinimumCharacterSetCount,
    [string]$passcodeMinutesOfInactivityBeforeLock,
    [string]$passcodeExpirationDays,
    [string]$passcodePreviousPasscodeBlockCount,
    ### Win 10 Settings ###
    [string]$bitLockerEnabled,
    [string]$secureBootEnabled,
    [string]$codeIntegrityEnabled,
    [string]$winosMinimumVersion,
    [string]$winosMaximumVersion,
    [string]$mobileOsMinimumVersion,
    [string]$mobileOsMaximumVersion,
    [string]$winpasswordRequired,
    [string]$passwordBlockSimple,
    [string]$winpasswordRequiredType,
    [string]$winpasswordMinimumLength,
    [string]$winpasswordMinutesOfInactivityBeforeLock,
    [string]$winpasswordExpirationDays,
    [string]$winpasswordPreviousPasswordBlockCount,
    [string]$winpasswordRequiredToUnlockFromIdle,
    [string]$winstorageRequireEncryption,
    ### macOS Settings ###
    [string]$systemIntegrityProtectionEnabled,
    [string]$macosMinimumVersion,
    [string]$macosMaximumVersion,
    [string]$macpasswordRequired,
    [string]$macpasswordMinimumLength,
    [string]$macpasswordRequiredType,
    [string]$macpasswordMinutesOfInactivityBeforeLock,
    [string]$macpasswordPreviousPasswordBlockCount,
    [string]$macpasswordExpirationDays,
    [string]$macstorageRequireEncryption,
    [string]$macpasswordMinimumCharacterSetCount
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
        securityBlockJailbrokenDevices = $securityBlockJailbrokenDevices
        osMinimumVersion = $osMinimumVersion
        osMaximumVersion = $osMaximumVersion
        passwordRequired = $passwordRequired
        passwordMinimumLength = $passwordMinimumLength
        passwordRequiredType = $passwordRequiredType
        passwordMinutesOfInactivityBeforeLock = $passwordMinutesOfInactivityBeforeLock
        passwordPreviousPasswordBlockCount = $passwordPreviousPasswordBlockCount
        passwordExpirationDays = $passwordExpirationDays
        storageRequireEncryption = $storageRequireEncryption
        securityPreventInstallAppsFromUnknownSources = $securityPreventInstallAppsFromUnknownSources
        securityDisableUsbDebugging = $securityDisableUsbDebugging
        minAndroidSecurityPatchLevel = $minAndroidSecurityPatchLevel
        deviceThreatProtectionRequiredSecurityLevel = $deviceThreatProtectionRequiredSecurityLevel
    }
}
if ($Platform -eq "AFW") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        afwsecurityBlockJailbrokenDevices = $afwsecurityBlockJailbrokenDevices
        afwdeviceThreatProtectionRequiredSecurityLevel = $afwdeviceThreatProtectionRequiredSecurityLevel
        afwosMinimumVersion = $afwosMinimumVersion
        afwosMaximumVersion = $afwosMaximumVersion
        afwpasswordRequired = $afwpasswordRequired
        afwpasswordMinimumLength = $afwpasswordMinimumLength
        afwpasswordRequiredType = $afwpasswordRequiredType
        afwpasswordMinutesOfInactivityBeforeLock = $afwpasswordMinutesOfInactivityBeforeLock
        afwpasswordPreviousPasswordBlockCount = $afwpasswordPreviousPasswordBlockCount
        afwpasswordExpirationDays = $afwpasswordExpirationDays
        afwstorageRequireEncryption = $afwstorageRequireEncryption
        afwsecurityPreventInstallAppsFromUnknownSources = $afwsecurityPreventInstallAppsFromUnknownSources
        afwsecurityDisableUsbDebugging = $afwsecurityDisableUsbDebugging
        afwminAndroidSecurityPatchLevel = $afwminAndroidSecurityPatchLevel
    }
}
if ($Platform -eq "Win10") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        bitLockerEnabled = $bitLockerEnabled
        secureBootEnabled = $secureBootEnabled
        codeIntegrityEnabled = $codeIntegrityEnabled
        winosMinimumVersion = $winosMinimumVersion
        winosMaximumVersion = $winosMaximumVersion
        mobileOsMinimumVersion = $mobileOsMinimumVersion
        mobileOsMaximumVersion = $mobileOsMaximumVersion
        winpasswordRequired = $winpasswordRequired
        passwordBlockSimple = $passwordBlockSimple
        winpasswordRequiredType = $winpasswordRequiredType
        winpasswordMinimumLength = $winpasswordMinimumLength
        winpasswordMinutesOfInactivityBeforeLock = $winpasswordMinutesOfInactivityBeforeLock
        winpasswordExpirationDays = $winpasswordExpirationDays
        winpasswordPreviousPasswordBlockCount = $winpasswordPreviousPasswordBlockCount
        winpasswordRequiredToUnlockFromIdle = $winpasswordRequiredToUnlockFromIdle
        winstorageRequireEncryption = $winstorageRequireEncryption

    }
}
if ($Platform -eq "IOS") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        managedEmailProfileRequired = $managedEmailProfileRequired
        iossecurityBlockJailbrokenDevices = $iossecurityBlockJailbrokenDevices
        iosdeviceThreatProtectionRequiredSecurityLevel = $iosdeviceThreatProtectionRequiredSecurityLevel
        iososMinimumVersion = $iososMinimumVersion
        iososMaximumVersion = $iososMaximumVersion
        passcodeRequired = $passcodeRequired
        passcodeBlockSimple = $passcodeBlockSimple
        passcodeMinimumLength = $passcodeMinimumLength
        passcodeRequiredType = $passcodeRequiredType
        passcodeMinimumCharacterSetCount = $passcodeMinimumCharacterSetCount
        passcodeMinutesOfInactivityBeforeLock = $passcodeMinutesOfInactivityBeforeLock
        passcodeExpirationDays = $passcodeExpirationDays
        passcodePreviousPasscodeBlockCount = $passcodePreviousPasscodeBlockCount

    }
}
if ($Platform -eq "macOS") {
    $params = @{
        Header = $Header
        ID = $ID
        displayName = $DisplayName
        description = $Description
        platform = $Platform
        systemIntegrityProtectionEnabled = $systemIntegrityProtectionEnabled
        macosMinimumVersion = $macosMinimumVersion
        macosMaximumVersion = $macosMaximumVersion
        macpasswordRequired = $macpasswordRequired
        macpasswordMinimumLength = $macpasswordMinimumLength
        macpasswordRequiredType = $macpasswordRequiredType
        macpasswordMinutesOfInactivityBeforeLock = $macpasswordMinutesOfInactivityBeforeLock
        macpasswordPreviousPasswordBlockCount = $macpasswordPreviousPasswordBlockCount
        macpasswordExpirationDays = $macpasswordExpirationDays
        macstorageRequireEncryption = $macstorageRequireEncryption
        macpasswordMinimumCharacterSetCount = $macpasswordMinimumCharacterSetCount
    }
}

Set-AzureIntuneComplianceSetting @params