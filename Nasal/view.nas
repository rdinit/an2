#
#
#
# An-2 for FlightGear
#
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# may 2010
#
# Custom views 
#

var forceView = func{
	var n = arg[0];
	var offset = getprop("/an2/mod-views/view-offset");
	if( n > 0 ) n = n + offset;
	setprop("sim/current-view/view-number", n);
	gui.popupTip(views[n].getNode("name").getValue());
};

var modView  = func{
	var n = getprop("sim/current-view/view-number");
	var offset = getprop("/an2/mod-views/view-offset");
	if( n == nil ) n = 0;
	if( n > 0 ) n = n - offset;
	if( n < 0 ) return;
	var mode = arg[0];
	if( mode == nil ) mode = 0;
	# get mod view coordinates	
	var mv = props.globals.getNode("an2/mod-views").getChildren("mod-view");
	if( mode == 1 )
	{
	setprop("an2/mod-views/mod", 1 );
# save current position
	setprop("an2/var/save-x", getprop("sim/current-view/x-offset-m") );
	setprop("an2/var/save-y", getprop("sim/current-view/y-offset-m") );
	setprop("an2/var/save-z", getprop("sim/current-view/z-offset-m") );
	setprop("an2/var/save-fov", getprop("sim/current-view/field-of-view") );
	setprop("an2/var/save-pitch", getprop("sim/current-view/pitch-offset-deg") );
	setprop("an2/var/save-heading",getprop("sim/current-view/heading-offset-deg"));
	setprop("an2/var/save-roll",getprop("sim/current-view/roll-offset-deg"));
# set modified view	
	setprop("sim/current-view/x-offset-m", mv[n].getNode("x-offset-m").getValue() );
	setprop("sim/current-view/y-offset-m", mv[n].getNode("y-offset-m").getValue() );
	setprop("sim/current-view/z-offset-m", mv[n].getNode("z-offset-m").getValue() );
	setprop("sim/current-view/field-of-view",
		mv[n].getNode("field-of-view").getValue() );
	setprop("sim/current-view/pitch-offset-deg", 
		mv[n].getNode("pitch-offset-deg").getValue() );
	setprop("sim/current-view/heading-offset-deg", 
		mv[n].getNode("heading-offset-deg").getValue() );
	setprop("sim/current-view/roll-offset-deg", 
		mv[n].getNode("roll-offset-deg").getValue() );

	return;
	}
	else
	{
	setprop("an2/mod-views/mod", 0 );
				
	setprop("sim/current-view/x-offset-m", getprop("an2/var/save-x") );
	setprop("sim/current-view/y-offset-m", getprop("an2/var/save-y") );
	setprop("sim/current-view/z-offset-m", getprop("an2/var/save-z") );
	setprop("sim/current-view/field-of-view", getprop("an2/var/save-fov") );
	setprop("sim/current-view/pitch-offset-deg", getprop("an2/var/save-pitch") );
	setprop("sim/current-view/heading-offset-deg",getprop("an2/var/save-heading"));
	setprop("sim/current-view/roll-offset-deg",getprop("an2/var/save-roll"));
	}
};


var init_offset = func{
setprop("/an2/mod-views/nav-view", 0);
setprop("/an2/mod-views/copilot-view", 0);
setprop("/an2/mod-views/view-offset", 7 );

}

init_offset();


print("View registered");