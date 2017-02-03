function Remove-TenantUser {
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization')]
        [string]
        $TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [switch]
        $Force,

        [string]
        $Server = "hosting.capto.dk"
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        Import-Module (New-ExchangeProxyModule -Command "Remove-Mailbox")
    }

    Process {
        if (-not $Force) {
            $title = "Delete User"
            $message = "Do you want to delete the user, including mailbox, files and user profile disks?"

            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                "Deletes the user."

            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                "Retains the user."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

            $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

            switch ($result) {
                0 {}
                1 {return}
            }
        }

        $Config = Get-TenantConfig -TenantName $TenantName
        
        $mbx  = Get-TenantMailbox -TenantName $TenantName -Name $Name -Single
        $user = Get-ADUser -Server $Server -Identity $mbx.DistinguishedName
        
        $updName = "UVHD-{0}.vhdx" -f $user.sid.Value

        $upds = @(Get-ChildItem -Path $Config.DataDfsUncPath -Filter "rdscollection_*" | Get-ChildItem -Recurse -Filter $updName)
        Write-Verbose "Found $($upds.Count) user profile disk(s)"

        if ($upds.Count -eq 0) {
            Write-Output "No user profile disks found for '$($user.UserPrincipalName)'"
        }
        else {
            foreach ($upd in $upds) {
                if ($PSCmdlet.ShouldProcess($upd.FullName, "Remove user profile disk")) {
                    try {
                        $upd | Remove-Item -Force
                    }
                    catch {
                        Write-Output "Unable to remove user profile disk '$($upd.FullName)'. You must do this manually"
                    }
                }
            }
        }

        $userFoldersPath = Join-Path $Config.FoldersDfsUncPath $user.SamAccountName
        if (-not (Test-Path $userFoldersPath)) {
            Write-Output "The path '$userFoldersPath' was not found"
        }
        else {
            if ($PSCmdlet.ShouldProcess($userFoldersPath, "Remove user folder")) {
                try {
                    $userFoldersPath | Remove-Item -Recurse -Force
                }
                catch {
                    Write-Output "Unable to remove user folder '$userFoldersPath'. You must do this manually"
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($user.UserPrincipalName, "Remove mailbox and AD user object")) {
            $mbx | Remove-Mailbox -Force -Confirm:$false
        }
    }
}