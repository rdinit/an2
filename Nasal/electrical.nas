# Electrical subsystem for AN-2

# TODO: Rechargable battery model

UPDATE_PERIOD = 0.1;
MAX_STARTER_CONSUMPTION = 140.0;
rpm_minlimit = 1000;
bus_27 = 0;
bus_115 = 0;

update_electric = func {

power_consumption = 0;
bus_27 = 0;
bus_115 = 0;

starter_flag = 0;

# check for property exist
if( getprop("/engines/engine/rpm" ) == nil ) { 
	return (settimer( update_electric, UPDATE_PERIOD ));}
# Battery switch
	setprop("/an2/systems/electrical/bus-27", bus_27);
if( getprop("/an2/controls/switches/battery_switch") == 1 )
{
	bus_27 = getprop ("/systems/electrical/suppliers/battery[0]");
	setprop("/an2/systems/electrical/bus-27", bus_27);
}

# generator procedure
if( getprop("/engines/engine/rpm") > rpm_minlimit ){
	if( getprop("/an2/controls/switches/generator") == 1 ){
 	bus_27 = getprop ("/systems/electrical/suppliers/battery[0]");
 	setprop("/an2/systems/electrical/bus-27", bus_27);
	}
	}
# generator lamp 
if( bus_27 > 1 )
	{
		if( getprop("/engines/engine/rpm") > rpm_minlimit ) 
		{
			if( getprop("/an2/controls/switches/generator") == 1 )
			{
			setprop("/an2/systems/electrical/generator_lamp", 0);
			}
			else { setprop("/an2/systems/electrical/generator_lamp", 1); }
		}
		else { setprop("/an2/systems/electrical/generator_lamp", 1); }
	}
	else { setprop("/an2/systems/electrical/generator_lamp", 0); }
	
# bus 36 V 400 Hz PT-125 (GIK-1)
if( getprop("/an2/controls/switches/gik_switch") == 1 )
	{
	if( bus_27 > 1.0 )	
		{
		power_consumption += 8.5;
		setprop("/an2/instrumentation/gik/serviceable", 1);
		}
		else {
		setprop("/an2/instrumentation/gik/serviceable", 0);
		}
	}
	else {
	setprop("/an2/instrumentation/gik/serviceable", 0);
	}
# bus 36 V 400 Hz PAG-1 (AGK-47B, GPK-48)
if( getprop("/an2/controls/switches/agk_switch") == 1 )
	{
	if( bus_27 > 1.0 )	
		{
		power_consumption += 3.5;
		setprop("/instrumentation/attitude-indicator/serviceable", 1);
		setprop("/instrumentation/heading-indicator/serviceable", 1);
		setprop("/instrumentation/turn-indicator/serviceable", 1);
		# gyro spin
		interpolate("/instrumentation/attitude-indicator/spin", 1, 5);
		interpolate("/instrumentation/heading-indicator/spin", 1, 5);
			}
		else {
		setprop("/instrumentation/attitude-indicator/serviceable", 0);
		setprop("/instrumentation/heading-indicator/serviceable", 0);
		setprop("/instrumentation/turn-indicator/serviceable", 0);
			}
			}
	else {
	setprop("/instrumentation/attitude-indicator/serviceable", 0);
	setprop("/instrumentation/heading-indicator/serviceable", 0);
	}
# bus 115 V 400 Hz PO-500
if( getprop("/an2/controls/switches/po_500_switch") == 1 )
	{
	if( bus_27 > 1.0 ) { bus_115 = 115.1; power_consumption += 20.0; } }
	else {bus_115 = 0;}
	setprop("/an2/systems/electrical/bus-115", bus_115);
# Proceed devices, powered by 115 V
if( bus_115 > 100 )
	{
		if( getprop("/an2/controls/switches/arp_switch") == 1 )
		{	# ADF
		power_consumption += 7.5;
		setprop("/instrumentation/adf/serviceable", 1);
		}
		else { setprop("/instrumentation/adf/serviceable", 0); }
		if( getprop("/an2/controls/switches/rv_switch") == 1 )
		{	# Radio altimeter
		power_consumption += 7.5;
		setprop("/an2/instrumentation/rv-um/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/rv-um/serviceable", 0); }
		if( getprop("/an2/controls/switches/ukv_switch") == 1 )
		{	# NAV radio
		power_consumption += 5.0;
		setprop("/instrumentation/nav/serviceable", 1);
		}
		else { setprop("/instrumentation/nav/serviceable", 0); }
		
	}
	else {	# stop 
	setprop("/instrumentation/adf/serviceable", 0);
	setprop("/an2/instrumentation/rv-um/serviceable", 0);
	setprop("/instrumentation/nav/serviceable", 0);
	}
# common switches
if( bus_27 > 10.0 )	
	{ 
	if( getprop("/an2/controls/switches/sbess_switch") == 1 )
		{ # Fuel meter SBESS
		power_consumption += 1.0;
		setprop("/an2/instrumentation/sbess/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/sbess/serviceable", 0);}
	if( getprop("/an2/controls/switches/emi_switch") == 1 )
		{ # Engine gauge EMI-3K
		power_consumption += 1.0;
		setprop("/an2/instrumentation/emi-3k/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/emi-3k/serviceable", 0);}
	if( getprop("/an2/controls/switches/flaps_power_switch") == 1 )
		{ # Flaps indicator switch
		power_consumption += 1.0;
		setprop("/an2/instrumentation/flaps/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/flaps/serviceable", 0);}
# 	if( getprop("/an2/controls/switches/temp_switch") == 1 )
# 		{ # TUE gauge switch
# 		power_consumption += 1.0;
# 		setprop("/an2/instrumentation/tue-48/serviceable", 1);
# 		}
# 		else { setprop("/an2/instrumentation/tue-48/serviceable", 0);}
	if( getprop("/an2/controls/switches/pvd_switch") == 1 )
		{ # PVD switch, not implemented yet
		power_consumption += 1.0;
		}
	if( getprop("/an2/controls/switches/uv_switch") == 1 )
		{ # Panel lighting switch
		power_consumption += 1.0;
		setprop("/an2/controls/switches/uv_light", 1);
		}
	if( getprop("/an2/controls/switches/mrv_switch") == 1 )
		{ # Marker beacon switch
		power_consumption += 1.0;
		setprop("/instrumentation/marker-beacon/serviceable", 1);
		}
		else { setprop("/instrumentation/marker-beacon/serviceable", 0);}
	
	if( getprop("/an2/controls/switches/landing_light_switch") == 1 )
		{ # Landing light
		power_consumption += 8.0;
		setprop("/controls/switches/landing-light", 1);
		}
		else { setprop("/controls/switches/landing-light", 0);}
	if( getprop("/an2/controls/switches/taxi_light_switch") == 1 )
		{ # Taxi light
		power_consumption += 5.0;
		setprop("/controls/switches/taxi-light", 1);
		}
		else { setprop("/controls/switches/taxi-light", 0);}
	if( getprop("/an2/controls/switches/nav_light_switch") == 1 )
		{ # Nav light
		power_consumption += 3.0;
		setprop("/controls/switches/nav-light", 1);
		}
		else { setprop("/controls/switches/nav-light", 0);}
	if( getprop("/an2/controls/switches/heat_switch") == 1 )
		{ # Window heat
		power_consumption += 31.0;
		setprop("/controls/anti-ice/window-heat", 1);
		}
		else { setprop("/controls/switches/pilot-heat", 0);}
	if( getprop("/an2/controls/switches/starter_switch") == 1 )
		{ # starter subsystem
		power_consumption += 0.5;
		setprop("/an2/instrumentation/starter/serviceable", 1);
		}
		else { setprop("/an2/instrumentation/starter/serviceable", 0);}
# panel lighting
# read standby RGB values for internal and external panel lighting
i_r = getprop("/an2/controls/light/int-red-standby"); if( i_r == nil ){ i_r = 0.0; }
i_g = getprop("/an2/controls/light/int-green-standby"); if( i_g == nil ){ i_g = 0.0; }
i_b = getprop("/an2/controls/light/int-blue-standby"); if( i_b == nil ){ i_b = 0.0; }
e_r = getprop("/an2/controls/light/ext-red-standby"); if( e_r == nil ){ e_r = 0.0; }
e_g = getprop("/an2/controls/light/ext-green-standby"); if( e_g == nil ){ e_g = 0.0; }
e_b = getprop("/an2/controls/light/ext-blue-standby"); if( e_b == nil ){ e_b = 0.0; }

	if( getprop("/an2/controls/switches/light_1_switch") == 1 )
		{
		power_consumption += 0.5;
		setprop("/an2/controls/light/ext-red", e_r );
		setprop("/an2/controls/light/ext-green", e_g );
		setprop("/an2/controls/light/ext-blue", e_b );
		}
		else { 
		setprop("/an2/controls/light/ext-red", 0.0 );
		setprop("/an2/controls/light/ext-green", 0.0 );
		setprop("/an2/controls/light/ext-blue", 0.0 );
		}
	if( getprop("/an2/controls/switches/light_2_switch") == 1 )
		{
		power_consumption += 0.5;
 		setprop("/an2/controls/light/int-red", i_r );
 		setprop("/an2/controls/light/int-green", i_g );
 		setprop("/an2/controls/light/int-blue", i_b );
		}
		else { 
		setprop("/an2/controls/light/int-red", 0.0 );
		setprop("/an2/controls/light/int-green", 0.0 );
		setprop("/an2/controls/light/int-blue", 0.0 );
		}

	if( getprop("/an2/controls/switches/starter_selector" ) == 1 )
		{
		if( getprop("/an2/instrumentation/starter/spin") != nil ){
		power_consumption += 
( 1.0 - getprop("/an2/instrumentation/starter/spin") ) * MAX_STARTER_CONSUMPTION;
		}}
# Trimmer indicators procedure
	if( abs( getprop("controls/flight/aileron-trim") ) < 0.005 )
	setprop("an2/systems/electrical/aileron_trim_lamp", 1.0);
	else setprop("an2/systems/electrical/aileron_trim_lamp", 0.0);

	if( abs( getprop("controls/flight/elevator-trim") ) < 0.005 )
	setprop("an2/systems/electrical/elev_trim_lamp", 1.0);
	else setprop("an2/systems/electrical/elev_trim_lamp", 0.0);

	if( abs( getprop("controls/flight/rudder-trim") ) < 0.005 )
	setprop("an2/systems/electrical/rudder_trim_lamp", 1.0);
	else setprop("an2/systems/electrical/rudder_trim_lamp", 0.0);
	
# Marker-Beacon procedure
	beacon_handler();



	}
	else {	# stop 
	setprop("/an2/instrumentation/sbess/serviceable", 0);
	setprop("/an2/instrumentation/emi-3k/serviceable", 0);
	setprop("/an2/instrumentation/flaps/serviceable", 0);
	setprop("/an2/controls/switches/uv_light", 0);
	setprop("/controls/switches/landing-light", 0);
	setprop("/controls/switches/taxi-light", 0);
	setprop("/controls/switches/nav-light", 0);
	setprop("/controls/anti-ice/window-heat", 0);
	setprop("/an2/instrumentation/starter/serviceable", 0);
	setprop("/instrumentation/marker-beacon/serviceable", 0);
	setprop("/an2/controls/light/ext-red", 0.0);
	setprop("/an2/controls/light/ext-green", 0.0);
	setprop("/an2/controls/light/ext-blue", 0.0);
	setprop("/an2/controls/light/int-red", 0.0);
	setprop("/an2/controls/light/int-green", 0.0);
	setprop("/an2/controls/light/int-blue", 0.0);
	setprop("an2/systems/electrical/elev_trim_lamp", 0.0);
	setprop("an2/systems/electrical/aileron_trim_lamp", 0.0);
	setprop("an2/systems/electrical/rudder_trim_lamp", 0.0);
	}
interpolate("/an2/instrumentation/electrical/amps", power_consumption, 0.3);
# A-1 procedure
	if( getprop("/an2/systems/electrical/generator_lamp") == 0 )
	{
	interpolate("/an2/instrumentation/a-1/indicated-amps", power_consumption, 0.3);
	}
	else {
# TODO: back current of generator should be here:
	interpolate("/an2/instrumentation/a-1/indicated-amps",0.0, 1);
	}
#update ADF lamps 
an2.adf_lamps();

settimer( update_electric, UPDATE_PERIOD );
} # end electric_handler	

