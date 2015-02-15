namespace eval tsp::rache { }

proc ::tsp::rache::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw rache angreifer verteidiger angriffszeit \[dragoons\]"
  putserv "PRIVMSG $chan :Example: !dw rache 1:1:1 2:3:4 20:00:03"
}

proc ::tsp::rache::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 3 || [llength [split [lindex $arguments 0] :]] < 3 || [llength [split [lindex $arguments 1] :]] < 3} {
    return "error"
  }

  set from_koord [lindex $arguments 0]
  set to_koord [lindex $arguments 1]
  set atttime [lindex $arguments 2]

  lassign [::tsp::mission::calc $from_koord $to_koord] norm goon

  if {[llength $arguments] > 3} {
    set goons [lindex $arguments 3]
    set goons [string tolower $goons]
    if { ($goons == "goons")||($goons == "goon")||($goons == "dragoons")||($goons == "dragoon") } {
      set returnTimeGoon [expr { [time2sec "00:$atttime"] + $goon }]  
      return "Return Time Dragoons: [clock format $returnTimeGoon -gmt 1 -format %H:%M:%S] \t\t [::tsp::rak::parse $nick $uhost $hand $chan [list $from_koord $to_koord [gettime $returnTimeGoon]]] \t\t [::tsp::klon::parse $nick $uhost $hand $chan [list $from_koord $to_koord [gettime $returnTimeGoon]]]"
    }
  }

  set returnTimeNorm [expr { [time2sec "00:$atttime"] + $norm }]
  return "Return Time: [clock format $returnTimeNorm -gmt 1 -format %H:%M:%S] \t\t [::tsp::rak::parse $nick $uhost $hand $chan [list $from_koord $to_koord [gettime $returnTimeNorm]]] \t\t [::tsp::klon::parse $nick $uhost $hand $chan [list $from_koord $to_koord [gettime $returnTimeNorm]]]"
}
