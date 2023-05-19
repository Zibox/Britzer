Function Invoke-ReverseDns {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True,ValueFromPipeline=$True)]
        [String[]] $Subnet
    )
    Begin {
        $ret = [System.Net.Dns]::GetHostEntry('52.85.151.122')

        $subnetBlock = {
            
        }
    }
    Process {
        
    }
    End {

    }
}

