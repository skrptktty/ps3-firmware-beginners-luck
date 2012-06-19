#!/usr/bin/tclsh
#
# ps3mfw -- PS3 MFW creator
#
# Copyright (C) Anonymous Developers (Code Monkeys)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

namespace eval ::xml {

    proc LoadFile {filename} {
	set fd [open $filename r]
	set data [read $fd]
	close $fd
	return [Load $data]
    }

    proc Load {xml} {
	# Remove any unwanted characters that could appear before/after the xml
	regsub {^.*?<} $xml {<} xml
	regsub {>[^>]*?$} $xml {>} xml
	if { $xml == "" } { return "" }
	# Remove xml file header and comments
	# Here the ".*?" in the regexp means a non greedy matching, 
	# which means match as little characters as possible.. the reason, here's an example :
	# <!-- comment --> <tag/> <!-- comment2 --> <tag2/>
	# the regsub {<!--.*-->} would remove from the first <!-- to the last --> 
	# which means we end up with <tag2/> and we loose <tag/>.. 
	# if it's greedy, it will match all possible chars, with non-greedy,
	# it will match only the smallest number: only the comment... 
	regsub -all {<\?xml.*?\?>} $xml "" xml
	regsub -all {<!--.*?-->} $xml "" xml
	# Avoid unmatched braces in list, in case we have a left or right accolade in the xml data
	set xml [string map {"\{" "&right_accolade;" "\}" "&left_accolade;" "\\" "&escape_char;"}  $xml]
	
	regsub -all {>\s*<} [string trim $xml " \r\n\t<>"] "\} \{" xml
	set xml [string map {> "\} \{#text \{" < "\}\} \{" }  $xml]

	set res ""   ;# string to collect the result
	set stack {} ;# track open tags
	set rest {}
	foreach item "{$xml}" {
	    switch -regexp -- $item {
		^# {
		    append res "{[lrange $item 0 end]} " ; #text item
		}
		^/ {
		    regexp {/(.+)} $item -> tagname ;# end tag
		    set expected [lindex $stack end]
		    if {$tagname!=$expected} {error "$item != $expected"}
		    set stack [lrange $stack 0 end-1]
		    append res "\}\} "
		}
		/$ { # singleton - start and end in one <> group
		    regexp {([^\s]+)(\s(.+))?/$} $item -> tagname - rest
		    set rest [regsub -all {\s*([^=\s]+)=\"([^\"]+)\"\s*} $rest {\1 {\2} }]
		    set rest [regsub -all {\s*([^=\s]+)=\'([^\']+)\'\s*} $rest {\1 {\2} }]
		    append res "{$tagname [list $rest] {}} "
		}
		default {
		    regexp {([^\s]+)(\s(.+))?$} $item -> tagname - rest
		    set rest [regsub -all {\s*([^=\s]+)=\"([^\"]+)\"\s*} $rest {\1 {\2} }]
		    set rest [regsub -all {\s*([^=\s]+)=\'([^\']+)\'\s*} $rest {\1 {\2} }]
		    lappend stack $tagname
		    append res "\{$tagname [list $rest] \{"
		}
	    }
	    if {[llength $rest]%2} {error "att's not paired: $rest"}
	}
	if [llength $stack] {error "unresolved: $stack"}
	
	# Unescape chars and accolades
	string map {"\} \}" "\}\}" "&right_accolade;" "\\\{" "&left_accolade;" "\\\}" "&escape_char;" "\\\\"} [xmldecode [lindex $res 0] 1]
    }

    proc Print {list {depth -1}} {
	set res ""
	switch -- [llength $list] {
	    2 {
		append res [xmlencode [lindex $list 1]]
	    }
	    3 {
		foreach {tag attributes children} $list break
		if {$depth > 0} {
		    append res [string repeat "    " $depth]
		}
		append res <$tag
		foreach {name value} $attributes {
		    append res " $name=\"$value\""
		}
		if {[llength $children] == 1 && [llength [lindex $children 0]] == 2} {
		    append res >
		    append res [Print [lindex $children 0]]
		    append res </$tag>
		    if {$depth >= 0} {
			append res "\n"
		    }
		} elseif {[llength $children] > 0} {
		    set child_depth $depth
		    append res >
		    if {$depth >= 0} {
			append res "\n"
			incr child_depth
		    }
		    foreach child $children {
			append res [Print $child $child_depth]
		    }
		    if {$depth > 0} {
			append res [string repeat "    " $depth]
		    }
		    append res </$tag>
		    if {$depth >= 0} {
			append res "\n"
		    }
		} else {
		    append res />
		    if {$depth >= 0} {
			append res "\n"
		    }
		}
	    }
	    default {error "could not parse $list"}
	}
	return $res
    }
    
    proc xmlencode {string} {
	    return [string map {
		    "<" "&lt;"
		    ">" "&gt;"
		    "\"" "&quot;"
		    "\t" "&#x9;"
		    "\r" "&#xd;"
		    "\n" "&#xa;"} $string]
    }

    proc xmldecode {string {escape 0}} {
	    set parsed ""
	    while {[set pos [string first "&#x" $string]] != -1 } {
		    append parsed [string range $string 0 [expr {$pos - 1}]]
		    incr pos 3
		    set byte ""
		    while {[set char [string range $string $pos $pos]] != ";" } {
			    append byte $char
			    incr pos
		    }
		    if {[expr {[string length $byte] % 2}] == 1} {
			    set byte "[string range $byte 0 end-1]0[string range $byte end end]"
		    }
		    set value [binary format H* $byte]
		    if {$escape } {
			    if {$value == "\{" } {
				    set value "\\\{"
			    } elseif {$value == "\}" } {
				    set value "\\\}"
			    } elseif {$value == "\\" } {
				    set value "\\\\"
			    }
		    }
		    append parsed $value
		    set string [string range $string [expr {$pos + 1}] end]
	    }
	    append parsed $string
	    return [string map { "&lt;" "<" "&gt;" ">" "&amp;" "&" "&quot;" "\"" "&apos;" "'" } $parsed]
    }

    proc PrettyPrint { xml } {
	return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[Print [Load $xml] 0]"
    }

    proc SaveToFile { list filename {pretty 1} } {
	if {$pretty} {
	    set depth 0
	} else {
	    set depth -1
	}
	set xml [Print $list $depth]
	set fd [open $filename w]
	puts $fd $xml
	close $fd
    }
    
    proc GetNodeIndices {list find {no 0} {stack ""}} {
	variable xmlTag_occurences

	if {$stack == "" } {
	    set xmlTag_occurences 0
	}
	set current_stack $stack
	set index -1
	foreach { tag attributes content} $list {
	    incr index
	    set current_stack "$stack:$tag"
	    if {$current_stack == $find || $current_stack == ":$find" } {
		#status_log "Found it in $current_stack\n" red
		if { $no == $xmlTag_occurences } {
		    return 0
		} else {
		    incr xmlTag_occurences
		}
		return ""
	    } else {
		if {[string first $current_stack $find] == -1 &&
		    [string first $current_stack ":$find"] == -1 } {
		    #status_log "$find not in $current_stack" red
		    continue
		} else { 
		    set index 2
		    set subindex 0
		    #status_log "$find is in a subkey of $current_stack\n" red
		    foreach subkey $content {
			set result [GetNodeIndices $subkey $find $no $current_stack]
			if { $result != "" } {
			    eval lappend index $subindex $result
			    return $index
			}
			incr subindex
		    }
		}
	    }	
	}

	return ""
    }

    proc GetNodeByIndex {list indices} {
	if {$indices == ""} {
	    return ""
	}
	set indices [lrange $indices 0 end-1]
	if {$indices == {}} {
	    return $list
	} else {
	    return [eval lindex [list $list] $indices]
	}
    }

    proc GetNode {list find {no 0}} {
	return [GetNodeByIndex $list [GetNodeIndices $list $find $no]]
    }

    proc GetData {list find {no 0}} {
	set node [GetNode $list $find $no]
	if {$node != ""} {
	    foreach { tag attributes children} $node break
	    foreach child $children {
		if {[llength $child] == 2} {
		    return [string map {"\\\\" "\\" "\\\{" "\{" "\\\}" "\}" } [lindex $child 1]]
		}
	    }
	}
	return ""
    }
    
    proc GetAttribute { list find attribute_name {no 0}} {	
	set node [GetNode $list $find $no]
	if {$node != ""} {
	    foreach { tag attributes children} $node break
	    array set attributes_arr $attributes
	    if { [info exists attributes_arr($attribute_name)] } {
		return [string map {"\\\\" "\\" "\\\{" "\{" "\\\}" "\}" } [set attributes_arr($attribute_name)]]
	    }
	} 
	return ""
    }
    
    proc ListChildren {list find {no 0}} {	
	set node [GetNode $list $find $no]
	if {$node != ""} {
	    foreach { tag attributes children} $node break
	    set tags [list]
	    foreach child $children {
		if {[llength $child] == 3} {
		    lappend tags [lindex $child 0]
		}
	    }
	    return $tags
	}
	return ""
    }

    proc GetAttributes { list find {no 0}} {	
	set node [GetNode $list $find $no]
	if {$node != ""} {
	    foreach { tag attributes children} $node break
	    return $attributes
	}
	return ""
    }
    
    proc ListAttributes { list find {no 0}} {	
	array set attributes [GetAttributes $list $find $no]
	return [array names attributes]
    }

    proc ReplaceNode {list indices node} {
	return [__modifyNode $list $indices $node "replace"]
    }

    proc InsertNode {list indices node} {
	return [__modifyNode $list $indices $node "insert"]
    } 

    proc RemoveNode {list indices} {
	return [__modifyNode $list $indices {} "remove"]
    } 

    proc GetNodeIndicesByAttribute {list find attribute value {no 0}} {
	    regsub {:$} $find {} find
	    regsub {.*:([^:]+)$} $find {\1} tag
	    set i -1
	    set index 0
	    while {1} {
		    incr i
		    set n [GetNode $list $find $i]
		    if {$n == "" } break
		    set key [GetAttribute $n $tag $attribute]
		    if {$key == $value} {
			    if {$no == $index} {
				    return [GetNodeIndices $list $find $i]
			    } else {
				    incr index
			    }
		    }
	    }
	    return ""
    }
    proc GetNodeByAttribute {list find attribute value {no 0}} {
	    return [GetNodeByIndex $list [GetNodeIndicesByAttribute $list $find $attribute $value $no]]
    }

    # Helper Functions
    proc __lmod_r {list indices mod {val {}}} {
	if { [llength $indices] == 0 } {
	    return $val
	} elseif {[llength $indices] == 1} {
	    if {$mod == "insert"} {
		return [linsert $list [lindex $indices 0] $val]
	    } elseif {$mod == "remove"} {
		return [lreplace $list [lindex $indices 0] [lindex $indices 0]]
	    } else {
		return [lreplace $list [lindex $indices 0] [lindex $indices 0] $val]
	    }
	} else {
	    return [lreplace $list [lindex $indices 0] [lindex $indices 0] [__lmod_r [lindex $list [lindex $indices 0]] [lrange $indices 1 end] $mod $val]]
	}
    }
    proc __modifyNode {list indices node operation} {
	set indices [lrange $indices 0 end-1]
	if {$indices == {}} {
	    return $node
	} else {
	    return [__lmod_r $list $indices $operation $node]
	}
    }

}

