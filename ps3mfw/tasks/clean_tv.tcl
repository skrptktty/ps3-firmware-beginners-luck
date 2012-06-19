#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 1500
# Category: TV
# Description: Clean unwanted icons from the XMB TV Category

# Option --clean_tv_xil: Remove "xil" icon from the XMB TV Category
# Option --clean_tv_gameexit: Remove "gameexit" icon from the XMB TV Category
# Option --clean_tv_gamedir: Remove "gameDir" icon from the XMB TV Category

# Type --clean_tv_xil: boolean
# Type --clean_tv_gameexit: boolean
# Type --clean_tv_gamedir: boolean

namespace eval ::clean_tv {

    array set ::clean_tv::options {
        --clean_tv_xil false
        --clean_tv_gameexit false
        --clean_tv_gamedir false
    }

    proc main {} {
        set CATEGORY_SYSCONF_XML [file join dev_flash vsh resource explore xmb category_tv.xml]
        modify_devflash_file ${CATEGORY_SYSCONF_XML} ::clean_tv::callback
    }

    proc callback { file } {
        variable options

        log "Modifying XML file [file tail ${file}]"

        set xml [::xml::LoadFile ${file}]

        if {$options(--clean_tv_xil)} {
            set xml [remove_node_from_xmb_xml ${xml} "xil" "xil"]
        }
        if {$options(--clean_tv_gameexit)} {
            set xml [remove_node_from_xmb_xml ${xml} "gameexit" "gameexit"]
        }
        if {$options(--clean_tv_gamedir)} {
            set xml [remove_node_from_xmb_xml ${xml} "gameDir" "gameDir"]
        }

        ::xml::SaveToFile ${xml} ${file}
    }
}
