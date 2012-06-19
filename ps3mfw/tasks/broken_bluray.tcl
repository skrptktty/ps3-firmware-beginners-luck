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
# Description: Allow firmware update of console with broken blu-ray drive
    
# Option --remove-bd-revoke: remove BdpRevoke (ENABLING THIS WILL REMOVE BLU-RAY DRIVE FIRMWARE)
# Option --remove-bd-firmware: remove BD firmware (ENABLING THIS WILL REMOVE BLU-RAY DRIVE FIRMWARE)

# Type --remove-bd-revoke: boolean
# Type --remove-bd-firmware: boolean

namespace eval ::broken_bluray {

    array set ::broken_bluray::options {
        --remove-bd-revoke false
        --remove-bd-firmware false
    }
    
    proc main {} {
        ::modify_upl_file ::broken_bluray::callback
    }
    
    proc callback { file } {
        log "Modifying XML file [file tail ${file}]"
    
        if {[package provide Tk] != "" } {
           tk_messageBox -default ok -message "Removing blu-ray drive firmware packages press ok to continue" -icon warning
        }

        set xml [::xml::LoadFile $file]

        if {$::broken_bluray::options(--remove-bd-revoke)} {
          set xml [::remove_pkg_from_upl_xml $xml "BdpRevoke" "blu-ray drive revoke"]
        }

        if {$::broken_bluray::options(--remove-bd-firmware)} {
          set xml [::remove_pkgs_from_upl_xml $xml "BD" "blu-ray drive firmware"]
        }
    
        ::xml::SaveToFile $xml $file
    }
}
