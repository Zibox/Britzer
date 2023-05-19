Function New-InitialSessionState {
    <#
        .SYNOPSIS
        Used to generate Initial Session State objects
        .DESCRIPTION
        Used to generate Intiial Sesion State objects for use within runspaces. Imports variables, functions, assemblies, modules and scripts, when specified.
        .PARAMETER Variable
        String array of variables you wish to import into the ISS
        .PARAMETER Function
        String array of functions you wish to import into the ISS
        .PARAMETER Assembly
        String array of assembly names you wish to import.
        .PARAMETER Module
        String array of module names you wish to import.
        .PARAMETER StartupScript
        String array of paths to execute on pool/runspace invoke.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Runspaces.InitialSessionState])]
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]] $Variable,
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]] $Function,
        [Parameter(Mandatory = $false, Position = 3)]
        [string[]] $Assembly,
        [Parameter(Mandatory = $false, Position = 4)]
        [string[]] $Module,
        [Parameter(Mandatory = $false, Position = 6)]
        [string[]] $StartupScript,

        [Parameter(Mandatory = $false)]
        [ValidateRange({0..2})]
        [System.Threading.ApartmentState] $ApartmentState = 2,
        [Parameter(Mandatory = $false)]
        [ValidateRange({(0..3)})]
        [System.Management.Automation.Runspaces.PSThreadOptions] $ThreadOptions = 0

    )
    Begin {
        $base = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        If (($ApartmentState -ne 2) -xor ($ThreadOptions -ne 0)) {
            $base.ApartmentState = $ApartmentState
            $base.ThreadOptions = $ThreadOptions
        }
    }
    Process {
        If ($Variable) {
            ForEach ($var in $Variable) {
                try {
                    $tempVar = Get-Variable -Name $var
                    $sessionVar = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::New($var, $tempVar.Value, $null)
                    [void] $base.Variables.Add($sessionVar)
                    Clear-Variable -Name @('tempVar','sessionVar','var')
                } catch {
                    New-Log -Level 'Error' -Message "Error thrown while adding variable '$var' to Initial Session State"
                }
            }
        }
        If ($Function) {
            ForEach ($command in $Function) {
                try {
                    $content = (Get-Content "function:\$command")
                    $functionEntry = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($command, $content)
                    [void] $base.Commands.Add($functionEntry)
                    Clear-Variable -Name @('content', 'functionEntry', 'command')
                } catch {
                    New-Log -Level 'Error' -Message "Error thrown while adding function '$command' to Initial Session State"
                }

            }
        }
        If ($Assembly) {
            ForEach ($exec in $Assembly) {
                try {
                    $entry = [System.Management.Automation.Runspaces.SessionStateAssemblyEntry]::New($exec)
                    [void] $base.Assemblies.Add($entry)
                    Clear-Variable -Name @('exec', 'entry')
                } catch {
                    New-Log -Level 'Error' -Message "Error thrown while adding assembly '$exec' to Initial Session State"
                }

            }
        }
        If ($Module) {
            ForEach ($mod in $Module) {
                try {
                    $module = Get-Module -Name $mod
                    $modHash = @{
                        ModuleName = $mod
                        ModuleVersion = $module.Version
                    }
                    If ($module.guid) {
                        $modHash['Guid'] = $module.Guid
                    }
                    $modEntry = [Microsoft.PowerShell.Commands.ModuleSpecification]::New($modHash)
                    [void] $base.Modules.Add($modEntry)
                    Clear-Variable -Name @('module', 'modHash', 'modEntry')
                } catch {
                    New-Log -Level 'Error' -Message "Error thrown while adding module '$mod' to Initial Session State"
                }
            }
        }
        If ($StartupScript) {
            ForEach ($script in $StartupScript) {
                try {
                    If (Test-Path -Path $script) {
                        [void] $base.StartupScripts.Add($script)
                    } Else {
                        throw
                    }
                } catch {
                    New-Log -Level 'Error' -Message "Error validating path '$script' for Intitial Session State Startup Script"
                }
            }
        }
    }
    End {
        return $base
    }
}