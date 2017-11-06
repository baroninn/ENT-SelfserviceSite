function New-AzureAPIPublicIP {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$false)]
        $Name,
        
        [Parameter(Mandatory=$true)]
        $RessourceGroupname,

        [Parameter(Mandatory=$true)]
        $AllocationMethod,

        [Parameter(Mandatory=$true)]
        $Version,

        [Parameter(Mandatory=$true)]
        $Location
    )
    

    Begin {

        $ErrorActionPreference = "Stop"
        $SubscriptionID = Get-AzureAPISubID -Header $Header
        $Endpoint = "https://management.azure.com/subscriptions"
    }
    
    Process {
        $BodyString = "
        {
          'properties': {
            'publicIPAllocationMethod': '" + $AllocationMethod + "',
            'publicIPAddressVersion': '" + $Version + "'
          },
          'location': '" + $Location + "'
        }"
        $params = @{
            ContentType = 'application/json'
            Headers = $Header
            Body = $BodyString
            Method = 'Put'      
            URI = "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Network/publicIPAddresses/$($Name)?api-version=2017-06-01"
        }

        Invoke-RestMethod @params
    }
}