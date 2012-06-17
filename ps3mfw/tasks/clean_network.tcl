#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 1700
# Category: Network
# Description: Clean unwanted icons from the XMB Network Category
    
# Option --clean-network-browser: Remove "Internet Browser" icon from the XMB Network Category
# Option --clean-network-folding-at-home: Remove "Life with PlayStation" icon from the XMB Network Category
# Option --clean-network-kensaku: Remove "Internet Search" icon from the XMB Network Category
# Option --clean-network-manual: Remove "Online Instruction Manuals" icon from the XMB Network Category
# Option --clean-network-premo: Remove "Remote Play" icon from the XMB Network Category

# Type --clean-network-browser: boolean
# Type --clean-network-folding-at-home: boolean
# Type --clean-network-kensaku: boolean
# Type --clean-network-manual: boolean
# Type --clean-network-premo: boolean

namespace eval ::clean_network {

    array set ::clean_network::options {
        --clean-network-browser false
        --clean-network-folding-at-home true
        --clean-network-kensaku true
        --clean-network-manual true
        --clean-network-premo true
    }
    
    proc main {} {
        set CATEGORY_NETWORK_XML [file join dev_flash vsh resource explore xmb category_network.xml]
        ::modify_devflash_file ${CATEGORY_NETWORK_XML} ::clean_network::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
# hack to get around upstream category_network.xml errant />
        set fd [open $file r] 
        set data [read $fd] 
        regsub {\s*/>(\s*/>\s*</Items>)} $data {\1} data
        close $fd
        set xml [::xml::Load $data]
    
# this should work but upstream category_network.xml has an errant />
#    set xml [::xml::LoadFile $file]
    
        if {$::clean_network::options(--clean-network-browser)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_browser" "Internet Browser"]
        }
        if {$::clean_network::options(--clean-network-folding-at-home)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_folding_at_home" "Life with PlayStation "]
        }
        if {$::clean_network::options(--clean-network-kensaku)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_kensaku" "Internet Search"]
        }
        if {$::clean_network::options(--clean-network-manual)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_manual" "Online Instruction Manuals"]
        }
        if {$::clean_network::options(--clean-network-premo)} {
            set xml [::remove_node_from_xmb_xml $xml "seg_premo" "Remote Play"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
