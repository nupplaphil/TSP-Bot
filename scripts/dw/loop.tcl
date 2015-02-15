namespace eval tsp::loop { }

proc ::tsp::loop::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw loop Von Loopzeit (d:h:m)"
  putserv "PRIVMSG $chan :Example: !dw loop 1:1:1 00:20:00"
}

proc ::tsp::loop::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 2 || [llength [split [lindex $arguments 0] :]] < 3} {
    return "error"
  }
  set from_koord [lindex $arguments 0]
  set atttime "[lindex $arguments 1]:00"
  while {[llength [split $atttime :]] < 4} {
    set atttime "00:$atttime"
  }
  set atttime [expr {[time2sec $atttime] / 2}]
  set distance [expr {( $atttime/60-90)/10}]
  if {$distance < 0} {
    set distance 0
  }
  set distanceGoons [expr {( $atttime*5/60-90)/10}]
  if {$distanceGoons < 0 || $atttime < 7200} {
    set distanceGoons 0
  }
  return "Loop from $from_koord for [lindex $arguments 1] - NORMAL: [::tsp::loop::get_koord $from_koord $distance] DRAGOON: [::tsp::loop::get_koord $from_koord $distanceGoons]"
}

proc ::tsp::loop::get_koord { from distance } {
  if {$distance < 1} {
    return "not available"
  }

  set from_q [gettok $from 1 :]
  set from_x [gettok $from 2 :]
  set from_y [gettok $from 3 :]

  set new_q [expr {$from_q - $distance/25}]
  if {[expr {$from_x - $distance%25}] < 1} {
    set new_q [expr {$new_q - 1}]
    set new_x [expr {25 + $from_x - $distance%25}]
  } else {
    set new_x [expr {$from_x - $distance%25}]
  }
  if {$new_q < 0} {
    set new_q [expr {$from_q + $distance/25 + ( $from_x + $distance%25)/25}]
    set new_x [expr {( $from_x + $distance%25)%25}]
  }
  return "$new_q:$new_x:$from_y"
}