#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# PRINT USAGE
proc usage {{msg ""}} {
    global options

    ego

    if {$msg != ""} {
        puts $msg
    }
    puts "Usage: ${::argv0} \[options\] <Original> <Modified> \[task\] \[task options\]"
    puts "eg. ${::argv0} PS3UPDAT.PUP PS3UPDAT.MFW.PUP"
    puts ""
    puts "Available options are : "
    foreach option [get_sorted_options [file normalize [info script]] [array names options]] {
        puts "  $option \"$options($option)\"\n    [get_option_description [file normalize [info script]] $option]"
    }
    puts "\nAvailable tasks are : "
    foreach task [get_sorted_task_files] {
        puts "\nTask:\n--[string map {_ -} [file rootname [file tail $task]]] : [string map {\n \n\t\t\t\t} [get_task_description $task]]"
        set taskname [file rootname [file tail $task]]
        if { [llength [array names ::${taskname}::options]] } {
            puts "  Task options:"
            foreach option [get_sorted_options $task [array names ::${taskname}::options]] {
                puts "  $option \"[set ::${taskname}::options($option)]\"\n    [get_option_description $task $option]"
            }
        }
    }
    puts ""
    exit -1
}

proc get_log_fd {} {
    global log_fd LOG_FILE

    if {![info exists log_fd]} {
        set log_fd [open $LOG_FILE w]
        fconfigure $log_fd -buffering none
    }
    return $log_fd
}

proc log {msg {force 0}} {
    global options

    if {!$options(--silent) || $force} {
        set fd [get_log_fd]
        puts $fd $msg
        if {$force} {
            puts stderr $msg
        } else {
            puts $msg
        }
    }
}

proc debug {msg} {
    if {$::options(--debug)} {
        log $msg 1
    }
}

proc grep {re args} {
    set result [list]
    set files [eval glob -types f $args]
    foreach file $files {
        set fp [open $file]
        set l 0
        while {[gets $fp line] >= 0} {
            if [regexp -- $re $line] {
                lappend result [list $file $line $l]
            }
            incr l
        }
        close $fp
    }
    set result
}

proc _get_comment_from_file {filename re} {
    set results [grep $re $filename]
    set comment ""
    foreach match $results {
        foreach {file match line} $match break
        append comment "[string trim [regsub $re $match {}]]\n"
    }
    string trim $comment
}

