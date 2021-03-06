function Add-UPNSuffix {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,
        [Parameter(Mandatory)]
        [string]$domain
    )

    Begin {
    }

    Process {

    $ErrorActionPreference = "Stop"

    Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox","Get-ADForest","Get-AcceptedDomain")
    Connect-O365 -Organization $TenantName
    $DC      = 'CPO-AD-01.hosting.capto.dk'
    $ENTname = "svc_selfservice@hosting.capto.dk"
    $ENTpass = ConvertTo-SecureString 'kdi*D*8djdjHBsbdnmsfhHHgdgdgd' -AsPlainText -Force
    $EntCred = New-Object System.Management.Automation.PSCredential $ENTname, $ENTpass

    $Config = Get-TenantConfig -TenantName $TenantName

    ##############################################################


    ## Trying to add the UPN's for the customer..

    foreach($i in $domain){
        
        if ($Config.TenantID365.ID -eq '43eea929-d726-4742-83a9-603c12a0d195') {
            try{
                Set-MsolADFSContext -Computer 'CPO-ADFS-01.hosting.capto.dk'
                New-MsolFederatedDomain -SupportMultipleDomain -DomainName $i
                }catch{ 
                    throw "Set-MSOLDomain - Error: $_"
            }
        }
        else{

            try{
                New-MsolDomain -Name $i
            }
            catch{
                Write-Verbose "Adding of $i did not succed.. Error: $_"
                throw "Adding of $i did not succed.. Error: $_"
            }
        }


        try{
            Set-ADForest -Identity 'hosting.capto.dk' -Server $DC -UPNSuffixes @{Add=$i} -Credential $EntCred
            }catch
                  { throw "Set-Adforest - Error: $_"
        }

        try{
            Set-ADOrganizationalUnit -Identity ("OU=" + $config.OUs[1].Name + "," + $config.OUs[1].path) -Add @{uPNSuffixes="$i"} -Server $DC
            }catch
                  { throw "Set-Adforest - Error: $_"
        }

        # Verifying domain creation..
        if((Get-MsolDomain -DomainName $i -ErrorAction SilentlyContinue) -ne $null){
            Write-Verbose ($i + " has been created as domain in O365..")
            }else{
            Write-Verbose ($i + " failed creation as domain in O365..")}

        if((Get-ADForest -Server $DC | select -ExpandProperty UPNSuffixes) -contains $i){
            Write-Verbose ($i + " has been created as UPN On-Prem..")
            }else{
            Write-Verbose ($i + " failed UPN creation On-Prem..")}
    
        }

         Get-Module msonline | Remove-Module
    }
}