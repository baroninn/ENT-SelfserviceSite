function New-MemberService {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory)]
        [string]$DatabaseServer,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$ServerInstance,

        [string]$Server = "hosting.capto.dk",

        [Parameter(Mandatory)]
        [pscredential]$ServiceAccount,

        [int]$ManagementServicesPort = 7045,

        [int]$ClientServicesPort = 7046,

        [int]$SOAPServicesPort = 7047,

        [int]$ODataServicesPort = 7048,

        [ValidateSet('Windows','UserName')]
        [string]$CredentialType = 'Windows',

        [string]$CertificateThumbprint,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }

    Process {
        $newMemberService = {
            param (
                $ServerInstance,
                $DatabaseServer,
                $DatabaseName,
                $ServiceAccountCredential,
                $ManagementServicesPort,
                $ClientServicesPort,
                $SOAPServicesPort,
                $ODataServicesPort,
                $CredentialType,
                $CertificateThumbprint
            )
            
            # Import NAV module. Microsoft code.
            $errorVariable = $null

            # Import-Module or register Snap-in, that will enable side-by-side registrations of management dll
            function RegisterSnapIn($snapIn, $visibleName)
            {
              $nstPath = "HKLM:\SOFTWARE\Microsoft\Microsoft Dynamics NAV\80\Service"
              $managementDllPath = Join-Path (Get-ItemProperty -path $nstPath).Path '\Microsoft.Dynamics.Nav.Management.dll'
  
              # First try to import the management module
              Import-Module $managementDllPath -ErrorVariable errorVariable -ErrorAction SilentlyContinue
  
              if (Check-ErrorVariable -eq $true)
              {
                # fallback to add the snap-in
                if ((Get-PSSnapin -Name $snapIn -ErrorAction SilentlyContinue) -eq $null)
                {
                    if ((Get-PSSnapin -Registered $snapIn -ErrorAction SilentlyContinue) -eq $null)
                    {
                        Write-Error "Unable to register module '$visibleName'" -ErrorAction Stop
                    }
                    else
                    {
                        Add-PSSnapin $snapIn            
                    }
                }
              }
            }

            # Check if there is any error in the ErrorVariable
            function Check-ErrorVariable
            {
                return ($errorVariable -ne $null -and $errorVariable.Count -gt 0)
            }

            # Register Microsoft Dynamics NAV Management Snap-in
            RegisterSnapIn "Microsoft.Dynamics.Nav.Management" "Microsoft Dynamics NAV Management Snap-in"
            ### End of Microsoft code

            $navparams = @{
                ServerInstance = $ServerInstance
                ManagementServicesPort       = $ManagementServicesPort 
                ClientServicesPort           = $ClientServicesPort 
                SOAPServicesPort             = $SOAPServicesPort 
                ODataServicesPort            = $ODataServicesPort 
                DatabaseServer               = $DatabaseServer 
                DatabaseName                 = $DatabaseName 
                ServiceAccount               = "User"
                ServiceAccountCredential     = $ServiceAccountCredential 
                ClientServicesCredentialType = $CredentialType
            }
            if ($CertificateThumbprint -ne $null -and $CertificateThumbprint -ne '') {
                $navparams.Add("ServicesCertificateThumbprint", $CertificateThumbprint)
            }

            New-NAVServerInstance @navparams
            Get-NAVServerInstance -ServerInstance $ServerInstance | Set-NAVServerInstance -Start 
        }

        Write-Verbose "Creating new service '$ServerInstance'..."
        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $newMemberService -ArgumentList $ServerInstance, $DatabaseServer, $DatabaseName, $ServiceAccount, $ManagementServicesPort, $ClientServicesPort, $SOAPServicesPort, $ODataServicesPort, $CredentialType, $CertificateThumbprint
        }
        else {
            throw "This cmdlet can only run on a remote computer."
        }
    }
}