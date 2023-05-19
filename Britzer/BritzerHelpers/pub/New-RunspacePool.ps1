Function New-RunspacePool {
    <#
        .SYNOPSIS
        Used to generate runspace pool from ISS
        .DESCRIPTION
        New-RunspacePool is used to create a new runspace pool, using the Initial Session State to help configure the environment for threads.
        .PARAMETER InitialSessionState
        Created via New-InitialSessionState, this provides variables, functions, assemblies, modules, etc to be made available in the pool.
        .PARAMETER MaxRunspaces
        Used to set limits on available threads in the pool.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Runspaces.RunspacePool])]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [InitialSessionState] $InitialSessionState,
        [Parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int] $MaxRunspaces = 10
    )
    Process {
        try {
        # https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshost?view=powershellsdk-7.2.0
        $pool = [RunspaceFactory]::CreateRunspacePool(1,$MaxRunspaces,$InitialSessionState, $host)
        return $pool
        } catch {
            New-Log -Level 'Error' -Message 'Failed to create runspace pool.'
        }
    }
}