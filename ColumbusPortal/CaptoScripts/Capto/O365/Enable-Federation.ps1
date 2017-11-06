function Enable-Federation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,
        [Parameter(Mandatory)]
        [string]$Domain
    )

    Begin {
    
    $ErrorActionPreference = "Stop"
    $Config = Get-TenantConfig -TenantName $TenantName

    Connect-O365 -Organization $TenantName
    
    }

    Process {

        ## Trying to add the UPN's for the customer..
        
        if ($Config.TenantID365.ID -eq '43eea929-d726-4742-83a9-603c12a0d195') {

                Set-MsolADFSContext -Computer 'CPO-ADFS-01.hosting.capto.dk'

                try{
                    if(-not (Get-MsolDomain -DomainName $Domain -ErrorAction SilentlyContinue)){
                        New-MsolFederatedDomain -SupportMultipleDomain -DomainName $Domain
                    }
                    else{
                        Convert-MsolDomainToFederated -SupportMultipleDomain -DomainName $Domain
                    }
                }
                catch{
                    Write-Error "Error: $_"
                    }
        }
        else{
                #$certRefs=Get-AdfsCertificate -CertificateType Token-Signing
                #$certBytes=$certRefs[0].Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
                #[System.IO.File]::WriteAllBytes("c:\Cert\tokensigning.cer", $certBytes)

                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("C:\Cert\tokensigning.cer")
                $certData = [system.convert]::tobase64string($cert.rawdata)

                $url="https://sts.capto.dk/adfs/ls/"
                $uri="http://$Domain/adfs/services/trust/"
                $ura="https://sts.capto.dk/adfs/services/trust/2005/usernamemixed"
                $logouturl="https://sts.capto.dk/adfs/ls/"
                $metadata="https://sts.capto.dk/adfs/services/trust/mex"
                #command to enable SSO
            try{
                Set-MsolDomainAuthentication -DomainName $Domain -Authentication Federated -ActiveLogOnUri $ura -PassiveLogOnUri $url -MetadataExchangeUri $metadata -SigningCertificate $certData -IssuerUri $uri -LogOffUri $logouturl -PreferredAuthenticationProtocol WsFed
            }
            catch{
                Write-Verbose "Federation settings of $Domain did not succeed.. Error: $_"
                throw "Federation settings of $Domain did not succeed.. Error: $_"
            }
        }
    }
}

