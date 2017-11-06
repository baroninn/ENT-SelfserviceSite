function Get-AzureAPIStorageAccount {
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
            $sa = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Storage/storageAccounts?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
            return $sa.value
        }
        elseif ($PsCmdlet.ParameterSetName -eq "RessourceGroupname") {
            if (-not $Name -and $RessourceGroupname) {
                $sa = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Storage/storageAccounts/?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $sa.value
            }
            if ($Name -and $RessourceGroupname) {
                $sa = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/resourceGroups/$($RessourceGroupname)/providers/Microsoft.Storage/storageAccounts/$($Name)?api-version=2017-06-01" -Method GET -Headers $Header -UseBasicParsing
                return $sa.value
            }
        }
    }
}
