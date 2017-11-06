function Create-DefaultIntuneComplianceSettings {
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
            $CurrentConfs = Get-AzureIntuneComplianceSetting -Header $Header
        }
        catch {
            $CurrentConfs = $null
        }
        ## Android
        $Android = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.androidCompliancePolicy"
            'description' = "Columbus standard Android Compliance Policy"
            'displayName' = "CASAndroid"
        }
        $Androidparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Android | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceCompliancePolicies"
        }
        ## Android for Work
        $Androidforwork = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.androidForWorkCompliancePolicy"
            'description' = "Columbus standard Android for Work Compliance Policy"
            'displayName' = "CASAndroidforWork"
        }
        $Androidforworkparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Androidforwork | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceCompliancePolicies"
        }
        ## Win10
        $Win10 = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.windows10CompliancePolicy"
            'description' = "Columbus standard Windows 10 Compliance Policy"
            'displayName' = "CASWin10"
        }
        $Win10params = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $Win10 | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceCompliancePolicies"
        }
        ## IOS
        $IOS = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.iosCompliancePolicy"
            'description' = "Columbus standard IOS Compliance Policy"
            'displayName' = "CASIOS"
        }
        $IOSparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $IOS | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceCompliancePolicies"
        }
        ## MAC
        $MAC = [pscustomobject]@{
            '@odata.type' = "#microsoft.graph.macOSCompliancePolicy"
            'description' = "Columbus standard MacOs Compliance Policy"
            'displayName' = "CASMac"
        }
        $MACparams = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $MAC | ConvertTo-Json -Compress
            Method = 'POST'      
            URI = "$Endpoint/deviceManagement/deviceCompliancePolicies"
        }



        [int]$count = 0
        if ($CurrentConfs) {
            if ($CurrentConfs.DisplayName -notcontains "CASWin10") {
                Invoke-RestMethod @Win10params > $null
                Write-Output "Windows 10 default Compliance Policy created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASAndroid") {
                Invoke-RestMethod @Androidparams > $null
                Write-Output "Android default Compliance Policy created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASAndroidforWork") {
                Invoke-RestMethod @Androidforworkparams > $null
                Write-Output "Android for work default Compliance Policy created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASIOS") {
                Invoke-RestMethod @IOSparams > $null
                Write-Output "IOS default Compliance Policy created"
                $count =+ 1
            }
            if ($CurrentConfs.DisplayName -notcontains "CASMac") {
                Invoke-RestMethod @MACparams > $null
                Write-Output "Mac default Compliance Policy created"
                $count =+ 1
            }
            if (-not $count -gt 0) {
                Write-Output "All default Compliance Policy's already created.."
            }
        }
        else {
            Invoke-RestMethod @Win10params > $null
            Write-Output "Windows 10 default Compliance Policy created"
            Invoke-RestMethod @Androidparams > $null
            Write-Output "Android default configuration created"
            Invoke-RestMethod @Androidforworkparams > $null
            Write-Output "Android for work default Compliance Policy created"
            Invoke-RestMethod @IOSparams > $null
            Write-Output "IOS default Compliance Policy created"
            Invoke-RestMethod @MACparams > $null
            Write-Output "Mac default Compliance Policy created"
        }
    }
}