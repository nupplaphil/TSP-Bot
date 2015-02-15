namespace eval tsp::bp { }

proc ::tsp::bp::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw bp Bot Anzahl \[, ...\]"
  putserv "PRIVMSG $chan :Usage: !dw dp Bot Anzahl \[, ...\]"
}

proc ::tsp::bp::parse { nick uhost hand chan arguments } {
  if { [llength $arguments] < 2 } {
    return "error"
  }

  set bpdp [::tsp::bp::parsebots $arguments]
  set bp [lindex $bpdp 0]
  set dp [lindex $bpdp 1]
  if { $bp == -1 } {
    return "error"
  } else {
    return "$arguments : Battlepoints $bp, Destructionpoints $dp"
  }
}

proc ::tsp::bp::calc { } {
  return "nothing to do"
}

proc ::tsp::bp::parsebots { arguments } {
  set bp 0
  set dp 0
  
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

    set currbpdp [::tsp::bp::getbpdp $droide $anz]
    set currbp [lindex $currbpdp 0]
    set currdp [lindex $currbpdp 1]

    if { $currbp == -1 } {
      return [list -1 -1]
    }
    set bp [expr {$bp + $currbp}]
    set dp [expr {$dp + $currdp}]
  }

  return [list $bp $dp]
}

# Gets the battlepoints of the current bot
# -1 = not found
proc ::tsp::bp::getbpdp { droide {anz 1}} {
  set dwini "Bot/ini/dw.ini"
  set line [ini_read $dwini "droide" $droide]
  if { $line == ";" } {
    return [list -1 -1]
  }
  set bp [gettok $line 5 " "]
  set dp [gettok $line 6 " "]  
  return [list [expr {$anz * $bp}] [expr {$anz * $dp}]]
}
