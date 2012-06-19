#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 500
# Description: Patch package installer

# Option --allow-pseudoretail-pkg: Patch to allow installation of pseudo-retail packages
# Option --allow-debug-pkg: Patch to allow installation of debug packages

# Type --allow-pseudoretail-pkg: boolean
# Type --allow-debug-pkg: boolean

namespace eval ::patch_nas_plugin {

    array set ::patch_nas_plugin::options {
        --allow-pseudoretail-pkg true
        --allow-debug-pkg true
    }

    proc main {} {
        set self [file join dev_flash vsh module nas_plugin.sprx]

        ::modify_devflash_file $self ::patch_nas_plugin::patch_self
    }

    proc patch_self { self } {
        if {!$::patch_nas_plugin::options(--allow-pseudoretail-pkg)} {
            log "WARNING: Enabled task has no enabled option" 1
        } elseif {!$::patch_nas_plugin::options(--allow-debug-pkg)} {
            log "WARNING: Enabled task has no enabled option" 1
        } else {
            ::modify_self_file $self ::patch_nas_plugin::patch_elf
        }
    }

    proc patch_elf { elf } {
        if {$::patch_nas_plugin::options(--allow-pseudoretail-pkg) } {
            log "Patching [file tail $elf] to allow pseudo-retail pkg installs"

            set search "\x7c\x60\x1b\x78\xf8\x1f\x01\x80"
            set replace "\x38\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_nas_plugin::options(--allow-debug-pkg) } {
            log "Patching [file tail $elf] to allow debug pkg installs"

            set search "\x2f\x89\x00\x00\x41\x9e\x00\x4c\x38\x00\x00\x00"
            set replace "\x60\x00\x00\x00"

            catch_die {::patch_elf $elf $search 4 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}
