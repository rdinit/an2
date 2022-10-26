
mixtureAxis = func {
    val = cmdarg().getNode("setting").getValue();
    if(size(arg) > 0) { val = -val; }
	setprop("/an2/controls/switches/mixture", (1.1+val*1.1)/2);
}


MIXT_STEP = 0.025;

adjMixture = func {
mixt = getprop("/an2/controls/switches/mixture");
if( mixt == nil ) { return; }
	if( arg[0] == 1 )
	{
		mixt = mixt + MIXT_STEP;
		if( mixt > 1.1 ) { mixt = 1.1; }
	}
	if( arg[0] == -1 )
	{
		mixt = mixt - MIXT_STEP;
		if( mixt < 0.0 ) { mixt = 0.0; }
	}
setprop("/an2/controls/switches/mixture", mixt);
	
}

