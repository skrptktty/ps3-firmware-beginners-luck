#!/usr/bin/env wish8.5
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# MacOS X / Windows wrapper 
#
# Mac OSX: Remove Cocoa argument from arglist
if {[string first "-psn" [lindex $argv 0]] == 0} { set argv [lrange $argv 1 end]}

#Source the main file
if { $::tcl_platform(platform) == "windows"} {
	source [file join [pwd] ps3mfw]
} else {
	#Set variable program_dir
	set program_dir [file dirname [info script]]
	set program [file tail [info script]]

	while {[catch {file readlink [file join $program_dir $program]} program]== 0} {
		if {[file pathtype $program] == "absolute"} {
			set program_dir [file dirname $program]
		} else {
			set program_dir [file join $program_dir [file dirname $program]]
		}

		set program [file tail $program]
	}

	unset program
	source [file join $program_dir ps3mfw]
}

