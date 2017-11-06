function Assign-DefaultIntuneDeviceGroups {
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
            $deviceconfs = Get-AzureIntuneDeviceConfiguration -Header $Header
        }
        catch {
            $CurrentGroups = $null
            $deviceconfs = $null
        }
        try {
            $IOS = @{
                "deviceConfigurationGroupAssignments" = @(
                    @{
                    "@odata.type"   = "#microsoft.graph.deviceConfigurationGroupAssignment";
                    'targetGroupId' = "$(($CurrentGroups | where{$_.displayname -match "IOS"}).id)"
                    'excludeGroup'  = $false
                    }
                )
            }
            $IOSparams = @{
                ContentType = 'application/json'
                Headers = $Header
                Body = $IOS | ConvertTo-Json -Compress
                Method = 'POST'      
                URI = "$Endpoint/deviceManagement/deviceConfigurations/$(($deviceconfs | where{$_.platform -eq "IOS"}).id)/assign"
            }
            Invoke-RestMethod @IOSparams > $null

            $Android = @{
                "deviceConfigurationGroupAssignments" = @(
                    @{
                    "@odata.type"   = "#microsoft.graph.deviceConfigurationGroupAssignment";
                    'targetGroupId' = "$(($CurrentGroups | where{$_.displayname -match "Android"}).id)"
                    'excludeGroup'  = $false
                    }
                )
            }
            $Androidparams = @{
                ContentType = 'application/json'
                Headers = $Header
                Body = $Android | ConvertTo-Json -Compress
                Method = 'POST'      
                URI = "$Endpoint/deviceManagement/deviceConfigurations/$(($deviceconfs | where{$_.platform -eq "Android"}).id)/assign"
            }

            Invoke-RestMethod @Androidparams > $null

            $Windows = @{
                "deviceConfigurationGroupAssignments" = @(
                    @{
                    "@odata.type"   = "#microsoft.graph.deviceConfigurationGroupAssignment";
                    'targetGroupId' = "$(($CurrentGroups | where{$_.displayname -match "Win10"}).id)"
                    'excludeGroup'  = $false
                    }
                )
            }
            $Windowsparams = @{
                ContentType = 'application/json'
                Headers = $Header
                Body = $Windows | ConvertTo-Json -Compress
                Method = 'POST'      
                URI = "$Endpoint/deviceManagement/deviceConfigurations/$(($deviceconfs | where{$_.platform -eq "Win10"}).id)/assign"
            }

            Invoke-RestMethod @Windowsparams > $null

            $macOS = @{
                "deviceConfigurationGroupAssignments" = @(
                    @{
                    "@odata.type"   = "#microsoft.graph.deviceConfigurationGroupAssignment";
                    'targetGroupId' = "$(($CurrentGroups | where{$_.displayname -match "Win10"}).id)"
                    'excludeGroup'  = $false
                    }
                )
            }
            $macOSparams = @{
                ContentType = 'application/json'
                Headers = $Header
                Body = $macOS | ConvertTo-Json -Compress
                Method = 'POST'      
                URI = "$Endpoint/deviceManagement/deviceConfigurations/$(($deviceconfs | where{$_.platform -eq "macOS"}).id)/assign"
            }

            Invoke-RestMethod @macOSparams > $null

            Write-Output "Assigned all device groups to configurations.."
        }
        catch {
            throw "Error: $($_.exception)"
        }

        
    }
}