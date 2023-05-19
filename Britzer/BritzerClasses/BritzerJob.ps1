Class BritzerJob {
    [PowerShell] $Powershell
    [Guid] $JobGuid = [guid]::NewGuid()

    BritzerJob($Pool) {
        $this.Powershell = [Powershell]::Create()
        $this.RunspacePool = $Pool
    }
    BritzerJob ($Pool,$ScriptBlock) {
        $this.Powershell = $this.BuildJob($Pool,$ScriptBlock)
    }
    BritzerJob ($Pool,$ScriptBlock, $Arguments) {
        $this.Powershell = $this.BuildJob($Pool,$ScriptBlock,$Arguments)

    }
    
    [Powershell] BuildJob ($ScriptBlock,$Pool) {
        $psObj = [Powershell]::Create()
        $psObj.AddScript($ScriptBlock) | Out-Null
        $psObj.RunspacePool = $Pool
        return $psObj
    }
    [Powershell] BuildJob ($ScriptBlock,$Pool,$Arguments) {
        $psObj = [Powershell]::Create()
        $psObj.AddScript($ScriptBlock).AddArgument($Arguments) | Out-Null
        $psObj.RunspacePool = $Pool
        return $psObj
    }

    [Powershell] Await ($PowershellObject) {
        $PowershellObject.BeginInvoke()
        while ($PowershellObject.InvocationStateInfo.State -contains 'Running') {
            
        }
        return $PowershellObject
    }
}
