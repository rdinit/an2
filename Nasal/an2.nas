    #############################################################################
    #    Copyright 								#
    #									   	#
    #    (C) 2010 by Yurik V. Nikiforoff - FDM, 3d instruments, animations, 	#
    #    systems and over.   							#
    #		yurik@megasignal.com					   	#
    #                                                                          	#
    #    This program is free software; you can redistribute it and#or modify  	#
    #    it under the terms of the GNU General Public License as published by  	#
    #    the Free Software Foundation; either version 2 of the License, or     	#
    #    (at your option) any later version.                                   	#
    #                                                                          	#
    #    This program is distributed in the hope that it will be useful,       	#
    #    but WITHOUT ANY WARRANTY; without even the implied warranty of        	#
    #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         	#
    #    GNU General Public License for more details.                          	#
    #                                                                          	#
    #    You should have received a copy of the GNU General Public License     	#
    #    along with this program; if not, write to the                         	#
    #    Free Software Foundation, Inc.,                                       	#
    #    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             	#
    #############################################################################
    
# Instrumentation for AN-2 
left_pos = 0;
right_pos = 0;
STRUT_LIMIT = 0.35;
STRUT_COEFT = 0.26;

gpk_caged = func{
caged = getprop("/an2/instrumentation/gpk-48/caged-flag");
if( caged == 1 ) { 
	setprop("/an2/instrumentation/gpk-48/caged-flag", 0); 
	return;
	}
if( caged == 0 ) {
	heading = getprop("/instrumentation/heading-indicator/indicated-heading-deg");
	offset = getprop("/instrumentation/heading-indicator/offset-deg");
	if( heading == nil) { return; }
	if( offset == nil) { return; }
	setprop("/an2/instrumentation/gpk-48/true-heading-deg", heading-offset ); 
	setprop("/an2/instrumentation/gpk-48/caged-flag", 1); 
	return;
	}
}

gik_adjust = func {
	if(getprop("/an2/instrumentation/gik/serviceable") == 1 )
	{
	if( getprop("/an2/instrumentation/gik/offset") > 0 ) {
		controls.slewProp ("/an2/instrumentation/gik/offset", -30 ); }
	}
}

# Radio Altimeter

# helper 
stop_rv = func {
	setprop("/an2/instrumentation/rv-um/lamp", 0);
	interpolate("/an2/instrumentation/rv-um/rv-altitude-m", 0, 1);
}

rv_um = func {
# check power
if( getprop("/an2/instrumentation/rv-um/serviceable" ) != 1 ){
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
	}
# check selector position
limit = getprop("/an2/instrumentation/rv-um/control");
if( limit == nil ){
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
}

if( limit < 1 ){ 
	stop_rv();
 	return ( settimer(rv_um, 0.3) ); 
}

altitude=getprop("/position/altitude-ft");
elevation=getprop("/position/ground-elev-ft");
rv_altitude_m = 0.3048*altitude;
  if( elevation != nil ){ rv_altitude_m = 0.3048*(altitude-elevation);}
  interpolate("/an2/instrumentation/rv-um/rv-altitude-m", rv_altitude_m, 0.3);
# convert from position to meters
	
	if(limit == 2){ limit = 50; }
	
if(limit == 3){ limit = 100; }
	if(limit == 4){ limit = 150; }
	if(limit == 5){ limit = 200; }
	if(limit == 6){ limit = 250; }
	if(limit == 7){ limit = 300; }
	if(limit == 8){ limit = 400; }
	if( rv_altitude_m < limit )
	{
 	setprop("/an2/instrumentation/rv-um/lamp", 1);
	}
	else { setprop("/an2/instrumentation/rv-um/lamp", 0); }
# control position
	if(limit == 1){ setprop("/an2/instrumentation/rv-um/lamp", 1); }
  settimer(rv_um, 0.3);
   }
rv_um ();	# start process first time


