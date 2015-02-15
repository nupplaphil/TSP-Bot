
proc koord2omni { koord } {
  return [expr {([gettok $koord 1 :]*500)+(([gettok $koord 3 :]-1)*25)+[gettok $koord 2 :]}]
}

proc omni2koord { omni } {
  set akt_r [expr {$omni % 500}]
  set akt_x [expr {$akt_r % 25}]
  if {$akt_x == 0} {
    set akt_x 25
  }
  set akt_s [expr {int(floor([expr {$omni / 500}]))}]
  set akt_y [expr {int(floor([expr {$akt_r /  25}]))}]
  incr akt_y

  if {$akt_x == 25} {
    incr akt_y -1
  }
  if {$akt_y < 1} {
    set akt_y 20
  }
  if {$akt_y == 20 && $akt_x == 25} {
    incr akt_s -1 
  }

  return "$akt_s:$akt_x:$akt_y"
}

proc gettok {1 2 {3 " "}} {
 if {![string match -nocase *$3* $1]&&$2==1} {return $1}
 if {![string match -nocase *$3* $1]&&$2>1} {return}
 if {$2=="0"} {
  if {[string match -nocase *$3* $1]} {
   set a [split $1 $3];return [llength $a]
  };return 1
 }
 set a [split $1 $3];if {$2>[llength $a]} {return}
 if {[lindex $a [expr $2 - 1]]==""&&[lindex $a $2]!=""} {return [lindex $a $2]}
 return [string trim [lindex $a [expr $2 - 1]]]
}

proc gettime { time } {  
  set vars    {seconds minutes hours }
  set factors {60      60      24}
  foreach v $vars f $factors {
    set $v [expr {$time % $f}]
    set time [expr {($time-[set $v]) / $f}] 
  }

  set msg ""
  if {$time > 0} {
    set msg "[expr {$time}]T"
  }

  set msg "$msg $hours:$minutes"
  if {$seconds > 0 && $seconds < 10} {
    set msg "$msg:0$seconds"
  } elseif { $seconds > 10 } {
    set msg "$msg:$seconds"
  }
  return $msg
}

proc time2sec {t} {
  foreach val [scan $t %d:%d:%d:%d] mul {86400 3600 60 1} {
    if {$val == {}} continue
    incr result [expr {$val * $mul}]
  }
  return $result
}

proc countchar {string char} {
  set rc [llength [split $string $char]]
  incr rc -1
  return $rc
}


putlog "TSP - Utils loaded"
