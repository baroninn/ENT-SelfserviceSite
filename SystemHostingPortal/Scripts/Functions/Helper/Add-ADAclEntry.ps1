<#

.SYNOPSIS
    Resolves AD Schema Name to GUID.

.DESCRIPTION
    Takes a schema name, and resolves it into a usable GUID. This is useful when setting permissions, because the schema name can not be used.

.EXAMPLE
    Resolve-ADSchemaName -Name UserObject

    Guid
    ----
    bf967aba-0de6-11d0-a285-00aa003049e2

#>
function Resolve-ADSchemaName {
    [Cmdletbinding()]
    param (
        [string]$Name
    )
    
    #GUIDs: https://technet.microsoft.com/en-us/library/cc755430(v=ws.10).aspx

    switch ($Name) {
        'All' {
            [guid]::Empty
        }
        'MembersProperty' {
            [guid]'bf9679c0-0de6-11d0-a285-00aa003049e2'
        }
        'UserObject' {
            [guid]'bf967aba-0de6-11d0-a285-00aa003049e2'
        }
        'GroupObject' {
            [guid]'bf967a9c-0de6-11d0-a285-00aa003049e2'
        }
        default {
            Write-Error "Unknown name '$Name'."
        }
    }
}

<#

.SYNOPSIS
    Add ACL to an AD object/property.

.DESCRIPTION
    Adds an ACL to either an AD object or property. This can be used to set granular permissions in AD. For example, a user can be granted access to change members of all group objects in a specific OU.

.EXAMPLE
        Add-ADAclEntry -ObjectType MembersProperty -InheritedObjectType GroupObject -TargetOrganizationalUnit "OU=DistributionGroups,DC=contoso,DC=com" -User "CONTOSO\DistributionGroupAdmins" -AccessControlType Allow -Rights ReadProperty, WriteProperty -Inheritance Descendents

        Grants the group CONTOSO\DistributionGroupAdmins rights to edit members of groups in the OU DistributionGroups.

#>
function Add-ADAclEntry {
    [Cmdletbinding()]
    param (
        # AD object that this should apply to.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('All', 'UserObject', 'GroupObject','MembersProperty')]
        [string]
        $ObjectType,

        # AD object that can inherit this.
        [Parameter(ParameterSetName='AddAclSimple')]
        [Parameter(ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('All', 'UserObject', 'GroupObject','MembersProperty')]
        [string]
        $InheritedObjectType='All',

        # Organizational Unit to apply the ACL on.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [string]
        $TargetOrganizationalUnit,

        # User or group that should get this permission.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [string]
        $User,

        # Security Identifier of the object that will either be allowed ot denied access.
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [System.Security.Principal.SecurityIdentifier]$SecurityIdentifier,

        # Set if this is an allow or deny ACL.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('Allow', 'Deny')]
        [System.Security.AccessControl.AccessControlType]
        $AccessControlType,

        # Rights that should be granted to the object/property.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('CreateChild', 'DeleteChild', 'ListChildren', 'Self', 'ReadProperty', 'WriteProperty', 'DeleteTree', 'ListObject', 
        'ExtendedRight', 'Delete', 'ReadControl', 'GenericExecute', 'GenericWrite', 'GenericRead', 'WriteDacl', 'WriteOwner', 'GenericAll', 'Synchronize', 'AccessSystemSecurity')]
        [System.DirectoryServices.ActiveDirectoryRights[]]
        $Rights,

        # Set if this ACL should be inherited.
        [Parameter(Mandatory, ParameterSetName='AddAclSimple')]
        [Parameter(Mandatory, ParameterSetName='AddAclWithSecurityIdentifier')]
        [ValidateSet('None', 'All', 'Descendents', 'SelfAndChildren', 'Children')]
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]
        $Inheritance
    )

    Set-StrictMode -Version 2
    $ErrorActionPreference = 'Stop'

    $applyObject   = Resolve-ADSchemaName -Name $ObjectType
    $inheritObject = Resolve-ADSchemaName -Name $InheritedObjectType

    if ($PSCmdlet.ParameterSetName -eq "AddAclSimple") {
        $ntaccount = New-Object System.Security.Principal.NTAccount($User)
        $sid       = $ntaccount.Translate([System.Security.Principal.SecurityIdentifier])
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AddAclWithSecurityIdentifier") {
        $sid       = $SecurityIdentifier
    }
    else {
        Write-Error "Unknown ParameterSetName '$($PSCmdlet.ParameterSetName)'."
    }

    Write-Verbose "Getting ACL for '$TargetOrganizationalUnit'."
    $ou   = [ADSI]"LDAP://$TargetOrganizationalUnit"
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid,$Rights,$AccessControlType,$applyObject,$Inheritance,$inheritObject)

    Write-Verbose "Adding ACL to '$TargetOrganizationalUnit'."
    $ou.ObjectSecurity.AddAccessRule($rule)
    $ou.CommitChanges()
}