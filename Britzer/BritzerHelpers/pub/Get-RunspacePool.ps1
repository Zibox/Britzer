Function Get-RunspacePooState {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.OrderedHashtable])]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool
    )
    Process {
        try {
            $stateObj = [System.Management.Automation.OrderedHashtable]::New()
            $stateObj['State'] = $RunspacePool.RunspacePoolStateInfo.State.ToString()
            $stateObj['Availability'] = $RunspacePool.RunspacePoolAvailability.ToString()
            $stateObj['Available Runspaces'] = $RunspacePool.GetAvailableRunspaces()
            return $stateObj
        } catch {
            NewLog -Level 'Error' -Message 'Failed to query runspace pool.'
        }
    }
}