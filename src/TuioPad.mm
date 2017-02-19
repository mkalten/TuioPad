/*
 TuioPad http://www.tuio.org/
 An Open Source TUIO App for iOS based on OpenFrameworks
 (c) 2010-2016 by Mehmet Akten <memo@memo.tv> and Martin Kaltenbrunner <martin@tuio.org>
 
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

#include "ofxAccelerometer.h"
#include "ofxiPhone.h"

#include "TpViewController.h"
#include "TpFingerDrawer.h"
#include "TpTuioSender.h"

#pragma mark Variables

TpViewController	*viewController;
TpFingerDrawer		fingerDrawer[OF_MAX_TOUCHES];

ofImage				imageUp;
ofPoint				rotatedTouchPosition;
ofPoint				restAccel;

#pragma mark App Loop Callbacks

void TuioPad::setup() {
	ofSetFrameRate(60);
	ofBackground(255, 255, 255);
	ofSetBackgroundAuto(true);
	
	ofxAccelerometer.setup();
	ofLoadImage(imageUp, "ThisWayUp.jpg");
	imageUp.update();
	
	NSString *nibName = @"TuioPhone";
	if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) {
		NSLog(@"TuioPad: got iPad");
		nibName = @"TuioPad";
	}
	
	viewController	= [[TpViewController alloc] initWithNibName:nibName bundle:nil];
	
	// open UI, not animated
	[viewController open:false];
}

void TuioPad::update() {

	if ([viewController isOn]) return;
	
	// if device is shaken hard, open UI, animated
	ofPoint &acc = ofxAccelerometer.getForce();
	float shake = acc.x*acc.x + acc.y*acc.y + acc.z*acc.z;

	if(shake > 4) {
		[viewController open:true];
		return;
	}
		
	[viewController tuioSender]->update();
}

void TuioPad::draw() {

	if ([viewController isOn]) return;
	
	glPushMatrix();
	glTranslatef(ofGetWidth()/2, ofGetHeight()/2, 0);
	static float currentUpRot = -90;
	float targetUpRot;
	switch([viewController deviceOrientation]) {
		case UIDeviceOrientationPortrait:
			targetUpRot = 0;
			break;
			
		case UIDeviceOrientationPortraitUpsideDown:
			targetUpRot = 180;
			break;
			
		default:
		case UIDeviceOrientationLandscapeLeft:
			targetUpRot = 90;
			break;
			
		case UIDeviceOrientationLandscapeRight:
			targetUpRot = -90;
			break;
			
	}
	currentUpRot += (targetUpRot - currentUpRot) * 0.1f;
	glRotatef(currentUpRot, 0, 0, 1);
	glColor4f(1, 1, 1, 1);
	ofSetRectMode(OF_RECTMODE_CENTER);
	imageUp.draw(0, 0);
	glPopMatrix();
	
	for(int i=0; i<OF_MAX_TOUCHES; i++) fingerDrawer[i].draw();	
 
}

void TuioPad::exit() {
	[viewController release];
}

#pragma mark Touch Callbacks

void rotXY(float x, float y) {
	switch([viewController deviceOrientation]) {
		case UIDeviceOrientationPortrait:
			rotatedTouchPosition.x = x/ofGetWidth();
			rotatedTouchPosition.y = y/ofGetHeight();
			break;
			
		case UIDeviceOrientationPortraitUpsideDown:
			rotatedTouchPosition.x = 1 - x/ofGetWidth();
			rotatedTouchPosition.y = 1 - y/ofGetHeight();
			break;
			
		case UIDeviceOrientationLandscapeRight:
			rotatedTouchPosition.x = 1 - y/ofGetHeight();
			rotatedTouchPosition.y = x/ofGetWidth();
			break;
			
		default:
		case UIDeviceOrientationLandscapeLeft:
			rotatedTouchPosition.x = y/ofGetHeight();
			rotatedTouchPosition.y = 1.0f - x/ofGetWidth();
			break;
	}
}

void TuioPad::touchDown(ofTouchEventArgs & touch){
	fingerDrawer[touch.id].touchDown(touch.x, touch.y);
	rotXY(touch.x, touch.y);
	[viewController tuioSender]->touchPressed(touch.id, rotatedTouchPosition.x, rotatedTouchPosition.y, touch.width, touch.height, touch.angle);
}

void TuioPad::touchMoved(ofTouchEventArgs & touch){
	fingerDrawer[touch.id].touchMoved(touch.x, touch.y);
	rotXY(touch.x, touch.y);
	[viewController tuioSender]->touchDragged(touch.id, rotatedTouchPosition.x, rotatedTouchPosition.y, touch.width, touch.height, touch.angle);
}

void TuioPad::touchUp(ofTouchEventArgs & touch){
	fingerDrawer[touch.id].touchUp();
	rotXY(touch.x, touch.y);
	[viewController tuioSender]->touchReleased(touch.id, rotatedTouchPosition.x, rotatedTouchPosition.y, touch.width, touch.height, touch.angle);
}

void TuioPad::touchDoubleTap(ofTouchEventArgs & touch) {}
void TuioPad::touchCancelled(ofTouchEventArgs & touch) {}
void TuioPad::lostFocus() {}
void TuioPad::gotFocus() {}
void TuioPad::gotMemoryWarning() {}
//void TuioPad::deviceOrientationChanged(int newOrientation) {}

