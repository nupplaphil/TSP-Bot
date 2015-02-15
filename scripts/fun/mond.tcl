
global mondini
set mondini "Bot/ini/mond.ini"

bind pubm -|- "#tsp *" on_text
bind join -|- "#tsp *" on_join
bind sign -|- "#tsp *" on_signoff
bind part -|- "#tsp *" on_signoff

proc on_signoff { nick uhost mask chan text } {
  global mondini

  if { [ini_read $mondini $chan status] == 2 && [gettok [ini_read $mondini $chan nick1] 1] == $nick } {
    putserv "PRIVMSG $chan :$nick ist mit einem Punkt abgehauen!!"
    ini_write $mondini $chan status 1
  } elseif { [ini_read $mondini $chan status] == 3 && ( [gettok [ini_read $mondini $chan nick1] 1] == $nick || [gettok [ini_read $mondini $chan nick2] 1] == $nick ) } {
    putserv "PRIVMSG $chan :$nick ist mit einem Punkt abgehauen!!"
    ini_write $mondini %chan status 1
  } elseif { [ini_read $mondini $chan status] == 4 && ( [gettok [ini_read $mondini $chan nick1] 1] == $nick || [gettok [ini_read $mondini $chan nick2] 1] == $nick || [gettok [ini_read $mondini $chan nick3] 1] == $nick ) } {
    putserv "PRIVMSG $chan :$nick ist mit einem Komma abgehauen!!"
    ini_write $mondini $chan $status 1
  }
}

proc on_join { nick uhost mask chan } {
  global botnick mondini
  if { $nick == $botnick && [ini_read $mondini $chan status] != 1} {
    start_timer $chan
    putlog "timer started"
  }
}


