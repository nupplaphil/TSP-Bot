#
#
# This is the main entry Point of the Bot
# Here every source in the Bot sub-directories getss loaded

# This is a Tcl script to be run immediately after connecting to a server.
bind evnt - init-server evnt:init_server

proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
  loadsources
}

# bind the dcc rehash to a custom rehash
unbind dcc  n rehash            *dcc:rehash
  bind dcc  n rehash             dcc:rehash

proc dcc:rehash { handle idx arg } {
  loadsources
  *dcc:rehash $handle $idx $arg
}

# Load all scripts in the subdirectories
proc loadsources { } {
  source Bot/identify.tcl
  set dir "Bot/scripts/"

  set includes [open "|find $dir -name \*.tcl -print" r]
  while { [gets $includes include] >= 0 } {
    source $include
  }

  close $includes
}

#Tries to load a script
proc sourcetry {file} {
  set scriptlist "$file $file.tcl scripts/$file scripts/$file.tcl"
  foreach script $scriptlist {
    if [file exists $script] {
      source $script
      return 1
    }
  }
  return 0
}