# Volt-ampermeter VA-3
va_handler = func {
mode = getprop("/an2/instrumentation/va-3/volts");
ampers = getprop("/an2/instrumentation/electrical/amps");
# battery charge current
if(getprop("/an2/systems/electrical/generator_lamp") == 0.0 ) 
	{
	ampers = -getprop("/engines/engine/rpm")/200.0;
	}
    	if( mode == 0 ){
    		if( ampers != nil ){
		interpolate("/an2/instrumentation/va-3/indicated-value", ampers, 1 );
		}
	}
	settimer(va_handler, 1);	
}
va_handler ();

va_volts = func {

    volts = getprop("/systems/electrical/volts");
	if( volts != nil ){
	interpolate("/an2/instrumentation/va-3/indicated-value", volts*4.2, 1 );
	}
	setprop("/an2/instrumentation/va-3/volts", 1);
}

va_ampers = func {

    	ampers = getprop("/an2/instrumentation/electrical/amps");
    	if("/an2/systems/electrical/generator_lamp" == 0 ) {ampers = 1;}
	if( ampers != nil ){
		interpolate("/an2/instrumentation/va-3/indicated-value", ampers, 1 );
	}
	setprop("/an2/instrumentation/va-3/volts", 0 );
	settimer(va_handler, 2);	
}

# ADF control

adf_selected = func {
    	freq = getprop("/an2/instrumentation/adf/selected-khz");
    	if( freq == nil ) {return }
    	if( freq < 150 ) {return }
    	if( freq > 1290 ) {return }
	setprop("/an2/instrumentation/adf/indicated-sel-ones", freq );
	setprop("/an2/instrumentation/adf/indicated-sel-dec", int(freq/10) );
	setprop("/an2/instrumentation/adf/indicated-sel-hund", int(freq/100) );
	pos = getprop("/an2/instrumentation/adf/selected_handle");
	pos = pos + 0.25;
       	interpolate("/an2/instrumentation/adf/selected_handle", pos, 0.1 );
	if (getprop("/an2/controls/switches/adf-selector") == 1){
	setprop("/instrumentation/adf/frequencies/selected-khz", freq );
	}
	else{
	setprop("/instrumentation/adf/frequencies/standby-khz", freq );
	}
#settimer(rev_sel_handle, 2.0);
}

adf_standby = func {
	freq = getprop("/an2/instrumentation/adf/standby-khz");
    	if( freq == nil ) {return }
    	if( freq < 150 ) {return }
    	if( freq > 1290 ) {return }    	
        setprop("/an2/instrumentation/adf/indicated-rez-ones", freq );
        setprop("/an2/instrumentation/adf/indicated-rez-dec", int(freq/10) );
        setprop("/an2/instrumentation/adf/indicated-rez-hund", int(freq/100) );
# vario position
	pos = getprop("/an2/instrumentation/adf/standby_handle");
	pos = pos + 0.25;
       	interpolate("/an2/instrumentation/adf/standby_handle", pos, 0.1 );
	if (getprop("/an2/controls/switches/adf-selector") == 2){
	setprop("/instrumentation/adf/frequencies/selected-khz", freq );
	}
	else{
	setprop("/instrumentation/adf/frequencies/standby-khz", freq );
	}
#settimer(rev_stand_handle, 2.0);

}

# S-meter for ADF with noise
# ADF signal level indicator not implemented (yet?), so it's simulation only.
adf_s_meter = func {
settimer(adf_s_meter, 1.0);

ena = getprop("/instrumentation/adf/serviceable");
if( ena != 1 ) {
	interpolate("/an2/instrumentation/adf/s_meter", 0.0, 1.0 ); 
	return; 
	}
ena = getprop("/instrumentation/adf/ident");
if( ena == "" ) {
       	interpolate("/an2/instrumentation/adf/s_meter", 0.0, 1.0 );
	}
else {	
	interpolate("/an2/instrumentation/adf/s_meter", 0.8 + 0.1 * rand(), 1.0 );
	}
}
# ADF lamps
adf_lamps = func {
lamps = getprop("/an2/controls/switches/adf-selector");
ena = getprop("/instrumentation/adf/serviceable");
if( ena != 1 )	{
	interpolate("/an2/instrumentation/adf/lamp_osn", 0.0, 0.1 );
	interpolate("/an2/instrumentation/adf/lamp_rez", 0.0, 0.1 );
	return;
	}
if( lamps == 2 ){ 
	interpolate("/an2/instrumentation/adf/lamp_osn", 0.0, 0.1 );
	interpolate("/an2/instrumentation/adf/lamp_rez", 1.0, 0.1 );
	}
if( lamps == 1 ){ 
	interpolate("/an2/instrumentation/adf/lamp_osn", 1.0, 0.1 );
	interpolate("/an2/instrumentation/adf/lamp_rez", 0.0, 0.1 );
	}
}

