namespace eval tsp::mission { }

proc ::tsp::mission::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw mission Von Nach"
  putserv "PRIVMSG $chan :Example: !dw mission 1:1:1 2:3:4"
}

proc ::tsp::mission::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 2 || [llength [split [lindex $arguments 0] :]] < 3 || [llength [split [lindex $arguments 1] :]] < 3} {
    return "error"
  }
putlog "here"
  set from_koord [lindex $arguments 0]
  set to_koord [lindex $arguments 1]

  lassign [::tsp::mission::calc $from_koord $to_koord] norm goon

  return "$from_koord nach $to_koord - NORMAL: [clock format $norm -gmt 1 -format %H:%M:%S] DRAGOON: [clock format $goon -gmt 1 -format %H:%M:%S]"
}

proc ::tsp::mission::calc { from to } {
  set distance [::tsp::mission::distance $from $to]

  set norm [expr {int($distance)}]

  set norm [expr { ($norm +60)*60 }]
  set goon [expr {$norm / 5}]
  if {$goon < 7200} {
    set goon 7200
  }

  list $norm $goon
}

proc ::tsp::mission::distance { from to } {
  set from_s [gettok $from 1 :]
  set from_x [gettok $from 2 :]
  set from_y [gettok $from 3 :]

  set to_s   [gettok $to   1 :]
  set to_x   [gettok $to   2 :]
  set to_y   [gettok $to   3 :]

  set ent_x [expr {(($from_s * 25) + $from_x) - ($to_x + ($to_s * 25))}]
  set ent_y [expr {$from_y - $to_y}]

  if {$ent_x < 0} {
    set ent_x [expr {$ent_x * -1}]
  }
  if {$ent_y < 0} {
    set ent_y [expr {$ent_y * -1}]
  }

  if {$to_y > $from_y} {
    set ent_y_alt [expr {$from_y + (20 - $to_y)}]
  } elseif {$to_y < $from_y} {
    set ent_y_alt [expr {$to_y + (20 - $from_y)}]
  } else {
    set ent_y_alt 9999999
  }
  if {$ent_y_alt < $ent_y} {
    set ent_y $ent_y_alt
  }

  set entfer [expr {ceil(sqrt([expr {($ent_x * $ent_x)+($ent_y * $ent_y)}]))}]
  set b_zeit [expr {30 + ($entfer * 10)}]

  return $b_zeit
}
