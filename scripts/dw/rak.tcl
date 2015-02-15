namespace eval tsp::rak { }

proc ::tsp::rak::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw rak vonkoord nachkoord \[einschlag\]"
}

proc ::tsp::rak::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 3 || [llength [split [lindex $arguments 0] :]] < 3 || [llength [split [lindex $arguments 1] :]] < 3} {
    return "error"
  }
  
  set vonkoord  [lindex $arguments 0]
  set nachkoord [lindex $arguments 1]

  set flugzeit [expr { (( [::tsp::mission::distance $vonkoord $nachkoord] + 60 ) * 60 / 200 ) + 120 }]

  if { [llength $arguments] > 2 } {
    set einschlag [lindex $arguments 2]
    set rakstart [expr { [time2sec "00:$einschlag"] - $flugzeit }]
    # Sinn? UnabhÃ¤ngig von aktueller Uhrzeit?
    if { $rakstart > 0 } {
      return "Rakstart: [clock format [expr {int($rakstart)}] -gmt 1 -format %H:%M:%S]"
    } else {
      return "Rakstart : nicht möglich - [clock format [expr {int($rakstart * -1)}] -gmt 1 -format %H:%M:%S]"
    }
  } else {
    return "Rak Flugzeit: [clock format [expr {int($flugzeit)}] -gmt 1 -format %H:%M:%S]"
  }
}
