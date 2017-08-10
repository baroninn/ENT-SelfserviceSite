# This is really a hack, it won't be able to resolve anything but default drive shares
function Resolve-UncPath {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ParameterSetName="UNCPath")]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName="LocalPath")]
        [string]$LocalPath,

        [Parameter(Mandatory, ParameterSetName="LocalPath")]
        [string]$ComputerName
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    if ($PSCmdlet.ParameterSetName -eq 'UNCPath') {
        if (-not $Path.StartsWith('\\')) {
            throw "'$Path' is not a valid UNC path"
        }

        $localPath = $Path.Substring(2)
        $localPath = $localPath.Substring($localPath.IndexOf('\') + 1)
        $localPath = $localPath.Replace('$',':')

        $localPath
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'LocalPath') {
        if ($LocalPath[1] -ne ':') {
            Write-Error "'$LocalPath' is not a valid path"
        }
        elseif ($LocalPath.IndexOf(':') -ne $LocalPath.LastIndexOf(':'))
        {
            Write-Error "LocalPath may only contain a single ':'"
        }

        "\\{0}\{1}" -f  $ComputerName, $LocalPath.Replace(':', '$')
    }
    else {
        Write-Error "Unknown ParameterSetName $($PSCmdlet.ParameterSetName)"
    }
}