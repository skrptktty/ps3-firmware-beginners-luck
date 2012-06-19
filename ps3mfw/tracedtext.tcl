 #----------------------------------------------------------------------
 #
 # TracedText.tcl --
 #
 #      Package that implements a change to the text widget that
 #      allows a -textvariable option to be specified at creation
 #      time.
 #
 #----------------------------------------------------------------------

 # Copyright (c) 1999, by Kevin B. Kenny.  All rights reserved.

 set RCSID([info script]) \
  {$Id: 1917,v 1.5 2003-12-13 07:00:07 jcw Exp $}

 package provide TracedText 1.0

 namespace eval TracedText {

     namespace export TracedText

     # The traced text widgets have a <Destroy> binding that
     # cleans up internal storage.  Establish it here so that
     # the widget creation procedure just has to fiddle binding
     # tags.

     bind TracedText <Destroy> [namespace code {cleanup %W}]
 }

 #----------------------------------------------------------------------
 #
 # TracedText::TracedText --
 #
 #      Create a text widget that supports a -textvariable flag
 #
 # Parameters:
 #      w    -- Path name of the widget
 #      args -- Option-value pairs
 #
 # Results:
 #      Returns the path name of the newly-created widget.
 #
 # Side effects:
 #      The widget is created.  If a -textvariable option is
 #      supplied, the widget command is renamed, and an alias
 #      is installed in the global namespace.  The alias command
 #      intercepts the 'insert' and 'delete' subcommands and
 #      updates the text variable.  In addition, a trace is
 #      established on the text variable to keep the text
 #      variable up to date.
 #
 # Options:
 #      The TracedText command accepts all the options of a text
 #      widget, plus a -textvariable option that gives the name
 #      of a variable or array element in the global namespace
 #      that will contain the same content as the widget itself.
 #
 # Limitations:
 #      The code does not work entirely correctly in the presence
 #      of embedded images.  The -textvariable option cannot be
 #      set via 'configure' or interrogated via 'cget'.
 #
 #----------------------------------------------------------------------

 proc TracedText::TracedText { w args } {

     variable textvar

     # Extract the special '-textvariable' option.

     set textArgs {}
     foreach { option value } $args {
        switch -exact -- $option {
            -textvariable {
                set textvar($w) $value
            }
            default {
                lappend textArgs $option $value
            }
        }
     }

     # Create the widget

     eval [list text $w] $textArgs

     # Rename the widget command to an alias in the "TracedText"
     # namespace.  Create a new command that looks just like the
     # widget command but goes off to the "widgetCmd" procedure.

     if {[info exists textvar($w)]} {

        rename $w alias$w
        proc ::$w args {

            # p is the name of this procedure, which may or
            # may not have a :: qualifier.

            set p [lindex [info level 0] 0]

            # w is the name of the traced text widget.

            set w [namespace tail $p]

            # Go to the TracedText::widgetCmd procedure to
            # process the command.

            return [eval [list TracedText::widgetCmd $w] $args]

        }

        # Adjust the bind tags so that the <Destroy> binding will fire.

        bindtags $w [linsert [bindtags $w] 1 TracedText]

        # If the variable exists, update the widget content.
        # Otherwise, create the variable.

        upvar \#0 $textvar($w) theVariable
        if { [info exists theVariable] } {
            alias$w insert 1.0 $theVariable
        } else {
            set theVariable {}
        }

        # Put a trace on the text variable so that we can update
        # the widget if it changes.

        trace variable theVariable w \
                [namespace code [list traceCallback $w]]

     }

     return $w
 }

 #----------------------------------------------------------------------
 #
 # TracedText::widgetCmd --
 #
 #      Widget command for a text widget with a textvariable.
 #
 # Parameters:
 #      w    -- Path name of the widget
 #      args -- Arguments to the widget command
 #
 # Results:
 #      Returns whatever the text widget does in response to the
 #      widget command.
 #
 # Side effects:
 #      In addition to whatever side effects the text widget
 #      has in response to the widget command, the 'insert' and
 #      'delete' widget commands cause the text variable of the
 #      widget to be updated.
 #
 #----------------------------------------------------------------------

 proc TracedText::widgetCmd {w args} {

     # Execute the widget command

     set retval [eval [list alias$w] $args]

     # After the widget command returns, set the text variable if
     # the command was 'insert' or 'delete.'

     switch -exact [lindex $args 0] {
        del -
        dele -
        delet -
        delete -
        ins -
        inse -
        inser -
        insert {

            variable textvar
            variable busy

            # The 'busy' variable keeps the traceCallback
            # procedure from attempting to reload the widget
            # content.

            upvar \#0 $textvar($w) content
            set busy($w) {}
            set content [$w get 1.0 end]
            unset busy($w)

        }
     }

     return $retval

 }

 #----------------------------------------------------------------------
 #
 # TracedText::traceCallback --
 #
 #      Trace callback entered when the text variable of a text widget
 #      is changed.
 #
 # Parameters:
 #      w     -- Path name of the widget
 #      name1 -- Name of the text variable in the calling namespace.
 #      name2 -- Subscript name of the text variable, if any.
 #      op    -- Traced variable operation (always "w")
 #
 # Results:
 #      None.
 #
 # Side effects:
 #      If the variable was being changed in response to an 'insert'
 #      or 'delete' command on the widget, the procedure does nothing.
 #      Otherwise, it deletes the entire content of the widget and
 #      replaces it with the new contents of the variable; it does this
 #      even if the widget is disabled.
 #
 #----------------------------------------------------------------------

 proc TracedText::traceCallback { w name1 name2 op } {

     variable busy

     if { ! [info exists busy($w)] } {

        variable textvar

        # Retrieve the changed content of the textvariable

        upvar 1 $name1 theVariable
        if { [array exists theVariable] } {
            set content $theVariable($name2)
        } else {
            set content $theVariable
        }

        # Enable the widget temporarily, and adjust its content.

        set state [alias$w cget -state]
        alias$w configure -state normal
        alias$w delete 1.0 end
        alias$w insert 1.0 $content
        alias$w configure -state $state

     }

     return
 }

 #----------------------------------------------------------------------
 #
 # TracedText::cleanup --
 #
 #      Clean up after destroyoing a text widget with a textvariable.
 #
 # Parameters:
 #      w -- Path name of the destroyed widget.
 #
 # Results:
 #      None.
 #
 # Side effects:
 #      The variables and traces that belong to the widget are deleted,
 #      as is the procedure that aliases the widget command.
 #
 #----------------------------------------------------------------------

 proc TracedText::cleanup { w } {

     variable textvar

     upvar #0 $textvar($w) theVariable
     trace vdelete theVariable w \
            [namespace code [list traceCallback $w]]
     unset textvar($w)
     rename ::$w {}

     return

 }