function Get-AzureAPIAvailabilitySet {
    [Cmdletbinding(DefaultParametersetName='None')]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(ParameterSetName='name', Mandatory=$false)]
        $Name,
        
        [Parameter(Mandatory=$true)]
        $RessourceGroupname
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {
        
        if ($PsCmdlet.ParameterSetName -eq "None") {
            $as = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Compute/availabilitySets?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing
            return $as.value
        }
        else {
            $as = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Compute/availabilitySets/$($Name)?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing
            return $as
        }
        
    }
}