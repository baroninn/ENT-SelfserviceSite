function Get-AzureAPIRessourceGroup {
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
        
        $rsg = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups?api-version=2017-05-10" -Method GET -Headers $Header -UseBasicParsing

        $rsgobject = @()
            foreach ($i in $rsg.value) {
                $object = [pscustomobject]@{
                    ID = $i.id.ToString()
                    Name = $i.name.ToString()
                    Location = $i.location.ToString()
                }
                $rsgobject += $object
            }
        return $rsgobject
    }
}
