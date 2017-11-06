function Get-AzureIntuneDevice {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$false)]
        [string]$ID
    )
    

    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if (-not $ID) {

            $DevicesList = @()
            try {
                $Devices = @(Invoke-RestMethod -Uri "$Endpoint/managedDevices" -Headers $header -Method Get).value
            }
            catch {
                throw "No Devices exist.."
            }

            foreach ($i in $Devices) {

                $DevicesList += $i
            }

            return $DevicesList
        }
        else {

            $DevicesList = @()
            try {
                $Devices = @(Invoke-RestMethod -Uri "$Endpoint/managedDevices/$ID" -Headers $header -Method Get)
            }
            catch {
                throw "No Devices exist.."
            }

            foreach ($i in $Devices) {

                $DevicesList += $i
            }

            return $DevicesList
        }
    }
}