#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

# Priority: 2500
# Description: Change SSL CA public certificate

# Option --ssl-cer: New SSL CA certificate (source)
# Option --change-cer: SSL CA public certificate (destination)

# Type --ssl-cer: file open {"SSL Certificate" {cer}}
# Type --change-cer: combobox {{DNAS} {Proxy} {ALL} {CA01.cer} {CA02.cer} {CA03.cer} {CA04.cer} {CA05.cer} {CA23.cer} {CA06.cer} {CA07.cer} {CA08.cer} {CA09.cer} {CA10.cer} {CA11.cer} {CA12.cer} {CA13.cer} {CA14.cer} {CA15.cer} {CA16.cer} {CA17.cer} {CA18.cer} {CA19.cer} {CA20.cer} {CA21.cer} {CA22.cer} {CA24.cer} {CA25.cer} {CA26.cer} {CA27.cer} {CA28.cer} {CA29.cer} {CA30.cer} {CA31.cer} {CA32.cer} {CA33.cer} {CA34.cer} {CA35.cer} {CA36.cer}}

namespace eval change_ssl_cer {

    array set ::change_ssl_cer::options {
        --ssl-cer "/path/to/file"
        --change-cer "CA27.cer"
    }

    proc main {} {
        variable options
        set src $options(--ssl-cer)
        set dst $options(--change-cer)
        set path [file join dev_flash data cert]

        if {[file exists ${src}] == 0 } {
            die "Source SSL CA public certificate file ${src} does not exist"
        } elseif {[string equal ${dst} "DNAS"] == 1} {
            log "Changing DNAS SSL CA public certificates to [file tail ${dst}]" 1
            set dst "CA01.cer CA02.cer CA03.cer CA04.cer CA05.cer"
            ::modify_devflash_files ${path} ${dst} ::change_ssl_cer::copy_ssl_certificate ${src}
        } elseif {[string equal ${dst} "Proxy"] == 1} {
            log "Changing SSL CA public certificates to [file tail ${src}]" 1
            set dst "CA06.cer CA07.cer CA08.cer CA09.cer CA10.cer CA11.cer CA12.cer CA13.cer CA14.cer CA15.cer CA16.cer CA17.cer CA18.cer CA19.cer CA20.cer CA21.cer CA22.cer CA23.cer CA24.cer CA25.cer CA26.cer CA27.cer CA28.cer CA29.cer CA30.cer CA31.cer CA32.cer CA33.cer CA34.cer CA35.cer CA36.cer"
            ::modify_devflash_files ${path} ${dst} ::change_ssl_cer::copy_ssl_certificate ${src}
        } elseif {[string equal ${dst} "ALL"] == 1} {
            log "Changing ALL SSL CA public certificates to [file tail ${dst}]" 1
            set dst "CA01.cer CA02.cer CA03.cer CA04.cer CA05.cer CA06.cer CA07.cer CA08.cer CA09.cer CA10.cer CA11.cer CA12.cer CA13.cer CA14.cer CA15.cer CA16.cer CA17.cer CA18.cer CA19.cer CA20.cer CA21.cer CA22.cer CA23.cer CA24.cer CA25.cer CA26.cer CA27.cer CA28.cer CA29.cer CA30.cer CA31.cer CA32.cer CA33.cer CA34.cer CA35.cer CA36.cer"
            ::modify_devflash_files ${path} ${dst} ::change_ssl_cer::copy_ssl_certificate ${src}
        } else {
            log "Changing SSL CA public certificate ${dst} to [file tail ${src}]" 1
            set dst [file join ${path} [lindex ${dst} 0]]
            ::modify_devflash_file ${dst} ::change_ssl_cer::copy_ssl_certificate ${src}
        }
    }

    proc copy_ssl_certificate { dst src } {
        if {[file exists ${src}] == 0} {
            die "Source file ${src} does not exist"
        } else {
            if {[file exists ${dst}] == 0} {
                die "Destination file ${dst} does not exist"
            } else {
                debug "Changing SSL certificate [file tail ${dst}] with [file tail ${src}]"
                copy_file -force ${src} ${dst}
            }
        }
    }
}
