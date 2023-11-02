$FileNames = Get-ChildItem -Path '.\hdl\' -File
$IPFileNames = Get-ChildItem -Path '.\ip\'

$Command = "python remote/r.py build.py build.tcl"
foreach ($FileName in $FileNames) {
    $Command += " hdl/" + $FileName
}
foreach ($IPFileName in $IPFileNames) {
    $command += " ip/" + $IPFileName + "/" + $IPFileName + ".xci"
}
$Command += " xdc/top_level.xdc obj/"

Write-Host $Command
Invoke-Expression $Command