proc on_text { nick uhost mask chan text } {
  global mondini

  if { [llength $text] < 1 } { return }

  set var [lindex $text 0]
  
  if { [llength $text] == 1 } {
    if { $var == "." } { ini_inc $mondini $chan punkte }
    if { $var == "," } { ini_inc $mondini $chan komma }
    if { $var == "-" } { ini_inc $mondini $chan strich }
    
    set reset [ini_read $mondini $chan reset]
    if { $var == "." && [gettok $reset 1] == "punkte" && [ini_read $mondini $chan punkte] >= [gettok $reset 2] } { mondreset $chan }
    if { $var == "," && [gettok $reset 1] == "komma" && [ini_read $mondini $chan komma] >= [gettok $reset 2] } { mondreset $chan }
    if { $var == "-" && [gettok $reset 1] == "strich" && [ini_read $mondini $chan strich] >= [gettok $reset 2] } { mondreset $chan }

    if { $var == "punkte?" } { putserv "PRIVMSG $chan :[ini_read $mondini $chan punkte] Punkte since [clock format [ini_read $mondini statschan $chan] -format "%d.%m.%C%y %H:%M" -gmt true ]" }
    if { $var == "kommas?" } { putserv "PRIVMSG $chan :[ini_read $mondini $chan komma] Kommas since [clock format [ini_read $mondini statschan $chan] -format "%d.%m.%C%y %H:%M" -gmt true ]" }
    if { $var == "striche?" } { putserv "PRIVMSG $chan :[ini_read $mondini $chan strich] Striche since [clock format [ini_read $mondini statschan $chan] -format "%d.%m.%C%y %H:%M" -gmt true ]" }
    if { $var == "xichter?" } { putserv "PRIVMSG $chan :[ini_read $mondini $chan xichter] Xichter since [clock format [ini_read $mondini statschan $chan] -format "%d.%m.%C%y %H:%M" -gmt true ]" }
    if { $var == "reset?" } { putserv "PRIVMSG $chan :Reset bei $reset" }

    if { $var == "."  && [ini_read $mondini $chan status] == 1} {
      set rnd [expr {int(1 + rand() * 20)}]
      if { $rnd >= 10 } {
        set randnr [expr {int(1 + rand() * [llength [ini_read $mondini punkt_txt]]) / 2}]
        set msg [ini_read $mondini punkt_txt $randnr]
      } else {
        set randnr [expr {int(1 + rand() * [llength [ini_read $mondini punkt1_txt]]) / 2}]
        set msg [ini_read $mondini punkt1_txt $randnr]
       }
      ini_write $mondini $chan nick1 "$nick $uhost"
      ini_write $mondini $chan status 2
      start_timer $chan
      putserv "PRIVMSG $chan :$msg"
    } elseif { $var == "." && [ini_read $mondini $chan status] == 2 && [gettok [ini_read $mondini $chan nick1] 2] != $uhost  } {
      set rnd [expr {int(1 + rand() * 20)}]
      if { $rnd >= 10 } {
        set randnr [expr {int(1 + rand() * [llength [ini_read $mondini punkt_txt]]) / 2}]
        set msg [ini_read $mondini punkt_txt $randnr]
      } else {
        set randnr [expr {int(1 + rand() * [llength [ini_read $mondini punkt2_txt]]) / 2}]
        set msg [ini_read $mondini punkt2_txt $randnr]
      }
      ini_write $mondini $chan nick2 "$nick $uhost"
      ini_write $mondini $chan status 3
      start_timer $chan
      putserv "PRIVMSG $chan :$msg"
    } elseif { $var == "," && [ini_read $mondini $chan status] == 3 && [gettok [ini_read $mondini $chan nick1] 2] != $uhost  && [gettok [ini_read $mondini $chan nick2] 2] != $uhost  } {
      set randnr [expr {int(1 + rand() * [llength [ini_read $mondini komma_txt]]) / 2}]
      set msg [ini_read $mondini komma_txt $randnr]
      ini_write $mondini $chan nick3 "$nick $uhost"
      ini_write $mondini $chan status 4
      start_timer $chan
      putserv "PRIVMSG $chan :$msg"
    } elseif { $var == "-" && [ini_read $mondini $chan status] == 4  && [gettok [ini_read $mondini $chan nick1] 2] != $uhost  && [gettok [ini_read $mondini $chan nick2] 2] != $uhost  && [gettok [ini_read $mondini $chan nick3] 2] != $uhost } {
      set randnr [expr {int(1 + rand() * [llength [ini_read $mondini strich_txt]]) / 2}]
      set msg [ini_read $mondini strich_txt $randnr]
      putserv "PRIVMSG $chan :$msg"
      ini_write $mondini $chan nick4 "$nick $uhost"
      ini_write $mondini $chan status 0 
      putserv "PRIVMSG $chan :Danke [gettok [ini_read $mondini $chan nick1] 1], [gettok [ini_read $mondini $chan nick2] 1], [gettok [ini_read $mondini $chan nick3] 1] und [gettok [ini_read $mondini $chan nick4] 1]"
      putquick "MODE $chan +www . , -"
      utimer 300 [putquick "MODE $chan -www . , -"]
      
      add_highscore $chan [gettok [ini_read $mondini $chan nick1] 1] [gettok [ini_read $mondini $chan nick2] 1] [gettok [ini_read $mondini $chan nick3] 1] [gettok [ini_read $mondini $chan nick4] 1]
      sort_highscore $chan

      start_timer $chan
      ini_inc $mondini $chan xichter
 
      if { [gettok $reset 1] == "xicht" && [ini_read $mondini $chan xichter] >= [gettok $reset 2] } { mondreset $chan } 
    }
  }

  if { $var == "!xichter" } {
    if { [llength $text] > 1 } {
      set prt [gettok $text 2]
    } else {
      set prt $nick
    }

    lassign [get_highscore $chan $prt] sr plz ges

    putserv "PRIVMSG $chan :$prt war an $sr Xichtern dabei. Damit auf Platz $plz von $ges"
  }

  if { $var == "!top" } {
    if { [llength $text] > 1 } {
      set count [gettok $text 2]
    } else {
      set count 10
    }

    if { ![string is integer -strict $count] } { return }
    if { $count > 10 } { set count 10 }

    putserv "PRIVMSG $chan :Top $count"    
    set msg ""
    for { set n 1 } { $n <= $count } { incr n } {
      if { $msg != "" } { set msg "$msg ;" }
      set msg "$msg [get_nick $chan $n]"
      if { $n % 5 == 0 } {
        putserv "PRIVMSG $chan :$msg"
        set msg ""
      }
    }

    if { $msg != "" } { putserv "PRIVMSG $chan :$msg" }

    putserv "PRIVMSG $chan :Gewinner der letzten Runde"
    putserv "PRIVMSG $chan :[ini_read $mondini $chan gewinner]"
  }

  if { $var == "!platz" && [llength $text] > 1 } {
    set platz [lindex $text 1]
    if {![string is integer -strict $platz]} { return }

    set platz_nick [get_nick $chan $platz]

    putserv "PRIVMSG $chan :Platz $platz : $platz_nick"
  }
}

