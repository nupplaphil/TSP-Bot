
namespace eval tsp::cp { }

global ::tsp::cp::public
set ::tsp::cp::public "1"

proc ::tsp::cp::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw cp eisen titan öl uran bps \[ kvp \]"
}

proc ::tsp::cp::parse { nick uhost hand chan arguments } {
  if { [llength $arguments]  < 5 } {
    return "error"
  }

  set eisen [lindex $arguments 0]
  set titan [lindex $arguments 1]
  set oel   [lindex $arguments 2]
  set uran  [lindex $arguments 3]
  set bps   [lindex $arguments 4]
  if { [llength $arguments] == 6 } {
    set kvp [lindex $arguments 5]
  } else {
    set kvp 20
  }
  
  set cp [::tsp::cp::calc $eisen $titan $oel $uran $bps $kvp]

  if { $cp == -1 } {
    return "error"
  } else {
    return "Clanpoints : $cp"
  }
}

proc ::tsp::cp::calc { eisen titan oel uran bps {kvp 20} } {
  if { ![string is integer -strict $eisen] ||
       ![string is integer -strict $titan] ||
       ![string is integer -strict $oel]   ||
       ![string is integer -strict $uran]  ||
       ![string is integer -strict $bps]   ||
       ![string is integer -strict $kvp]   } {
    return -1
  }
  set eisen [expr {double($eisen)}]
  set titan [expr {double($titan)}]
  set oel   [expr {double($oel)}]
  set uran  [expr {double($uran)}]
  set bps   [expr {double($bps)}]
  return [expr {1 + ($kvp + ($bps / 10000) + (($eisen + $titan + $oel + $uran) / 4))}]
}
