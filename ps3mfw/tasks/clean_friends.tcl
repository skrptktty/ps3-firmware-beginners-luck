#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 1900
# Category: Friends
# Description: Clean unwanted icons from the XMB Friends Category

# Option --clean-friends-avcroom: Remove "Video Chat" icon from the XMB Friends Category
# Option --clean-friends-chat: Remove "Chat Room" icon from the XMB Friends Category
# Option --clean-friends-message-box: Remove "Message Box" icon from the XMB Friends Category
# Option --clean-friends-nas: Remove "My Profile" icon from the XMB Friends Category
# Option --clean-friends-new-chat: Remove "New Chat" icon from the XMB Friends Category
# Type --clean-friends-avcroom: boolean
# Type --clean-friends-chat: boolean
# Type --clean-friends-message-box: boolean
# Type --clean-friends-nas: boolean
# Type --clean-friends-new-chat: boolean

namespace eval ::clean_friends {

    array set ::clean_friends::options {
        --clean-friends-avcroom true
        --clean-friends-chat true
        --clean-friends-message-box true
        --clean-friends-nas true
        --clean-friends-new-chat true
    }

    proc main {} {
        set CATEGORY_FRIENDS_XML [file join dev_flash vsh resource explore xmb category_friend.xml]
        ::modify_devflash_file ${CATEGORY_FRIENDS_XML} ::clean_friends::callback
    }

    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"

        set xml [::xml::LoadFile $file]
        if {$::clean_friends::options(--clean-friends-avcroom)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_avcroom" "Video Chat"]
        }
        if {$::clean_friends::options(--clean-friends-chat)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_chat" "Chat"]
        }
        if {$::clean_friends::options(--clean-friends-message-box)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_message_box" "Message Box"]
        }
        if {$::clean_friends::options(--clean-friends-nas)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_nas" "???NAS???"]
        }
        if {$::clean_friends::options(--clean-friends-new-chat)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_new_chat" "New Chat"]
        }

        ::xml::SaveToFile $xml $file
    }
}