# init ADF on startup

adf_start = func {
freq = getprop("/instrumentation/adf/frequencies/selected-khz" );
if( freq == nil ) { settimer(adf_start, 1);  return; }
setprop("/an2/instrumentation/adf/selected-khz", freq );
freq = getprop("/instrumentation/adf/frequencies/standby-khz" );
if( freq == nil ) { settimer(adf_start, 1);  return; }
setprop("/an2/instrumentation/adf/standby-khz", freq );

setprop("/an2/instrumentation/adf/standby_handle", 0.0);
setprop("/an2/instrumentation/adf/selected_handle", 0.0);

setlistener("/an2/instrumentation/adf/selected-khz", adf_selected  );
setlistener("/an2/instrumentation/adf/standby-khz", adf_standby );
setlistener("/an2/controls/switches/adf-selector", adf_lamps );

settimer(adf_s_meter, 1.0);

#one times - for animate digit wheels on adf control instrument
settimer(adf_selected, 2);
settimer(adf_standby, 2);	

}

adf_start();

# Gear
left_gear = func
{
 left_pos = getprop("/gear/gear/compression-norm");
 if( left_pos > 0.0  ) {
 	left_pos = left_pos * STRUT_COEFT;
 	if( left_pos > STRUT_LIMIT ) { 
#print("Left strut overload");
	left_pos = STRUT_LIMIT; # strut damaged;
	} 
	setprop("/an2/gear/left", left_pos );
	}
}

right_gear = func
{
 right_pos = getprop("/gear/gear[1]/compression-norm");
 if( right_pos > 0  ) {
 	right_pos = right_pos * STRUT_COEFT;
 	if( right_pos > STRUT_LIMIT ) { 
	right_pos = STRUT_LIMIT;
#print("Right strut overload");
	} # strut damaged;
	setprop("/an2/gear/right", right_pos );
	}
}

setlistener("/gear/gear/compression-norm", left_gear  );
setlistener("/gear/gear[1]/compression-norm", right_gear  );

# Door
# Thanks to BF109 autors :)
toggle_door = func
{
  if(getprop("/an2/controls/door-pos-norm") > 0) 
	{
    	interpolate("/an2/controls/door-pos-norm", 0, 2);
	} 
	else {
    	interpolate("/an2/controls/door-pos-norm", 1, 2);
	}
}

# Dampers 

oil_damper = func {
if( arg[0] > 0 ) { 
	if( getprop ("/an2/systems/dampers/oil-damper") < 0.995 )
	{
	controls.slewProp ("/an2/systems/dampers/oil-damper", 0.5); 
	}}
else 	{ 
	if( getprop ("/an2/systems/dampers/oil-damper") > 0.005 )
	{
	controls.slewProp ("/an2/systems/dampers/oil-damper", -0.5); 
	}}

}


air_damper = func {
if( arg[0] > 0 ) { 
	if( getprop ("/an2/systems/dampers/air-damper") < 0.995 )
{
	controls.slewProp ("/an2/systems/dampers/air-damper", 0.5); 
}}
else 	{ 
	if( getprop ("/an2/systems/dampers/air-damper") > 0.005 )
{
	controls.slewProp ("/an2/systems/dampers/air-damper", -0.5); 
}}

}


