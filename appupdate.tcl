#!/usr/local/bin/tclsh

cd "[file dirname [info script]]/"

# do an app update on the de1plus code base, if this is a de1plus machine
if {[file exists "de1plus.tcl"] == 1} {
	package provide de1plus 1.0
}


source "updater.tcl"

determine_if_android

#source pkgIndex.tcl
#package require de1_utils
#package require snit
package require sha256
package require crc32
package require http 2.5
package require tls 1.6
::http::register https 443 ::tls::socket
cd "[file dirname [info script]]/"
set ::settings(logfile) "updatelog.txt"
set debugcnt 0

proc translate {x} {return $x}

set tk ""
catch {
	set tk [package present Tk]
}
if {$tk != ""} {
	button .hello -text "Update app" -command { pack forget .frame; start_app_update; } -height 10 -width 40
	frame .frame -border 2
	button .frame.redownloadapp -text " Redownload entire app " -command { catch { file delete "manifest.txt"; file delete "timestamp.txt"; pack forget .frame; start_app_update; } ; exit } 
	button .frame.resetapp -text " Reset app settings " -command { catch { file delete "settings.tdb"; } ; exit } 
	
	pack .hello  -pady 10 -padx 10
	pack .frame -side bottom -pady 0 -padx 0

	pack .frame.resetapp -side left -pady 10 -padx 10
	pack .frame.redownloadapp -side right -pady 10 -padx 10
	
	.hello configure -text "[ifexists ::de1(app_update_button_label)] Update app"

}

