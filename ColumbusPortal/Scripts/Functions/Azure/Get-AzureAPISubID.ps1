function Get-AzureAPISubID {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        $Header
    )

    Begin {

        $ErrorActionPreference = "Stop"
    }
    
    Process {
        
        $ResponseSubscriptions=Invoke-WebRequest -Uri "https://management.azure.com/subscriptions?api-version=2015-01-01" -Method GET -Headers $Header -UseBasicParsing
        $ResponseSubscriptionsJSON=$ResponseSubscriptions|ConvertFrom-Json
        $ResponseSubscriptionsJSON.value.subscriptionId
    }
}