# Livereas
# change_livreas = func
# {
# selector = getprop("/an2/livreas/selector");
# log = screen.window.new( nil, -100, 1, 2 );
# 
# if( selector != nil ) 
#    {
# 	if( selector < 0 ) { selector = 0; }
# 	if( selector >= 8 ) { selector = 0;}
# 	selector = selector + 1;
# 	if( selector == 1 )
# 	{
# 	log.write("Aeroflot-60", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","afl60_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","afl60_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 2 )
# 	{
# 	log.write("Aeroflot-70", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","afl70_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","afl70_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 3 )
# 	{
# 	log.write("Aeroflot-80", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","afl80_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","afl80_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 4 )
# 	{
# 	log.write("Aeroflot-90", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","afl90_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","afl90_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 5 )
# 	{
# 	log.write("Agricultural", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","agri_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","agri_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 6 )
# 	{
# 	log.write("Military", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","mil_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","mil_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 7 )
# 	{
# 	log.write("Aeroclub Rzhevka", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","rzhevka_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","rzhevka_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	return;
# 	}
# 	if( selector == 8 )
# 	{
# 	log.write("USA First :)", 0.0, 1.0, 1.0 );
# 	setprop("/an2/livreas/fuselage","usa_fuse_1_t.rgb");
# 	setprop("/an2/livreas/wings","usa_wings_1_t.rgb");
# 	setprop("/an2/livreas/selector", selector );
# 	}	
#     }
# }


# starter help
# starter_help = func
# {
# help_win = screen.window.new( nil, -100, 8, 10 );
# if( getprop("/sim/panel/visibility") == 0 )
# 	{
# 	help_win.write("Please, read Docs/an2.html for engine start procedure", 0.0, 1.0, 1.0 );
# 	return;
# 	}
# sw_win = screen.window.new( 380, 430, 1, 10 );
# sel_win = screen.window.new( 680, 430, 1, 10 );
# magn_win = screen.window.new( 430, 450, 1, 10 );
# fuel_win = screen.window.new( 90, 60, 1, 10 );
# alt_win = screen.window.new( 90, 185, 1, 10 );
# batt_win = screen.window.new( 830, 250, 1, 10 );
# line_1_win = screen.window.new( 740, 480, 1, 10 );
# line_2_win = screen.window.new( 800, 280, 1, 10 );
# 
# help_win.write("Before start, turn on main battery switch, set magneto selector to (1+2) position,", 0.0, 1.0, 1.0 );
# help_win.write("set fuel tank selector to up position, and turn throttle to idle.", 0.0, 1.0, 1.0 );
# help_win.write("For start engine, turn on starter switch,", 0.0, 1.0, 1.0 );
# help_win.write("spin inertial starter by turn starter selector to left position,", 0.0, 1.0, 1.0 );
# help_win.write("hold until spinup - see to ampermeter, listen sound of gyro. ", 0.0, 1.0, 1.0 );
# help_win.write("After spinup, turn starter selector to right and hold until engine started.", 0.0, 1.0, 1.0 );
# help_win.write("Turn on all switches on line 1 & 2, except panel lighting. Turn on PO-500 alternator.", 0.0, 1.0, 1.0 );
# help_win.write("Turn on radio altimeter and set warning to desired altitude. Turn off starter switch.", 0.0, 1.0, 1.0 );
# 
# 
# sw_win.write("Starter switch ->", 0.0, 1.0, 1.0 );
# sel_win.write("<- Starter selector", 0.0, 1.0, 1.0 );
# magn_win.write("Magneto selector ->", 0.0, 1.0, 1.0 );
# fuel_win.write("<- Fuel tank selector", 0.0, 1.0, 1.0 );
# alt_win.write("<- Radio altimeter selector", 0.0, 1.0, 1.0 );
# batt_win.write("<- Main battery switch", 0.0, 1.0, 1.0 );
# line_1_win.write("<-   Line 1 switches   ->", 0.0, 1.0, 1.0 );
# line_2_win.write("<-   Line 2 switches   ->", 0.0, 1.0, 1.0 );
# }

