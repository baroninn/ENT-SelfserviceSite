<#

.SYNOPSIS
    Add ACL to a filesystem object.

.DESCRIPTION
    You can use this cmdlet to add an ACL to filesystemobjects or create an ACL template to apply later.

.EXAMPLE
    Add-AclEntry -User "CONTOSO\JohnDoe" -FileSystemRights Modify -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -Path "C:\Data\userlist.csv"

    This command adds an ACL to the file C:\Data\userlist.csv for the user JohnDoe.

.EXAMPLE
    $user = Get-ADUser -Identity JohnDoe
    $sid = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $user.SID

    Add-AclEntry -SecurityIdentifier $sid -FileSystemRights Modify -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -Path "C:\Data\userlist.csv"

    This command uses a security identifier to set ACL on a filesystem object.

.EXAMPLE
    $aclTemplate = Add-AclEntry -User "CONTOSO\JohnDoe" -FileSystemRights Modify -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -OnlyReturnAcl

    This command generates an ACL template to use later.

.EXAMPLE
    Add-AclEntry -AclToAdd $aclTemplate -Path "C:\Data\userlist.csv"

    This command uses an ACL template.

#>
function Add-AclEntry {
    param(
        # Permissions to either allow or deny in the ACL. Accepts an array of values.
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('ReadData', 'ReadData', 'CreateFiles', 'CreateFiles', 'AppendData', 'AppendData', 'ReadExtendedAttributes', 'WriteExtendedAttributes', 'ExecuteFile', 'ExecuteFile', 'DeleteSubdirectoriesAndFiles', 'ReadAttributes', 'WriteAttributes', 'Write', 'Delete', 'Read
Permissions', 'Read', 'ReadAndExecute', 'Modify', 'ChangePermissions', 'TakeOwnership', 'Synchronize', 'FullControl')]
        [System.Security.AccessControl.FileSystemRights[]]$FileSystemRights,

        # Choose whether the ACL should allow or deny the filesystemrights chosen.
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('Allow', 'Deny')]
        [System.Security.AccessControl.AccessControlType]$AccessControlType,

        # User (or group) that will either be allowed or denied access. If it is a domain user, use "DOMAIN\username" or "username@domain".
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [string]$User,

        # Security Identifier of the object that will either be allowed ot denied access.
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [System.Security.Principal.SecurityIdentifier]$SecurityIdentifier,


        # See InheritanceFlags at MSDN for further information: https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.inheritanceflags(v=vs.110).aspx
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('None','ContainerInherit','ObjectInherit')]
        [System.Security.AccessControl.InheritanceFlags[]]$InheritanceFlags,

        # See PropagationFlags at MSDN for further information: https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.propagationflags(v=vs.110).aspx
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('None','NoPropagateInherit','InheritOnly')]
        [System.Security.AccessControl.PropagationFlags]$PropagationFlags,

        # Will return an ACL template to use later.
        [Parameter(Mandatory, ParameterSetName='OnlyCreateAcl')]
        [switch]$OnlyReturnAcl,

        # Accepts an ACL template, or an array of ACL templates.
        [Parameter(Mandatory, ParameterSetName='AddAclWithObject')]
        [System.Security.AccessControl.FileSystemAccessRule[]]$AclToAdd,

        # Path of the filesystem object to set ACL.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithObject')]
        [ValidateScript({ Test-Path $_ })] 
        [string]$Path
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    if ($PSCmdlet.ParameterSetName -eq 'AddAclWithSecurityIdentifier') {
        [System.Security.Principal.SecurityIdentifier]$User = $SecurityIdentifier
    }

    if ($PSCmdlet.ParameterSetName -eq 'AddAclSimple' -or $PSCmdlet.ParameterSetName -eq 'AddAclWithSecurityIdentifier' -or $PSCmdlet.ParameterSetName -eq 'OnlyCreateAcl') {
        Write-Verbose "Creating AccessRule type $AccessControlType for $User with '$($FileSystemRights -join ', ')' permissions, Inheritance $InheritanceFlags, Propagation $PropagationFlags"
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($User, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
    }

    if ($PSCmdlet.ParameterSetName -eq 'AddAclSimple' -or $PSCmdlet.ParameterSetName -eq 'AddAclWithObject' -or $PSCmdlet.ParameterSetName -eq 'AddAclWithSecurityIdentifier') {
        Write-Verbose "Getting ACL for $Path"
        $acl = Get-Acl -Path $Path

        if ($PSCmdlet.ParameterSetName -eq 'AddAclSimple' -or $PSCmdlet.ParameterSetName -eq 'AddAclWithSecurityIdentifier') {
            $acl.AddAccessRule($accessRule)
        }
        else {
            foreach ($newAcl in $AclToAdd) {
                $acl.AddAccessRule($newAcl)
            }
        }
    
        Write-Verbose "Setting ACL on $Path"
        Set-Acl -Path $Path -AclObject $acl
    }
    else {
        return $accessRule
    }
}
