#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 2300
# Description: Patch firmware for installation shop/promo unit

# Option --patch-promo-flags: Patch promo_flags file
# Option --patch-update-flags: Patch update_flags file
# Option --patch-version: Append string to build version

# Type --patch-promo-flags: boolean
# Type --patch-update-flags: boolean
# Type --patch-version: string 
    
namespace eval ::patch_shop {

    array set ::patch_shop::options {
        --patch-promo-flags true
        --patch-update-flags true
        --patch-version "Promotional-to-Retail"
    }

    proc main {} {
        if {$::patch_shop::options(--patch-promo-flags)} {
          debug "Patching [file tail $::CUSTOM_PROMO_FLAGS_TXT]"
          set fd [open $::CUSTOM_PROMO_FLAGS_TXT w]
          puts -nonewline $fd "0"
          close $fd
        }
        if {$::patch_shop::options(--patch-update-flags)} {
          debug "Patching [file tail $::CUSTOM_UPDATE_FLAGS_TXT]"
          set fd [open $::CUSTOM_UPDATE_FLAGS_TXT w]
          puts -nonewline $fd "0300"
          close $fd
        }
        if {$::patch_shop::options(--patch-version) != ""} {
          append ::options(--build-suffix) "($::patch_shop::options(--patch-version))"
        }
    }
}
