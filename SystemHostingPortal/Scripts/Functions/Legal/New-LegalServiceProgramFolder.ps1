function New-LegalServiceProgramFolder {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Source,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Destination
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }

    Process {
        if (-not (Test-Path -Path $Source)) {
            Write-Error "Source '$Source' was not found."
        }

        if (-not (Test-Path -Path $Destination)) {
            Write-Verbose "Creating directory '$Destination'"
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        else {
            $files = Get-ChildItem -Path $Destination -Recurse
            if ($files -ne $null) {
                Write-Error "Destination '$Destination' is not empty."
            }
        }

        Write-Verbose "Copying '$Source' to '$Destination'..."
        Copy-Item -Path "$Source\*" -Destination $Destination -Recurse
    }
}