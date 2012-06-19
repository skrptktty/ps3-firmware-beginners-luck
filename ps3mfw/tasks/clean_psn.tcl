#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1800
# Category: PlayStation Network
# Description: Clean unwanted icons from the XMB PlayStation Network Category
    
# Option --clean-psn-commerce-new: Remove "What's New" icon from the XMB PlayStation Network Category
# Option --clean-psn-home: Remove "PlayStation Home" icon from the XMB PlayStation Network Category
# Option --clean-psn-regist: Remove "Sign In" icon from the XMB PlayStation Network Category
# Option --clean-psn-welcome: Remove "PlayStation Store" icon from the XMB PlayStation Network Category

# Type --clean-psn-commerce-new: boolean
# Type --clean-psn-home: boolean
# Type --clean-psn-regist: boolean
# Type --clean-psn-welcome: boolean

namespace eval ::clean_psn {

    array set ::clean_psn::options {
        --clean-psn-commerce-new true
        --clean-psn-home true
        --clean-psn-regist true
        --clean-psn-welcome true
    }
    
    proc main {} {
        set CATEGORY_PSN_XML [file join dev_flash vsh resource explore xmb category_psn.xml]
        ::modify_devflash_file ${CATEGORY_PSN_XML} ::clean_psn::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        set xml [::xml::LoadFile $file]
        if {$::clean_psn::options(--clean-psn-commerce-new)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_commerce_new" "What's New"]
        }
        if {$::clean_psn::options(--clean-psn-home)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_home" "PlayStation Home"]
        }
        if {$::clean_psn::options(--clean-psn-regist)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_regist" "Sign In"]
        }
        if {$::clean_psn::options(--clean-psn-welcome)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_welcome" "PlayStation Store"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
