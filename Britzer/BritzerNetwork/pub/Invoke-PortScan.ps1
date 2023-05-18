Function Invoke-PortScan {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,
        ValueFromPipeline = $True)]
        [string[]] $IpAddress,

        [Parameter(Mandatory = $True,
        ValueFromPipeline = $False)]
        [int[]] $Port,

        [Parameter(Mandatory = $False)]
        [Switch] $Udp
    )
    Begin {
        $portTestBlock = {
            
        }
    }
    Process {

    }
    End {}
}