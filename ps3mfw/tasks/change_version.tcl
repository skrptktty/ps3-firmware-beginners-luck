#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#
    
# Priority: 100
# Description: Change PUP build / version

# Option --pup-build: PUP build number
# Option --version-string: If set, overrides the entire PUP version string
# Option --version-prefix: Prefix to add to the PUP version string
# Option --version-suffix: Suffix to add to the PUP version string

# Type --pup-build: string
# Type --version-string: string
# Type --version-prefix: string
# Type --version-suffix: string
    
namespace eval ::change_version {

    array set ::change_version::options {
      --pup-build ""
      --version-string ""
      --version-prefix ""
      --version-suffix "-PS3MFW"
    }

    proc main {} {
      variable options

      if {$options(--pup-build) != ""} {
        ::set_pup_build $options(--pup-build)
      } else {
        ::set_pup_build [::get_pup_build]
      }

      log "Changing PUP version.txt file"
      if {$options(--version-string) != ""} {
        ::modify_pup_version_file $options(--version-string) "" 1
      } else {
        ::modify_pup_version_file $options(--version-prefix) $options(--version-suffix)
      }
    }
}

