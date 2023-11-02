param(
    [string]$tb_name
)

$FileNames = Get-ChildItem -Path '.\hdl\' -File
$IPFileNames = Get-ChildItem -Path '.\ip\'

$IVerilogCommand = "iverilog -g2012 -o sim/" + $tb_name + ".out"
foreach ($FileName in $FileNames) {
    $IVerilogCommand += " hdl/" + $FileName
}
foreach ($IPFileName in $IPFileNames) {
    $command += " ip/" + $IPFileName + "/" + $IPFileName + ".xci"
}

$IVerilogCommand += " xdc/top_level.xdc obj/"

Write-Host $IVerilogCommand
Invoke-Expression $IVerilogCommand

$VVPCommand = "vvp sim/" + $tb_name + ".out"
Write-Host $VVPCommand
Invoke-Expression $VVPCommand