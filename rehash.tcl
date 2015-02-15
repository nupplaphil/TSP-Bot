# This is the main script for the TSP-Bot
# Copies all the tcl scripts from the
# script directory to the
# temp directory
unbind dcc  n rehash            *dcc:rehash
  bind dcc  n rehash             dcc:rehash

proc dcc:rehash { handle idx arg } {
	*dcc:rehash $handle $idx $arg
}
