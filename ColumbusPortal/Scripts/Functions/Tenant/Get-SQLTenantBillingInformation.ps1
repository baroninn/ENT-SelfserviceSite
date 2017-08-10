#requires -version 3

function New-BillingObject {
    [Cmdletbinding()]
    param()

    Begin {
    }
    Process {
        [pscustomobject]@{
            FileServer = [pscustomobject]@{
                Allocated = 0
                FreeSpace = 0
                Used      = 0
            }
            Totalstorage = [pscustomobject]@{
                TotalAllocated = 0
            }
            ADUser = [pscustomobject]@{
                Users = @()
            }
            Server = [pscustomobject]@{
                Servers = @()
            }
            Database = [pscustomobject]@{
                TotalUsage = 0
            }

            Office365 = [pscustomobject]@{
                Info = @()
            }
        }
    }
}

function New-ADUserBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            DisplayName        = $null
            PrimarySmtpAddress = 'null'
            SAMAccountName     = $null
            Type               = $null
            Disabled           = $false
            TestUser           = $false
            LightUser          = $false
        }
    }
}

function New-ENTServerBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            Name            = $null
            OperatingSystem = $null
            Memory          = 0
            CPUCount        = 0
        }
    }
}

function New-Office365BillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            TenantID           = $null
            License            = $null
            Admin              = $null
            PartnerName        = $null
        }
    }
}

function Get-SQLTenantBillingInformation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        
    }

    Process {

        $stats = New-BillingObject
        
        # connection
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select top 1 TenantBilling FROM [dbo].[{0}_CustomerReport] ORDER BY [dbo].[{0}_CustomerReport].Date DESC;" -f $Organization

        # execute - data reader
        $reader = $sqlCmd.ExecuteReader()
        $tables = @()
        while ($reader.Read()) {
            $tables += $reader["TenantBilling"]
        }
        $reader.Close()

        $JSONBilling = $tables | ConvertFrom-Json

        $JSONBilling


    }

}