proc get_task_description {filename} {
    return [_get_comment_from_file $filename {^# Description:}]
}

proc get_option_description {filename option} {
    return [_get_comment_from_file $filename "^# Option ${option}:"]
}

proc get_sorted_options {filename options} {
    return [lsort -command [list sort_options $filename] $options]
}

proc sort_options {file opt1 opt2 } {
    set re1 "^# Option ${opt1}:"
    set re2 "^# Option ${opt2}:"
    set results1 [grep $re1 $file]
    set results2 [grep $re2 $file]

    if {$results1 == {} && $results2 == {}} {
        return [string compare $opt1 $opt2]
    } elseif {$results1 == {}} {
        return 1
    } elseif {$results2 == {}} {
        return -1
    } else {
        foreach {file match line1} [lindex $results1 0] break
        foreach {file match line2} [lindex $results2 0] break
        return [expr {$line1 - $line2}]
    }
}

proc get_option_type {filename option} {
    return [_get_comment_from_file $filename "^# Type ${option}:"]
}

proc task_to_file {task} {
    return [file join ${::TASKS_DIR} ${task}.tcl]
}

proc file_to_task {file} {
    return [file rootname [file tail $file]]
}

proc compare_tasks {task1 task2} {
    return [compare_task_files [task_to_file $task1] [task_to_file $task2]]
}

proc compare_task_files {file1 file2} {
    set prio1 [_get_comment_from_file $file1 {^# Priority:}]
    set prio2 [_get_comment_from_file $file2 {^# Priority:}]

    if {$prio1 == {} && $prio2 == {}} {
        return [string compare $file1 $file2]
    } elseif {$prio1 == {}} {
        return 1
    } elseif {$prio2 == {}} {
        return -1
    } else {
        return [expr {$prio1 - $prio2}]
    }
}

proc sort_tasks {tasks} {
    return [lsort -command compare_tasks $tasks]
}

proc sort_task_files {files} {
    return [lsort -command compare_task_files $files]
}

proc get_sorted_tasks { {tasks {}} } {
    set files [glob -nocomplain [file join ${::TASKS_DIR} *.tcl]]
    set tasks [list]
    foreach file $files {
        lappend tasks [file_to_task $file]
    }
    return [sort_tasks $tasks]
}

proc get_sorted_task_files { } {
    set files [glob -nocomplain [file join ${::TASKS_DIR} *.tcl]]
    return [sort_task_files $files]
}

proc get_selected_tasks { } {
    return ${::selected_tasks}
}

# failure function
proc die {message} {
    global LOG_FILE

    log "FATAL ERROR: $message" 1
    puts stderr "See ${LOG_FILE} for more info"
    puts stderr "Last lines of log : "
    puts stderr "*****************"
    catch {puts stderr "[tail $LOG_FILE]"}
    puts stderr "*****************"
    exit -2
}

proc catch_die {command message} {
    set catch {
        if {[catch {@command@} res] } {
            die "@message@ : $res"
        }
        return $res
    }
    debug "Executing command $command"
    set catch [string map [list "@command@" "$command" "@message@" "$message"] $catch]
    uplevel 1 $catch
}

proc shell {args} {
    set fd [get_log_fd]
    debug "Executing shell $args"
    eval exec $args >&@ $fd
}

proc hexify { str } {
    set out ""
    for {set i 0} { $i < [string length $str] } { incr i} {
        set c [string range $str $i $i]
        binary scan $c H* h
        append out "\[$h\]"
    }
    return $out
}

proc tail {filename {n 10}} {
    set fd [open $filename r]
    set lines [list]
    while {![eof $fd]} {
        lappend lines [gets $fd]
        if {[llength $lines] > $n} {
            set lines [lrange $lines end-$n end]
        }
    }
    close $fd
    return [join $lines "\n"]
}

proc copy_file {args} {
    catch_die {file copy {*}${args}} "Unable to copy $args"
}

proc pup_extract {pup dest} {
#    shell ${::PUP} x $pup $dest
    shell ${::PUPUNPACK} [file nativename $pup] [file nativename $dest]
}

proc pup_create {dir pup build} {
#    shell ${::PUP} c $dir $pup $build
    shell ${::PUPPACK} $pup [file nativename $dir] [file nativename $build]
}

proc pup_get_build {pup} {
    set fd [open $pup r]
    fconfigure $fd -translation binary
    seek $fd 16
    set build [read $fd 8]
    close $fd

    if {[binary scan $build W build_ver] != 1} {
        error "Cannot read 64 bit big endian from [hexify $build]"
    }

    return $build_ver
}

proc extract_tar {tar dest} {

    file mkdir $dest
    debug "Extracting tar file [file tail $tar] into [file tail $dest]"
    catch_die {::tar::untar $tar -dir $dest} "Could not untar file $tar"
}

proc create_tar {tar directory files} {
    set debug [file tail $tar]
    if {$debug == "content" } {
        set debug [file tail [file dirname $tar]]
    }
    debug "Creating tar file $debug"
    set pwd [pwd]
    cd $directory
    catch_die {::tar::create $tar $files} "Could not create tar file $tar"
    cd $pwd
}

proc find_devflash_archive {dir find} {

    foreach file [glob -nocomplain [file join $dir * content]] {
        if {[catch {::tar::stat $file $find}] == 0} {
            return $file
        }
    }
    return ""
}

proc unpkg { pkg dest } {
    shell ${::UNPKG} [file nativename $pkg] [file nativename $dest]
}

proc pkg { pkg dest } {
    shell ${::PKG} retail [file nativename $pkg] [file nativename $dest]
}

proc unpkg_archive {pkg dest} {
    debug "unpkg-ing file [file tail $pkg]"
    catch_die {unpkg $pkg $dest} "Could not unpkg file [file tail $pkg]"
}

proc pkg_archive {dir pkg} {
    debug "pkg-ing file [file tail $pkg]"
    catch_die {pkg $dir $pkg} "Could not pkg file [file tail $pkg]"
}

proc unpkg_devflash_all {dir} {
    file mkdir $dir
    foreach file [lsort [glob -nocomplain [file join ${::CUSTOM_UPDATE_DIR} dev_flash_*]]] {
        unpkg_archive $file [file join $dir [file tail $file]]
    }
}

proc cosunpkg { pkg dest } {
    shell ${::COSUNPKG} [file nativename $pkg] [file nativename $dest]
}

proc cospkg { dir pkg } {
    shell ${::COSPKG} [file nativename $pkg] [file nativename $dir]
}

proc cosunpkg_package { pkg dest } {
    debug "cosunpkg-ing file [file tail $pkg]"
    catch_die { cosunpkg $pkg $dest } "Could not cosunpkg file [file tail $pkg]"
}

proc cospkg_package { dir pkg } {
    debug "cospkg-ing file [file tail $dir]"
    catch_die { cospkg $dir $pkg } "Could not cospkg file [file tail $pkg]"
}

proc modify_coreos_file { file callback args } {
    log "Modifying CORE_OS file [file tail $file]"
    set pkg [file join ${::CUSTOM_UPDATE_DIR} CORE_OS_PACKAGE.pkg]
    set unpkgdir [file join ${::CUSTOM_UPDATE_DIR} CORE_OS_PACKAGE.unpkg]
    set cosunpkgdir [file join ${::CUSTOM_UPDATE_DIR} CORE_OS_PACKAGE]
    
    ::unpkg_archive $pkg $unpkgdir
    ::cosunpkg_package [file join $unpkgdir content] $cosunpkgdir

    if {[file writable [file join $cosunpkgdir $file]] } {
        eval $callback [file join $cosunpkgdir $file] $args
    } elseif { ![file exists [file join $cosunpkgdir $file]] } {
        die "Could not find $file in CORE_OS_PACKAGE"
    } else {
        die "File $file is not writable in CORE_OS_PACKAGE"
    }

    ::cospkg_package $cosunpkgdir [file join $unpkgdir content]
    ::pkg_archive $unpkgdir $pkg
}

proc get_pup_build {} {
    debug "Getting PUP build from [file tail ${::IN_FILE}]"
    catch_die {pup_get_build ${::IN_FILE}} "Could not get the PUP build information"
    return [pup_get_build ${::IN_FILE}]
}

proc set_pup_build {build} {
    debug "PUP build: $build"
    set ::PUP_BUILD $build
}

proc get_pup_version {} {
    debug "Getting PUP version from [file tail ${::CUSTOM_VERSION_TXT}]"
    set fd [open [file join ${::CUSTOM_VERSION_TXT}] r]
    set version [string trim [read $fd]]
    close $fd
    return $version
}

proc set_pup_version {version} {
    debug "Setting PUP version in [file tail ${::CUSTOM_VERSION_TXT}]"
    set fd [open [file join ${::CUSTOM_VERSION_TXT}] w]
    puts $fd "${version}"
    close $fd
}

proc modify_pup_version_file {prefix suffix {clear 0}} {
    if {$clear} {
      set version ""
    } else {
      set version [::get_pup_version]
    }
    debug "PUP version: ${prefix}${version}${suffix}"
    set_pup_version "${prefix}${version}${suffix}"
}

proc sed_in_place {file search replace} {
    set fd [open $file r]
    set data [read $fd]
    close $fd

    set data [string map [list $search $replace] $data]

    set fd [open $file w]
    puts -nonewline $fd $data
    close $fd
}

proc unself {in out} {
    shell ${::UNSELF} [file nativename $in] [file nativename $out]
}

proc makeself {in out original} {
    shell ${::MAKESELF} [file nativename $in] [file nativename $out] [file nativename $original]
}

proc decrypt_self {in out} {
    debug "Decrypting self file [file tail $in]"
    catch_die {unself $in $out} "Could not decrypt file [file tail $in]"
}

proc sign_elf {in out original} {
    debug "Rebuilding self file [file tail $out]"
    catch_die {makeself $in $out $original} "Could not rebuild file [file tail $out]"
}

proc modify_self_file {file callback args} {
    log "Modifying self/sprx file [file tail $file]"
    decrypt_self $file ${file}.elf
    eval $callback ${file}.elf $args
    sign_elf ${file}.elf ${file}.self $file
    file rename -force ${file}.self $file
    file delete ${file}.elf
}

proc patch_self {file search replace_offset replace {ignore_bytes {}}} {
    modify_self_file $file patch_elf $search $replace_offset $replace $ignore_bytes
}

proc patch_elf {file search replace_offset replace {ignore_bytes {}}} {
    patch_file $file $search $replace_offset $replace $ignore_bytes
}

proc patch_file {file search replace_offset replace {ignore_bytes {}}} {
    foreach bytes $ignore_bytes {
        if {[llength $bytes] == 1} {
            set search [string replace $search $bytes $bytes "?"]
        } elseif {[llength $bytes] == 2} {
            set idx1 [lindex $bytes 0]
            set idx2 [lindex $bytes 1]
            set len [expr {$idx2 - $idx1 + 1}]
            if {$len < 0} {
                set len 0
            }
            set search [string replace $search $idx1 $idx2 [string repeat "?" $len]]
        }
    }
    set fd [open $file r+]
    fconfigure $fd -translation binary
    set offset -1
    set buffer ""
    while {![eof $fd]} {
        append buffer [read $fd 1]
        if {[string length $buffer] > [string length $search]} {
            set buffer [string range $buffer 1 end]
        }
        set tmp $buffer
        foreach bytes $ignore_bytes {
            if {[llength $bytes] == 1} {
                set tmp [string replace $tmp $bytes $bytes "?"]
            } elseif {[llength $bytes] == 2} {
                set idx1 [lindex $bytes 0]
                set idx2 [lindex $bytes 1]
                set len [expr {$idx2 - $idx1 + 1}]
                if {$len < 0} {
                    set len 0
                }
                set tmp [string replace $tmp $idx1 $idx2 [string repeat "?" $len]]
            }
        }
        if {$tmp == $search} {
            if {$offset != -1} {
                error "Pattern found multiple times"
            }
            set offset [tell $fd]
            incr offset -[string length $search]
            incr offset $replace_offset
        }
    }
    if {$offset == -1} {
        error "Could not find pattern to patch"
    }
    debug "offset: $offset"
    seek $fd $offset
    puts -nonewline $fd $replace
    close $fd
}

proc patch_file_multi {file search replace_offset replace {ignore_bytes {}}} {
    foreach bytes $ignore_bytes {
        if {[llength $bytes] == 0} {
            set search [string replace $search $bytes $bytes "?"]
        } else {
            set search [string replace $search [lindex $bytes 0] [lindex $bytes 1] "?"]
        }
    }
    set fd [open $file r+]
    fconfigure $fd -translation binary
    set offset -1
    set counter 0
    set buffer ""
    while {![eof $fd]} {
        append buffer [read $fd 1]
        if {[string length $buffer] > [string length $search]} {
            set buffer [string range $buffer 1 end]
        }
        set tmp $buffer
        foreach bytes $ignore_bytes {
            if {[llength $bytes] == 0} {
                set tmp [string replace $tmp $bytes $bytes "?"]
            } else {
                set tmp [string replace $tmp [lindex $bytes 0] [lindex $bytes 1] "?"]
            }
        }
        if {$tmp == $search} {
            incr counter 1
            set offset [tell $fd]
            incr offset -[string length $search]
            incr offset $replace_offset
            debug "offset: $offset"
            seek $fd $offset
            puts -nonewline $fd $replace
            seek $fd $offset
            set offset -1
        }
    }
    if {$counter == 0} {
        debug "Could not find pattern to patch"
    } else {
        debug "Replaced $counter occurences of search pattern"
    }
    close $fd
}

proc modify_devflash_file {file callback args} {
    log "Modifying dev_flash file [file tail $file]"
    set tar_file [find_devflash_archive ${::CUSTOM_DEVFLASH_DIR} $file]

    if {$tar_file == ""} {
        die "Could not find [file tail $file]"
    }

    set pkg_file [file tail [file dirname $tar_file]]
    debug "Found [file tail $file] in $pkg_file"

    file delete -force [file join ${::CUSTOM_DEVFLASH_DIR} dev_flash]
    extract_tar $tar_file ${::CUSTOM_DEVFLASH_DIR}

    if {[file writable [file join ${::CUSTOM_DEVFLASH_DIR} $file]] } {
        eval $callback [file join ${::CUSTOM_DEVFLASH_DIR} $file] $args
    } elseif { ![file exists [file join ${::CUSTOM_DEVFLASH_DIR} $file]] } {
        die "Could not find $file in ${::CUSTOM_DEVFLASH_DIR}"
    } else {
        die "File $file is not writable in ${::CUSTOM_DEVFLASH_DIR}"
    }

    file delete -force $tar_file

    create_tar $tar_file ${::CUSTOM_DEVFLASH_DIR} dev_flash

    set pkg [file join ${::CUSTOM_UPDATE_DIR} $pkg_file]
    set unpkgdir [file join ${::CUSTOM_DEVFLASH_DIR} $pkg_file]
    pkg_archive $unpkgdir $pkg
}

proc modify_devflash_files {path files callback args} {
    foreach file $files {
        set file [file join $path $file]
        log "Modifying dev_flash file [file tail $file]"

        set tar_file [find_devflash_archive ${::CUSTOM_DEVFLASH_DIR} $file]

        if {$tar_file == ""} {
            debug "Skipping [file tail $file] not found"
            continue
        }

        set pkg_file [file tail [file dirname $tar_file]]
        debug "Found [file tail $file] in $pkg_file"

        file delete -force [file join ${::CUSTOM_DEVFLASH_DIR} dev_flash]
        extract_tar $tar_file ${::CUSTOM_DEVFLASH_DIR}

        if {[file writable [file join ${::CUSTOM_DEVFLASH_DIR} $file]] } {
            eval $callback [file join ${::CUSTOM_DEVFLASH_DIR} $file] $args
        } elseif { ![file exists [file join ${::CUSTOM_DEVFLASH_DIR} $file]] } {
            debug "Could not find $file in ${::CUSTOM_DEVFLASH_DIR}"
            continue
        } else {
            die "File $file is not writable in ${::CUSTOM_DEVFLASH_DIR}"
        }

        file delete -force $tar_file

        create_tar $tar_file ${::CUSTOM_DEVFLASH_DIR} dev_flash

        set pkg [file join ${::CUSTOM_UPDATE_DIR} $pkg_file]
        set unpkgdir [file join ${::CUSTOM_DEVFLASH_DIR} $pkg_file]
        pkg_archive $unpkgdir $pkg
    }
}

proc modify_upl_file {callback args} {
    log "Modifying UPL.xml file"
    set file "content"
    set pkg [file join ${::CUSTOM_UPDATE_DIR} UPL.xml.pkg]
    set unpkgdir [file join ${::CUSTOM_UPDATE_DIR} UPL.xml.unpkg]

    ::unpkg_archive $pkg $unpkgdir

    if {[file writable [file join $unpkgdir $file]] } {
        eval $callback [file join $unpkgdir $file] $args
    } elseif { ![file exists [file join $unpkgdir $file]] } {
        die "Could not find $file in $unpkgdir"
    } else {
        die "File $file is not writable in $unpkgdir"
    }

    ::pkg_archive $unpkgdir $pkg
}

proc remove_node_from_xmb_xml { xml key message} {
    log "Removing \"$message\" from XML"

    while { [::xml::GetNodeByAttribute $xml "XMBML:View:Attributes:Table" key $key] != "" } {
        set xml [::xml::RemoveNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Attributes:Table" key $key]]
    }
    while { [::xml::GetNodeByAttribute $xml "XMBML:View:Items:Query" key $key] != "" } {
        set xml [::xml::RemoveNode $xml [::xml::GetNodeIndicesByAttribute $xml "XMBML:View:Items:Query" key $key]]
    }

    return $xml
}

proc change_build_upl_xml { xml key message } {
    log "Not implemented yet"
}

proc remove_pkg_from_upl_xml { xml key message } {
    log "Removing \"$message\" package from UPL.xml" 1

    set i 0
    while { 1 } {
        set index [::xml::GetNodeIndices $xml "UpdatePackageList:Package" $i]
        if {$index == "" } break
        set node [::xml::GetNodeByIndex $xml $index]
        set data [::xml::GetData $node "Package:Type"]
        #debug "index: $index :: node: $node :: data: $data"
        if {[string equal $data $key] == 1 } {
            #debug "data: $data :: key: $key"
            set xml [::xml::RemoveNode $xml $index]
            break
        }
        incr i 1
    }

    return $xml
}

proc remove_pkgs_from_upl_xml { xml key message } {
    log "Removing \"$message\" packages from UPL.xml" 1

    set i 0
    while { 1 } {
        set index [::xml::GetNodeIndices $xml "UpdatePackageList:Package" $i]
        if {$index == "" } break
        set node [::xml::GetNodeByIndex $xml $index]
        set data [::xml::GetData $node "Package:Type"]
        #debug "index: $index :: node: $node :: data: $data"
        if {[string equal $data $key] == 1 } {
            #debug "data: $data :: key: $key"
            set xml [::xml::RemoveNode $xml $index]
            incr i -1
        }
        incr i 1
    }

    return $xml
}

# .rco files handling routines
proc rco_dump {rco rco_xml rco_dir} {
    shell ${::RCOMAGE} dump [file nativename $rco] [file nativename $rco_xml] --resdir [file nativename $rco_dir]
}

proc rco_compile {rco_xml rco_new} {
    set RCOMAGE_OPTS "--pack-hdr zlib --zlib-method default --zlib-level 9"
    shell ${::RCOMAGE} compile [file nativename $rco_xml] [file nativename $rco_new] {*}$RCOMAGE_OPTS
}

proc unpack_rco_file {rco rco_xml rco_dir} {
    log "unpacking rco file [file tail $rco]"
    catch_die {rco_dump $rco $rco_xml $rco_dir} "Could not unpack rco file [file tail $rco]"
}

proc pack_rco_file {rco_xml rco_new} {
    log "packing rco file [file tail $rco_new]"
    catch_die {rco_compile $rco_xml $rco_new} "Could not pack rco file [file tail $rco_new]"
}

proc callback_modify_rco {rco_file callback callback_args} {
    set RCO_XML ${rco_file}.xml
    set RCO_DIR ${rco_file}_dir
    set RCO_NEW ${rco_file}.new

    catch_die {file mkdir $RCO_DIR} "Could not create dir $RCO_DIR"
    unpack_rco_file $rco_file $RCO_XML $RCO_DIR

    eval $callback $RCO_DIR $callback_args

    pack_rco_file $RCO_XML $RCO_NEW
    catch_die {
        file rename -force $RCO_NEW $rco_file
        file delete -force $RCO_XML
        file delete -force $RCO_DIR
    } "Could not cleanup files after modifying [file tail $rco_file]"
}

proc modify_rco_file {rco_file callback args} {
    modify_devflash_file $rco_file callback_modify_rco $callback $args
}

proc get_header_key_upl_xml { file key message } {
    debug "Getting \"$message\" information from UPL.xml"

    set xml [::xml::LoadFile $file]
    set data [::xml::GetData $xml "UpdatePackageList:Header:$key"]
    if {$data != ""} {
        debug "$key: $data"
        return $data
    }
    return ""
}

proc set_header_key_upl_xml { file key replace message } {
    log "Setting \"$message\" information in UPL.xml" 1

    set xml [::xml::LoadFile $file]

    set search [::xml::GetData $xml "UpdatePackageList:Header:$key"]
    if {$search != "" } {
        debug "$key: $search -> $replace"
        set fd [open $file r]
        set xml [read $fd]
        close $fd

        set xml [string map [list $search $replace] $xml]

        set fd [open $file w]
        puts -nonewline $fd $xml
        close $fd
        return $search
    }
    return ""
}

proc unspp {in out} {
    shell ${::UNSPP} [file nativename $in] [file nativename $out]
}

proc spp {in out} {
    shell ${::SPP} 355 [file nativename $in] [file nativename $out]
}

proc decrypt_spp {in out} {
    debug "Decrypting spp file [file tail $in]"
    catch_die {unspp $in $out} "Could not decrypt file [file tail $in]"
}

proc patch_pp {file search replace_offset replace {ignore_bytes {}}} {
    patch_file $file $search $replace_offset $replace $ignore_bytes
}

proc sign_pp {in out} {
    debug "Rebuilding spp file [file tail $out]"
    catch_die {spp $in $out} "Could not rebuild file [file tail $out]"
}

proc modify_spp_file {file callback args} {
    log "Modifying spp file [file tail $file]"
    decrypt_spp $file ${file}.pp
    eval $callback ${file}.pp $args
    sign_pp ${file}.pp $file
    file delete ${file}.pp
}
