Function New-Log {
    [CmdletBinding()]
    [OutputType([void])]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Error','Info','Warn','Debug')]
        [string] $Level,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Message
    )
    Begin {
        $log = "{0} :: {1}: {2}" -f @((Get-Date -Format "G"), $Level, $Message)
    }
    Process {
        switch ($Level) {
            'Error' {
                Write-Error -Message $Log
                Break
            }
            'Info' {
                Write-Information -MessageData $log -InformationAction Continue
                Break
            }
            'Warn' {
                Write-Warning -Message $log
                Break
            }
            'Debug' {
                Write-Debug -Message $log
                Break
            }
            default {
                Break
            }
        }
    }
    End {
        If ($WriteFile -eq $True) {
            $log | Out-File -FilePath ("$($global:config['LogPath'])/$((Get-Date -format "d") -replace '/','-').log") -Append
        }
        Clear-Variable -Name 'log'
    }
}