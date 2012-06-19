#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 200
# Description: Add a custom message to the 'New Features' installation screen

# Option --license-auto-add-features: Automatically generate the enabled features of PS3MFW
# Option --license-features-message: Prefix message to the generated features list
# Option --license-message: New Features message (Appears after the license agreement)
# Type --license-auto-add-features: boolean
# Type --license-features-message: string
# Type --license-message: textarea

namespace eval ::add_license_msg {

    array set ::add_license_msg::options {
        --license-auto-add-features true
        --license-features-message "PS3MFW Features Enabled:"
        --license-message ""
    }

    append ::add_license_msg::options(--license-message) "Modified firmware created by $::tcl_platform(user) using PS3MFW Framework.\n\n"
    append ::add_license_msg::options(--license-message) "This system firmware update has been modified from the original, and is therefore unofficial and not endorsed by SCE.\n\n"
    append ::add_license_msg::options(--license-message) "Installation of this system firmware update increases the risk of rendering your game system unstable or unusable.\n\n"
    append ::add_license_msg::options(--license-message) "Use at your own risk.  No guarantee expressed or implied.\n\n"
    append ::add_license_msg::options(--license-message) "If anything bad happens as a result of installing this system update, you cannot hold anyone responsible but yourself.\n\n"
    append ::add_license_msg::options(--license-message) "The creators of this system firmware modification process do not condone piracy.\n"
    append ::add_license_msg::options(--license-message) "Use your system responsibly and only play games that you have purchased.\n"
    append ::add_license_msg::options(--license-message) "Enjoy!\n\n"

    proc main {} {
        set MAX_MESSAGE_SIZE 1500

        set message $::add_license_msg::options(--license-message)
        if {$::add_license_msg::options(--license-auto-add-features)} {
            append message "\n$::add_license_msg::options(--license-features-message)\n"
            foreach task [sort_tasks [get_selected_tasks]] {
                if {$task == "add_license_msg"} continue
                set file [file join $::TASKS_DIR ${task}.tcl]
                append message "[get_task_description $file]\n"
                foreach option [get_sorted_options $file [array names ::${task}::options]] {
                    if {[string is boolean -strict [set ::${task}::options($option)]] &&
                        [set ::${task}::options($option)]} {
                        if {[get_option_description $file $option] != ""} {
                            append message "  [get_option_description $file $option]\n"
                        }
                    }
                }
                append message "\n"
            }
            debug "Generated New features message : \n$message"
        }

        log "Modifying License file"
        #log "This may take some time, please be patient..."

        set messages [list]
        for {set i 0} {$i < [string length $message]} {} {
            set msg [string range $message $i [expr {$i + $MAX_MESSAGE_SIZE - 1}]]
            set idx [string last "\n\n" $msg]
            if {$idx > 0} {
                incr idx 1
            } else {
                set idx [string last "\n" $msg]
            }
            if {$idx > 0} {
                set msg [string range $message $i [expr {$i + $idx}]]
            }
            incr i [string length $msg]
            while {[string range $msg end end] == "\n"} {
                set msg [string range $msg 0 end-1]
            }
            lappend messages $msg
        }

        if {$messages == {}} {
            return
        }

        # index 1 through 9 don't seem to work
        set index 10
        while {[grep "<str id=\"msg_updater_$index\">" $::CUSTOM_LICENSE_XML] != {}} {
            incr index
        }

        set message_nodes ""
        for {set i 0} {$i < [llength $messages]} {incr i} {
            append message_nodes "<str id=\"msg_updater_${index}\">[::xml::xmlencode [lindex $messages $i]]</str>\n\t"
            incr index
        }
        append message_nodes "<str id=\"msg_update_eula_1\">"

        ::sed_in_place $::CUSTOM_LICENSE_XML "<str id=\"msg_update_eula_1\">" $message_nodes

# set xml [::xml::LoadFile $::CUSTOM_LICENSE_XML]

# # index 1 through 9 don't seem to work
# set index 10
# while {[::xml::GetNodeByAttribute $xml "xml:locale:str" id "msg_updater_$index"] != ""} {
#     incr index
# }

# set message_nodes [list]
# for {set i 0} {$i < [llength $messages]} {incr i} {
#     set node_xml "<str id=\"msg_updater_${index}\">[::xml::xmlencode [lindex $messages $i]]</str>"
#     lappend message_nodes [::xml::Load $node_xml]
#     incr index
# }

# set i 0
# while {true} {
#     set node_idx [::xml::GetNodeIndices $xml "xml:locale" $i]
#     if {$node_idx == ""} break
#     log "Modifying license for locale [::xml::GetAttribute $xml xml:locale lang $i]"
#     foreach node $message_nodes {
#         set xml [::xml::InsertNode $xml [::xml::GetNodeIndicesByAttribute $xml "xml:locale:str" id "msg_update_eula_1" $i] $node]
#     }
#     incr i
# }
# ::xml::SaveToFile $xml $::CUSTOM_LICENSE_XML
    }
}

