function Get-AzureAPIVMs {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {

        $ErrorActionPreference = "Stop"

        $Header = Get-AzureAPIToken -Organization $Organization
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {
        $AllVms = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Compute/virtualMachines?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing
        #$AllVms = Invoke-WebRequest -Uri "$Endpoint/2d83a567-d8b1-4b85-bbde-a084a2b1e1e1/resourceGroups/SHT/providers/Microsoft.Compute/virtualMachines/test2?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing

        $VMs = @()
        
        foreach ($i in $AllVms.value) {
            $resourceGroup = ($i.id -split 'resourceGroups/')[1].split('/')[0]
            $VM = Invoke-RestMethod -Uri ("$Endpoint/$($SubscriptionID)" + "/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$($i.name)" + '?$expand=instanceView&api-version=2017-03-30') -Method GET -Headers $Header -UseBasicParsing
            #$VM = Invoke-WebRequest -Uri ("$Endpoint/$($SubscriptionID)" + "/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$($i.name)" + '?&api-version=2017-03-30') -Method GET -Headers $Header -UseBasicParsing

            ## IP slow because of foreach for all ips, but needed because of ressourcegroup..
            $IPs = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$resourceGroup/providers/Microsoft.Network/publicIPAddresses?api-version=2017-08-01" -Method GET -Headers $Header -UseBasicParsing

            ## Network interfaces...
            $Networks = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$resourceGroup/providers/Microsoft.Network/networkInterfaces?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing

            $newnetwork = ""
            foreach ($net in $Networks.value) {
                if ($net.properties.PSObject.Properties['virtualMachine'] -ne $null) {
                    ## use a try/catch to support missing properties.. 
                    try{
                        if ($net.properties.VirtualMachine.Id.split("/")[-1] -like "*$($VM.name)*") {
                            $newnetwork = $net.properties.IpConfigurations.properties.PublicIpAddress.Id.split("/")[-1]
                        }
                    }
                    catch{}
                }
            }

            $Sizes = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Compute/locations/eastus/vmSizes?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing


            if ($newnetwork) {

                $PublicIPs = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$resourceGroup/providers/Microsoft.Network/publicIPAddresses/$($newnetwork)?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing

                $VMs += [pscustomobject]@{
                    ResourceGroupName = $resourceGroup
                    Name              = $VM.name
                    VmId              = $VM.properties.vmId
                    Location          = $VM.location
                    VmSize            = $VM.properties.hardwareProfile.vmSize
                    ProvisioningState = $VM.properties.provisioningState
                    PowerState        = $vm.properties.instanceView.statuses | where{$_.code -like "*PowerState*"} | select -ExpandProperty DisplayStatus
                    IPAddress         = $PublicIPs.properties.ipAddress
                    CPU               = ($Sizes.value | where{$_.name -like $VM.properties.hardwareProfile.vmSize}).numberOfCores
                    RAM               = ($Sizes.value | where{$_.name -like $VM.properties.hardwareProfile.vmSize}).memoryInMB
                }
                   
            }
            else {
                $VMs += [pscustomobject]@{
                    ResourceGroupName = $resourceGroup
                    Name              = $VM.name
                    VmId              = $VM.properties.vmId
                    Location          = $VM.location
                    VmSize            = $VM.properties.hardwareProfile.vmSize
                    ProvisioningState = $VM.properties.provisioningState
                    PowerState        = $vm.properties.instanceView.statuses | where{$_.code -like "*PowerState*"} | select -ExpandProperty DisplayStatus
                    IPAddress         = "No IP"
                    CPU               = ($Sizes.value | where{$_.name -like $VM.properties.hardwareProfile.vmSize}).numberOfCores
                    RAM               = ($Sizes.value | where{$_.name -like $VM.properties.hardwareProfile.vmSize}).memoryInMB
                }
            }
        }

        return $VMs
        
    }
}