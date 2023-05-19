Function  Resize-RunspacePool {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [int] $MaxRunspaces,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [int] $MinRunspaces
    )
    Process {
        $success = $false
        try {
            If ($MaxRunspaces) {
                $success = $RunspacePool.SetMaxRunspaces($MaxRunspaces)
            }
            If ($MinRunspaces) {
                $success = $RunspacePool.SetMinRunspaces($MinRunspaces)
            }
        } catch {
            $success = $false
            Write-Log -Level 'Error' -Message 'Failed to resize runspace pool'
        }
        return $success
    }
}