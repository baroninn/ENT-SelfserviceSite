function New-TenantDatabase {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        
    }
    Process {
        # Nice and vulnerable to injections
        $query = @"
USE TemplateDB;
GO

CREATE DATABASE {0}
GO

ALTER DATABASE [{0}]
	MODIFY FILE (Name = N'{0}', FILEGROWTH = 10%)
GO

USE [{0}]
GO

EXEC sp_grantlogin N'CAPTO\{0}_NAV_SVC'
CREATE USER "CAPTO\{0}_NAV_SVC" FOR LOGIN "CAPTO\{0}_NAV_SVC"
EXEC sp_addrolemember N'db_owner', N'CAPTO\{0}_NAV_SVC'
"@

        $query = $query -f $TenantName.ToUpper()
        $script = {
            [Cmdletbinding()]
            param (
                [Parameter(Mandatory)]
                [string]$Query
            )
            $ErrorActionPreference = 'Stop'
            Set-StrictMode -Version 2.0

            Invoke-SqlCmd -Query $Query
        }

        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $script -ArgumentList $query
        }
        else {
            Invoke-Command -ScriptBlock $script -ArgumentList $query
        }
    }
}