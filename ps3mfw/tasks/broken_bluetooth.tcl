#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 2100
# Description: Allow firmware update of console with broken bluetooth
    
# Option --remove-bt-firmware: remove Bluetooth firmware (ENABLING THIS WILL REMOVE BLUETOOTH FIRMWARE)

# Type --remove-bt-firmware: boolean

namespace eval ::broken_bluetooth {

    array set ::broken_bluetooth::options {
        --remove-bt-firmware false
    }
    
    proc main {} {
        ::modify_upl_file ::broken_bluetooth::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Removing bluetooth firmware packages press ok to continue" -icon warning
        }

        set xml [::xml::LoadFile $file]

        if {$::broken_bluetooth::options(--remove-bt-firmware)} {
          set xml [::remove_pkgs_from_upl_xml $xml "BT" "bluetooth firmware"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}