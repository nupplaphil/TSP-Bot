####################
## INI Database v0.4.2 [ DEC/16/1999 ]
##  By mamaKIN (mamakin@mailandnews.com)
##
##  Thanks to Amadeus` for spotting some important issues
##
## Visit http://mort.level5.net/~mamakin/scripts/eggdrop/inidb.html for updates
##
## Description:
##   INI Datbase allows people to easily store settings and easily access them.
##   * INI Database is for TCL scripters only *
##
##-----------------------------------------------------------------------------
##   PROCEDURE:   ini_read <ini file> <section> <item>
##   DESCRIPTION: Reads the value of an item from the specified section in the
##                ini file.
##   RETURNS:     the value of the item if successful; semi-colon ';' otherwise
##                (semi-colon because any other characters could be used as the
##                  value, so use "\;" when comparing ini_read's return value)
##-----------------------------------------------------------------------------
##   PROCEDURE:   ini_write <ini file> <section> <item> [value]
##   DESCRITPION: Sets the value of item in the specified section in the ini
##                file.
##   RETURNS:     TRUE (1) if successful; FALSE (0) otherwise
##-----------------------------------------------------------------------------
##   PROCEDURE:   ini_remove <ini file> <section> [item]
##   DESCRIPTION: Removes a section of the ini file or an item of the section.
##                Use "" in place of the item variable if you wish to
##                exclude it.
##                ( Use "file delete" if you want to remove the ini file )
##   RETURNS:     TRUE (1) if successful; FALSE (0) otherwise
##-----------------------------------------------------------------------------
####################

set inidb_ver "{INI Database v0.4.2} {04200!00} {6447b} {945384656} {mamaKIN}"

proc ini_read {inifile section { item "" }} {
  set item [lindex $item 0]
  if {[lindex $inifile 0] == "" || [lindex $section 0] == ""} { return "\;" }
  if {![file exists $inifile]} { return "\;" }
  set fileo [open $inifile r]
  set sect ""
  while {![eof $fileo]} {
    set rline [gets $fileo]
    set rline [string trim $rline]
    if {$rline != "" || [string index $rline 0] != "\;"} {
      if {[string index $rline 0] == "\[" && [string index $rline [expr [string length $rline] - 1]] == "\]"} {
        set sect [string range $rline 1 [expr [string length $rline] - 2]]
      } elseif {[string tolower $sect] == [string tolower $section]} {
        set im [string tolower [string range $rline 0 [expr [string first = $rline] - 1]]]        
        set va [string range $rline [expr [string first = $rline] + 1] end]
        if { ${im} != "" } {
          set itm(${im}) $va
        }
      }
    }
  }
  close $fileo;
  if {$item == ""} {
    array get itm
  } else {
    if { [catch {set rtrn $itm([string tolower $item])}] } { return "\;" }
    return $rtrn
  }
}

proc ini_write {inifile section item value} {
  set section [lindex [string tolower $section] 0]
  if {[lindex $inifile 0] == "" || [lindex $section 0] == "" || [lindex $item 0] == ""} { return 0 }
  if {![file exists $inifile] || [file size $inifile] == 0} {
    set filew [open $inifile w]
    puts $filew "\[$section\]"
    puts $filew "[string tolower $item]=$value"
    close $filew; return 1
  }
  set fileo [open $inifile r]
  set cursect ""; set sect ""
  while {![eof $fileo]} {
    set rline [string trim [gets $fileo]]
    if {$rline != "" || [string index $rline 0] != "\;"} {
      if {[string index $rline 0] == "\[" && [string index $rline [expr [string length $rline] - 1]] == "\]"} {
        set cursect [string tolower [string range $rline 1 [expr [string length $rline] - 2]]]
        lappend sect $cursect
      } {
        set im [string tolower [string range $rline 0 [expr [string first = $rline] - 1]]]
        set vl [string range $rline [expr [string first = $rline] + 1] end]
        lappend [join "ini $cursect" ""]($im) $vl
      }
    }
  }
  close $fileo; unset fileo
  if {[lsearch $sect $section] == -1} { lappend sect $section }
  set [join "ini $section" ""]([string tolower $item]) $value
  set fileo [open $inifile w]
  foreach sct $sect {
    puts $fileo "\[$sct\]"
    foreach ite [array names [join "ini $sct" ""]] {
      set ite [lindex $ite 0]
      set valu [set [join "ini $sct" ""]($ite)]     
      if {$ite != ""} {
        puts $fileo "$ite=[join $valu]"
      }
    }
    puts $fileo ""
  }
  close $fileo
  return 1
}

proc ini_remove { inifile section item } {
  set section [lindex [string tolower $section] 0]
  set item [lindex [string tolower $item] 0]
  if {[lindex $inifile 0] == ""} { return 0 }
  if {![file exists $inifile]} { return 0 }
  if {$section == ""} { return 0 }
  set fileo [open $inifile r]
  set cursect ""; set sect ""
  while {![eof $fileo]} {
    set rline [string trim [gets $fileo]]
    if {$rline != "" || [string index $rline 0] != "\;"} {
      if {[string index $rline 0] == "\[" && [string index $rline [expr [string length $rline] - 1]] == "\]"} {
        set cursect [string tolower [string range $rline 1 [expr [string length $rline] - 2]]]
        lappend sect $cursect
      } {
        set im [string tolower [string range $rline 0 [expr [string first = $rline] - 1]]]
        set vl [string range $rline [expr [string first = $rline] + 1] end]
        lappend [join "ini $cursect" ""]($im) $vl
      }
    }
  }
  close $fileo; unset fileo
  set sesect [lsearch $sect $section]
  if {$sesect == -1} {
    return 0
  } {
    if {$item == ""} { set sect [lreplace $sect $sesect $sesect] }
  }
  if { ![catch {[unset [join "ini $section" ""]($item)] }] } {
    if {[llength [array names [join "ini $section" ""]]] == 1} {
      set sect [lreplace $sect $sesect $sesect]
    }
  }
  if {[llength $sect] == 0} { file delete $inifile; return 1 }
  set fileo [open $inifile w]
  foreach sct $sect {
    puts $fileo "\[$sct\]"
    foreach ite [array names [join "ini $sct" ""]] {
      set ite [lindex $ite 0]
      set valu [set [join "ini $sct" ""]($ite)]
      if {$ite != "" && [lindex $valu 0] != ""} {
        puts $fileo "$ite=[join $valu]"
      }
    }
    puts $fileo ""
  }
  close $fileo
  return 1
}

if {[info exists version]} {
  putlog "Loaded [lindex $inidb_ver 0] by [lindex $inidb_ver 4]"
}

