Function Copy-TaskSequence(
    [String]$SiteCode,
    [String]$SiteServer,
    [String]$SourceTSName,
    [String]$DestTSName
) {
    $NameSpace = "ROOT\SMS\Site_$($SiteCode)"
    $SourceTS = Get-WmiObject -ComputerName $SiteServer -Namespace $NameSpace -Class "SMS_TaskSequencePackage" -Filter "Name='$($SourceTSName)'"
    if(!$SourceTS) {
        Return $null
    }

    $Class = [WMIClass]"$($NameSpace):SMS_TaskSequencePackage"

    $TSParams = $Class.PSBase.GetMethodParameters("GetSequence")
    $TSParams.TaskSequencePackage = $SourceTS
    $NewTS = ($Class.PSBase.InvokeMethod("GetSequence", $TSParams, $null)).TaskSequence
	
    $NewTSPkg = $Class.CreateInstance()
    $newTSPkg = $SourceTS
    $newTSPkg.Name = $DestTSName
    $NewTSPkg.PackageID = ""

    $PutSequenceParams = $Class.PSBase.GetMethodParameters("SetSequence")
    $PutSequenceParams.TaskSequence = $NewTS
    $PutSequenceParams.TaskSequencePackage = $newTSPkg
    $SetSequence = $Class.PSBase.InvokeMethod("SetSequence",$PutSequenceParams,$null)
    $NewTSPkgID = $SetSequence.SavedTaskSequencePackagePath.Split('=')[1]

    $DestTS = Get-WmiObject -ComputerName $SiteServer -Namespace $NameSpace -Class "SMS_TaskSequencePackage" -Filter "PackageID=$($NewTSPkgID)"

    Return $DestTS
}