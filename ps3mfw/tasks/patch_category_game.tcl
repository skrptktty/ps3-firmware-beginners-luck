#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1000
# Description: Add new icons to the XMB Game category
    
# Option --patch-package-files: Add "Install Package Files" icon to the XMB Game Category
# Option --patch-app-home: Add "/app_home" icon to the XMB Game Category
    
# Type --patch-package-files: boolean
# Type --patch-app-home: boolean

namespace eval ::patch_category_game {
    
    array set ::patch_category_game::options {
        --patch-package-files true
        --patch-app-home true
    }
    
    proc main {} {
        set CATEGORY_GAME_TOOL2_XML [file join dev_flash vsh resource explore xmb category_game_tool2.xml]
        set CATEGORY_GAME_XML [file join dev_flash vsh resource explore xmb category_game.xml]

        ::modify_devflash_file $CATEGORY_GAME_TOOL2_XML ::patch_category_game::find_nodes
        ::modify_devflash_file $CATEGORY_GAME_XML ::patch_category_game::inject_nodes
    }
    
    proc find_nodes { file } {
        log "Parsing XML: [file tail $file]"
        set xml [::xml::LoadFile $file]

        if {$::patch_category_game::options(--patch-package-files)} {
            set ::query_package_files [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_package_files"]
            set ::view_package_files [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_package_files"]
            set ::view_packages [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_packages"]
    
            if {$::query_package_files == "" || $::view_package_files == "" || $::view_packages == "" } {
                die "Could not parse $file"
            }
        }

        if {$::patch_category_game::options(--patch-app-home)} {
            set ::query_gamedebug [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key "seg_gamedebug"]
            set ::view_gamedebug [::xml::GetNodeByAttribute $xml "XMBML:View" id "seg_gamedebug"]
    
            if {$::query_gamedebug == "" || $::view_gamedebug== "" } {
                die "Could not parse $file"
            }
        }
    }
    
    proc inject_nodes { file } {
        log "Modifying XML: [file tail $file]"
        set xml [::xml::LoadFile $file]

        if {$::patch_category_game::options(--patch-package-files)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_package_files]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_packages]
    
            unset ::query_package_files
            unset ::view_package_files
            unset ::view_packages
        }

        if {$::patch_category_game::options(--patch-app-home)} {
            set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key "seg_gameexit"] $::query_gamedebug]
            set xml [::xml::InsertNode $xml {2 end 0} $::view_gamedebug]

            unset ::query_gamedebug
            unset ::view_gamedebug
        }
        ::xml::SaveToFile $xml $file
    }
}
