function Start-IntuneDeviceTask {
    [Cmdletbinding(DefaultParametersetName='None')]
    param (
        [Parameter(Mandatory)]
        $Header,

        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$Task,
        [parameter(mandatory)]
        [string]$Id,
        [Parameter(ParameterSetName='enableLostMode', Mandatory=$false)]
        $message,
        [Parameter(ParameterSetName='enableLostMode', Mandatory=$true)]
        $phoneNumber,
        [Parameter(ParameterSetName='enableLostMode', Mandatory=$true)]
        $footer
    )
    

    Begin {
        
        $ErrorActionPreference = "Stop"
        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {
        
        $returnobject = [pscustomobject]@{
            Status = "Error"
            Id = $Id
        }
        if ($Task -eq "enableLostMode") {

            $enableLostMode = [pscustomobject]@{
                'message' = $message
                'phoneNumber' = $phoneNumber
                'footer' = $footer
            }

            try {
                $webrequest = Invoke-RestMethod -Uri "$Endpoint/managedDevices/$Id/$Task" -Headers $header -Method Post -Body ($enableLostMode | ConvertTo-Json -Compress) -ContentType 'application/json'
                $returnobject.Status = "Success"
            }
            catch {
                throw $_.Exception
            }
        }
        else {
            try {
                $webrequest = Invoke-RestMethod -Uri "$Endpoint/managedDevices/$Id/$Task" -Headers $header -Method Post
                $returnobject.Status = "Success"
            }
            catch {
                throw $_.Exception
            }
        }

        return $returnobject
    }
}