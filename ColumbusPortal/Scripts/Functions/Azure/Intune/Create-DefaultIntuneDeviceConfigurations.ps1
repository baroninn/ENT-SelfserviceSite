function Create-DefaultIntuneDeviceConfigurations {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header
    )
    
    Begin {

        $ErrorActionPreference = "Stop"
        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        try {
            $CurrentConfs = Get-AzureIntuneDeviceConfiguration -Header $Header
            $CurrentUpdateConfs = Get-AzureIntuneDeviceConfiguration -Header $Header -Updates
        }
        catch {
            $CurrentConfs = $null
        }
        ## Android
        $Android = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.androidGeneralDeviceConfiguration"
            'description' = "Columbus standard Android Device Restriction Configuration"
            'displayName' = "CASAndroid"
        }
        $Androidparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Android | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }
        ## Android for Work
        $Androidforwork = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.androidForWorkGeneralDeviceConfiguration"
            'description' = "Columbus standard Android for Work Device Restriction Configuration"
            'displayName' = "CASAndroidforWork"
        }
        $Androidforworkparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Androidforwork | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }
        ## Win10
        $Win10 = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.windows10GeneralConfiguration"
            'description' = "Columbus standard Windows 10 Device Restriction Configuration"
            'displayName' = "CASWin10"
        }
        $Win10params = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Win10 | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }
        ## IOS
        $IOS = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.iosGeneralDeviceConfiguration"
            'description' = "Columbus standard IOS Device Restriction Configuration"
            'displayName' = "CASIOS"
        }
        $IOSparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $IOS | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }
        ## MAC
        $MAC = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.macOSGeneralDeviceConfiguration"
            'description' = "Columbus standard MacOs Device Restriction Configuration"
            'displayName' = "CASMac"
        }
        $MACparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $MAC | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }
        ## Windows 10 Update settings
        $W10Update = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.windowsUpdateForBusinessConfiguration"
            'description' = "Columbus standard Windows 10 Update Configuration"
            'displayName' = "CASW10Update"
            'deliveryOptimizationMode' = "httpWithPeeringNat"
            'prereleaseFeatures' = "settingsOnly"
            'microsoftUpdateServiceAllowed' = $true
            'driversExcluded' = $false
            'qualityUpdatesDeferralPeriodInDays' = 0
            'featureUpdatesDeferralPeriodInDays' = 0
            'businessReadyUpdatesOnly' = "all"
            'previewBuildSetting' = "userDefined"
        }
        $W10Updateparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $W10Update | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceConfigurations"
        }

        
        $iconUrl = "C:\Hosting.png"

        $iconResponse = Invoke-WebRequest "$iconUrl" -UseBasicParsing
        $base64icon = [System.Convert]::ToBase64String($iconResponse.Content)
        $iconExt = ([System.IO.Path]::GetExtension("$iconURL")).replace(".","")
        $iconType = "image/$iconExt"

        ## Intune branding
        $Branding = [pscustomobject]@{
            intuneBrand = [pscustomobject] @{
                'displayName' = "Columbus A/S"
                'contactITName' = "Columbus Support"
                'contactITPhoneNumber' = "+4588326262"
                'contactITEmailAddress' = "support.cis@columbusglobal.com"
                'contactITNotes' = ""
                'privacyUrl' = ""
                'onlineSupportSiteUrl' = ""
                'onlineSupportSiteName' = ""
                'themeColor' = [pscustomobject]@{
                    'r' = "255"
                    'g' = "102"
                    'b' = "0"
                }
                'showLogo' = $true
                lightBackgroundLogo = [pscustomobject]@{
                    'type' = "$iconType`;base"
                    'value' = "$base64icon"
                }
                darkBackgroundLogo = [pscustomobject]@{
                    'type' = "$iconType`;base"
                    'value' = "$base64icon"
                }
                'showNameNextToLogo' = $false
            }
        }
        $Brandingparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Branding | ConvertTo-Json -Compress
            Method = 'PATCH'      
            URI = "$Endpoint/deviceManagement"
        }

        Invoke-RestMethod @Brandingparams > $null
        Write-Output "Branding has been updated to Columbus default..!"

        [int]$updatecount = 0
        if ($CurrentUpdateConfs) {
            if ($CurrentUpdateConfs.DisplayName -notcontains "CASW10Update") {
                Invoke-RestMethod @W10Updateparams > $null
                Write-Output "Windows 10 default Update configuration created"
                $updatecount =+ 1
            }
            if (-not $updatecount -gt 0) {
                Write-Output "All Default Update configurations already created.."
            }
        }
        else {
            Invoke-RestMethod @W10Updateparams > $null
            Write-Output "Windows 10 default Update configuration created"
        }
        [int]$count = 0
        if ($CurrentConfs) {
            if ($CurrentConfs.DisplayName -notcontains "CASWin10") {
                Invoke-RestMethod @Win10params > $null
                Write-Output "Windows 10 default configuration created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASAndroid") {
                Invoke-RestMethod @Androidparams > $null
                Write-Output "Android default configuration created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASAndroidforWork") {
                Invoke-RestMethod @Androidforworkparams > $null
                Write-Output "Android for work default configuration created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASIOS") {
                Invoke-RestMethod @IOSparams > $null
                Write-Output "IOS default configuration created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASMac") {
                Invoke-RestMethod @MACparams > $null
                Write-Output "Mac default configuration created"
                $count =+ 1
            }
            if (-not $count -gt 0) {
                Write-Output "All default configurations already created.."
            }
        }
        else {
            Invoke-RestMethod @Win10params > $null
            Write-Output "Windows 10 default configuration created"
            Invoke-RestMethod @Androidparams > $null
            Write-Output "Android default configuration created"
            Invoke-RestMethod @Androidforworkparams > $null
            Write-Output "Android for work default configuration created"
            Invoke-RestMethod @IOSparams > $null
            Write-Output "IOS default configuration created"
            Invoke-RestMethod @MACparams > $null
            Write-Output "Mac default configuration created"
        }
    }
}