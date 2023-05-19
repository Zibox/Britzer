using namespace System.Collections.Generic
using namespace System.Collections.Concurrent

$filesSplat = @{
    Path = $PSScriptRoot
    Exclude = @('using.ps1')
    File = $True
    Recurse = $True
}
$files = Get-ChildItem @filesSplat
ForEach ($file in $files) {
    If ($file.Extension -eq '.ps1') {
        . $file.FullName
    }
}
$export = ($files.Where({(Split-Path -Path $_.DirectoryName -Leaf) -eq 'pub'}) | Select-Object -ExpandProperty BaseName)

# var init
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$Britzer = [Hashtable]::Synchronized(@{})

# make primary hashtable keys
$Britzer['Config'] = ((Get-Content -Path "$PSScriptRoot/appsettings.json") | ConvertFrom-Json)
$Britzer['Jobs'] = [ConcurrentDictionary[[string],[PSCustomObject]]]::New()
$Britzer['JobReturns'] = [ConcurrentDictionary[[string],[PSCustomObject]]]::New()
$Britzer['Temp'] = [ConcurrentDictionary[[String],[PSCustomObject]]]::New()
# copy functions, variables, add other startup scripts, etc for runspaces.
[void] $sessionState.StartupScripts.Add("$PSScriptRoot/BritzerUsings/using.ps1")
[void] $sessionState.Variables.Add(([System.Management.Automation.Runspaces.SessionStateVariableEntry]::New('Britzer',$Britzer,$null)))
ForEach ($function in $export) {
    $content = (Get-Content "function:\$function")
    $functionEntry = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($function, $content)
    [void] $sessionState.Commands.Add($functionEntry)
}

$Britzer['Pool'] = [RunspaceFactory]::CreateRunspacePool(1,$Britzer['Config'].MaxThreads, $sessionState, $host)
$Britzer['Pool'].Open()

#Export functions and hashtable
Export-ModuleMember -Function $export -Variable 'Britzer'

$squid =@"
        .--'''''''''--.
     .'      .---.      '.
    /    .-----------.    \
   /        .-----.        \
   |       .-.   .-.       |
   |      /   \ /   \      |
    \    | .-. | .-. |    /
     '-._| | | | | | |_.-'
         | '-' | '-' |
          \___/ \___/
       _.-'  /   \  `-._
     .' _.--|     |--._ '.
     ' _...-|     |-..._ '
            |     |
            '.___.'
            Britzer
    You best commit when you
        race the sand man
"@
Write-Host $squid