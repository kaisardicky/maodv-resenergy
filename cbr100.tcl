#
# nodes: 50, max conn: 15, send rate: 0.20000000000000001, seed: 1
#
#
# 48 connecting to 49 at time 2.5568388786897245
#
set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(98) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(99) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 1
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 1000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 0 "$cbr_(0) start"
#
#Total sources/connections: 10/15
#
