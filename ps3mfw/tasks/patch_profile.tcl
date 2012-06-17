#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
# Copyright (C) glevand (geoffrey.levand@mail.ru)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 300
# Description: Patch profile

# Option --patch-profile-gameos-bootmem-size: Increase boot memory size of GameOS (Needed for OtherOS++)

# Type --patch-profile-gameos-bootmem-size: boolean

namespace eval ::patch_profile {

    array set ::patch_profile::options {
        --patch-profile-gameos-bootmem-size true
    }

    proc main { } {
        set spp "default.spp"

        ::modify_coreos_file $spp ::patch_profile::patch_spp
    }

    proc patch_spp {spp} {
        ::modify_spp_file $spp ::patch_profile::patch_pp
    }

    proc patch_pp {pp} {
        if {$::patch_profile::options(--patch-profile-gameos-bootmem-size)} {
            log "Patching GameOS profile to increase boot memory size"

            set search  "\x50\x53\x33\x5f\x4c\x50\x41\x52\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
	    append search "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x06\x00\x00\x02\x50"
	    append search "\x10\x70\x00\x00\x02\x00\x00\x01\x2f\x66\x6c\x68\x2f\x6f\x73\x2f\x6c\x76\x32\x5f"
	    append search "\x6b\x65\x72\x6e\x65\x6c\x2e\x73\x65\x6c\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x1b"

            catch_die {::patch_pp $pp $search 304 $replace} \
                "Unable to patch spp [file tail $pp]"
        }
    }
}
