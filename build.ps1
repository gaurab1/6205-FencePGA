$Excluded = @(".gitkeep")

$FileNames = Get-ChildItem -Path '.\hdl\' -File  | Where-Object { $Excluded -notcontains $_ }
$IPFileNames = Get-ChildItem -Path '.\ip\' | Where-Object { $Excluded -notcontains $_ }

$Command = "python remote/r.py build.py build.tcl"
foreach ($FileName in $FileNames) {
    $Command += " hdl/" + $FileName
}
foreach ($IPFileName in $IPFileNames) {
    $Command += " ip/" + $IPFileName + "/" + $IPFileName + ".xci"
}
$Command += " xdc/top_level.xdc obj/"

Write-Host $Command
Invoke-Expression $Command