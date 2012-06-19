#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1600
# Category: Game
# Description: Clean unwanted icons from the XMB Game Category
    
# Option --clean-game-gamedata: Remove "Game Data" icon from the XMB Game Category
# Option --clean-game-mcutility: Remove "Memory Card Utility (PS/PS2)" icon from the XMB Game Category
# Option --clean-game-minis-manual: Remove "Minis Manual" icon from the XMB Game Category
# Option --clean-game-welcome: Remove "PlayStation Store" icon from the XMB Game Category
# Option --clean-game-sdps3: Remove "Saved Data Utility (PS3)" icon from the XMB Game Category
# Option --clean-game-sdpsp: Remove "Saved Data Utility (minis)" icon from the XMB Game Category
# Option --clean-game-trophy: Remove "Trophy Collection" icon from the XMB Game Category

# Type --clean-game-gamedata: boolean
# Type --clean-game-mcutility: boolean
# Type --clean-game-minis-manual: boolean
# Type --clean-game-welcome: boolean
# Type --clean-game-sdps3: boolean
# Type --clean-game-sdpsp: boolean
# Type --clean-game-trophy: boolean

namespace eval ::clean_game {

    array set ::clean_game::options {
        --clean-game-gamedata false
        --clean-game-mcutility false
        --clean-game-minis-manual true
        --clean-game-welcome true
        --clean-game-sdps3 false
        --clean-game-sdpsp false
        --clean-game-trophy false
    }
    
    proc main {} {
        set CATEGORY_GAME_XML [file join dev_flash vsh resource explore xmb category_game.xml]
        ::modify_devflash_file ${CATEGORY_GAME_XML} ::clean_game::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        set xml [::xml::LoadFile $file]
        if {$::clean_game::options(--clean-game-gamedata)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_gamedata" "Game Data"]
        }
        if {$::clean_game::options(--clean-game-mcutility)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_mcutility" "Memory Card Utility (PS/PS2)"]
        }
        if {$::clean_game::options(--clean-game-minis-manual)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_minis_manual" "Minis Manual"]
        }
        if {$::clean_game::options(--clean-game-welcome)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_welcome" "PlayStation Store"]
        }
        if {$::clean_game::options(--clean-game-sdps3)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_sdps3" "Saved Data Utility (PS3)"]
        }
        if {$::clean_game::options(--clean-game-sdpsp)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_sdpsp" "Saved Data Utility (minis)"]
        }
        if {$::clean_game::options(--clean-game-trophy)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_trophy" "Trophy Collection"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
