function New-SCCMCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$FQDN
    )

    begin{

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        
        $Server1 = 'file-01.corp.systemhosting.dk'
        $Server2 = 'sht008.corp.systemhosting.dk'
        $Domain  = $FQDN.Split('.').Get(1).ToString()
        
    }


    process{

            $Scriptblock1 = {  
                param($Organization, 
                      $FQDN
                      )          
            
            $path = 'd:\data\VMM-A-Library\ApplicationFrameworks\Enterprise Customer\XMLs'
            $Server= 'sht008.corp.systemhosting.dk'
            #Create the UNattend files in the VVM library for the customer
            
            $password = 'fjh4!%njr45&4!"' | ConvertTo-SecureString -asPlainText -Force
            $username = "corp\svc_selfservicecapto" 
            $credential = New-Object System.Management.Automation.PSCredential($username,$password)

            new-item -Path "$path\$Organization" -ItemType Directory
            copy-item "$path\_MasterXXX_2012R2_RDS_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_RDS_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_Fileserver_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_SQL_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_Exchange_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_Other_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_Nav_Unattend.xml"
            copy-item "$path\_MasterXXX_2012R2_XXX_Unattend.xml" -destination "$path\$Organization\$Organization`_2012R2_RDGW_Unattend.xml"
 
            ## Change RDS Unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_RDS_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile)
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=RDS,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change fileserver unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_Fileserver_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=Fileservers,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change SQL unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_SQL_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=SQL,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change EXCHANGE unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_EXCHANGE_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=Exchange,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change Other unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_Other_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=Other,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change NAV unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_NAV_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=NAV,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile)
 
            ## Change RDGW unattend
            $xmlFile = "$path\$Organization\$Organization`_2012R2_RDGW_Unattend.xml"
            $xmlContent = [XML](gc $xmlFile) 
            $xmlContent.unattend.settings.component.identification.childnodes.'#text' = "OU=RDGateways,OU=Deploy,OU=Backbone,OU=SystemHosting,DC=corp,DC=$domain,DC=dk"
            $xmlContent.Save($xmlFile) 


            }

        Invoke-Command -ComputerName $Server1 -ScriptBlock $Scriptblock1 -ArgumentList $Organization, $FQDN
            
            $Scriptblock2 = {
                param($Organization, 
                      $FQDN
                      )

            Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1) 
            $SiteCode = get-psdrive -psprovider cmsite
            Set-Location ($SiteCode.Name + ":\")

            $Schedule1 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Monday -RecurCount 1
            $Schedule2 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Tuesday -RecurCount 1
            $Schedule3 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Wednesday -RecurCount 1
            $Schedule4 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Thursday -RecurCount 1
            $Schedule5 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Friday -RecurCount 1
            $Schedule6 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Saturday -RecurCount 1
            $Schedule7 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Sunday -RecurCount 1

            # Limiting collection in SCCM
            $LimitingCollection = 'All Clients Active - Servers'

            #Collection Names, change if needed
            $Collection2 = "$Organization - 3. Deploy RDS"
            $Collection3 = "$Organization - 2. Deploy Non RDS"
            $Collection4 = "$Organization - 1.1 Domain Controllers"
            $Collection5 = "$Organization - 1.2 Exchange"
            $Collection6 = "$Organization - 1.4 MPGWs"
            $Collection7 = "$Organization - 1.6 RDS"
            $Collection8 = "$Organization - 1.5 RDGateways"
            $Collection9 = "$Organization - 1.3 FileServers"
            $Collection10 = "$Organization - 1.7 SQL"
            $Collection1 = "$Organization - 1. All Servers" #bygges sidst fordi den skal have de andre collections included
            $Collection12 = "$Organization - 2.5 Deploy SQL" #bliver meldt ind i SQL Server 2014 - Enterprise Kunder Collection (SH10025A)
            $Collection16 = "$Organization - 2.1 Deploy Exchange"
            $Collection11 = "$Organization - 2.2 Deploy Fileservers"
            $Collection13 = "$Organization - 2.5 Deploy RDGateways"
            $Collection14 = "$Organization - 2.3 Deploy Nav"
            $Collection15 = "$Organization - 2.4 Deploy Other"


            #Here we go building stuff

            #Create the Customer folder under device collection \ Customers
            new-item -Name $Organization -Path ".\DeviceCollection\A. Customers"


            #$Collection2 = "$Organization - Deploy RDS"


            New-CMDeviceCollection -Name $Collection2  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule2  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection2 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=RDS,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection2
            #next linie is needed because PS is wierd :) 
            $Collection2 = Get-CMDeviceCollection -name $Collection2
            Move-CMObject -InputObject $Collection2 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection2.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection2.CollectionID) -VariableName FQDN -VariableValue $FQDN




            #$Collection12 = "$Organization - Deploy SQL"
            New-CMDeviceCollection -Name $Collection12  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule2  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection12 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=SQL,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection12
            #next linie is needed because PS is wierd :) 
            $Collection12 = Get-CMDeviceCollection -name $Collection12
            Move-CMObject -InputObject $Collection12 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection12.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection12.CollectionID) -VariableName FQDN -VariableValue $FQDN

            #$Collection11 = "$Organization - Deploy Fileservers"
            New-CMDeviceCollection -Name $Collection11  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule3  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection11 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Fileservers,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection11
            #next linie is needed because PS is wierd :) 
            $Collection11 = Get-CMDeviceCollection -name $Collection11
            Move-CMObject -InputObject $Collection11 -Folderpath ".\DeviceCollection\A. Customers\$Organization"
            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection11.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection11.CollectionID) -VariableName FQDN -VariableValue $FQDN


            #$Collection13 = "$Organization - Deploy RDGateways"
            New-CMDeviceCollection -Name $Collection13  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule4  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection13 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=RDGateways,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection13
            #next linie is needed because PS is wierd :) 
            $Collection13 = Get-CMDeviceCollection -name $Collection13
            Move-CMObject -InputObject $Collection13 -Folderpath ".\DeviceCollection\A. Customers\$Organization"
            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection13.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection13.CollectionID) -VariableName FQDN -VariableValue $FQDN

            #$Collection14 = "$Organization - Deploy Nav"
            New-CMDeviceCollection -Name $Collection14  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule6  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection14 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Nav,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection14
            #next linie is needed because PS is wierd :) 
            $Collection14 = Get-CMDeviceCollection -name $Collection14
            Move-CMObject -InputObject $Collection14 -Folderpath ".\DeviceCollection\A. Customers\$Organization"
            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection14.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection14.CollectionID) -VariableName FQDN -VariableValue $FQDN

            #$Collection15 = "$Organization - Deploy Other"
            New-CMDeviceCollection -Name $Collection15  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule5  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection15 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Others,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection15
            #next linie is needed because PS is wierd :) 
            $Collection15 = Get-CMDeviceCollection -name $Collection15
            Move-CMObject -InputObject $Collection15 -Folderpath ".\DeviceCollection\A. Customers\$Organization"
            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection15.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection15.CollectionID) -VariableName FQDN -VariableValue $FQDN

            #$Collection16 = "$Organization - Deploy Exchange"
            New-CMDeviceCollection -Name $Collection16  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule3  -RefreshType both
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection16 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Exchange,OU=Deploy,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection16
            #next linie is needed because PS is wierd :) 
            $Collection16 = Get-CMDeviceCollection -name $Collection16
            Move-CMObject -InputObject $Collection16 -Folderpath ".\DeviceCollection\A. Customers\$Organization"
            #Add the customer initials as a collection variable to the deploy RDS collections
            New-CMDeviceCollectionVariable -collectionid $($Collection16.CollectionID) -VariableName Customer -VariableValue $Organization
            New-CMDeviceCollectionVariable -collectionid $($Collection16.CollectionID) -VariableName FQDN -VariableValue $FQDN

            #$Collection4 = "$Organization - Domain Controllers"
            New-CMDeviceCollection -Name $Collection4  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule4  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection4 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Domain Controllers,DC=%'" -RuleName $Collection4
            #next linie is needed because PS is wierd :) 
            $Collection4 = Get-CMDeviceCollection -name $Collection4
            Move-CMObject -InputObject $Collection4 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection5 = "$Organization - Exchange"
            New-CMDeviceCollection -Name $Collection5  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule5  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection5 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Exchange,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection5
            #next linie is needed because PS is wierd :) 
            $Collection5 = Get-CMDeviceCollection -name $Collection5
            Move-CMObject -InputObject $Collection5 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection6 = "$Organization - MPGWs"
            New-CMDeviceCollection -Name $Collection6  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule6  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection6 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=MPGWs,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection6
            #next linie is needed because PS is wierd :) 
            $Collection6 = Get-CMDeviceCollection -name $Collection6
            Move-CMObject -InputObject $Collection6 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection7 = "$Organization - RDS"
            New-CMDeviceCollection -Name $Collection7  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule7  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection7 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=RDS,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection7
            #next linie is needed because PS is wierd :) 
            $Collection7 = Get-CMDeviceCollection -name $Collection7
            Move-CMObject -InputObject $Collection7 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection8 = "$Organization - RD Gateways"
            New-CMDeviceCollection -Name $Collection8  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule1  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection8 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=RDGateways,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection8
            #next linie is needed because PS is wierd :) 
            $Collection8 = Get-CMDeviceCollection -name $Collection8
            Move-CMObject -InputObject $Collection8 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection9 = "$Organization - File Servers"
            New-CMDeviceCollection -Name $Collection9  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule2  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection9 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=Fileservers,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection9
            #next linie is needed because PS is wierd :) 
            $Collection9 = Get-CMDeviceCollection -name $Collection9
            Move-CMObject -InputObject $Collection9 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection10 = "$Organization - SQL"
            New-CMDeviceCollection -Name $Collection10  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule3  -RefreshType Periodic
            Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Collection10 -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.DistinguishedName like 'CN=%,OU=SQL,OU=Servers,OU=BackBone,OU=SYSTEMHOSTING,%'" -RuleName $Collection10
            #next linie is needed because PS is wierd :) 
            $Collection10 = Get-CMDeviceCollection -name $Collection10
            Move-CMObject -InputObject $Collection10 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection1 = "$Organization - All Servers" #bygges sidst fordi den skal have de andre collections included
            New-CMDeviceCollection -Name $Collection1 -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule1 -RefreshType Both
            $Collection1 = Get-CMDeviceCollection -name $Collection1

            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection4.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection5.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection6.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection7.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection8.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection9.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection1.name) -IncludeCollectionName $($Collection10.name)

            Move-CMObject -InputObject $Collection1 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #$Collection3 = "$Organization - Deploy Non RDS"
            New-CMDeviceCollection -Name $Collection3  -LimitingCollectionName $LimitingCollection -RefreshSchedule $Schedule3  -RefreshType both
            $Collection3 = Get-CMDeviceCollection -name $Collection3

            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection12.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection11.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection13.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection14.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection15.name)
            Add-CMDeviceCollectionincludeMembershipRule -CollectionName $($Collection3.name) -IncludeCollectionName $($Collection16.name)

            Move-CMObject -InputObject $Collection3 -Folderpath ".\DeviceCollection\A. Customers\$Organization"

            #Add these new Collections to the Patch Collections in SCCM 

            Add-CMDeviceCollectionIncludeMembershipRule -CollectionID SH1000CA -IncludeCollectionName  $($Collection2.name)
            Add-CMDeviceCollectionIncludeMembershipRule -CollectionID SH1000CD -IncludeCollectionName  $($Collection3.name)
            Add-CMDeviceCollectionIncludeMembershipRule -CollectionID SH10025A -IncludeCollectionName  $($Collection12.name)



        }

        Invoke-Command -ComputerName $Server2 -ScriptBlock $Scriptblock2 -ArgumentList $Organization, $FQDN
    }
}