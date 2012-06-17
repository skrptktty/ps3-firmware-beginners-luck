#!/usr/bin/tclsh
#
# ps3mfw.tcl -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 2000
# Description: Patch translations: fix typos, change strings, replace languages

# Option --fix-typo-sysconf-Italian: Fix a typo in the Italian localization of the sysconf plugin

# Type --fix-typo-sysconf-Italian: boolean

namespace eval ::patch_translations {

    array set ::patch_translations::options {
        --fix-typo-sysconf-Italian true
    }

    proc main { } {
        if {$::patch_translations::options(--fix-typo-sysconf-Italian)} {
            fix_typo_sysconf_Italian
        }
    }

    proc fix_typo_sysconf_Italian { } {
        set SYSCONF_PLUGIN_RCO [file join dev_flash vsh resource sysconf_plugin.rco]
       ::modify_rco_file $SYSCONF_PLUGIN_RCO ::patch_translations::callback_fix_typo_sysconf_Italian
    }

    proc callback_fix_typo_sysconf_Italian {path args} {
        log "Patching Italian.xml into [file tail $path]"
        sed_in_place [file join $path Italian.xml] backuip backup
    }

}

