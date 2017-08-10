New-Variable -Name Stopwatch -Value $null -Scope Global -Force

function Write-VerboseEx {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    if ($GLOBAL:Stopwatch -eq $null) {
        Start-VerboseEx
    }

    Write-Verbose -Message ("{0}> {1}" -f $GLOBAL:Stopwatch.Elapsed.TotalSeconds, $Message)
}

function Start-VerboseEx {
    param ()

    Write-Verbose "Starting VerboseEx stopwatch..."
    $GLOBAL:Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Start-Sleep -Milliseconds 1
}

function Stop-VerboseEx {
    param ()

    $GLOBAL:Stopwatch.Stop()
    $GLOBAL:Stopwatch = $null
}