#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch Appldr (Experimental!)

# Option --patch-appldr-fself-340: Patch Appldr to allow Fself (3.40-3.55) set debug true
# Option --patch-appldr-fself-330: Patch Appldr to allow Fself (3.10-3.30) set debug true

# Type --patch-appldr-340: boolean
# Type --patch-appldr-330: boolean

namespace eval ::patch_appldr {

    array set ::patch_appldr::options {
        --patch-appldr-fself-340 false
        --patch-appldr-fself-330 true
    }

    proc main { } {
        set self "appldr"

        ::modify_coreos_file $self ::patch_appldr::patch_self
    }

    proc patch_elf {elf} {
        if {$::patch_appldr::options(--patch-appldr-fself-340)} {
            log "Patching Appldr to allow Fself (3.40-3.55)"

            set search  "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x00\x04\x80\x32\x80\x80"
            set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x11\x73\x00\x32\x80\x80"

            catch_die {::patch_elf $elf $search 7 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }

    proc patch_elf {elf} {
        if {$::patch_appldr::options(--patch-appldr-fself-330)} {
            log "Patching Appldr to allow Fself (3.10-3.30)"

            set search  "\x40\x80\x0e\x0d\x20\x00\x69\x09\x32\x00\x04\x80\x32\x80\x80"
            set replace "\x40\x80\x0e\x0c\x20\x00\x57\x83\x32\x11\x73\x00\x32\x80\x80"

            catch_die {::patch_elf $elf $search 7 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }

}
