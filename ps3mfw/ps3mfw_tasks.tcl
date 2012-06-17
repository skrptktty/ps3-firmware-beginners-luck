#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

proc ego {} {
    puts "PS3MFW Creator v${::PS3MFW_VERSION}"
    puts "    Copyright (C) 2011 Project PS3MFW"
    puts "    This program comes with ABSOLUTELY NO WARRANTY;"
    puts "    This is free software, and you are welcome to redistribute it"
    puts "    under certain conditions; see COPYING for details."
    puts ""
    puts "    Developed By :"
    puts "    Anonymous Developers"
    puts ""
}

proc ego_gui {} {
    log "PS3MFW Creator v${::PS3MFW_VERSION}"
    log "    Copyright (C) 2011 Project PS3MFW"
    log "    This program comes with ABSOLUTELY NO WARRANTY;"
    log "    This is free software, and you are welcome to redistribute it"
    log "    under certain conditions; see COPYING for details."
    log ""
    log "    Developed By :"
    log "    Anonymous Developers"
    log ""
}

proc clean_up {} {
    log "Deleting output files"
    catch_die {file delete -force -- ${::CUSTOM_PUP_DIR} ${::ORIGINAL_PUP_DIR} ${::OUT_FILE}} \
        "Could not cleanup output files"
}

proc unpack_source_pup {pup dest} {
    log "Unpacking source PUP [file tail ${pup}]"
    catch_die {pup_extract ${pup} ${dest}} "Error extracting PUP file [file tail ${pup}]"

    # Check for license.txt for people using older version of ps3tools
    set license_txt [file join ${::CUSTOM_UPDATE_DIR} license.txt]
    if {![file exists ${::CUSTOM_LICENSE_XML}] && [file exists ${license_txt}]} {
        set ::CUSTOM_LICENSE_XML ${license_txt}
    }
}

proc pack_custom_pup {dir pup} {
    set build ${::PUP_BUILD}
    set obuild [get_pup_build]
    if {${build} == "" || ![string is integer ${build}] || ${build} == ${obuild}} {
        set build ${obuild}
        incr build
    }
    # create pup
    log "Packing Modified PUP [file tail ${pup}]"
    catch_die {pup_create ${dir} ${pup} $build} "Error packing PUP file [file tail ${pup}]"
}

proc build_mfw {input output tasks} {
    global options

    set ::selected_tasks [sort_tasks ${tasks}]

    # print out ego info
    ego_gui

    if {${input} == "" || ${output} == ""} {
        die "Must specify an input and output file"
    }
    if {![file exists ${input}]} {
        die "Input file does not exist"
    }

    log "Selected tasks : ${::selected_tasks}"

    if {[info exists ::env(HOME)]} {
        debug "HOME=$::env(HOME)"
    }
    if {[info exists ::env(USERPROFILE)]} {
        debug "USERPROFILE=$::env(USERPROFILE)"
    }
    if {[info exists ::env(PATH)]} {
        debug "PATH=$::env(PATH)"
    }

    clean_up

    # PREPARE PS3UPDAT.PUP for modification
    unpack_source_pup ${input} ${::CUSTOM_PUP_DIR}

    extract_tar ${::CUSTOM_UPDATE_TAR} ${::CUSTOM_UPDATE_DIR}

    # copy original PUP to working dir
    copy_file ${::CUSTOM_PUP_DIR} ${::ORIGINAL_PUP_DIR}

    log "Unpacking all dev_flash files"
    unpkg_devflash_all ${::CUSTOM_DEVFLASH_DIR}

    # Execute tasks
    foreach task ${::selected_tasks} {
        log "******** Running task $task **********"
        eval [string map {- _} ${task}::main]
    }
    log "******** Completed tasks **********"

    # RECREATE PS3UPDAT.PUP
    file delete -force ${::CUSTOM_DEVFLASH_DIR}
    set files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} *.pkg]]
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} *.img]]
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} dev_flash3_*]]
    eval lappend files [lsort [glob -nocomplain -tails -directory ${::CUSTOM_UPDATE_DIR} dev_flash_*]]
    create_tar ${::CUSTOM_UPDATE_TAR}  ${::CUSTOM_UPDATE_DIR} ${files}

    pack_custom_pup ${::CUSTOM_PUP_DIR} ${::OUT_FILE}
}
