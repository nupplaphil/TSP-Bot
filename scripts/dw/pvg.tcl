namespace eval tsp::pvg { }

proc ::tsp::pvg::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw pvg uran"
  putserv "PRIVMSG $chan :Usage: !dw pvg Bot Anzahl \[, ...\]"
}

proc ::tsp::pvg::parse { nick uhost hand chan arguments } {
  if { [llength $arguments] < 1 } {
    return "error"
  }

  if { [llength $arguments] == 1} {
    set uran [lindex $arguments 0]
    if { ![string is integer -strict $uran] } {
          return "error"
    }

    lassign [::tsp::pvg::reversecost $uran] anz_sola anz_goon
    return " Uran: $uran -> Solaron: $anz_sola ( [expr {$anz_sola * 2200}] ) - Dragoon: $anz_goon ( [expr {$anz_goon * 1000}] ) "
  }

  set uran [::tsp::pvg::parsebots $arguments]

  if { $uran == 0 } {
    return "Ein oder mehrere Droiden sind PVG Immun!"
  } elseif { $uran == -1 } {
    return "error"
  } else {
    return "$arguments : eigen $uran , bnd [expr {int($uran * 1.5)}] , fremd [expr {$uran * 3}] Einheiten Uran"
  }
}

proc ::tsp::pvg::calc { } {
  return "nothing to do"
}

proc ::tsp::pvg::reversecost { uran } {
  set anz_sola [expr {round(floor([expr {double($uran) / 2200}]))}]
  set anz_goon [expr {round(floor([expr {double($uran) / 1000}]))}]
  list $anz_sola $anz_goon
}

proc ::tsp::pvg::parsebots { arguments } {
  set uran 0
  
  foreach i [split $arguments ,] {
    set line [string trim $i]
    if { [countchar $line " "] < 1 || [llength $line] != 2 } {
      return -1
    }
    set droide [gettok $line 1 " "]
    set anz    [gettok $line 2 " "]
    if { ![string is double -strict $anz] } {
      return -1
    }
    set curruran [::tsp::pvg::geturan $droide $anz]
    if { $curruran == -1 } {
      return -1
    } elseif { $curruran == 0 } {
      return 0
    }
    set uran [expr {$uran + $curruran}]
  }
  
  return $uran
}

# Gets the uran of the current bot
# 0 = PVG-Immun , -1 = not found
proc ::tsp::pvg::geturan { droide {anz 1}} {
  set dwini "Bot/ini/dw.ini"

  set line [ini_read $dwini "droide" $droide]
  if { $line == ";" } {
    return -1
  }

  if { [gettok $line 7 " "] == "PVG-Immunitaet" } {
    set cost 0
  } else {
    set cost [gettok $line 2 " "]
  
  }
  
  return [expr {$anz * 4 * $cost}]
}
