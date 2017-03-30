/*
 TuioPad http://www.tuio.org/
 An Open Source TUIO App for iOS based on OpenFrameworks
 (c) 2010-2017 by Mehmet Akten <memo@memo.tv> and Martin Kaltenbrunner <martin@tuio.org>
 
 TuioPad is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TuioPad is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TuioPad.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "TuioPad.h"

int main(int argc, char *argv[]) {
	ofiOSWindowSettings settings;
	settings.enableRetina = true; // enables retina resolution if the device supports it.
	settings.enableDepth = false; // enables depth buffer for 3d drawing.
	settings.enableAntiAliasing = true; // enables anti-aliasing which smooths out graphics on the screen.
	settings.numOfAntiAliasingSamples = 4; // number of samples used for anti-aliasing.
	settings.enableHardwareOrientation = true; // enables native view orientation.
	settings.enableHardwareOrientationAnimation = true; // enables native orientation changes to be animated.
	settings.glesVersion = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, etc.
	
	ofCreateWindow(settings);
	return ofRunApp(new TuioPad);
}
