function Enable-Sikkermail {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,

        [string]$SendAsGroup,

        [string]$Alias,

        [switch]$Force,

        [switch]$Remove,

        [switch]$UpdateALL
    )
    Begin {
            $ErrorActionPreference = 'Stop'
            Set-StrictMode -Version 2
            $Config = Get-TenantConfig -TenantName $TenantName

            if ($Config.PrimarySmtpAddress -like "*dummy*") {
                throw "Dummy domain exist on customer.. Please run remove dummy domain before adding Sikkermail.."
            }

            ## AD attributes, same for all customers..
            $attributes = @{
            extensionAttribute2 = "##B2SPIRIT#:#207#"
            extensionAttribute3 = "##B2SPIRIT#:#210#indgaaende@prod.e-boks.dk"
            extensionAttribute4 = "##B2SPIRIT#:#208#True#209#True#211#False#212#False#213#False#214#False"
            extensionAttribute5 = "##B2SPIRIT#:#215#False#216#False#217#False#218#False#219#False#220#True"
            }
            if ($Alias) {
            $attributes += @{extensionAttribute1 = "##B2SPIRIT#:#187#$Alias;$Alias"}
            }

            $RemoveAttributes = @("extensionAttribute1", "extensionAttribute2", "extensionAttribute3", "extensionAttribute4", "extensionAttribute5")
            $UpdateAttributes = @("extensionAttribute2", "extensionAttribute3", "extensionAttribute4", "extensionAttribute5")

            ## Get info for SSH query
            $ComendoDomain = ($Config.PrimarySmtpAddress -replace '\.', '-')
            $Query1 = "sudo /usr/local/bin/SSSAddSecureMailDomain.sh @$($Config.PrimarySmtpAddress) smtp:$($ComendoDomain).smtp1.comendosystems.com"

    }

    Process {

            if ($UpdateALL -and -not $Remove -and -not $Force) {
                foreach($_ in Get-ADGroup -Filter "Description -eq 'Sikkermail'" -Server $Config.DomainFQDN) {
                    Write-Verbose "Updating attributes on '$($_.Name).."
                    Set-Adgroup -Identity $_.Name -Server $Config.DomainFQDN -Description "SikkerMail" -Clear $UpdateAttributes
                    Set-Adgroup -Identity $_.Name -Server $Config.DomainFQDN -Description "SikkerMail" -Add $attributes
                }
            }
            else {
                        ## Get Sendasgroup as object and create the GPO we will be working on..
                        $groupmember = Get-ADGroup $SendAsGroup -Server $Config.DomainFQDN

                    if (-not $Remove -and -not $Force -and -not $UpdateALL) {
                        Write-Verbose "Setting attributes on '$($groupmember.Name).."
                        Set-Adgroup -Identity $SendAsGroup -Server $Config.DomainFQDN -Description "SikkerMail" -Add $attributes
                        Add-ADGroupMember -Identity "Base_Role_SikkerMailAddin_User" -Server $Config.DomainFQDN -Members $groupmember
                    }
                    if ($Remove -and -not $Force -and -not $UpdateALL) { 
                        Write-Verbose "Removing attributes on '$($groupmember.Name).."
                        Set-Adgroup -Identity $SendAsGroup -Server $Config.DomainFQDN -Description "SikkerMail" -Clear $attributes
                        Remove-ADGroupMember -Identity "Base_Role_SikkerMailAddin_User" -Server $Config.DomainFQDN -Members $groupmember
                    }
                    if ($Force -and -not $Remove -and -not $UpdateALL) {
                        Write-Verbose "Forcing attributes on '$($groupmember.Name).."
                        Set-Adgroup -Identity $SendAsGroup -Server $Config.DomainFQDN -Description "SikkerMail" -Clear $RemoveAttributes
                        Set-Adgroup -Identity $SendAsGroup -Server $Config.DomainFQDN -Description "SikkerMail" -Add $attributes
                        Add-ADGroupMember -Identity "Base_Role_SikkerMailAddin_User" -Server $Config.DomainFQDN -Members $groupmember -ErrorAction SilentlyContinue
                    }


                    ## Begin GPO changes..

                    $GPO = Get-GPO -Name "$($Tenantname)_GPO_RDS_Sikkermail" -Domain $Config.DomainFQDN -ErrorAction SilentlyContinue

                    if (-not (Get-GPO -Name "$($Tenantname)_GPO_RDS_Sikkermail" -Domain $Config.DomainFQDN -ErrorAction SilentlyContinue)) {

                        $newGpo = Get-GPO -Name 'Template_GPO_RDS_Sikkermail' -Domain $Config.DomainFQDN | 
                                  Copy-GPO -TargetName ($TenantName + "_GPO_RDS_Sikkermail") -CopyAcl -TargetDomain $Config.DomainFQDN -SourceDomain $Config.DomainFQDN
                        $gpoPath = "\\$($Config.DomainFQDN)\SYSVOL\$($Config.DomainFQDN)\Policies\{{{0}}}" -f $newGpo.Id

                        Write-Verbose "Beginning XML editing of '$($newGpo.DisplayName)'."
                        $registrySubPath = 'User\Preferences\Registry\Registry.xml'
                        $registryPath = Join-Path $gpoPath $registrySubPath
                        [xml]$registryXml = Get-Content -Path $registryPath
                        $registryXml.Registrysettings.Collection.Registry.Filters.FilterGroup.name   = ("CAPTO\" + $groupmember.SamAccountName)
                        $registryXml.Registrysettings.Collection.Registry.Filters.FilterGroup.sid    = $groupmember.SID.Value
                        $registryXml.Save($registryPath)


                        Write-Verbose "Linking GPO '$($newGpo.DisplayName)' to OU '$($Config.UsersOU)'."
                        $newGpo | New-GPLink -Target $Config.UsersOU -Domain $Config.DomainFQDN | Out-Null
                        $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $groupmember.Name -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                        $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $Config.BaseRdsRoleGroupName -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                    }
                    elseif (-not $Remove) {
                        $GPO | Set-GPPermission -PermissionLevel GpoApply -TargetName $groupmember.Name -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                        $Gpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $Config.BaseRdsRoleGroupName -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                    }
                    elseif ($Remove) {
                        $GPO | Set-GPPermission -PermissionLevel None -TargetName $groupmember.Name -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                        $Gpo | Set-GPPermission -PermissionLevel None -TargetName $Config.BaseRdsRoleGroupName -TargetType Group -Domain $Config.DomainFQDN | Out-Null
                    }

                }
        }
}