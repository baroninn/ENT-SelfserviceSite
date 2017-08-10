function Get-ScheduledJobs {
    [Cmdletbinding()]
    param (
        
        [switch]$reboot,
        [switch]$expandvhd,
        [switch]$expandcpuram
    )
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
    }
    Process {

        $connStr = "Server=sht004;Integrated Security=true;Database=SCORCH_Tasks"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        $sqlConn.Open()

        if ($reboot) {
            $query = "SELECT * FROM ScheduledJobs WHERE Status != 'Done' AND RunbookId = 'aff2a4e4-ba95-4b1c-9008-36dbb4380b3d'"
        }
        if ($expandvhd) {
            $query = "SELECT * FROM ScheduledJobs WHERE Status != 'Done' AND RunbookId = '723909bd-a325-432c-84e8-79d911153847'"
        }
        if ($expandcpuram) {
            $query = "SELECT * FROM ScheduledJobs WHERE Status != 'Done' AND RunbookId = 'ebdc76b6-c29e-4865-ae19-ae8f2661d85e'"
        }

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $query
        $result = $cmd.ExecuteReader()

        $table = New-Object System.Data.DataTable
        $table.Load($result)

        $list = New-Object System.Collections.Generic.List[PSObject]

        foreach ($t in $table) {
            $params = $t.Parameters.Replace('|1', '=').Replace('|2', ';')
            $vmname = "Unknown"

            foreach ($p in $params.Split(';')) {
                if ($p -like "VMName=*") {
                    $vmname = $p.Replace("VMName=","")
                }
            }

            $list.Add(
             @{
                ScheduledTime = $t.ScheduledTime
                Status = $t.Status
                Parameters = $params
                EmailStatusTo = $t.EmailStatusTo
                VMName = $vmname
                RunbookID = $t.RunbookId
                TaskID = $t.TaskID
            })
        }


        $list | select @{
            Expression={$_.ScheduledTime}
            Label = "ScheduledTime"
        },
        @{
            Expression={$_.Status}
            Label = "Status"
        },
        @{
            Expression={$_.VMName}
            Label = "VMName"
        },
        @{
            Expression={$_.Parameters}
            Label = "Parameters"
        },
        @{
            Expression={$_.RunbookID}
            Label = "RunbookID"
        },
        @{
            Expression={$_.TaskID}
            Label = "TaskID"
        },
        @{
            Expression={$_.EmailStatusTo}
            Label = "EmailStatusTo"
        } | sort ScheduledTime

    }
}