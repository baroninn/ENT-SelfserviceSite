function Get-AzureVMs {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $creds = Get-RemoteCredentials -SSS
        #$Config = Get-SQLEntConfig -Organization $Organization

        ## Log in to Azure
        #Import-Module AzureRM.Compute | Out-Null
        #Get-Module | Out-File c:\test.txt -Append -Force
        #$Username = $Config.AdminUser
        #$password = ConvertTo-SecureString $Config.AdminPass -AsPlainText -Force

        <#
        $Username = '2fad6202-8a03-485b-b0e7-87f78be287da'
        $password = ConvertTo-SecureString 'w/FJPlEujT82xzt4w3NWkxtIhxfyNG+gc9KTxtBslT8=' -AsPlainText -Force
        $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password
        $Login = Login-AzureRmAccount -Credential $Credentials -ServicePrincipal -TenantId 'c8399d6d-f345-424d-b58c-526612a63f03'
        #>
    }
    
    Process {
    $test ={
        Import-Module AzureRM
        $Username = 'admin@castestcloud.onmicrosoft.com'
        $password = ConvertTo-SecureString 'Start2017!' -AsPlainText -Force
        $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

        $Credentials | out-file c:\test.txt -Append -Force
        $Login = Login-AzureRmAccount -Credential $Credentials -SubscriptionId ed30c243-073c-4457-aea2-8df7e2591792 -TenantId b9084bb2-f051-4a00-a62f-b0c617f582d4

        $Info = @()

        foreach ($i in (Get-AzureRmVM -status)) {
            $VM = Get-AzureRmVM -Name $i.Name -ResourceGroupName $i.ResourceGroupName -Status

            $Info += [pscustomobject]@{
                  ResourceGroupName = $vm.ResourceGroupName
                  Name              = $vm.Name
                  VmId              = $i.VmId
                  Location          = $i.Location
                  VmSize            = $i.HardwareProfile.VmSize
                  ProvisioningState = $i.ProvisioningState
                  PowerState        = $i.PowerState
                  IPAddress         = "0.0.0.0"
                  CPU               = "1"
                  RAM               = "RAM"
            }
        }

        #$Info | Out-File c:\test.txt -Append -Force

        return $Info

    }
    $PCS = Invoke-Command -ScriptBlock $test
    return $PCS

        <#
        $Info = [pscustomobject]@{
            ResourceGroupName = "TEST"
            Name              = "TEST"
            VmId              = "TEST"
            Location          = "TEST"
            VmSize            = "TEST"
            ProvisioningState = "TEST"
            PowerState        = "TEST"
        }
        $Info | Out-File c:\test.txt -Append -Force
        $info
        #>
    }
}

