#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 2400
# Description: Change default "Air Paint" theme

# Option --theme-src: Source theme file
# Option --theme-dst: Destination theme slot

# Type --theme-src: file open {"PS3 Theme" {p3t}}
# Type --theme-dst: label {01 "Air Paint"}

namespace eval change_theme {

    array set ::change_theme::options {
        --theme-src "filename.p3t"
        --theme-dst "01 \"Air Paint\""
    }

    proc main {} {
        variable options
        set src $options(--theme-src)
        set dst [file join dev_flash vsh resource theme [lindex $options(--theme-dst) 0].p3t]

        if {[file exists $options(--theme-src)] == 0} {
            die "$src does not exist"
        } else {
            ::modify_devflash_file $dst ::change_theme::replace_theme $src
        }
    }

    proc replace_theme { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Changing default \"Air Paint\" theme [file tail $dst] with [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
}
