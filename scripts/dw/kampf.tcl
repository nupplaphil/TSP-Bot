namespace eval tsp::kampf { }

proc ::tsp::kampf::help { chan } {
  putserv "PRIVMSG $chan :Usage: !dw kampf Bot Anzahl \[, ...\] vs Bot Anzahl \[, ...\]"
  putserv "PRIVMSG $chan :Example: !dw kampf Solaron 10, Dragoon 20 vs Xenox 20, SP 10, Plasmawerfer 2"
}

proc ::tsp::kampf::parse { nick uhost hand chan arguments } {
  if { [llength $arguments] < 2 } {
    return "error"
  }
  set arguments [string tolower $arguments]
  set arguments [string map { " vs " " & " } $arguments]
  set sides [split $arguments "&"]

  if { !([llength $sides] == 2) } {
    return "error"
  }

  set ang  [lindex $sides 0]
  set vrt [lindex $sides 1]

  set ang_k 0.0
  set vrt_k 0.0

  foreach i [split $ang ,] {
    set line [string trim $i]
    if { [countchar $line " "] < 1 || [llength $line] != 2 } {
      continue;
    }
    set droide [gettok $line 1 " "]
    set anz    [gettok $line 2 " "]
    if { ![string is double -strict $anz] } {
      continue;
    }
    lassign [::tsp::kampf::getattdef $droide] att def
    if {$att == -1} {return "error"}
    if {$def == -1} {return "error"}
    set ang_k [expr {$ang_k + ((double($att) + double($def) / 2) * $anz)}]
  }

  foreach i [split $vrt ,] {
    set line [string trim $i]
    if { [countchar $line " "] < 1 || [llength $line] != 2 } {
      continue;
    }
    set droide [gettok $line 1 " "]
    set anz    [gettok $line 2 " "]
    if { ![string is double -strict $anz] } {
      continue;
    }
    lassign [::tsp::kampf::getattdef $droide] att def
    if {$att == -1} {return "error"}
    if {$def == -1} {return "error"}
    set vrt_k [expr {$vrt_k + ((double($def) + double($att) / 2) * $anz)}]
  }

  set proz_n     [expr {round(floor( (100 /  $vrt_k        ) *  $ang_k         - 100))}]
  set proz_a_max [expr {round(floor( (100 / ($vrt_k * 0.88)) * ($ang_k * 1.42) - 100))}]
  set proz_v_max [expr {round(floor( (100 / ($vrt_k * 1.12)) * ($ang_k * 0.89) - 100))}]

  return "Angriffserfolg: ( neutral: $proz_n% ) ( angreifer max: $proz_a_max% ) ( verteidiger max: $proz_v_max% )"
}

proc ::tsp::kampf::calc { } {
  return "no calculations found!"
}

proc ::tsp::kampf::getattdef { droide } {
  set inidir "Bot/ini/dw.ini"

  set line [ini_read $inidir "droide" $droide]

  if { $line == ";" } {
    set line [ini_read $inidir "turme" $droide]
  }

  if { $line == ";" } {
    set att -1
    set def -1
  } else {
    set att [gettok $line 1 " "]
    set def [gettok $line 2 " "]
  }

  list $att $def
}
