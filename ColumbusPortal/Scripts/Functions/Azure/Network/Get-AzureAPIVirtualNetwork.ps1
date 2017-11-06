function Get-AzureAPIVirtualNetwork {
    [Cmdletbinding(DefaultParametersetName='None')]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(ParameterSetName='Name', Mandatory=$true)]
        [string]$RessourceGroupname,

        [Parameter(ParameterSetName='Name', Mandatory=$false)]
        [string]$Name
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {

        if ($PsCmdlet.ParameterSetName -eq "None") {
            $vnet = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Network/virtualNetworks?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
            return $vnet.value
        }
        elseif ($PsCmdlet.ParameterSetName -eq "Name") {
            if (-not $Name -and $RessourceGroupname) {
                $vnet = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Network/virtualNetworks?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $vnet.value
            }
            else {
                $vnet = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Network/virtualNetworks/$($Name)?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $vnet
            }
        }
    }
}
