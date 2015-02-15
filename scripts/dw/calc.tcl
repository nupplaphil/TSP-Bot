
namespace eval tsp {}

bind pubm -|- "#tsp-intern !dw*" ::tsp::calc
bind pubm -|- "#tsp !dw*" ::tsp::calc_pub

proc ::tsp::calc_pub {nick uhost hand chan text} {
  if { [llength $text] < 2} {
    [::tsp::help_pub $nick] 
    return 1
  }

  set command [lindex $text 1]
  set command [string tolower $command]

  if { [info exists [expr {$command}]::public] != 1 } {
    [::tsp::help_pub $nick]
    return 1
  }

  set function [info procs ::tsp::[expr {$command}]::parse]
  if { $function == "" } {
    [::tsp::help $nick]
    return 1
  }

  if { [llength $text] == 1} {
    [::tsp::help_pub $nick]
    return 1
  }

  set restargs [lrange $text 2 end]
  set msg [$function $nick $uhost $hand $chan $restargs]

  if { $msg == "error" } {
    [::tsp::[expr {$command}]::help $chan]
    return 1
  }

  putserv "PRIVMSG $chan :$msg"

}

proc ::tsp::calc {nick uhost hand chan text} {
  if {[llength $text] < 2} {
    [::tsp::help $nick]
    return 1
  }

  set command [lindex $text 1]
  set command [string tolower $command]
  
  if { $command == "dp" } {
    set command "bp"
  }
  
  set function [info procs ::tsp::[expr {$command}]::parse]
  if { $function == "" } {
    [::tsp::help $nick]
    return 1
  }

  if { [llength $text] == 1} {
    [::tsp::[expr {$command}]::help $chan]
    return 1
  }

  set restargs [lrange $text 2 end]
  set msg [$function $nick $uhost $hand $chan $restargs]

  if { $msg == "error" } {
    [::tsp::[expr {$command}]::help $chan] 
    return 1
  }

  putserv "PRIVMSG $chan :$msg"
}

proc ::tsp::help_pub { nick } {
  putserv "NOTICE $nick :Available functions:"
  foreach ns [namespace children ::tsp] {
    set function [info procs [expr {$ns}]::parse]
    if {$function != "" } {
      set publ [info exists [expr {$ns}]::public]
      if {$publ != 1} { continue }
      set namefunction [gettok $ns 4 :]
      putserv "NOTICE $nick :!dw $namefunction"
    }
  }
}

proc ::tsp::help { nick } {
  putserv "NOTICE $nick :Available functions:"
  foreach ns [namespace children ::tsp] {
    set function [info procs [expr {$ns}]::parse]
    if {$function != "" } {
      set namefunction [gettok $ns 4 :]
      putserv "NOTICE $nick :!dw $namefunction"
    }
  }
}

putlog "TSP Scripts loaded"
