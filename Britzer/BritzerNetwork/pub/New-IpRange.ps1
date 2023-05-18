Function New-IpRange {
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory,
        ValueFromPipeline)]
        [ValidatePattern("^(([12]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])(\.|\/)){4}([1-2]?[0-9]|3[0-2])$")]
        [string[]] $Subnet
    )
    Begin {
        $job = {
            param($guid)
            While ($Britzer['Temp']['Ip']['maxHosts'].Count -gt 1) {
                # lock queue to dequeue, perf hit is minimal and beats concurrentqueue by a LOT.
                [System.Threading.Monitor]::Enter($Britzer['Temp']['Ip']['maxHosts'])
                $i = $Britzer['Temp']['Ip']['maxHosts'].DeQueue()
                [System.Threading.Monitor]::Exit($Britzer['Temp']['Ip']['maxHosts'])
                $nextHostBin = [Convert]::ToString(([Convert]::ToInt32($Britzer['Temp']['Ip']['hostIdBin'], 2) + $i), 2)
                $zeroAdd = $Britzer['Temp']['Ip']['hostIdBin'].Length - $nextHostBin.Length
                $nextHostBin = ('0' * $zeroAdd) + $nextHostBin
                $nextIpBin = $Britzer['Temp']['Ip']['netIdBin'] + $nextHostBin
                $ipAddress = For ($x = 1; $x -le 4;  $x++) {
                    $startChar = ( $x - 1) * 8
                    $octBin = $nextIpBin.Substring($startChar, 8)
                    [Convert]::ToInt32($octBin, 2)
                }
                $ip = $ipAddress -Join '.'
                $Britzer['JobReturns']["$guid"].Add($ip)
                #$innerLoop 
            }
        }
    }
    Process {
        $subnetJobs =[List[guid]]::New()
        ForEach ($sub in $Subnet) {
            $split = $sub.Split('/')
            [string] $ip = $split[0]
            [int] $cidr = $split[1]
            [int[]] $octs = $ip.Split('.')
            $binArray = ForEach ($oct in $octs) {
                ('0' * (8 - ([Convert]::ToString($oct,2).Length)) + [Convert]::ToString($oct,2))
            }
            $Britzer['Temp']['Ip'] = @{}
            $bin = $binArray -Join ''
            $hostBits = 32 - $cidr
            $Britzer['Temp']['Ip']['netIdBin'] = $bin.Substring(0, $cidr) # needed in loop
            $Britzer['Temp']['Ip']['hostIdBin'] = ($bin.SubString($cidr, $hostBits)) -Replace (1,0) # needed in loop
            
            If ($cidr -le 4) {
                # 4 exeeds  0x7FEFFFFF, need to partition or something, terminate for now
                $e = [System.Exception]::New('Total IP dataset for CIDR /4 is too large and exceeds 0x7FEFFFFF. Terminating.')
                Write-Error -Exception $e
                return
            }
            $Britzer['Temp']['Ip']['maxHosts'] = [Queue[int]] (1..([Convert]::ToInt32(('1' * $hostBits), 2) - 1)) # needed in loop

            $psObj = [PowerShell]::Create()
            $psObj.RunspacePool = $Britzer['Pool']
            $jobId = ([Guid]::Newguid()).Guid
            [void] $psObj.AddScript($Job).AddArgument($jobId)
            [void] $jobObj = [PSCustomObject] @{
                Thread = $psObj.BeginInvoke()
                PsObj = $psObj
            }
            $Britzer['JobReturns']["$jobId"] = [List[string]]::New()
            [void] $Britzer['Jobs'].TryAdd($jobId,$jobObj)
            
            $subnetJobs.Add($jobId)
        }
    }
    End {
        Watch-Job -JobId $subnetJobs
    }
}