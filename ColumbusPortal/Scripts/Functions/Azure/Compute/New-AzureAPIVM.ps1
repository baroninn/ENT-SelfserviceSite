function New-AzureAPIVM {
    [Cmdletbinding(DefaultParametersetName='None')]
    <#
    .SYNOPSIS
        Create a VM in Azure ARM through REST API

    .PARAMETER Organization
        Needed to log on to the correct tenant.

    .EXAMPLE
        Get-AzureAPIToken -Organization XXX

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-08-20
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Location,

        [Parameter(Mandatory)]
        [string]$RessourceGroupName,

        [Parameter(Mandatory)]
        [string]$StorageAccount,

        [Parameter(Mandatory)]
        [string]$VirtualNetwork,
        [Parameter(Mandatory)]

        [string]$NetworkInterface,

        [Parameter(Mandatory)]
        [string]$Subnet,

        [Parameter(Mandatory)]
        [string]$PublicIP,

        [Parameter(Mandatory)]
        [string]$AvailabilitySet,

        [Parameter(Mandatory)]
        [string]$VMSize
    )

    Begin {


        $ErrorActionPreference = "Stop"

        $Header = Get-AzureAPIToken -Organization $Organization
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"

    }
    
    Process {
        $subnetname = 'default'
        $nsgname = 'TEST-nsg'
        $subnetprefix = '10.0.0.0/24'
        $publicIPaddressname = "mypublicdns479912394" 
        #$NICName = 'Your Azure NIC Name'
        #$interface = Get-AzureAPINetworkInterface -Header $Header -RessourceGroupname $RessourceGroupName -Name $VirtualNetwork
        $storageuri = Get-AzureAPIStorageAccount -Header $Header
        $Avail = Get-AzureAPIAvailabilitySet -Header $Header -RessourceGroupname $RessourceGroupName -Name $AvailabilitySet
        $vmpwd = 'Shareonline.dk!2'
        $AccountName = 'jst'
        $OSDiskName = $Name + "osDisk"
        $publisher = "MicrosoftWindowsServer"
        $offer = "WindowsServer"
        $sku = "2016-Datacenter"
        $version = "latest"
        
        $BodyString = "
        {
          'properties': {
            'hardwareProfile': {
              'vmSize': '" + $VMSize + "'
            },
            'storageProfile': {
              'imageReference': {
                'publisher':'"+ $publisher + "',
                'offer': '" + $offer + "',
                'sku': '" + $sku + "',
                'version': '" + $version + "'
              },
              'osDisk': {
                'name': '" + $OSDiskName + "',
                'createOption': 'fromImage',
                'managedDisk': {
                    'storageAccountType': 'Standard_LRS'
                    }
              }
            },
            'osProfile': {
              'computerName': '" + $Name + "',
              'adminUsername': '" + $AccountName +  "',
              'adminPassword': '" + $vmpwd + "',
              'secrets': []
            },
            'networkProfile': {
              'networkInterfaces': [
                {
                  'id': '" + $NetworkInterface + "'
                }
              ]
            },
            'diagnosticsProfile': {
              'bootDiagnostics': {
                'enabled': true,
                'storageUri': '" + $storageuri.properties.primaryEndpoints.blob + "'
              }
            },
            'availabilitySet': {
              'id': '" + $Avail.id + "'
            }
          },
          'location': '" + $location + "'
        }"
        
        <#
        $BodyObject = [pscustomobject]@{
            properties = [pscustomobject]@{
                hardwareprofile = [pscustomobject]@{
                    vmSize = $VMSize
                }
                storageProfile = [pscustomobject]@{
                    imageReference = [pscustomobject]@{
                        publisher = $publisher
                        offer = $offer
                        sku = $sku
                        version = $version
                    }
                    osDisk = [pscustomobject]@{
                        name = $OSDiskName
                        createOption = "fromImage"
                        managedDisk = [pscustomobject]@{
                            storageAccountType = "Standard_LRS"
                        }
                    }
                }
                osProfile = [pscustomobject]@{
                    computerName = $Name
                    adminUsername = $AccountName
                    adminPassword = $vmpwd
                }
                networkProfile = [pscustomobject]@{
                    networkInterfaces = [pscustomobject]@{
                        id = "$NetworkInterface"
                    }
                }
                diagnosticsProfile = [pscustomobject]@{
                    bootDiagnostics = [pscustomobject]@{
                        enabled = $true
                        storageUri = $storageuri.properties.primaryEndpoints.blob
                    }
                }
                availabilitySet = [pscustomobject]@{
                    id = $Avail.id
                }
                
            }
            location = $Location
        }
        #>
        #$BodyString | Out-File c:\test.txt -Append -Force

        $params = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $BodyString
            Method = 'Put'      
            URI = "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($Name)?api-version=2017-03-30"
        }

        Invoke-RestMethod @params

    }
}