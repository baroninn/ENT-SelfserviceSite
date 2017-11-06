


$VM = [pscustomobject]@{
    properties = [pscustomobject]@{
        hardwareProfile = [pscustomobject]@{
            vmSize = "Basic_A0"
        }
        storageProfile = [pscustomobject]@{
            imageReference = [pscustomobject]@{
                publisher = "MicrosoftWindowsServer"
                offer =  "WindowsServer"
                sku =  "2016-Datacenter-with-Containers"
                version = "latest"
            }
        }
        osProfile = [pscustomobject]@{
            computerName = "TEST4"
            adminUsername = "jst"
            adminPassword = "Shareonline.dk!2"
            windowsConfiguration = [pscustomobject]@{
                provisionVMAgent = $true
                enableAutomaticUpdates = $true
            }
        }
        diagnosticsProfile = [pscustomobject]@{
            bootDiagnostics = [pscustomobject]@{
                enabled = $true
                storageUri = "https://shtasrdisk001.blob.core.windows.net/"
            }
        }
        NetworkProfile = [pscustomobject]@{
            NetworkInterfaces = [pscustomobject]@{
                Primary =  $null
                ID = "/subscriptions/ed30c243-073c-4457-aea2-8df7e2591792/resourceGroups/JST/providers/Microsoft.Network/virtualNetworks/JST-vnet/subnets/default"
               #Id = "/subscriptions/ed30c243-073c-4457-aea2-8df7e2591792/resourceGroups/JST/providers/Microsoft.Network/networkInterfaces/myNic"
            }
        }

    }
    location = "EastUS"
}
