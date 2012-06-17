#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Notes: ac3 codec a52 channels stereo samplerate 48kHz bitrate 640kb/s

# Priority: 2200
# Description: Replace coldboot audio/video files (USE CAUTION)

# Option --coldboot-raf: coldboot.raf video filename
# Option --coldboot-stereo: coldboot_stereo.ac3 audio filename
# Option --coldboot-multi: coldboot_multi.ac3 audio filename

# Type --coldboot-raf: file open {"RAF Video" {raf}}
# Type --coldboot-stereo: file open {"AC3 Audio" {ac3}}
# Type --coldboot-multi: file open {"AC3 Audio" {ac3}}

namespace eval change_coldboot_files {

    array set ::change_coldboot_files::options {
        --coldboot-raf "/path/to/file"
        --coldboot-stereo "/path/to/file"
        --coldboot-multi "/path/to/file"
    }

    proc main {} {
        variable options

        set coldboot_raf [file join dev_flash vsh resource coldboot.raf]
        set coldboot_stereo [file join dev_flash vsh resource coldboot_stereo.ac3]
        set coldboot_multi [file join dev_flash vsh resource coldboot_multi.ac3]

        if {[file exists $options(--coldboot-raf)] == 0 } {
            log "Skipping coldboot.raf, $options(--coldboot-raf) does not exist"
        } else {
            ::modify_devflash_file ${coldboot_raf} ::change_coldboot_files::copy_coldboot_file $::change_coldboot_files::options(--coldboot-raf)
        }

        if {[file exists $options(--coldboot-stereo)] == 0 } {
            log "Skipping coldboot_stereo, $options(--coldboot-stereo) does not exist"
        } else {
            ::modify_devflash_file ${coldboot_stereo} ::change_coldboot_files::copy_coldboot_file $::change_coldboot_files::options(--coldboot-stereo)
        }

        if {[file exists $options(--coldboot-multi)] == 0 } {
            log "Skipping coldboot_multi, $options(--coldboot-multi) does not exist"
        } else {
            ::modify_devflash_file ${coldboot_multi} ::change_coldboot_files::copy_coldboot_file $::change_coldboot_files::options(--coldboot-multi)
        }
    }

    proc copy_coldboot_file { dst src } {
        if {[file exists $src] == 0} {
            die "$src does not exist"
        } else {
            if {[file exists $dst] == 0} {
                die "$dst does not exist"
            } else {
                log "Replacing default coldboot file [file tail $dst] with [file tail $src]"
                copy_file -force $src $dst
            }
        }
    }
}
