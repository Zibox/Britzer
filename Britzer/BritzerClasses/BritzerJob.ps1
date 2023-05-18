Class BritzerJob {
    [PowerShell] $Powershell
    [Guid] $JobGuid

    BritzerJob ($Powershell, $JobGuid) {
        $this.Powershell = $Powershell
        $this.$JobGuid = $JobGuid
    }
}