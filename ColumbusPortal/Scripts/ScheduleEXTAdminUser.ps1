[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Customer,
    [parameter(mandatory)]
    [string]$Firstname,
    [parameter(mandatory)]
    [string]$Lastname,
    [parameter(mandatory)]
    [string]$Email,
    [parameter(mandatory)]
    [string]$Company,
    [parameter(mandatory)]
    [string]$Description,
    [parameter(mandatory)]
    [datetime]$Expiredate
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

[DateTime]$DateTime = Get-Date -Format g

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
$sqlConnection.Open()

$Update = "INSERT INTO [dbo].[EXTAdminUsers_Scheduled](Status, Organization, FirstName, LastName, Email, SamAccountName, Company, Description, DateTime, ExpireDate, Customer) VALUES ('Scheduled', 'Scheduled', '$Firstname', '$Lastname', '$email', 'External', '$Company', '$Description', '$DateTime', '$ExpireDate', '$Customer')"
$cmd = $sqlConnection.CreateCommand()
$cmd.CommandText = $update
$result = $cmd.ExecuteReader()
$sqlConnection.Close()
