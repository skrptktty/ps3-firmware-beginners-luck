#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 700
# Description: Patch Application launcher

# Option --allow-unsigned-app: Patch to allow running of unsigned applications

# Type --allow-unsigned-app: boolean

namespace eval ::patch_vsh {

    array set ::patch_vsh::options {
        --allow-unsigned-app true
    }

    proc main { } {
        set self [file join dev_flash vsh module vsh.self]

        ::modify_devflash_file $self ::patch_vsh::patch_self
    }

    proc patch_self {self} {
        if {!$::patch_vsh::options(--allow-unsigned-app)} {
            log "WARNING: Enabled task has no enabled option" 1
        } else {
            ::modify_self_file $self ::patch_vsh::patch_elf
        }
    }

    proc patch_elf {elf} {
        if {$::patch_vsh::options(--allow-unsigned-app)} {
            log "Patching [file tail $elf] to allow running of unsigned applications"

            set search "\xF8\x21\xFF\x81\x7C\x08\x02\xA6\x38\x61\x00\x70\xF8\x01\x00\x90\x4B\xFF\xFF\xE1\x38\x00\x00\x00"
            set replace "\x38\x60\x00\x01\x4E\x80\x00\x20"

            catch_die {::patch_elf $elf $search 0 $replace} "Unable to patch self [file tail $elf]"

            set search "\xA0\x7F\x00\x04\x39\x60\x00\x01\x38\x03\xFF\x7F\x2B\xA0\x00\x01\x40\x9D\x00\x08\x39\x60\x00\x00"
            set replace "\x60\x00\x00\x00"

            catch_die {::patch_elf $elf $search 20 $replace} "Unable to patch self [file tail $elf]"

            log "WARNING: Running unsigned applications will only work if the kernel also supports this option" 1
        }
    }
}
