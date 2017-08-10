$test = gc "C:\Users\jst.DK\Documents\GitHub\ENTSSS\SystemHostingPortal\Scripts\Functions\Config\PRV.txt"

$Config = Get-Content "C:\Users\jst.DK\Documents\GitHub\ENTSSS\SystemHostingPortal\Scripts\Functions\Config\PRV\PRV.txt" | ConvertFrom-Json

$test = @()
$test += [pscustomobject]@{
        UserContainer  = ""
        ExchangeServer = ""
        DomainFQDN     = ""
        Domain         = "CORP"
        EmailDomains   = [pscustomobject]@{
            DomainName   = "provinord.dk","kryta.dk","grathwol.dk"
            }
        }

$test | ConvertTo-Json | Out-File "C:\Users\jst.DK\Documents\PRV.txt" -Force

$Config.EmailDomains.DomainName

