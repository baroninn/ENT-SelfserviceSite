function New-ExchangeProxyModule {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Command,

        [Parameter(Mandatory)]
        [psobject]$Config,

        # Skips check for existing modules, and always creates a new one.
        [switch]$NewModule
    )

    $sessionName = 'ENTExchange'

    $returnModule = $null
    if (-not $NewModule) {
        Write-Verbose "Looking for existing Exchange module..."
        foreach ($module in (Get-Module -Name "tmp_*")) {
            Write-Verbose "'$($module.Name)' contains: $([string]$module.ExportedCommands.Keys -join ', ')."
            $count = 0
            foreach ($c in $Command) {
                if ($module.ExportedCommands.ContainsKey($c)) {
                    $count++
                }
                else {
                    break
                }
            }

            if ($count -eq $Command.Count) {
                Write-Verbose "Found module '$($module.Name)'."
                $returnModule = $module
                break
            }
        }
    }

    if ($returnModule) {
        return $returnModule
    }
    
    # Remove existing sessions
    Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue | Remove-PSSession

    try {
        $returnModule = Import-PSSession -Session (New-PSsession -Name $sessionName -ConfigurationName Microsoft.Exchange -ConnectionUri "$($Config.ExchangeServer)/Powershell") -CommandName $Command
    }
    catch {
        if ($_.FullyQualifiedErrorId -ne 'ErrorNoCommandsImportedBecauseOfSkipping,Microsoft.PowerShell.Commands.ImportPSSessionCommand') {
            throw $_
        }
        else {
            if ($returnModule -eq $null) {
                return
            }
        }
    }
    
    # Remove the module from this scope, to avoid it getting stuck in the users scope.
    Get-Module -Name $returnModule.Name | Remove-Module
    Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue | Remove-PSSession

    return $returnModule
}