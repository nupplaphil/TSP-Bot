namespace eval tsp::rm { }

proc ::tsp::rm::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw rm tage \[anzahl tage\] \[botanzahl (optional)\]"
  putserv "PRIVMSG $chan :Usage: !dw rm uran \[uranmenge\] \[botanzahl (optional)\]"
}

proc ::tsp::rm::parse { nick uhost hand chan arguments } {
  if { [llength $arguments] < 2 } {
    return "error"
  }
  set type [lindex $arguments 0]
  set amount [lindex $arguments 1]

  if { [llength $arguments] > 2 } {
    set number_of_bots [lindex $arguments 2]
    if { ($number_of_bots > 10)||($number_of_bots < 1) } { set number_of_bots 10 }
  } else {
    set number_of_bots 10
  }
  if { $type == "tage" } {
    return "Eisen: [expr {$amount*$number_of_bots*100+1000}] Titan: [expr {$amount*$number_of_bots*10+2000}] Öl: [expr {$amount*$number_of_bots*300+2500}] Uran: [expr {$amount*$number_of_bots*600+1200}]"
  } elseif { $type == "uran" } {
    return "Tage: [expr {($amount-1200)/(600*$number_of_bots)}]"
  } else {
    return "error"
  }
}
