<#
    Modified 22-10-2015 by Dennis Rye
        Added functionality to run on a remote computer as well. Performance overall is decreased though.
#>

<#
    .SYNOPSIS
        Starts a process to handle commands, standard output, and standard error redirection.
    .DESCRIPTION
        Starts a process to handle commands, standard output, and standard error redirection.
    .PARAMETER FilePath
        Specifies the path to the executable.
    .PARAMETER ArgumentList
        Lists of arguments passed to the executable
    .PARAMETER TimeOut
        Specifies the timeout for the process. If the value is set to 0, the function waits for the process to end.
    .PARAMETER ComputerName
        Specifies a remote computer to run process on.   
#>
function Start-ProcessWithErrorHandling
{
    [CmdletBinding()]
    param ( 
        [parameter(Mandatory=$true)]
        [string]$FilePath,
        [parameter(Mandatory=$true)]
        [string[]]$ArgumentList,
        [parameter(Mandatory=$false)]
        [int]$TimeOut = 0,
        [parameter(Mandatory=$false)]
        [string]$ComputerName
    )     

    Write-Verbose "Running external command: $FilePath $ArgumentList"

    $StdErrFile = [System.IO.Path]::GetTempFileName()
    $StdOutFile = [System.IO.Path]::GetTempFileName()

    # Hack to make it work, vulnerable to injections. If not used, ExitCode will not be returned.              
    if ($ComputerName) {
        $scriptblock = [scriptblock]::Create("Invoke-Command -ComputerName $ComputerName -ScriptBlock { `$result = Start-Process -FilePath '$FilePath' -PassThru -Wait -NoNewWindow -RedirectStandardError '$StdErrFile' -RedirectStandardOutput '$StdOutFile' -ArgumentList '$ArgumentList'; while (`$result.HasExited -eq `$false) {sleep 1}; `$result }")

        $StdErrFile = $StdErrFile.Replace("C:", "\\$ComputerName\C$")
        $StdOutFile = $StdOutFile.Replace("C:", "\\$ComputerName\C$")
    }
    else {
        #$scriptblock = [scriptblock]::Create("Start-Process -FilePath `"$FilePath`" -PassThru -Wait -NoNewWindow -RedirectStandardError `"$StdErrFile`" -RedirectStandardOutput `"$StdOutFile`" -ArgumentList `"$ArgumentList`"")
        $scriptblock = [scriptblock]::Create("Invoke-Command -ScriptBlock { `$result = Start-Process -FilePath '$FilePath' -PassThru -Wait -NoNewWindow -RedirectStandardError '$StdErrFile' -RedirectStandardOutput '$StdOutFile' -ArgumentList '$ArgumentList'; while (`$result.HasExited -eq `$false) {sleep 1}; `$result }")
    }

    # Unfortunately this is fairly slow for both local and remote commands, but it works.
    $job = Start-Job -ScriptBlock $scriptblock

    # progress indication, assume upper bound 500 sec
    # start the pogress indicator after 5 sec
    [int]$percent = 0;
    $program = Split-Path $FilePath -Leaf
    while (Get-Job -Id $job.Id | where {$_.State -eq 'Running'}) {

        Write-Progress -Activity "Running $program..." -PercentComplete $percent -CurrentOperation "$percent% complete" -Status "Please wait."

		# naive algoritm stops progress indication at 95%
        if ($percent -lt 95) {
            $percent = $percent + 1;
        }

		if ($TimeOut -ne 0) {
			# Decrease timeout with wait cycles
			$TimeOut -= 5
			if ($TimeOut -le 0) {
				Write-Error "Running $program timed out"
				$result | Stop-Process -ErrorAction SilentlyContinue
				break
			}
		}
        
        sleep 1
    } 

    Write-Progress -Activity "Running $program..." -PercentComplete 100 -CurrentOperation "100% complete" -Completed -Status "Done."

    $result = $job | Receive-Job

    $outputFromProcess = Get-Content $StdOutFile 
    $errorOutputFromProcess = Get-Content $StdOutFile 

    # Many exe files send the same content to stderr and stdout
    # if we have the same number of lines in the stderr and stdout, we will only write log the stderr
	# if the line numbers are different we will write both logs
    if (@($outputFromProcess).Count -ne @($errorOutputFromProcess).Count) {
        $outputFromProcess | ForEach-Object {Write-Verbose "   $_"} # indent
    }

    $errorOutputFromProcess | ForEach-Object {Write-Verbose "   $_"} # indent

    [int]$exitCode = $result.ExitCode
    if ($exitCode -ne 0)
    {
        [string] $output = $errorOutputFromProcess
        Write-Error "$FilePath $ArgumentList failed with error $exitCode`n$output"
    }
}
Export-ModuleMember -Function Start-ProcessWithErrorHandling