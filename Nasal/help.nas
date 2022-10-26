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

var help_win = screen.window.new( 0, 0, 1, 3 );
help_win.fg = [0,1,1,1];


var altimeter = func {
   var press_inhg = getprop("/instrumentation/altimeter/setting-inhg");
   if(  press_inhg == nil ) press_inhg = 0.0;
help_win.write(sprintf("Baro alt pressure: %.0f mmhg %.2f inhg ", press_inhg*25.4, press_inhg) );
}

setlistener( "/instrumentation/altimeter/setting-inhg", altimeter );

var messenger = func{
help_win.write(arg[0]);
}
print("Help subsystem started");
