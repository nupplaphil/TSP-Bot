bind pub - fire fire
bind pub - bהm bam
bind pub - peace peace
bind pub - moo moo
bind pub - caps caps
bind pub - afk? afk
bind pub - weiblich? weiblich
bind pub - lalilu lalilu
bind pub - würfeln wurfeln
bind pub - augenfarbe augenfarbe

proc fire { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :Fire in my hole!"
}

proc bam { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :Bהm! Bהההm! Bההההההm! Bההההההההההm! Bהההההההההההההההההההההההההm!"
}

proc peace { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :bombing for peace is like fucking for virginity."
}

proc moo { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :mooooo0Oo.. $nick ..oO"
}

proc caps { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :BEI MIR KOMMT IMMER DIE EINS STATT EINEM AUSRUFEZEICHEN111"
}

proc afk { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :away from komputer ;)"
}

proc weiblich { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :yeah, irc.. where men are men, and women are men too :)"
}

proc lalilu { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :lalilu nur der man im mond schaut zu wie die kleinen kinder schlafen und nun schlaf auch du."
}

# generate random integer number in the range [min,max]
proc RandomInteger {min max} {
    return [expr {int(rand()*($max-$min+1)+$min)}]
}

proc wurfeln { nick uhost hand chan text } {
  set from 1
  set to 6

  set t_from [lindex $text 0]
    if { [string is integer -strict $t_from] } {
      set from $t_from
  }

  set t_to [lindex $text 1]
  if { [string is integer -strict $t_to] } {
    set to $t_to
  } elseif { [string is integer -strict $t_from] } {
    set to $t_from
    set from 1
  }
    
  putserv "PRIVMSG $chan :$nick würfelt [RandomInteger $from $to]"
}

proc augenfarbe { nick uhost hand chan args } {
  putserv "PRIVMSG $chan :blond"
}

putlog "fun.tcl loaded"
