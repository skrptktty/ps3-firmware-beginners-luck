#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
 
# Priority: 2900
# Description: Change a specific file in devflash manually

# Option --change-filenames: Filenames to change (must start with 'dev_flash/')

# Type --change-filenames: textarea


namespace eval change_devflash_files {

    array set ::change_devflash_files::options {
        --change-filenames "dev_flash/path/to/file/to/change"
    }

    proc main {} {
        variable options
        foreach file [split $options(--change-filenames) "\n"] {
            if {[string equal -length 14 "dev_flash/path" ${file}] != 1} {
                if {[string equal -length 10 "dev_flash/" ${file}] == 1} {
                    ::modify_devflash_file ${file} ::change_devflash_files::change_file
                }
            }
        }
    }

    proc change_file { file } {
        log "The file to change is in ${file}"

        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Change the file '${file}' then press ok to continue" -icon warning
        } else {
           puts "Press \[RETURN\] or \[ENTER\] to continue"
           gets stdin
        }
    }
}
