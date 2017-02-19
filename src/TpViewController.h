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

#pragma once

#import <UIKit/UIKit.h>

class TpTuioSender;
@class TpSettings;

@interface TpViewController : UIViewController {

	IBOutlet UITextField		*hostTextField;
	IBOutlet UITextField		*portTextField;
	IBOutlet UISegmentedControl	*orientControl;
	IBOutlet UISwitch			*periodicUpdatesSwitch;
	IBOutlet UISwitch			*fullUpdatesSwitch;
	IBOutlet UISwitch			*blobSwitch;
	IBOutlet UILabel			*statusLabel;
	//IBOutlet UILabel			*hostLabel;
	IBOutlet UIButton			*startButton;
	IBOutlet UIButton			*exitButton;
	IBOutlet UIButton			*hostButton;
	IBOutlet UISegmentedControl	*packetSwitch;

	IBOutlet TpSettings			*settings;
	TpTuioSender				*tuioSender;

	bool						isOn;
	bool						network;
	int							deviceOrientation;
}

@property (readonly, nonatomic)		TpTuioSender		*tuioSender;
@property (readonly, nonatomic)		TpSettings			*settings;
@property (readonly, nonatomic)		bool				isOn;
@property (readonly, nonatomic)		int					deviceOrientation;


-(void) open:(bool)animate;
-(IBAction) close;

-(IBAction) textFieldDoneEditing:(id)sender;
-(IBAction) detectHostPressed:(id)sender;
-(IBAction) defaultPortPressed:(id)sender;
-(IBAction) orientControlChanged:(id)sender;
-(IBAction) backgroundPressed:(id)sender;
-(IBAction) connectPressed:(id)sender;
-(IBAction) exitPressed:(id)sender;
-(IBAction) packetSelected:(id)sender;

-(bool) connect;
-(void) disconnect;
-(void) checkNetwork;

@end
