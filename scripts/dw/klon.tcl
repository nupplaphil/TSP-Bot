namespace eval tsp::klon { }

proc ::tsp::klon::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw klon Von Nach \[ Einschlag \}"
  putserv "PRIVMSG $chan :Example: !dw klon 1:1:1 2:3:4 20:00:03"
}

proc ::tsp::klon::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 2 || [llength [split [lindex $arguments 0] :]] < 3 || [llength [split [lindex $arguments 1] :]] < 3} {
    return "error"
  }

  set from_koord [lindex $arguments 0]
  set to_koord [lindex $arguments 1]

  if {[llength $arguments] == 3} {
    set einschlag [time2sec "00:[lindex $arguments 2]"]
    return [::tsp::klon::calc $from_koord $to_koord $einschlag]
  } else {
    return [::tsp::klon::calc $from_koord $to_koord]
  }
}

proc ::tsp::klon::calc { from_koord to_koord { einschlag 0 } } {
  if { $einschlag > 0 } {
    #24h support added
    set fuss  [expr {$einschlag - [::tsp::klon::calc_one $from_koord $to_koord 1]}]
    if { $fuss < 0 } { set fuss [expr {24*60*60 + $fuss}] }
    set buggy [expr {$einschlag - [::tsp::klon::calc_one $from_koord $to_koord 2]}]
    if { $buggy < 0 } { set buggy [expr {24*60*60 + $buggy}] }
    set lkw   [expr {$einschlag - [::tsp::klon::calc_one $from_koord $to_koord 3]}]
    if { $lkw < 0 } { set lkw [expr {24*60*60 + $lkw}] }
    set jet   [expr {$einschlag - [::tsp::klon::calc_one $from_koord $to_koord 4]}]
    if { $jet < 0 } { set jet [expr {24*60*60 + $jet}] }

#  Macht nicht viel sinn? Uhrzeit wird nicht verwendet? Nur kurz nach 0 Uhr k�nnen keine Klone gestartet werden?
#
#    if { $jet > 0} {
#      set fuss  [expr {$fuss > 0 ? "Fuss [gettime $fuss]; " : "Too late for Fuss! "}]
#      set buggy [expr {$buggy > 0 ? "Buggy [gettime $buggy]; " : "Too late for Buggy! "}]
#      set lkw   [expr {$lkw > 0 ? "LKW [gettime $lkw]; " : "Too late for LKW! "}]
#      set msg "Klonstart: $fuss$buggy$lkw Jetpack [gettime $jet]"
#    } else {
#      set msg "Klonstart: nicht möglich - [gettime [expr {$jet * -1}]] zu spät!"
#    }

  } else {
    set fuss  [::tsp::klon::calc_one $from_koord $to_koord 1]
    set buggy [::tsp::klon::calc_one $from_koord $to_koord 2]
    set lkw   [::tsp::klon::calc_one $from_koord $to_koord 3]
    set jet   [::tsp::klon::calc_one $from_koord $to_koord 4]
  }
  return "Klonstart: Fuss [clock format $fuss -gmt 1 -format %H:%M:%S]; Buggy [clock format $buggy -gmt 1 -format %H:%M:%S]; LKW [clock format $lkw -gmt 1 -format %H:%M:%S]; Jetpack [clock format $jet -gmt 1 -format %H:%M:%S]"
}

proc ::tsp::klon::calc_one { from to type } {
  set b_zeit [::tsp::mission::distance $from $to]

  # Setzt Werte fuer jweilige Geschwindigkeit
  switch $type {
    1 {
      # FUSS
      set b_zeit [expr {($b_zeit / 100) * 120}]
    }
    2 {
      # BUGGY
      set b_zeit [expr {($b_zeit / 100) * 80}]
    }
    3 {
      # LASTWAGEN
      set b_zeit [expr {($b_zeit / 100) * 110}]
    }
    4 {
      # JETPACK
      set b_zeit [expr {$b_zeit / 2}]
    }
    default {
      return "error"
    }
  }
  
  # generelle Werte
  if { $b_zeit > 0 } {
    set b_zeit [expr {$b_zeit + 30}]
  }
  set b_zeit [expr {round($b_zeit)}]

  set tag_b_zeit 0
  set std_b_zeit 0

  # beginne Umrechnung
  if { $b_zeit > 0 } {
    set std_b_zeit [expr {$b_zeit / 60}]
    if { [gettok $std_b_zeit 0 :] == 2} {
      set std_b_zeit [gettok $std_b_zeit 1 :]
    }
    set b_zeit [expr {$b_zeit - ($std_b_zeit * 60)}]
    if { $std_b_zeit > 24 } {
      set tag_b_zeit [expr {$std_b_zeit / 24}]
      if { [gettok $tag_b_zeit 0 :] == 2 } {
        set tag_b_zeit [gettok $tag_b_zeit 1 :]
      }
      set std_b_zeit [expr {$std_b_zeit - ($tag_b_zeit * 24)}]
    }
  }
  
  return [expr {($tag_b_zeit * 86400) + ($std_b_zeit * 3600) + ($b_zeit * 60)}] 
}
