function Get-AzureIntuneDeviceConfiguration {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Header,

        [Parameter(Mandatory = $false)]
        [string]$ID,

        [Parameter(Mandatory = $false)]
        [switch]$Updates
    )
    

    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if ($Updates) {
            $Configurations = @()
            try {
                $DeviceConfigurations = @(Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations" -Headers $header -Method Get).value
            }
            catch {
                throw "No configurations exist.."
            }
            if ($DeviceConfigurations) {
                foreach ($i in $DeviceConfigurations) {
                    if ($i."@odata.type" -like "#microsoft.graph.windowsUpdateForBusinessConfiguration") {

                            $i | Add-Member -Name platform -MemberType NoteProperty -Value "Win10Update"
                            ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                            try{
                                
                                if ($i.installationSchedule -eq $null) {
                                    $i | Add-Member -Name installationSchedule -MemberType NoteProperty -Value "null" -Force
                                }
                                if ($i.assignmentStatus -eq $null) {
                                    $i | Add-Member -Name assignmentStatus -MemberType NoteProperty -Value "null" -Force
                                }
                        
                            }catch{
                                throw "Error in adding null properties to device configuration.."
                            }
                            $Configurations += $i
                        }
                    }
                }
            return $Configurations
        }
        else {
            if (-not $ID) {

                $Configurations = @()
                try {
                    $DeviceConfigurations = @(Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations" -Headers $header -Method Get).value
                }
                catch {
                    throw "No configurations exist.."
                }

                if ($DeviceConfigurations) {
                    foreach ($i in $DeviceConfigurations) {

                        if ($i."@odata.type" -like "#microsoft.graph.androidGeneralDeviceConfiguration") {
                                $i | Add-Member -Name platform -MemberType NoteProperty -Value "Android"
                                $Configurations += $i
                            }
                        if ($i."@odata.type" -like "#microsoft.graph.androidForWorkGeneralDeviceConfiguration") {
                            $i | Add-Member -Name platform -MemberType NoteProperty -Value "AFW"
                            $Configurations += $i
                        }
                        if ($i."@odata.type" -like "#microsoft.graph.windows10GeneralConfiguration") {
                                $i | Add-Member -Name platform -MemberType NoteProperty -Value "Win10"
                                ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                                try{
                                    if ($i.edgeSearchEngine -eq $null) {
                                        $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "null" -Force
                                        $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                                    }
                                    elseif ($i.edgeSearchEngine.'@odata.type' -eq "#microsoft.graph.edgeSearchEngine") {
                                        $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineType)" -Force
                                        $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                                    }
                                    elseif ($i.edgeSearchEngine.'@odata.type' -eq "#microsoft.graph.edgeSearchEngineCustom") {

                                        if ($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl -like "*go.microsoft.com*") {
                                            $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl)" -Force
                                            $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                                        }
                                        else{
                                            $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl)" -Force
                                            $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "Custom" -Force
                                        }
                                    }
                                    if ($i.wiFiScanInterval -eq $null) {
                                        $i | Add-Member -Name wiFiScanInterval -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderSignatureUpdateIntervalInHours -eq $null) {
                                        $i | Add-Member -Name defenderSignatureUpdateIntervalInHours -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderDaysBeforeDeletingQuarantinedMalware -eq $null) {
                                        $i | Add-Member -Name defenderDaysBeforeDeletingQuarantinedMalware -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderPotentiallyUnwantedAppAction -eq $null) {
                                        $i | Add-Member -Name defenderPotentiallyUnwantedAppAction -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderScanMaxCpu -eq $null) {
                                        $i | Add-Member -Name defenderScanMaxCpu -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderScheduledQuickScanTime -eq $null) {
                                        $i | Add-Member -Name defenderScheduledQuickScanTime -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderScheduledScanTime -eq $null) {
                                        $i | Add-Member -Name defenderScheduledScanTime -MemberType NoteProperty -Value "null" -Force
                                    }
                                    if ($i.defenderDetectedMalwareActions -eq $null) {
                                        $i | Add-Member -Name defenderlowseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                        $i | Add-Member -Name defendermoderateseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                        $i | Add-Member -Name defenderhighseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                        $i | Add-Member -Name defendersevereseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                        $i | Add-Member -Name defenderDetectedMalwareActions -MemberType NoteProperty -Value "False" -Force
                                    }
                                    else {
                                        $i | Add-Member -Name defenderlowseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.lowSeverity -Force
                                        $i | Add-Member -Name defendermoderateseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.moderateSeverity -Force
                                        $i | Add-Member -Name defenderhighseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.highSeverity -Force
                                        $i | Add-Member -Name defendersevereseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.severeSeverity -Force
                                        $i | Add-Member -Name defenderDetectedMalwareActions -MemberType NoteProperty -Value "True" -Force                            
                                    }
                        
                                }catch{
                                    throw "Error in adding null properties to device configuration.."
                                }
                                $Configurations += $i
                            }
                        if ($i."@odata.type" -like "#microsoft.graph.iosGeneralDeviceConfiguration") {
                                $i | Add-Member -Name platform -MemberType NoteProperty -Value "IOS"
                                $Configurations += $i
                            }
                        if ($i."@odata.type" -like "#microsoft.graph.macOSGeneralDeviceConfiguration") {
                            $i | Add-Member -Name platform -MemberType NoteProperty -Value "macOS"
                            $Configurations += $i
                        }
                    
                    }
                    return $Configurations
                }
            } 
            else {
                $i = @(Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceConfigurations/$ID" -Headers $header -Method Get)

                if ($i."@odata.type" -like "#microsoft.graph.androidGeneralDeviceConfiguration") {
                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "Android"
                    }
                if ($i."@odata.type" -like "#microsoft.graph.androidForWorkGeneralDeviceConfiguration") {
                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "AFW"
                    }
                if ($i."@odata.type" -like "#microsoft.graph.windows10GeneralConfiguration") {
                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "Win10"

                        ### Handle Null properties with fake null's, so that C# can accept it (i'm stronger in PS than C# ;) )
                        try{
                            if ($i.edgeSearchEngine -eq $null) {
                                $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "null" -Force
                                $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                            }
                            elseif ($i.edgeSearchEngine.'@odata.type' -eq "#microsoft.graph.edgeSearchEngine") {
                                $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineType)" -Force
                                $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                            }
                            elseif ($i.edgeSearchEngine.'@odata.type' -eq "#microsoft.graph.edgeSearchEngineCustom") {

                                if ($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl -like "*go.microsoft.com*") {
                                    $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl)" -Force
                                    $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "null" -Force
                                }
                                else{
                                    $i | Add-Member -Name edgeCustomURL -MemberType NoteProperty -Value "$($i.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl)" -Force
                                    $i | Add-Member -Name edgeSearchEngine -MemberType NoteProperty -Value "Custom" -Force
                                }
                            }
                            if ($i.defenderDetectedMalwareActions -eq $null) {
                            
                                $i | Add-Member -Name defenderlowseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                $i | Add-Member -Name defendermoderateseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                $i | Add-Member -Name defenderhighseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                $i | Add-Member -Name defendersevereseverity -MemberType NoteProperty -Value "deviceDefault" -Force
                                $i | Add-Member -Name defenderDetectedMalwareActions -MemberType NoteProperty -Value "False" -Force
                            }
                            elseif ($i.defenderDetectedMalwareActions.lowSeverity -eq "deviceDefault" -and $i.defenderDetectedMalwareActions.moderateSeverity -eq "deviceDefault" -and $i.defenderDetectedMalwareActions.highSeverity -eq "deviceDefault" -and $i.defenderDetectedMalwareActions.severeSeverity -eq "deviceDefault") {
                                $i | Add-Member -Name defenderlowseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.lowSeverity -Force
                                $i | Add-Member -Name defendermoderateseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.moderateSeverity -Force
                                $i | Add-Member -Name defenderhighseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.highSeverity -Force
                                $i | Add-Member -Name defendersevereseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.severeSeverity -Force
                                $i | Add-Member -Name defenderDetectedMalwareActions -MemberType NoteProperty -Value "False" -Force
                            }
                            else {
                                $i | Add-Member -Name defenderlowseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.lowSeverity -Force
                                $i | Add-Member -Name defendermoderateseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.moderateSeverity -Force
                                $i | Add-Member -Name defenderhighseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.highSeverity -Force
                                $i | Add-Member -Name defendersevereseverity -MemberType NoteProperty -Value $i.defenderDetectedMalwareActions.severeSeverity -Force
                                $i | Add-Member -Name defenderDetectedMalwareActions -MemberType NoteProperty -Value "True" -Force
                            }
                        
                        }catch{
                            throw "Error in adding null properties to device configuration.."
                        }
                    }
                if ($i."@odata.type" -like "#microsoft.graph.iosGeneralDeviceConfiguration") {
                        $i | Add-Member -Name platform -MemberType NoteProperty -Value "IOS"
                    }
                if ($i."@odata.type" -like "#microsoft.graph.macOSGeneralDeviceConfiguration") {

                    $i | Add-Member -Name platform -MemberType NoteProperty -Value "macOS"

                }

                return $i
            }
        }
    }
}
