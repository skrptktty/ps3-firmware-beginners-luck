#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1400
# Category: Video
# Description: Clean unwanted icons from the XMB Video Category
    
# Option --clean-video-bddata-mgmt: Remove "BD Data Utility" icon from the XMB Video Category
# Option --clean-video-dlna-scan: Remove "Search for Media Servers" icon from the XMB Video Category
# Option --clean-video-dlna-device: Remove "Network Media Servers" icon from the XMB Video Category
# Option --clean-video-editingvideo-mgmt: Remove "Video Editor & Uploader" icon from the XMB Video Category
# Option --clean-video-netflix: Remove "Netflix" icon from the XMB Video Category
# Option --clean-video-welcome: Remove "PlayStation Store" icon from the XMB Video Category

# Type --clean-video-bddata-mgmt: boolean
# Type --clean-video-dlna-scan: boolean
# Type --clean-video-dlna-device: boolean
# Type --clean-video-editingvideo-mgmt: boolean
# Type --clean-video-netflix: boolean
# Type --clean-video-welcome: boolean

namespace eval ::clean_video {

    array set ::clean_video::options {
        --clean-video-bddata-mgmt false
        --clean-video-dlna-scan false
        --clean-video-dlna-device false
        --clean-video-editingvideo-mgmt true
        --clean-video-netflix true
        --clean-video-welcome true
    }
    
    proc main {} {
        set CATEGORY_VIDEO_XML [file join dev_flash vsh resource explore xmb category_video.xml]
        ::modify_devflash_file ${CATEGORY_VIDEO_XML} ::clean_video::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        set xml [::xml::LoadFile $file]
        if {$::clean_video::options(--clean-video-bddata-mgmt)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_bddata_mgmt" "BD Data Utility"]
        }
        if {$::clean_video::options(--clean-video-dlna-scan)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_scan" "Search for Media Servers"]
        }
        if {$::clean_video::options(--clean-video-dlna-device)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_dlna_device" "Network Media Servers"]
        }
        if {$::clean_video::options(--clean-video-editingvideo-mgmt)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_editingvideo_mgmt" "Video Editor & Uploader"]
        }
        if {$::clean_video::options(--clean-video-netflix)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_netflix" "Netflix"]
        }
        if {$::clean_video::options(--clean-video-welcome)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_welcome" "PlayStation Store"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
