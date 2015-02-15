
namespace eval tsp::uran { }

proc ::tsp::uran::help { chan } {
  putserv "PRIVMSG $chan :Eintrag aktualisieren - !dw uran Anzahl"
  putserv "PRIVMSG $chan :Abfragen aller Einträge - !dw uran view"
  putserv "PRIVMSG $chan :Gesamturanstand - !dw uran gesamt"
  putserv "PRIVMSG $chan :Eintrag löschen - !dw uran del user"
}

proc ::tsp::uran::parse { nick uhost hand chan arguments } {
  if {[llength $arguments] < 1} {
    return "error"
  }

  set dwini "Bot/ini/dw.ini"
 
  set arg [lindex $arguments 0]
  if { $arg == "view" } {
    array set items [ini_read $dwini "uran"]

    foreach itm [array names items] {
      if {$itm == ""} { continue }
      set line $items($itm)
      set uran      [gettok $line 1 " "]
      set time_form [clock format [gettok $line 2 " "] -format "%d.%m.%C%y" -gmt true]
      putserv "NOTICE $nick :$itm $uran (am $time_form)"
    }
  } elseif { $arg == "del" && [llength $arguments] > 1 } {
    set othernick [lindex $arguments 1]
    if { [ini_read $dwini "uran" $othernick] != "\;" } { 
      if { [ini_remove $dwini "uran" $othernick] == 1 } {
        return "$othernick wurde aus Uranliste gelöscht"
      } else {
        return "$othernick konnte nicht gelöscht werden"
      }
    } else {
      return "$othernick nicht in der Liste gefunden"
    }
  } elseif { $arg == "gesamt" } {
    set uran 0
    array set items [ini_read $dwini "uran"]

    foreach itm [array names items] {
      if {$itm == ""} { continue }
      set uran [expr {$uran + [gettok $items($itm) 1 " "]}]
    }

    return "Uranvermögen von $uran uran"
  } elseif { [string is integer -strict $arg] } {
    if { [ini_write $dwini "uran" $nick "$arg [clock seconds]"] == 1 } {
      return "Uranliste aktualisiert"
    } else {
      return "Uranliste konnte nicht aktualisiert werden"
    }
  } 
}

proc ::tsp::uran::calc { } {
}

set ::tsp::uran::onjoin_chans "#tsp-intern"

## On Join deaktiviert
# bind join - * ::tsp::uran::onjoin

proc ::tsp::uran::onjoin { nick uhost hand chan } {
  global ::tsp::uran::onjoin_chans botnick

  set chans onjoin_chans

  if {(([lsearch -exact [string tolower $onjoin_chans] [string tolower $chan]] != -1) || ($onjoin_chans == "*")) && (![matchattr $hand b]) && ($nick != $botnick)} {
    set dwini "Bot/ini/dw.ini"
    set stand [ini_read $dwini "uran" $nick]
    if {$stand == ";"} {
      puthelp "NOTICE $nick :Du hast noch keinen Uranstand eingetrage (!dw uran 105000) und regelmässig aktualisieren"
    } elseif {$stand != ";"} {
      set now [expr {[clock seconds] - [gettok $stand 2 " "]}]
      # Ã¤lter als 2 Tage
      if {$now > 172800} {
        puthelp "NOTICE $nick :Aktualisiere deinen Uranstand (aktuell eingetragen: $stand)"
      }
    }
  }
}
