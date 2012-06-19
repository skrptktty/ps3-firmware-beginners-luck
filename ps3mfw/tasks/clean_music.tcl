#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1300
# Category: Music
# Description: Clean unwanted icons from the XMB Music Category
    
# Option --clean-music-dlna-scan: Remove "Search for Media Servers" icon from the XMB Music Category
# Option --clean-music-dlna-device: Remove "Network Media Servers" icon from the XMB Music Category
# Option --clean-music-playlists: Remove "Playlists" icon from the XMB Music Category
# Option --clean-music-welcome: Remove "PlayStation Store" icon from the XMB Music Category

# Type --clean-music-dlna-scan: boolean
# Type --clean-music-dlna-device: boolean
# Type --clean-music-playlists: boolean
# Type --clean-music-welcome: boolean

namespace eval ::clean_music {

    array set ::clean_music::options {
        --clean-music-dlna-scan false
        --clean-music-dlna-device false
        --clean-music-playlists false
        --clean-music-welcome true
    }
    
    proc main {} {
        set CATEGORY_MUSIC_XML [file join dev_flash vsh resource explore xmb category_music.xml]
        ::modify_devflash_file ${CATEGORY_MUSIC_XML} ::clean_music::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        set xml [::xml::LoadFile $file]
        if {$::clean_music::options(--clean-music-dlna-scan)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_scan" "Search for Media Servers"]
        }
        if {$::clean_music::options(--clean-music-dlna-device)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_device" "Network Media Servers"]
        }
        if {$::clean_music::options(--clean-music-playlists)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_playlist_mgmt" "Playlists"]
        }
        if {$::clean_music::options(--clean-music-welcome)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_welcome" "PlayStation Store"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
