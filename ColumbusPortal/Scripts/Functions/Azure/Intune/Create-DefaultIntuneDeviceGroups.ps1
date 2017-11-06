function Create-DefaultIntuneDeviceGroups {
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
            $CurrentGroups = Get-AzureGroup -Header $Header
        }
        catch {
            $CurrentGroups = $null
        }

        $Groups = @()
        $Groups += [pscustomobject]@{
            membershipRule = '(device.deviceOSType -contains "Windows")'
            displayName    = "CASWin10Devices"
            description    = "All Windows 10 Devices"
        }
        $Groups += [pscustomobject]@{
            membershipRule = '(device.deviceOSType -contains "IOS")'
            displayName    = "CASIOSDevices"
            description    = "All IOS Devices"
        }
        $Groups += [pscustomobject]@{
            membershipRule = '(device.deviceOSType -contains "Android")'
            displayName    = "CASAndroidDevices"
            description    = "All Android Devices"
        }
        $Groups += [pscustomobject]@{
            membershipRule = '(device.deviceOSType -contains "macOS")'
            displayName    = "CASmacOSDevices"
            description    = "All macOS Devices"
        }

        $Count = 0;

        foreach ($i in $Groups) {
            if ($CurrentGroups.displayName -match "$($i.displayName)") {
                Write-Verbose "$($i.displayName) already exist.. Moving on.."
            }
            else {
                $Group = @{
                    "description" = "$($i.description)"
                    "displayName" = "$($i.displayName)"
                    "groupTypes" = @("DynamicMembership")
                    "membershipRule" = "$($i.membershipRule)"
                    "MailEnabled" = $false
                    "MailNickName" = "$($i.displayName)"
                    "SecurityEnabled" = $true
                    "membershipRuleProcessingState" = "on"
                }
                $params = @{
                    ContentType = 'application/json'
                    Headers = $Header
                    Body = $Group | ConvertTo-Json -Compress
                    Method = 'POST'      
                    URI = "$Endpoint/groups"
                }

                Invoke-RestMethod @params > $null
                $Count = $Count + 1
            }
        }

        if ($Count -gt 0) {
            Write-Output "Created missing default Intune groups"
        }
        else {
            Write-Output "All Device groups already existed.. Moving on.."
        }
    }
}