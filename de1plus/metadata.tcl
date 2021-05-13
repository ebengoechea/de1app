package provide de1_metadata 1.0

package require de1_logging 1.0
package require de1_updater 1.1
package require de1_utils 1.1

namespace eval ::metadata {
	namespace export *
	namespace ensemble create

	# Data Dictionary
	variable dd
	set dd [dict create]
	
#	variable dd_fields
#	set dd_fields {domain category section subsection owner_type owner 
#		name name_plural short_name short_name_plural description propagate
#		data_type cardinality min max default smallincrement bigincrement n_decimals measure_unit
#		default_dui_widget}
	
	proc init { } {
		metadata dictionary init
		metadata dictionary add domain validate_domain
		metadata dictionary add category validate_nonempty_string
		metadata dictionary add section validate_nonempty_string
		metadata dictionary add subsection validate_nonempty_string
		metadata dictionary add owner_type validate_owner_type
		metadata dictionary add name validate_nonempty_string
		metadata dictionary add short_name validate_nonempty_string
		
		metadata add profile_title name "Profile title" short_name "Profile"
		metadata add drink_tds {name "Total Dissolved Solids" short_name "TDS"}
		
		return {}
	}

	namespace eval dictionary  {
		namespace export *
		namespace ensemble create
		
		variable properties
		set properties [dict create]
		
		proc init {} {
			variable properties
			set properties [dict create]
		}
		
		proc add { prop {vcmd {}} } {
			variable properties
			if { [dict exists $properties $prop] } {
				msg -WARNING [namespace current] "add: property name '$prop' already exists in the metadata data dictionary, duplicates not allowed"
				return
			}
			if { [string is wordchar -strict $vcmd] && [namespace which -command [namespace current]::$vcmd] ne "" } {
				set vcmd [namespace current]::$vcmd
			}
			dict set properties $prop $vcmd
		}

		proc properties { args } {
			variable properties
			return [dict keys $properties {*}$args]
		}

		proc exists { prop } {
			variable properties
			return [dict exists $properties $prop]
		}
		
		proc get {} {
			variable properties
			return $properties
		}
		
		proc validate_domain { domain } {
			return [expr {$data_type in {shot profile}}]
		}
		
		proc validate_data_type { data_type } {
			return [expr {$data_type in {text long_text category number date}}]
		}
		
		proc validate_length { length } {
			return [expr {$length in {{} list} || [string is integer $length]}]
		}

		proc validate_owner_type { owner_type } {
			return [expr {$owner_type in {{} base skin plugin}}]
		}
		
		proc validate_nonempty_string { text } {
			return [expr {$text ne ""}]
		}

		proc validate_boolean { bool } {
			return [expr {[string is true -strict $bool] || [string is false -strict $bool]}]
		}
		
	}
	
	proc add { field args } {
		variable dd
		if { [dict exists $dd $field] } {
			msg -WARNING [namespace current] "add: field name '$field' already exists in the data dictionary, duplicates not allowed"
			return
		}
		
		if { [llength $args] == 1 } {
			set args [lindex $args 0]
		} 
		set field_dict [dict create {*}$args]
		
		dict set dd $field $field_dict
	}

	# If no properties are specified in 'args', return a Tcl dict with all the properties.
	# If 'args' is given, return a list with the values of the requested properties.
	proc get { field args } {
		variable dd
		if { ![dict exists $dd $field] } {
			msg -WARNING [namespace current] "get: field name '$field' not found in the data dictionary"
			return {}
		} 
		
		set field_dd [dict get $dd $field]
		if { $args eq "" } {
			return $field_dd
		} else {
			if { [llength $args] == 1 } {
				set args [lindex $args 0]
			}
			set alist {}
			foreach fn $args {
				lappend alist [dict get $field_dd $fn]
			}
			return $alist
		}
	}
	
	proc fields { args } {
		variable dd
		set glob_pattern ""
		if { [llength $args] > 0 && [string range [lindex $args 0] 0 0] ne "-" } {
			set fields [dict keys $dd [pop args]]
		} else {
			set fields [dict keys $dd]
		}
		
		for { set i 0 } { $i < [llength $args] } { incr i 2 } {
			set filter_field [lindex $args $i]
			if { [string range $filter_field 0 0] eq "-" } {
				set filter_field [string range $filter_field 1 end]
			}
			set filter_values [lindex $args [expr {$i+1}]]
			
			if { [metadata dictionary exists $filter_field] } {
				set filtered_fields {}
				foreach fn $fields {
					if { [metadata get $fn $filter_field] in $filter_values } {
						lappend filtered_fields $fn
					}
				}				
				set fields $filtered_fields
			} else {
				msg -WARNING [namespace current] "fields: metadata dictionary filter field '$filter_field' not found"
			}
		}
		
		return $fields
	}
	
	proc exists { field } {
		variable dd
		return [dict exists $dd $field]
	}	
}