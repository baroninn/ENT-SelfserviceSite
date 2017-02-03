function Update-VersionConf {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,

        [switch]$Force,

        [switch]$UpdateAll
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        [pscredential]$RemoteCredential = Get-RemoteCredentials -CORP

    }
    Process {
        try{
            $Config = Get-TenantConfig -TenantName $TenantName
        }catch{Write-Verbose "Because of something the tenant config cannot be retrieved.."
               Return}
        try{
            # Create folder for version share..
            foreach ($folder in ($Config.Folders | where{$_.Name -eq 'Version'})) {
                Write-Verbose "Creating folder '$($folder.Name)' in '$($folder.Path)'"
                $newFolder = New-Item -ItemType Directory -Name $folder.Name -Path $folder.Path

                foreach ($permission in $folder.Permissions) {
                    $adObject = Get-ADObject -Filter "SAMAccountName -eq '$($permission.IdentityReference.Value)'" -Properties objectSid -Server $Config.DomainFQDN

                    $params = @{
                        FileSystemRights   = $permission.FileSystemRights  -split ', '
                        AccessControlType  = $permission.AccessControlType
                        SecurityIdentifier = $adObject.objectSid
                        InheritanceFlags   = $permission.InheritanceFlags  -split ', '
                        PropagationFlags   = $permission.PropagationFlags  -split ', '
                        Path               = $newFolder.FullName 
                    }

                    Add-AclEntry @params
                }
            }
        }catch{Write-Verbose "$($folder.Name) already exists.."}

        # Create SMB shares.
        foreach ($share in ($Config.Shares | where{$_.Name -like "*Version$"})) {
            try{
                Write-Verbose "Creating share '$($share.Name)' with local path '$($share.Path)' on computer '$($Config.FileServer.Fqdn)'"
                New-SmbShare -Name $share.Name -Path $share.Path -FullAccess 'Everyone' -CimSession "$($Config.FileServer.Fqdn)" | Out-Null
            
            }catch{Write-Verbose "$($share.Name) already exists.."}
                
        }

        # Create DFS shares through PowerShell Endpoint.
        try {
            $dfsnError = $null
            $dfsnModule = Import-PSSession (New-PSSession -ComputerName $Config.SelfServicePSEndpoint -ConfigurationName 'Selfservice' -Name 'SelfServiceEndpoint')

            foreach ($dfsFolder in ($Config.DfsFolders | where{$_.path -like "*Version"})) {
                Write-Verbose "Creating DFS folder '$($dfsFolder.Path)' with target path '$($dfsFolder.TargetPath)'"
                New-DfsnFolder -Path $dfsFolder.Path -TargetPath $dfsFolder.TargetPath -CimSession (Get-ADDomainController -Domain $Config.DomainFQDN -Discover).HostName | Out-Null

                foreach ($account in $dfsFolder.Accounts) {
                    Write-Verbose "Granting access for '$account' on '$($dfsFolder.Path)'"
                    Grant-DfsnAccess -Path $dfsFolder.Path -AccountName $account | Out-Null
                }
            }
        }
        catch {
            $dfsnError = $_
        }
        finally {
            $dfsnModule | Remove-Module
            Remove-PSSession -Name 'SelfServiceEndpoint'
        }

        if ($dfsnError) {
            Write-Verbose $dfsnError
        }




    }
}
    