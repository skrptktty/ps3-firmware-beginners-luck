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
    
# Priority: 400
# Description: Patch LV2 kernel
    
# Option --patch-lv2-peek-poke: Patch to add Peek&Poke system calls to LV2
# Option --patch-lv2-lv1-peek-poke-355: Patch to add LV1 Peek&Poke system calls to LV2 3.55 (LV1 peek/poke patch necessary)
# Option --patch-lv2-lv1-call-355: Patch to add LV1 Call system call to LV2 3.55

# Type --patch-lv2-peek-poke: boolean
# Type --patch-lv2-lv1-peek-poke-355: boolean
# Type --patch-lv2-lv1-call-355: boolean

namespace eval ::patch_lv2 {

    array set ::patch_lv2::options {
        --patch-lv2-peek-poke true
        --patch-lv2-lv1-peek-poke-355 true
        --patch-lv2-lv1-call-355 true
    }

    proc main { } {
        set self "lv2_kernel.self"

        ::modify_coreos_file $self ::patch_lv2::patch_self
    }

    proc patch_self {self} {
        if {!$::patch_lv2::options(--patch-lv2-peek-poke)} {
            log "WARNING: nothing to do for LV2 patching" 1
        } else {
            set lv1_task 0
            foreach task [get_selected_tasks] {
                if {$task == "patch_lv1"} {
                    set lv1_task 1
                    break
                }
            }

            if {$lv1_task == 0} {
                log "WARNING: You enabled Peek&Poke without enabling LV1 mmap patching." 1
                log "WARNING: Patching LV1 mmap is necessary for Poke to function." 1
            } else {
                ::modify_self_file $self ::patch_lv2::patch_elf
            }
        }
    }

    proc patch_elf {elf} {
        if {$::patch_lv2::options(--patch-lv2-peek-poke)} {
            log "Patching LV2 to allow Peek and Poke support"

            set search    "\xEB\xA1\x00\x88\x38\x60\x00\x00\xEB\xC1\x00\x90\xEB\xE1\x00\x98"
            append search "\x7C\x08\x03\xA6\x7C\x63\x07\xB4\x38\x21\x00\xA0\x4E\x80\x00\x20"
            append search "\x3C\x60\x80\x01\x60\x63\x00\x03\x4E\x80\x00\x20\x3C\x60\x80\x01"
            append search "\x60\x63\x00\x03\x4E\x80\x00\x20"
            set replace   "\xE8\x63\x00\x00\x60\x00\x00\x00\x4E\x80\x00\x20\xF8\x83\x00\x00\x60\x00\x00\x00"

            catch_die {::patch_elf $elf $search 32 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_lv2::options(--patch-lv2-lv1-peek-poke-355)} {
            log "Patching LV2 to allow LV1 Peek and Poke support (3.55)"

            set search     "\x7C\x71\x43\xA6\x7C\x92\x43\xA6\x7C\xB3\x43\xA6\x48"
            set replace    "\x7C\x08\x02\xA6\xF8\x01\x00\x10\x39\x60\x00\xB6\x44\x00\x00\x22"
	    append replace "\x7C\x83\x23\x78\xE8\x01\x00\x10\x7C\x08\x03\xA6\x4E\x80\x00\x20"
	    append replace "\x7C\x08\x02\xA6\xF8\x01\x00\x10\x39\x60\x00\xB7\x44\x00\x00\x22"
	    append replace "\x38\x60\x00\x00\xE8\x01\x00\x10\x7C\x08\x03\xA6\x4E\x80\x00\x20"

            catch_die {::patch_elf $elf $search 5644 $replace} \
                "Unable to patch self [file tail $elf]"

            set search     "\xEB\xA1\x00\x88\x38\x60\x00\x00\xEB\xC1\x00\x90\xEB\xE1\x00\x98"
            append search  "\x7C\x08\x03\xA6\x7C\x63\x07\xB4\x38\x21\x00\xA0\x4E\x80\x00\x20"
            set replace    "\x4B\xFE\x83\xB8\x60\x00\x00\x00\x60\x00\x00\x00\x4B\xFE\x83\xCC"
	    append replace "\x60\x00\x00\x00\x60\x00\x00\x00"

            catch_die {::patch_elf $elf $search 56 $replace} \
                "Unable to patch self [file tail $elf]"
        }

        if {$::patch_lv2::options(--patch-lv2-lv1-call-355)} {
            log "Patching LV2 to allow LV1 Call support (3.55)"

            set search     "\x7C\x71\x43\xA6\x7C\x92\x43\xA6\x7C\xB3\x43\xA6\x48"
            set replace    "\x7C\x08\x02\xA6\xF8\x01\x00\x10\x7D\x4B\x53\x78\x44\x00\x00\x22"
	    append replace "\xE8\x01\x00\x10\x7C\x08\x03\xA6\x4E\x80\x00\x20"

            catch_die {::patch_elf $elf $search 5708 $replace} \
                "Unable to patch self [file tail $elf]"

            set search     "\xEB\xA1\x00\x88\x38\x60\x00\x00\xEB\xC1\x00\x90\xEB\xE1\x00\x98"
            append search  "\x7C\x08\x03\xA6\x7C\x63\x07\xB4\x38\x21\x00\xA0\x4E\x80\x00\x20"
            set replace    "\x4B\xFE\x83\xE0\x60\x00\x00\x00\x60\x00\x00\x00"

            catch_die {::patch_elf $elf $search 80 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}
