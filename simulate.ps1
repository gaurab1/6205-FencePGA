param(
    [Parameter(Position = 0)]
    [string]$tb_name,
    [string[]]$hdl,
    [string[]]$ip
)

$IVerilogCommand = "iverilog -g2012 -o sim/" + $tb_name + ".out sim/" + $tb_name + "_tb.sv"
foreach ($FileName in $hdl) {
    $IVerilogCommand += " hdl/" + $FileName + ".sv"
}
foreach ($IPFileName in $ip) {
    $IVerilogCommand += " ip/" + $IPFileName + "/" + $IPFileName + ".xci"
}

$IverilogCommand += " hdl/types.svh"

Write-Host $IVerilogCommand
Invoke-Expression $IVerilogCommand

$VVPCommand = "vvp sim/" + $tb_name + ".out"
Write-Host $VVPCommand
Invoke-Expression $VVPCommand