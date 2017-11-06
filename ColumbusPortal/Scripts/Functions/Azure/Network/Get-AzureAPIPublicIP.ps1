function Get-AzureAPIPublicIP {
    [Cmdletbinding(DefaultParametersetName='None')]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(ParameterSetName='RessourceGroupname', Mandatory=$false)]
        $Name,
        
        [Parameter(ParameterSetName='RessourceGroupname', Mandatory=$true)]
        $RessourceGroupname
    )
    

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {

        
        if ($PsCmdlet.ParameterSetName -eq "None") {
            $pip = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Network/publicIPAddresses?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
            return $pip.value
        }
        elseif ($PsCmdlet.ParameterSetName -eq "RessourceGroupname") {
            if (-not $Name -and $RessourceGroupname) {
                $pip = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Network/publicIPAddresses?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $pip.value
            }
            if ($Name -and $RessourceGroupname) {
                $pip = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Network/publicIPAddresses/$($Name)?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $pip
            }
        }
    }
}