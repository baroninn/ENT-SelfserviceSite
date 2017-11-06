function Get-AzureAPINetworkSecurityGroup {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        $Header
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {
        
        $nsg = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Network/networkSecurityGroups?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing

        return $nsg.value
    }
}
