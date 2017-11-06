function Get-AzureAPIVMSecurity {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {

        $ErrorActionPreference = "Stop"

        $Header = Get-AzureAPIToken -Organization $Organization
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com"
    }
    
    Process {
        $Security = Invoke-RestMethod -Uri "$Endpoint/subscriptions/$($SubscriptionID)/providers/microsoft.Security/securityStatuses?api-version=2015-06-01-preview" -Method GET -Headers $Header
        $SecurityTasks = Invoke-RestMethod -Uri "$Endpoint/subscriptions/$($SubscriptionID)//providers/microsoft.Security/tasks?api-version=2015-06-01-preview" -Method GET -Headers $Header

        $VMs = ($Security.value -match 'virtualMachines') | where {$_.id -notmatch 'networking'}

        #$VMstatus =
        $NewObject = [pscustomobject]@{
            vms = [pscustomobject]@{
                info = @()
            }
        }

        $VMstatus = foreach ($i in $VMs) {
            #### Patch Information ####
            $string = ($i.id -split ('/securityStatuses'))[0]
            $PatchSecurity = Invoke-RestMethod -Uri "$Endpoint$string/dataCollectionResults/patch?api-version=2015-06-01-preview" -Method GET -Headers $Header

            #### Malware Information ####
            $EndpointSecurity = Invoke-RestMethod -Uri "$Endpoint$string/dataCollectionResults/Antimalware?api-version=2015-06-01-preview" -Method GET -Headers $Header

            $VMobject = [pscustomobject]@{
                PatchesSecurityState         = $null
                Name                         = $null
                securityState                = $null
                MalwaresecurityState         = $null
                Patches                      = $null
                MalWareErrors                = $null
                VMRecommendations            = $null
            }

            $VMRecommendationobject = [pscustomobject]@{
                vmId        = $null
                vmName      = $null
                name        = $null
                uniqueKey   = $null
                resourceId  = $null
            }


            $VMobject.MalwaresecurityState = $i.properties.antimalwareScannerData.securityState
            $VMobject.Name                 = $i.name
            $VMobject.PatchesSecurityState = $i.properties.patchScannerData.missingPatchesSecurityState
            $VMobject.securityState        = $i.properties.securityState

            if ($PatchSecurity.properties.missingPatches) {
                $VMobject.Patches = $PatchSecurity.properties.missingPatches

                foreach ($patchlink in $VMobject.Patches){ $patchlink.linksToMsDocumentation = $patchlink.linksToMsDocumentation}
            }
            else {
                #$Patchobject.patchId = "No patches needed.."
                $VMobject.Patches = "No patches needed.."
            }
            if ($EndpointSecurity.properties.antimalwareScenarios) {
                $VMobject.MalWareErrors = $EndpointSecurity.properties.antimalwareScenarios
            }
            else {
                #$Malwareobject.patchId = "Nothing to report.."
                $VMobject.MalWareErrors = "Nothing to report.."
            }

            try {
                foreach ($s in $SecurityTasks.value.properties.securityTaskParameters) {
                    if ($s.PSobject.Properties.Name -contains "vmName") {
                        if ($s.vmName -like "*$($i.name)*") {

                            $VMRecommendationobject.vmID = $s.vmId
                            $VMRecommendationobject.vmName = $s.vmName
                            $VMRecommendationobject.name = $s.name
                            $VMRecommendationobject.uniqueKey = $s.uniqueKey
                            $VMRecommendationobject.resourceId = $s.resourceId

                            $VMobject.VMRecommendations += $VMRecommendationobject
                            
                        }

                    }

                }
            }
            catch{
                $VMobject.VMRecommendations = "No VM recommendations"
            }


            $NewObject.vms.info += $VMobject

        }

        return $NewObject
        
    }
}