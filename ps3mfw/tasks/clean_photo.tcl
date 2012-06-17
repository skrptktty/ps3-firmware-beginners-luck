#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1200
# Category: Photo
# Description: Clean unwanted icons from the XMB Photo Category
    
# Option --clean-photo-dlna-scan: Remove "Search for Media Servers" icon from the XMB Photo Category
# Option --clean-photo-dlna-device: Remove "Network Media Servers" icon from the XMB Photo Category
# Option --clean-photo-hakoniwa: Remove "Photo Gallery" icon from the XMB Photo Category
# Option --clean-photo-playlists: Remove "Playlists" icon from the XMB Photo Category
# Option --clean-photo-screenshot: Remove "Screenshot" icon from the XMB Photo Category

# Type --clean-photo-dlna-scan: boolean
# Type --clean-photo-dlna-device: boolean
# Type --clean-photo-hakoniwa: boolean
# Type --clean-photo-playlists: boolean
# Type --clean-photo-screenshot: boolean

namespace eval ::clean_photo {

    array set ::clean_photo::options {
        --clean-photo-dlna-scan false
        --clean-photo-dlna-device false
        --clean-photo-hakoniwa true
        --clean-photo-playlists false
        --clean-photo-screenshot true
    }
    
    proc main {} {
        set CATEGORY_PHOTO_XML [file join dev_flash vsh resource explore xmb category_photo.xml]
        ::modify_devflash_file ${CATEGORY_PHOTO_XML} ::clean_photo::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        set xml [::xml::LoadFile $file]
        if {$::clean_photo::options(--clean-photo-dlna-scan)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_scan" "Search for Media Servers"]
        }
        if {$::clean_photo::options(--clean-photo-dlna-device)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_device" "Network Media Servers"]
        }
        if {$::clean_photo::options(--clean-photo-hakoniwa)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_hakoniwa" "Photo Gallery"]
        }
        if {$::clean_photo::options(--clean-photo-playlists)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_playlist_mgmt" "Playlists"]
        }
        if {$::clean_photo::options(--clean-photo-screenshot)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_screenshot" "Screenshot"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
