#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 1050
# Description: Add "TV" category to the XMB

# Option --tv-cat: Show TV category in xmb no matter if your country support it.
    
# Type --tv-cat: boolean


namespace eval ::tv_category {

    array set ::tv_category::options {
        --tv-cat true
    }

    proc main {} {		
		if {$::tv_category::options(--tv-cat)} {
		set CATEGORY_XML [file join dev_flash vsh resource explore xmb category_tv.xml]
		set XMB_PLUGIN [file join dev_flash vsh module xmb_plugin.sprx]
		modify_devflash_file $XMB_PLUGIN ::tv_category::patch_self
        }
	}
	
    proc patch_self {self} {
        log "Patching [file tail $self]"
        ::modify_self_file $self ::tv_category::patch_elf
    }

    proc patch_elf {elf} {
            log "Patching [file tail $elf] to add tv category"

            set search  "\x64\x65\x76\x5f\x68\x64\x64\x30\x2f\x67\x61\x6d\x65\x2f\x42\x43\x45\x53\x30\x30\x32\x37\x35"
            set replace "\x64\x65\x76\x5f\x66\x6c\x61\x73\x68\x2f\x64\x61\x74\x61\x2f\x63\x65\x72\x74\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
    }
}