# slats_extend = 16.0;# deg
# slats_retract = 15.0;# deg
# 
# slats_handler = func {
# settimer(slats_handler, 0);
# 	pos = getprop("/fdm/jsbsim/aero/alpha-deg");
# 	if( pos == nil ) { return; }
# 	if( pos > slats_extend ) 
# 		{
# 		interpolate( "/an2/systems/slats/position", 1.0, 0.1 );
# 		setprop( "/controls/flight/speedbrakes", 1.0 );
# 		return;
# 		}
# 	if( pos < slats_retract ) 
# 		{
# 		interpolate( "/an2/systems/slats/position", 0.0, 0.1 );
# 		setprop( "/controls/flight/speedbrakes", 0.0 );
# 		return;
# 		}
# }
# 
# slats_handler();

# Pilot view selector
view_toggle = func {
if ( getprop("/sim/current-view/view-number") != 0 ) { return; }
pos = getprop("/sim/current-view/x-offset-m");
if ( pos == nil ) { return; }
interpolate("/sim/current-view/x-offset-m", -pos, 0.5 );
}

# Virtual second pilot
var simply_ap = func{
	var state = getprop("/autopilot/locks/altitude" );
	if( state == "pitch-hold" )
	{
	help.messenger("Autopilot OFF");
	setprop("/autopilot/locks/altitude", "" );
	setprop("/autopilot/locks/heading", "" );
	}
	else {
	setprop("/autopilot/settings/target-pitch-deg", getprop("/orientation/pitch-deg") );
	setprop("/autopilot/locks/heading", "wing-leveler" );
	setprop("/autopilot/locks/altitude", "pitch-hold" );
	help.messenger("Autopilot ON: wing leveler on, pitch lock");
	}


}

# Autostart procedure for lazy simmers
var autostart = func{
# Electrical
	setprop( "/an2/controls/switches/agk_switch", 1.0 );
	setprop( "/an2/controls/switches/arp_switch", 1.0 );
	setprop( "/an2/controls/switches/battery_switch", 1.0 );
	setprop( "/an2/controls/switches/brake_switch", 1.0 );
	setprop( "/an2/controls/switches/emi_switch", 1.0 );
	setprop( "/an2/controls/switches/generator", 1.0 );
	setprop( "/an2/controls/switches/gik_switch", 1.0 );
	setprop( "/an2/controls/switches/mrv_switch", 1.0 );
	setprop( "/an2/controls/switches/po_500_switch", 1.0 );
	setprop( "/an2/controls/switches/rv_switch", 1.0 );
	setprop( "/an2/controls/switches/ukv_switch", 1.0 );
	setprop( "/an2/controls/switches/sbess_switch", 1.0 );
	setprop( "/an2/controls/switches/flaps_power_switch", 1.0 );
	setprop( "/an2/controls/switches/oil_power_switch", 1.0 );
	setprop( "/an2/instrumentation/rv-um/control", 2.0 );
	setprop( "/an2/instrumentation/fuel-select/animation", 2.0 );
	setprop( "/an2/instrumentation/fuel-select/position", 2.0 );
	# Attitude
	setprop( "/instrumentation/attitude-indicator/caged-flag", 0.0 );
	# Altimeter
	setprop( "/instrumentation/altimeter/setting-inhg", 
		getprop( "/environment/pressure-inhg") );
	# GIK
	setprop( "/an2/instrumentation/gik/offset", 0.0 );
	setprop( "/instrumentation/adf/rotation-deg", 
		getprop( "/orientation/heading-magnetic-deg") );

	# start engine
	setprop( "/controls/engines/engine[0]/magnetos", 3 );
	setprop( "/controls/engines/engine[0]/throttle", 0.5 );
	setprop( "/controls/engines/engine[0]/starter", 1 );
	setprop( "/controls/engines/engine[0]/propeller-pitch", 1.0 );
	starter_helper();
	help.messenger("Autostart for lazy simmers");
}

var starter_helper = func{
	if( getprop( "/engines/engine[0]/running" ) )
		{
		setprop( "/controls/engines/engine[0]/starter", 0 );
		setprop( "/controls/engines/engine[0]/throttle", 0.0 );
		}
	else {
		setprop( "/controls/engines/engine[0]/starter", 1 );
		settimer(starter_helper, 0.1);
		}
}

setprop("/sim/menubar/default/menu[3]/enabled", 0 );
print("Avionics started, default autopilot disabled");
