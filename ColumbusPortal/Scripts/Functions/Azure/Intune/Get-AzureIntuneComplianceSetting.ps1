function Get-AzureIntuneComplianceSetting {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$false)]
        [string]$ID
    )
    

    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if (-not $ID) {

            $Configurations = @()
            try {
                $ComplianceConfigurations = @(Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies" -Headers $header -Method Get).value
            }
            catch {
                throw "No configurations exist.."
            }

            if ($ComplianceConfigurations) {
                foreach ($i in $ComplianceConfigurations) {

                    if ($i."@odata.type" -like "#microsoft.graph.androidCompliancePolicy") {

                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "Android"
                        ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                        try{
                            if ($i.description -eq $null) {
                                $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMinimumVersion -eq $null) {
                                $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMaximumVersion -eq $null) {
                                $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumLength -eq $null) {
                                $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordExpirationDays -eq $null) {
                                $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                                $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                                $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.minAndroidSecurityPatchLevel -eq $null) {
                                $i | Add-Member -Name minAndroidSecurityPatchLevel -MemberType NoteProperty -Value "null" -Force
                            }
                        
                        }catch{
                            throw "Error in adding null properties to device configuration.."
                        }

                        $Configurations += $i

                    }
                    if ($i."@odata.type" -like "#microsoft.graph.androidForWorkCompliancePolicy") {

                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "AFW"
                        ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                        try{
                            if ($i.description -eq $null) {
                                $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMinimumVersion -eq $null) {
                                $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMaximumVersion -eq $null) {
                                $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumLength -eq $null) {
                                $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordExpirationDays -eq $null) {
                                $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                                $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                                $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.minAndroidSecurityPatchLevel -eq $null) {
                                $i | Add-Member -Name minAndroidSecurityPatchLevel -MemberType NoteProperty -Value "null" -Force
                            }
                        
                        }catch{
                            throw "Error in adding null properties to device configuration.."
                        }

                        $Configurations += $i

                    }
                    if ($i."@odata.type" -like "#microsoft.graph.windows10CompliancePolicy") {
                            $i | Add-Member -Name platform -MemberType NoteProperty -Value "Win10"
                            ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                            try{
                                if ($i.description -eq $null) {
                                    $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.osMinimumVersion -eq $null) {
                                    $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.osMaximumVersion -eq $null) {
                                    $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.mobileOsMinimumVersion -eq $null) {
                                    $i | Add-Member -Name mobileOsMinimumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.mobileOsMaximumVersion -eq $null) {
                                    $i | Add-Member -Name mobileOsMaximumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passwordMinimumLength -eq $null) {
                                    $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passwordExpirationDays -eq $null) {
                                    $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                                    $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                                    $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passwordMinimumCharacterSetCount -eq $null) {
                                    $i | Add-Member -Name passwordMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                                }
                        
                            }catch{
                                throw "Error in adding null properties to device configuration.."
                            }
                            $Configurations += $i
                        }
                    if ($i."@odata.type" -like "#microsoft.graph.iosCompliancePolicy") {
                            $i | Add-Member -Name platform -MemberType NoteProperty -Value "IOS"
                            ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                            try{
                                if ($i.description -eq $null) {
                                    $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.osMinimumVersion -eq $null) {
                                    $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.osMaximumVersion -eq $null) {
                                    $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passcodeExpirationDays -eq $null) {
                                    $i | Add-Member -Name passcodeExpirationDays -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passcodeMinimumLength -eq $null) {
                                    $i | Add-Member -Name passcodeMinimumLength -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passcodeMinutesOfInactivityBeforeLock -eq $null) {
                                    $i | Add-Member -Name passcodeMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passcodeMinimumCharacterSetCount -eq $null) {
                                    $i | Add-Member -Name passcodeMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.passcodePreviousPasscodeBlockCount -eq $null) {
                                    $i | Add-Member -Name passcodePreviousPasscodeBlockCount -MemberType NoteProperty -Value "null" -Force
                                }
                        
                            }catch{
                                throw "Error in adding null properties to device configuration.."
                            }
                            $Configurations += $i
                        }
                    if ($i."@odata.type" -like "#microsoft.graph.macOSCompliancePolicy") {

                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "macOS"
                        ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                        try{
                            if ($i.description -eq $null) {
                                $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMinimumVersion -eq $null) {
                                $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMaximumVersion -eq $null) {
                                $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumLength -eq $null) {
                                $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumCharacterSetCount -eq $null) {
                                $i | Add-Member -Name passwordMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordExpirationDays -eq $null) {
                                $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                                $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                                $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                            }

                        }catch{
                            throw "Error in adding null properties to device configuration.."
                        }

                        $Configurations += $i

                    }
                    
                }
                return $ComplianceConfigurations
            }
        } 
        else {
            $i = @(Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID" -Headers $header -Method Get)

            if ($i."@odata.type" -like "#microsoft.graph.androidCompliancePolicy") {

                    $i | Add-Member -Name platform -MemberType NoteProperty -Value "Android"
                    ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                    try{
                        if ($i.description -eq $null) {
                            $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMinimumVersion -eq $null) {
                            $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMaximumVersion -eq $null) {
                            $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinimumLength -eq $null) {
                            $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordExpirationDays -eq $null) {
                            $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                            $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                            $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.minAndroidSecurityPatchLevel -eq $null) {
                            $i | Add-Member -Name minAndroidSecurityPatchLevel -MemberType NoteProperty -Value "null" -Force
                        }
                        
                    }catch{
                        throw "Error in adding null properties to device configuration.."
                    }
                }
            if ($i."@odata.type" -like "#microsoft.graph.androidForWorkCompliancePolicy") {

                    $i | Add-Member -Name platform -MemberType NoteProperty -Value "AFW"
                    ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                    try{
                        if ($i.description -eq $null) {
                            $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMinimumVersion -eq $null) {
                            $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMaximumVersion -eq $null) {
                            $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinimumLength -eq $null) {
                            $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordExpirationDays -eq $null) {
                            $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                            $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                            $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.minAndroidSecurityPatchLevel -eq $null) {
                            $i | Add-Member -Name minAndroidSecurityPatchLevel -MemberType NoteProperty -Value "null" -Force
                        }
                        
                    }catch{
                        throw "Error in adding null properties to device configuration.."
                    }

                    $Configurations += $i

                }
            if ($i."@odata.type" -like "#microsoft.graph.windows10CompliancePolicy") {
                    $i | Add-Member -Name platform -MemberType NoteProperty -Value "Win10"

                    ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                    try{
                        if ($i.description -eq $null) {
                            $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.mobileOsMinimumVersion -eq $null) {
                            $i | Add-Member -Name mobileOsMinimumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.mobileOsMaximumVersion -eq $null) {
                            $i | Add-Member -Name mobileOsMaximumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMinimumVersion -eq $null) {
                            $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMaximumVersion -eq $null) {
                            $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinimumLength -eq $null) {
                            $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordExpirationDays -eq $null) {
                            $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                            $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                            $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passwordMinimumCharacterSetCount -eq $null) {
                            $i | Add-Member -Name passwordMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                        }
                        
                    }catch{
                        throw "Error in adding null properties to device configuration.."
                    }
                }
            if ($i."@odata.type" -like "#microsoft.graph.iosCompliancePolicy") {
                    $i | Add-Member -Name platform -MemberType NoteProperty -Value "IOS"
                
                    ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                    try{
                        if ($i.description -eq $null) {
                            $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMinimumVersion -eq $null) {
                            $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.osMaximumVersion -eq $null) {
                            $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passcodeExpirationDays -eq $null) {
                            $i | Add-Member -Name passcodeExpirationDays -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passcodeMinimumLength -eq $null) {
                            $i | Add-Member -Name passcodeMinimumLength -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passcodeMinutesOfInactivityBeforeLock -eq $null) {
                            $i | Add-Member -Name passcodeMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passcodeMinimumCharacterSetCount -eq $null) {
                            $i | Add-Member -Name passcodeMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                        }
                        if ($i.passcodePreviousPasscodeBlockCount -eq $null) {
                            $i | Add-Member -Name passcodePreviousPasscodeBlockCount -MemberType NoteProperty -Value "null" -Force
                        }
                        
                    }catch{
                        throw "Error in adding null properties to device configuration.."
                    }
                }
            if ($i."@odata.type" -like "#microsoft.graph.macOSCompliancePolicy") {

                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "macOS"
                        ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                        try{
                            if ($i.description -eq $null) {
                                $i | Add-Member -Name description -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMinimumVersion -eq $null) {
                                $i | Add-Member -Name osMinimumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.osMaximumVersion -eq $null) {
                                $i | Add-Member -Name osMaximumVersion -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumLength -eq $null) {
                                $i | Add-Member -Name passwordMinimumLength -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinimumCharacterSetCount -eq $null) {
                                $i | Add-Member -Name passwordMinimumCharacterSetCount -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordExpirationDays -eq $null) {
                                $i | Add-Member -Name passwordExpirationDays -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordMinutesOfInactivityBeforeLock -eq $null) {
                                $i | Add-Member -Name passwordMinutesOfInactivityBeforeLock -MemberType NoteProperty -Value "null" -Force
                            }
                            if ($i.passwordPreviousPasswordBlockCount -eq $null) {
                                $i | Add-Member -Name passwordPreviousPasswordBlockCount -MemberType NoteProperty -Value "null" -Force
                            }
                        
                        }catch{
                            throw "Error in adding null properties to device configuration.."
                        }

                        $Configurations += $i

                    }

            return $i
        }
    }
}
