Function Watch-Job{
    [Cmdletbinding()]
    Param(
        [guid[]] $JobId
    )
    $jobs = foreach ($job in $JobId) {
        $Britzer['Jobs']["$Job"].PsObj
    }
    while ($jobs.InvocationStateInfo.State -contains 'Running') {

    }
}