function Set-AzureIntuneComplianceSetting {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$true)]
        [string]$ID,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Android", "AFW", "IOS", "Win10", "macOS")]
        [string]$Platform,

        [string]$DisplayName,
        [string]$Description,
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
    

    Begin {

        $ErrorActionPreference = "Stop"
        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if ($Platform -eq "Android") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if (-not $Description) {$DeviceConfiguration.description = $null}else{$DeviceConfiguration.description = $Description}
            if ($securityBlockJailbrokenDevices) {$DeviceConfiguration.securityBlockJailbrokenDevices = $securityBlockJailbrokenDevices.ToLower()}
            if (-not $osMinimumVersion){$DeviceConfiguration.osMinimumVersion = $null}else{$DeviceConfiguration.osMinimumVersion = $osMinimumVersion}
            if (-not $osMaximumVersion){$DeviceConfiguration.osMaximumVersion = $null}else{$DeviceConfiguration.osMaximumVersion = $osMaximumVersion}
            if ($passwordRequired) {$DeviceConfiguration.passwordRequired = $passwordRequired.ToLower()}
            if (-not $passwordMinimumLength){$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $passwordMinimumLength}
            if ($passwordRequiredType) {$DeviceConfiguration.passwordRequiredType = $passwordRequiredType}
            if (-not $passwordMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $passwordMinutesOfInactivityBeforeLock}
            if (-not $passwordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $passwordPreviousPasswordBlockCount}
            if (-not $passwordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $passwordExpirationDays}
            if ($storageRequireEncryption) {$DeviceConfiguration.storageRequireEncryption = $storageRequireEncryption.ToLower()}
            if ($securityPreventInstallAppsFromUnknownSources) {$DeviceConfiguration.securityPreventInstallAppsFromUnknownSources = $securityPreventInstallAppsFromUnknownSources.ToLower()}
            if ($securityDisableUsbDebugging) {$DeviceConfiguration.securityDisableUsbDebugging = $securityDisableUsbDebugging.ToLower()}
            if (-not $minAndroidSecurityPatchLevel) {$DeviceConfiguration.minAndroidSecurityPatchLevel = $null}else{$DeviceConfiguration.minAndroidSecurityPatchLevel = $minAndroidSecurityPatchLevel}
            if (-not $deviceThreatProtectionRequiredSecurityLevel) {
                $DeviceConfiguration.deviceThreatProtectionEnabled = "false"
                $DeviceConfiguration.deviceThreatProtectionRequiredSecurityLevel = $null
            }
            else{
                $DeviceConfiguration.deviceThreatProtectionEnabled = "true"
                $DeviceConfiguration.deviceThreatProtectionRequiredSecurityLevel = $deviceThreatProtectionRequiredSecurityLevel
            }

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "AFW") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if (-not $Description) {$DeviceConfiguration.description = $null}else{$DeviceConfiguration.description = $Description}
            if ($afwsecurityBlockJailbrokenDevices) {$DeviceConfiguration.securityBlockJailbrokenDevices = $afwsecurityBlockJailbrokenDevices.ToLower()}
            if ($afwdeviceThreatProtectionRequiredSecurityLevel) {$DeviceConfiguration.deviceThreatProtectionRequiredSecurityLevel = $afwdeviceThreatProtectionRequiredSecurityLevel}
            if (-not $afwosMinimumVersion){$DeviceConfiguration.osMinimumVersion = $null}else{$DeviceConfiguration.osMinimumVersion = $afwosMinimumVersion}
            if (-not $afwosMaximumVersion){$DeviceConfiguration.osMaximumVersion = $null}else{$DeviceConfiguration.osMaximumVersion = $afwosMaximumVersion}
            if ($afwpasswordRequired) {$DeviceConfiguration.passwordRequired = $afwpasswordRequired.ToLower()}
            if (-not $afwpasswordMinimumLength){$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $afwpasswordMinimumLength}
            if ($afwpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $afwpasswordRequiredType}
            if (-not $afwpasswordMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $afwpasswordMinutesOfInactivityBeforeLock}
            if (-not $afwpasswordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $afwpasswordPreviousPasswordBlockCount}
            if (-not $afwpasswordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $afwpasswordExpirationDays}
            if ($afwstorageRequireEncryption) {$DeviceConfiguration.storageRequireEncryption = $afwstorageRequireEncryption.ToLower()}
            if ($afwsecurityPreventInstallAppsFromUnknownSources) {$DeviceConfiguration.securityPreventInstallAppsFromUnknownSources = $afwsecurityPreventInstallAppsFromUnknownSources.ToLower()}
            if ($afwsecurityDisableUsbDebugging) {$DeviceConfiguration.securityDisableUsbDebugging = $afwsecurityDisableUsbDebugging.ToLower()}
            if (-not $afwminAndroidSecurityPatchLevel) {
                $DeviceConfiguration.deviceThreatProtectionEnabled = "false"
                $DeviceConfiguration.minAndroidSecurityPatchLevel = $null
            }
            else{
                $DeviceConfiguration.deviceThreatProtectionEnabled = "true"
                $DeviceConfiguration.minAndroidSecurityPatchLevel = $afwminAndroidSecurityPatchLevel
            }

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "IOS") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if (-not $Description) {$DeviceConfiguration.description = $null}else{$DeviceConfiguration.description = $Description}
            if ($managedEmailProfileRequired) {$DeviceConfiguration.managedEmailProfileRequired = $managedEmailProfileRequired}
            if ($iossecurityBlockJailbrokenDevices) {$DeviceConfiguration.securityBlockJailbrokenDevices = $iossecurityBlockJailbrokenDevices}
            if ($iosdeviceThreatProtectionRequiredSecurityLevel) {$DeviceConfiguration.deviceThreatProtectionRequiredSecurityLevel = $iosdeviceThreatProtectionRequiredSecurityLevel}
            if (-not $iososMinimumVersion) {$DeviceConfiguration.osMinimumVersion = $null}else{$DeviceConfiguration.osMinimumVersion = $iososMinimumVersion}
            if (-not $iososMaximumVersion) {$DeviceConfiguration.osMaximumVersion = $null}else{$DeviceConfiguration.osMaximumVersion = $iososMaximumVersion}
            if ($passcodeRequired) {$DeviceConfiguration.passcodeRequired = $passcodeRequired}
            if ($passcodeBlockSimple) {$DeviceConfiguration.passcodeBlockSimple = $passcodeBlockSimple}
            if (-not $passcodeMinimumLength) {$DeviceConfiguration.passcodeMinimumLength = $null}else{$DeviceConfiguration.passcodeMinimumLength = $passcodeMinimumLength}
            if ($passcodeRequiredType) {$DeviceConfiguration.passcodeRequiredType = $passcodeRequiredType}
            if (-not $passcodeMinimumCharacterSetCount) {$DeviceConfiguration.passcodeMinimumCharacterSetCount = $null}else{$DeviceConfiguration.passcodeMinimumCharacterSetCount = $passcodeMinimumCharacterSetCount}
            if (-not $passcodeMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passcodeMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passcodeMinutesOfInactivityBeforeLock = $passcodeMinutesOfInactivityBeforeLock}
            if (-not $passcodeExpirationDays) {$DeviceConfiguration.passcodeExpirationDays = $null}else{$DeviceConfiguration.passcodeExpirationDays = $passcodeExpirationDays}
            if (-not $passcodePreviousPasscodeBlockCount) {$DeviceConfiguration.passcodePreviousPasscodeBlockCount = $null}else{$DeviceConfiguration.passcodePreviousPasscodeBlockCount = $passcodePreviousPasscodeBlockCount}


            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "Win10") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if (-not $Description) {$DeviceConfiguration.description = $null}else{$DeviceConfiguration.description = $Description}
            if ($bitLockerEnabled) {$DeviceConfiguration.bitLockerEnabled = $bitLockerEnabled}
            if ($secureBootEnabled) {$DeviceConfiguration.secureBootEnabled = $secureBootEnabled}
            if ($codeIntegrityEnabled) {$DeviceConfiguration.codeIntegrityEnabled = $codeIntegrityEnabled}
            if (-not $winosMinimumVersion){$DeviceConfiguration.osMinimumVersion = $null}else{$DeviceConfiguration.osMinimumVersion = $winosMinimumVersion}
            if (-not $winosMaximumVersion){$DeviceConfiguration.osMaximumVersion = $null}else{$DeviceConfiguration.osMaximumVersion = $winosMaximumVersion}
            if (-not $mobileOsMinimumVersion){$DeviceConfiguration.mobileOsMinimumVersion = $null}else{$DeviceConfiguration.mobileOsMinimumVersion = $mobileOsMinimumVersion}
            if (-not $mobileOsMaximumVersion){$DeviceConfiguration.mobileOsMaximumVersion = $null}else{$DeviceConfiguration.mobileOsMaximumVersion = $mobileOsMaximumVersion}
            if ($winpasswordRequired) {$DeviceConfiguration.passwordRequired = $winpasswordRequired}
            if ($passwordBlockSimple) {$DeviceConfiguration.passwordBlockSimple = $passwordBlockSimple}
            if ($winpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $winpasswordRequiredType}
            if (-not $winpasswordMinimumLength){$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $winpasswordMinimumLength}
            if (-not $winpasswordMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $winpasswordMinutesOfInactivityBeforeLock}
            if (-not $winpasswordExpirationDays){$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $winpasswordExpirationDays}
            if (-not $winpasswordPreviousPasswordBlockCount){$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $winpasswordPreviousPasswordBlockCount}
            if ($winpasswordRequiredToUnlockFromIdle) {$DeviceConfiguration.passwordRequiredToUnlockFromIdle = $winpasswordRequiredToUnlockFromIdle}
            if ($winstorageRequireEncryption) {$DeviceConfiguration.storageRequireEncryption = $winstorageRequireEncryption}


            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
        if ($Platform -eq "macOS") {

            $DeviceConfiguration = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get

            if ($DisplayName) {$DeviceConfiguration.displayName = $DisplayName}
            if (-not $Description) {$DeviceConfiguration.description = $null}else{$DeviceConfiguration.description = $Description}
            if ($systemIntegrityProtectionEnabled) {$DeviceConfiguration.systemIntegrityProtectionEnabled = $systemIntegrityProtectionEnabled.ToLower()}
            if (-not $macosMinimumVersion){$DeviceConfiguration.osMinimumVersion = $null}else{$DeviceConfiguration.osMinimumVersion = $macosMinimumVersion}
            if (-not $macosMaximumVersion){$DeviceConfiguration.osMaximumVersion = $null}else{$DeviceConfiguration.osMaximumVersion = $macosMaximumVersion}
            if ($macpasswordRequired) {$DeviceConfiguration.passwordRequired = $macpasswordRequired.ToLower()}
            if (-not $macpasswordMinimumLength){$DeviceConfiguration.passwordMinimumLength = $null}else{$DeviceConfiguration.passwordMinimumLength = $macpasswordMinimumLength}
            if ($macpasswordRequiredType) {$DeviceConfiguration.passwordRequiredType = $macpasswordRequiredType}
            if (-not $macpasswordMinutesOfInactivityBeforeLock) {$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $null}else{$DeviceConfiguration.passwordMinutesOfInactivityBeforeLock = $macpasswordMinutesOfInactivityBeforeLock}
            if (-not $macpasswordPreviousPasswordBlockCount) {$DeviceConfiguration.passwordPreviousPasswordBlockCount = $null}else{$DeviceConfiguration.passwordPreviousPasswordBlockCount = $macpasswordPreviousPasswordBlockCount}
            if (-not $macpasswordExpirationDays) {$DeviceConfiguration.passwordExpirationDays = $null}else{$DeviceConfiguration.passwordExpirationDays = $macpasswordExpirationDays}
            if ($macstorageRequireEncryption) {$DeviceConfiguration.storageRequireEncryption = $macstorageRequireEncryption.ToLower()}
            if ($macpasswordMinimumCharacterSetCount) {$DeviceConfiguration.passwordMinimumCharacterSetCount = $macpasswordMinimumCharacterSetCount.ToLower()}

            $body = $DeviceConfiguration | ConvertTo-Json

            Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Patch -Body $body -ContentType 'application/json'
        }
    }
}