update_electric ();


light_switch = func {
if( arg[0] == 1 )
	{
	setprop("/an2/controls/switches/uv_switch", 1);
	if( bus_27 > 10.0 )
	{ 
		setprop("/an2/controls/switches/uv_light", 1);
		setprop("/an2/controls/light/uv-bright", 0.8);
	}
	else { 
		setprop("/an2/controls/switches/uv_light", 0);
		setprop("/an2/controls/light/uv-bright", 0);
	}
     }
else {
	setprop("/an2/controls/switches/uv_switch", 0);
	setprop("/an2/controls/switches/uv_light", 0);
	setprop("/an2/controls/light/uv-bright", 0);
	}
}

# starter procedure
spinup = func {
setprop("/an2/controls/switches/starter_selector", 1 );
if( getprop("/an2/instrumentation/starter/serviceable") == 1 )
 	{
 	interpolate("/an2/instrumentation/starter/spin", 1, 4);
 	}
}

starter_idle = func {
	interpolate("/an2/instrumentation/starter/spin", 0, 5);
	setprop("/an2/controls/switches/starter_selector", 0 );
	setprop("/controls/engines/engine/starter", 0 );
}

starter_on = func {
if( getprop("/an2/instrumentation/starter/serviceable") == 1 ){
	interpolate("/an2/instrumentation/starter/spin", 0, 3);
	setprop("/an2/controls/switches/starter_selector", 2 );
	if( getprop("/an2/instrumentation/starter/spin") > 0.01 ){
	setprop("/controls/engines/engine/starter", 1 );
	}
	else { setprop("/controls/engines/engine/starter", 0 ); }
	}

}

# Marker-Beacon handler

var beacon_handler = func {
	if( getprop("/instrumentation/marker-beacon/inner") or
		getprop("/instrumentation/marker-beacon/middle") or
		getprop("/instrumentation/marker-beacon/outer") )
		setprop( "/an2/systems/electrical/marker_lamp", 1.0 );
	else setprop( "/an2/systems/electrical/marker_lamp", 0.0 );
}

print("Electrical system started");
