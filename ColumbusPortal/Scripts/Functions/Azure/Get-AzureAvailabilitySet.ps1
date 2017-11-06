function Get-AzureAvailabilitySet {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        $Header,
        [Parameter(Mandatory)]
        $RessourceGroup
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {
        
        $as = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroup)/providers/Microsoft.Compute/availabilitySets?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing

        return $as.value
    }
}
