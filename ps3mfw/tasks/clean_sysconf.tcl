#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 1100
# Category: Settings
# Description: Clean unwanted icons from the XMB Settings Category

# Option --clean_sysconf_chat: Remove "Chat Settings" icon from the XMB Settings Category
# Option --clean_sysconf_print: Remove "Printer Settings" icon from the XMB Settings Category
# Option --clean_sysconf_security: Remove "Security Settings" icon from the XMB Settings Category
# Option --clean_sysconf_remote: Remove "Remote Play Settings" icon from the XMB Settings Category

# Type --clean_sysconf_chat: boolean
# Type --clean_sysconf_print: boolean
# Type --clean_sysconf_security: boolean
# Type --clean_sysconf_remote: boolean

namespace eval ::clean_sysconf {

    array set ::clean_sysconf::options {
        --clean_sysconf_chat true
        --clean_sysconf_print true
        --clean_sysconf_security true
        --clean_sysconf_remote true
    }

    proc main {} {
        set CATEGORY_SYSCONF_XML [file join dev_flash vsh resource explore xmb category_sysconf.xml]
        modify_devflash_file ${CATEGORY_SYSCONF_XML} ::clean_sysconf::callback
    }

    proc callback { file } {
        variable options

        log "Modifying XML file [file tail ${file}]"

        set xml [::xml::LoadFile $file]
        if {$options(--clean_sysconf_chat)} {
            set xml [remove_node_from_xmb_xml $xml "chat" "Chat Settings"]
        }
        if {$options(--clean_sysconf_print)} {
            set xml [remove_node_from_xmb_xml $xml "print" "Printer Settings"]
        }
        if {$options(--clean_sysconf_security)} {
            set xml [remove_node_from_xmb_xml $xml "security" "Security Settings"]
        }
        if {$options(--clean_sysconf_remote)} {
            set xml [remove_node_from_xmb_xml $xml "remote" "Remote Play Settings"]
        }

        ::xml::SaveToFile $xml $file
    }
}
