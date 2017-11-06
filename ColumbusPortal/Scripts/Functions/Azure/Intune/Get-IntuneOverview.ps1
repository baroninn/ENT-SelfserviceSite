function Get-IntuneOverview {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header
    )
    
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        try {
            $EnrollOverview = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/managedDeviceOverview/" -Headers $header -Method Get
        }
        catch {
            throw $_
        }
        try {
            $ComplianceOverview = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicyDeviceStateSummary" -Headers $header -Method Get
        }
        catch {
            throw $_
        }

        $EnrollOverviewobject = [pscustomobject]@{
            enrolledDeviceCount = $EnrollOverview.enrolledDeviceCount
            mdmEnrolledCount = $EnrollOverview.mdmEnrolledCount
            dualEnrolledDeviceCount = $EnrollOverview.dualEnrolledDeviceCount
            deviceOperatingSystemSummary = [pscustomobject] @{
                androidCount = $EnrollOverview.deviceOperatingSystemSummary.androidCount
                iosCount = $EnrollOverview.deviceOperatingSystemSummary.iosCount
                macOSCount = $EnrollOverview.deviceOperatingSystemSummary.macOSCount
                windowsMobileCount = $EnrollOverview.deviceOperatingSystemSummary.windowsMobileCount
                windowsCount = $EnrollOverview.deviceOperatingSystemSummary.windowsCount
                unknownCount = $EnrollOverview.deviceOperatingSystemSummary.unknownCount
            }
            deviceExchangeAccessStateSummary = [pscustomobject] @{
                allowedDeviceCount = $EnrollOverview.deviceExchangeAccessStateSummary.allowedDeviceCount
                blockedDeviceCount = $EnrollOverview.deviceExchangeAccessStateSummary.blockedDeviceCount
                quarantinedDeviceCount = $EnrollOverview.deviceExchangeAccessStateSummary.quarantinedDeviceCount
                unknownDeviceCount = $EnrollOverview.deviceExchangeAccessStateSummary.unknownDeviceCount
                unavailableDeviceCount = $EnrollOverview.deviceExchangeAccessStateSummary.unavailableDeviceCount
            }
            deviceCompliancePolicyDeviceStateSummary = [pscustomobject]@{
                inGracePeriodCount = $ComplianceOverview.inGracePeriodCount
                unknownDeviceCount = $ComplianceOverview.unknownDeviceCount
                notApplicableDeviceCount = $ComplianceOverview.notApplicableDeviceCount
                compliantDeviceCount = $ComplianceOverview.compliantDeviceCount
                remediatedDeviceCount = $ComplianceOverview.remediatedDeviceCount
                nonCompliantDeviceCount = $ComplianceOverview.nonCompliantDeviceCount
                errorDeviceCount = $ComplianceOverview.errorDeviceCount
                conflictDeviceCount = $ComplianceOverview.conflictDeviceCount
            }

        }

        return $EnrollOverviewobject

    }
}
