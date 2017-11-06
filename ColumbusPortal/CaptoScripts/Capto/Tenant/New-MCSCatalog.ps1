Function New-MCSCatalog {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("AdvoPlus", "Legal", "Member2015")]
        [string]$Solution,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$VMName,

        [Parameter(Mandatory)]
        [string]$OU,

        [Parameter(Mandatory)]
        [string]$NamingScheme

    )

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2
        $CTXServer = "cpo-ctx-01.hosting.capto.dk"
        $Cred = Get-RemoteCredentials -CPO

    $CTXBlock = {
            param($Solution, $Name, $VMName, $OU, $NamingScheme)
            
            Add-PSSnapIn citrix*

            $CTXHOST1 = "cpo-ctx-01.hosting.capto.dk:80"
            $CTXHOST2 = "cpo-ctx-02.hosting.capto.dk:80"

            $LoggingID = Start-LogHighLevelOperation  -AdminAddress $CTXHOST1 -Source "SelfServicesSite" -Text "Create Machine Catalog from SSS $Name"

            $BrokerCatalog = New-BrokerCatalog  -AdminAddress $CTXHOST1 -AllocationType "Random" -IsRemotePC $False -LoggingId $LoggingID.Id -MinimumFunctionalLevel "L7_8" -Name $Name -PersistUserChanges "Discard" -ProvisioningType "MCS" -Scope @() -SessionSupport "MultiSession" -ZoneUid "11fa6b19-351a-4ee6-830e-b64bf2027792"

            $AcctIdentityPool = New-AcctIdentityPool -AdminAddress $CTXHOST1 -AllowUnicode -Domain "hosting.capto.dk" -IdentityPoolName "$Name" -LoggingId $LoggingID.Id -NamingScheme $NamingScheme -NamingSchemeType "Numeric" -OU "OU=$OU,OU=CITRIX,OU=Servers,OU=Backend,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk" -Scope @()

            Set-BrokerCatalogMetadata  -AdminAddress $CTXHOST1 -CatalogId $BrokerCatalog.Uid -LoggingId $LoggingID.Id -Name $Name -Value $AcctIdentityPool.IdentityPoolUid.Guid

            $Path = Get-ChildItem "XDHyp:\HostingUnits\CPO-HYP\" | where {$_.FullName -like "$VMName.vm*"} | select -ExpandProperty FullPath

            $Snapshot = New-HypVMSnapshot  -AdminAddress $CTXHOST1 -LiteralPath $Path -LoggingId $LoggingID.Id -SnapshotName "$(Get-Date -Format "dd-MM-yyyy HH:mm") - $Name" 

            $test = Test-ProvSchemeNameAvailable  -AdminAddress $CTXHOST1 -ProvisioningSchemeName @("$Name")

            $ProvScheme = New-ProvScheme  -AdminAddress $CTXHOST1 -CleanOnBoot -HostingUnitName "CPO-HYP" -IdentityPoolName $Name -LoggingId $LoggingID.Id -MasterImageVM $Snapshot -NetworkMapping @{"D3353248-1935-4C86-BC2E-5A36A2D7D8B2"="XDHyp:\HostingUnits\CPO-HYP\\CPO Prod - 245.network"} -ProvisioningSchemeName "$Name" -RunAsynchronously -Scope @() -VMCpuCount 4 -VMMemoryMB 4096

            #$Publish = Publish-ProvMasterVMImage  -AdminAddress $CTXHOST1 -LoggingId $LoggingID.Id -MasterImageVM "$SnapShot" -ProvisioningSchemeName "$($ProvScheme.ProvisioningSchemeName)" -RunAsynchronously

            $TaskStatus = Get-ProvTask -TaskId $ProvScheme.Guid

            While ( $TaskStatus.Active -eq $True ) {
                Start-Sleep 15
                $TaskStatus = Get-ProvTask -TaskId $ProvScheme.Guid
            }

            #$PublishStatus = Get-ProvTask -TaskId $Publish.Guid

            #While ( $PublishStatus.Active -eq $True ) {
            #    Start-Sleep 15
            #    $PublishStatus = Get-ProvTask -AdminAddress $CTXHOST1 -TaskId $Publish.Guid
            #}

            $ProvSchemeID = Get-ProvScheme -ProvisioningSchemeName $Name

            Set-BrokerCatalog  -AdminAddress $CTXHOST1 -LoggingId $LoggingID.Id -Name "$Name" -ProvisioningSchemeId $ProvSchemeID.ProvisioningSchemeUid.Guid

            Add-ProvSchemeControllerAddress  -AdminAddress $CTXHOST1 -ControllerAddress @("$CTXHOST1","$CTXHOST2") -LoggingId $LoggingID.Id -ProvisioningSchemeName "$Name"

            Stop-LogHighLevelOperation  -AdminAddress $CTXHOST1 -HighLevelOperationId $LoggingID.Id -IsSuccessful $True
    }
    
    Invoke-Command -ComputerName $CTXServer -ScriptBlock $CTXBlock -InDisconnectedSession -ArgumentList $Solution, $Name, $VMName, $OU, $NamingScheme -Credential $Cred

}