proc mondreset { chan } {
  global mondini
  set chantxt "Bot/txt/mond/mond_$chan"
  
  if { [ini_read $mondini $chan reset] == "\;" } { return }
 
  ini_write $mondini statschan $chan [clock seconds]
  ini_write $mondini $chan punkte 0
  ini_write $mondini $chan komma 0
  ini_write $mondini $chan strich 0
  ini_write $mondini $chan xichter 0

  set gewinner [ini_read $mondini $chan gewinner]
  set winner [get_nick $chan 1] 
  ini_write $mondini $chan gewinner "$winner \([clock format [clock seconds] -format "%d.%m.%C%y" -gmt true]\); $gewinner"
  
  set source      "[expr {$chantxt}].txt"
  set destination "[expr {$chantxt}]_reset_[clock format [clock seconds] -format "%C%y%m%d" -gmt true].txt"
  mv $source $destination
  set fs [open $source w]
  close $fs

  putserv "PRIVMSG $chan :Xichter Reset durchgeführt!"
}

proc get_nick { chan platz } {
  set chantxt "Bot/txt/mond/mond_$chan.txt"
  set fp [open $chantxt r]
  set data [read -nonewline $fp]
  close $fp

  set platz [incr platz -1]

  set lines [split $data "\n"]

  if { [catch { set retr [lindex $lines $platz] }] } {
    return "Kein Platz"
  }
  return $retr
}

proc ini_inc { inifile section item } {
  if { [catch { set value [ini_read $inifile $section $item] }] }  {
    return "\;"
  }
  if { ![string is integer -strict value] } {
    return "\;"
  }

  ini_write $inifile $section $item [incr value]
}

proc start_timer { chan } {
  global mondini
  set currtimer [ini_read $mondini $chan timer]
  if { $currtimer != "\;" } {
    catch { killutimer $currtimer }
    putlog "killed $currtimer"
  }
  
  set randnr [expr {int(700 + (rand() * 700))}]
  putlog "$randnr"
  set timerid [utimer $randnr [list ini_write $mondini $chan status 1]]
  ini_write $mondini $chan timer $timerid
}

proc add_highscore { chan nick1 nick2 nick3 nick4 } {
  set chantxt "Bot/txt/mond/mond_$chan.txt"
  set nicklist [list $nick1 $nick2 $nick3 $nick4]
  set fp [open $chantxt r]
  set data [read -nonewline $fp]
  close $fp

  set lines [split $data "\n"]
  set countlines [expr {[llength $lines] - 1}]

  for {set p 0} {$p <= $countlines} {incr p} {
    set currnick [gettok [lindex $lines $p] 1]
    set curranz  [gettok [lindex $lines $p] 2]

    for {set n 0} {$n < 4} {incr n} {
      set othernick [lindex $nicklist $n]
      if { $othernick == $currnick } {        
        lset lines $p  "$currnick [incr curranz]"
        lset nicklist $n ""
      }
    }
  }

  foreach nick $nicklist {
    if { $nick != "" } {
      lappend lines "$nick 1"
    }
  }

  set fp [open $chantxt w]
  puts $fp [join $lines "\n"]
  close $fp
}

proc sort_highscore { chan } {
  set chantxt "Bot/txt/mond/mond_$chan.txt"
  set fp [open $chantxt r]
  set data [read -nonewline $fp]
  close $fp

  set lines [split $data "\n"]

  set list_lines ""
  foreach line $lines { 
    lappend lst_lines [split $line " "]    
  }

  set lst_lines [lsort -index 1 -integer -decreasing $lst_lines]

  set fp [open $chantxt w]
  foreach lstelem $lst_lines {
    puts $fp [join $lstelem " "]
  }
  close $fp
}

proc get_highscore { chan nick } {
  set chantxt "Bot/txt/mond/mond_$chan.txt"
  set fp [open $chantxt r]
  set data [read -nonewline $fp]
  close $fp

  set lines [split $data "\n"]
  set countlines [llength $lines]
  
  set sr 0
  set lnr 0
  set l 0

  for { } { $l < $countlines } { incr l } {
    set line [lindex $lines $l]
    if { [gettok $line 1] == $nick } {
      set sr [gettok $line 2]
      set lnr [expr {$l+1}]
    }
  }

  list $sr $lnr $l
}
