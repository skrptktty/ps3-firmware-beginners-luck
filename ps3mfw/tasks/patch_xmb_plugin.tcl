#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 2500
# Description: Remove unwanted icons from the XMB

# Option --patch-xmb-plugin: Remove below items from the XMB
# Option --patch-xmb-ingame-plugin: Remove below items from the in-game XMB
# Option --remove-user: Remove "Users" icon from the XMB
# Option --remove-sysconf: Remove "Settings" icon from the XMB
# Option --remove-photo: Remove "Photo" icon from the XMB
# Option --remove-music: Remove "Music" icon from the XMB
# Option --remove-video: Remove "Video" icon from the XMB
# Option --remove-tv: Remove "TV" icon from the XMB
# Option --remove-game: Remove "Games" icon from the XMB
# Option --remove-network: Remove "Network" icon from the XMB
# Option --remove-psn: Remove "PlayStation Network" icon from the XMB
# Option --remove-friends: Remove "Friends" icon from the XMB

# Type --patch-xmb-plugin: boolean
# Type --patch-xmb-ingame-plugin: boolean
# Type --remove-user: boolean
# Type --remove-sysconf: boolean
# Type --remove-photo: boolean
# Type --remove-music: boolean
# Type --remove-video: boolean
# Type --remove-tv: boolean
# Type --remove-game: boolean
# Type --remove-network: boolean
# Type --remove-psn: boolean
# Type --remove-friends: boolean

namespace eval ::patch_xmb_plugin {

    array set ::patch_xmb_plugin::options {
        --patch-xmb-plugin false
        --patch-xmb-ingame-plugin false
        --remove-user false
        --remove-sysconf false
        --remove-photo false
        --remove-music false
        --remove-video false
        --remove-tv false
        --remove-game false
        --remove-network false
        --remove-psn false
        --remove-friends false
    }
    
    proc main {} {
        if {$::patch_xmb_plugin::options(--patch-xmb-plugin)} {
          set XMB_SPRX [file join dev_flash vsh module xmb_plugin.sprx]
	  ::modify_devflash_file ${XMB_SPRX} ::patch_xmb_plugin::patch_self
        }
        if {$::patch_xmb_plugin::options(--patch-xmb-ingame-plugin)} {
          set XMB_SPRX [file join dev_flash vsh module xmb_ingame.sprx]
	  ::modify_devflash_file ${XMB_SPRX} ::patch_xmb_plugin::patch_self
        }
    }
    
    proc patch_self {self} {
        log "Patching [file tail $self]"
        ::modify_self_file $self ::patch_xmb_plugin::patch_elf
    }

    proc patch_elf {elf} {
        if {$::patch_xmb_plugin::options(--remove-user)} {
            debug "Patching [file tail $elf] to remove user menu"

            set search  "\x6c\x69\x73\x74\x5f\x75\x73\x65\x72"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-sysconf)} {
            debug "Patching [file tail $elf] to remove settings menu"

            set search  "\x6c\x69\x73\x74\x5f\x73\x79\x73\x63\x6f\x6e\x66"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-photo)} {
            debug "Patching [file tail $elf] to remove photo menu"

            set search  "\x6c\x69\x73\x74\x5f\x70\x68\x6f\x74\x6f"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-music)} {
            debug "Patching [file tail $elf] to remove music menu"

            set search  "\x6c\x69\x73\x74\x5f\x6d\x75\x73\x69\x63"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-video)} {
            debug "Patching [file tail $elf] to remove video menu"

            set search  "\x6c\x69\x73\x74\x5f\x76\x69\x64\x65\x6f"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-tv)} {
            debug "Patching [file tail $elf] to remove tv menu"

            set search  "\x6c\x69\x73\x74\x5f\x74\x76"
            set replace "\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-game)} {
            debug "Patching [file tail $elf] to remove game menu"

            set search  "\x6c\x69\x73\x74\x5f\x67\x61\x6d\x65"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-network)} {
            debug "Patching [file tail $elf] to remove network menu"

            set search  "\x6c\x69\x73\x74\x5f\x6e\x65\x74\x77\x6f\x72\x6b"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-psn)} {
            debug "Patching [file tail $elf] to remove psn menu"

            set search  "\x6c\x69\x73\x74\x5f\x70\x73\x6e"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
        if {$::patch_xmb_plugin::options(--remove-friends)} {
            debug "Patching [file tail $elf] to remove friends menu"

            set search  "\x6c\x69\x73\x74\x5f\x66\x72\x69\x65\x6e\x64"
            set replace "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

            catch_die {::patch_elf $elf $search 0 $replace} \
                "Unable to patch self [file tail $elf]"
        }
    }
}
