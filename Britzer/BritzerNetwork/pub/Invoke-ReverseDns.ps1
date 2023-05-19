Function Invoke-ReverseDns {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True,ValueFromPipeline=$True)]
        [String[]] $Subnet
    )
    Begin {
        $ret = [System.Net.Dns]::GetHostEntry('ip')

        $subnetBlock = {
            
        }
    }
    Process {
        
    }
    End {

    }
}

