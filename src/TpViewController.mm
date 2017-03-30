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

#import <QuartzCore/CoreAnimation.h>

#import "TpViewController.h"
#import "TpTuioSender.h"
#import "TpSettings.h"

@implementation TpViewController

@synthesize settings;
@synthesize tuioSender;
@synthesize isOn;
@synthesize deviceOrientation;

#pragma mark ----- Utility -----

-(bool)connect {
	NSLog(@"TpViewController::connect %@ %@ %li", hostTextField.text, portTextField.text, (long)(packetSwitch.selectedSegmentIndex));
	bool connected = tuioSender->setup([hostTextField.text UTF8String], [portTextField.text intValue], packetSwitch.selectedSegmentIndex, [[settings getIpAddress] UTF8String], blobSwitch.on);
	
	if (connected) {
		if(periodicUpdatesSwitch.on) tuioSender->tuioServer->enablePeriodicMessages();
		else tuioSender->tuioServer->disablePeriodicMessages();
		
		if(fullUpdatesSwitch.on) tuioSender->tuioServer->enableFullUpdate();
		else tuioSender->tuioServer->disableFullUpdate();
		
		return true;
	} else return false;
}

-(void)disconnect {
	tuioSender->close();
	[self checkNetwork];
}

#pragma mark ----- Control events -----

-(IBAction) orientControlChanged:(id)sender {
		
	switch(orientControl.selectedSegmentIndex) {
		case 0:	
			deviceOrientation = [[UIDevice currentDevice] orientation];
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
			break;

		case 1:
			deviceOrientation = UIDeviceOrientationLandscapeRight;
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			break;
			
		case 2:
			deviceOrientation = UIDeviceOrientationPortrait;
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			break;
	}

}

-(IBAction) textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

-(IBAction) backgroundPressed:(id)sender {
	[hostTextField resignFirstResponder];
	[portTextField resignFirstResponder];
}

-(IBAction) connectPressed:(id)sender {
	
	if (!network) return;
	
	[settings setInt:packetSwitch.selectedSegmentIndex forKey:kSetting_Packet];
	if (packetSwitch.selectedSegmentIndex<2) [settings setString:hostTextField.text forKey:kSetting_HostIP];
	[settings setInt:[portTextField.text intValue] forKey:kSetting_Port];
	[settings setInt:orientControl.selectedSegmentIndex forKey:kSetting_Orientation];
	[settings setInt:periodicUpdatesSwitch.on forKey:kSetting_PeriodicUpdates];
	[settings setInt:fullUpdatesSwitch.on forKey:kSetting_FullUpdates];
	[settings setInt:blobSwitch.on forKey:kSetting_BlobMessages];
	[settings saveSettings];
	
	if ([self connect])
		[self close];
	else {
		NSString *status = [NSString stringWithFormat:@"could not connect to %@:%@", hostTextField.text, portTextField.text];
		statusLabel.textColor = [UIColor redColor];
		statusLabel.text = status;
	}
}

-(IBAction) packetSelected:(id)sender {
	if (packetSwitch.selectedSegmentIndex==2) {
		NSLog(@"TpViewController::set %@", hostTextField.text);
		[settings setString:hostTextField.text forKey:kSetting_HostIP];
		hostTextField.text = @"incoming connection";
		hostTextField.textColor = [UIColor grayColor];
		//hostLabel.text = @"server";
		hostTextField.enabled = NO;
		hostButton.enabled = NO;
	} else {
		hostTextField.text = [settings getString:kSetting_HostIP];
		hostTextField.enabled = YES;
		hostButton.enabled = YES;
		hostTextField.textColor = [UIColor blackColor];
		//hostLabel.text = @"client";
	}
}

-(IBAction) detectHostPressed:(id)sender {
	if (packetSwitch.selectedSegmentIndex<2)
		hostTextField.text = [settings getDefaultFor:kSetting_HostIP];
}

-(IBAction) defaultPortPressed:(id)sender {
	packetSwitch.selectedSegmentIndex = 0;
	portTextField.text = [NSString stringWithFormat:@"%i", [[settings getDefaultFor:kSetting_Port] intValue]];
}

#pragma mark ----- Open & close -----

#define ANIMATION_TIME		0.5f
#define ANIMATION_CURVE		UIViewAnimationCurveEaseIn

-(void)open:(bool)animate {
	NSLog(@"TpViewController::open %i", animate);
		
	if(self.view.superview == nil) {
		if(animate) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:ANIMATION_TIME];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
			[UIView setAnimationCurve: ANIMATION_CURVE];
			[self viewWillAppear:YES];
			[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
			[self viewDidAppear:YES];
			[UIView commitAnimations];
		} else {
			[[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
		}
		
			}
	
	// suspend update loop while UI is visible
	isOn = true;
	[self disconnect];
	ofSetFrameRate(0);
}


-(void) close {
	NSLog(@"TpViewController::close");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ANIMATION_TIME];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
	[UIView setAnimationCurve: ANIMATION_CURVE];
	[self viewWillDisappear:YES];
	[self.view removeFromSuperview];
	[self viewDidDisappear:YES];
	[UIView commitAnimations];
	
	ofSetFrameRate(60);			// restore update loop	
	isOn = false;
}

-(IBAction) exitPressed:(id)sender {
	
	[settings setInt:packetSwitch.selectedSegmentIndex forKey:kSetting_Packet];
	if (packetSwitch.selectedSegmentIndex<2) [settings setString:hostTextField.text forKey:kSetting_HostIP];
	[settings setInt:[portTextField.text intValue] forKey:kSetting_Port];
	[settings setInt:orientControl.selectedSegmentIndex forKey:kSetting_Orientation];
	[settings setInt:periodicUpdatesSwitch.on forKey:kSetting_PeriodicUpdates];
	[settings setInt:fullUpdatesSwitch.on forKey:kSetting_FullUpdates];
	[settings setInt:blobSwitch.on forKey:kSetting_BlobMessages];
	[settings saveSettings];
	exit(0);
}


#pragma mark ----- Default events -----

-(void)viewDidLoad {
	NSLog(@"TpViewController::viewDidLoad");
	[super viewDidLoad];
	
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	
	tuioSender = new TpTuioSender();
	
	NSString *HostIP = [settings getString:kSetting_HostIP];
	packetSwitch.selectedSegmentIndex		= [settings getInt:kSetting_Packet];
	if (packetSwitch.selectedSegmentIndex<2)
		hostTextField.text					= [settings getString:kSetting_HostIP];	
	else {
		hostTextField.text = @"incoming connection";
		hostTextField.textColor = [UIColor grayColor];
		hostTextField.enabled = NO;
		hostButton.enabled = NO;
	}
	[settings setString:HostIP forKey:kSetting_HostIP];
	portTextField.text						= [NSString stringWithFormat:@"%i", [settings getInt:kSetting_Port]];
	orientControl.selectedSegmentIndex		= [settings getInt:kSetting_Orientation];
	periodicUpdatesSwitch.on				= [settings getInt:kSetting_PeriodicUpdates];
	fullUpdatesSwitch.on					= [settings getInt:kSetting_FullUpdates];
	blobSwitch.on							= [settings getInt:kSetting_BlobMessages];
	
	[self.navigationController pushViewController:self animated:YES];
	
	[self orientControlChanged:nil];
	[self checkNetwork];

	
//	[self connect];

}

- (void) checkNetwork {
	
	network = [settings connectedToNetwork];
	if (network) {
		NSString *address = [settings getIpAddress];
		
		NSString *status = [NSString stringWithFormat:@"your network address is %@", address];
		statusLabel.textColor = [UIColor whiteColor];
		statusLabel.text = status;
		[startButton setEnabled: YES];
		NSLog(@"TpViewController: %@", status);
	} else {
		statusLabel.textColor = [UIColor redColor];
		statusLabel.text = @"no active network connection available!";
		[startButton setEnabled: NO];
		//NSLog(@"TpViewController: no active network connection available!");
	}
}

- (void) didRotate:(NSNotification *)notification {	
	int o = [[UIDevice currentDevice] orientation];
	if(o != UIDeviceOrientationUnknown && o != UIDeviceOrientationFaceUp && o != UIDeviceOrientationFaceDown) {
		deviceOrientation = o;
	} else if([settings getInt:kSetting_Orientation] == 0) {
		deviceOrientation = UIDeviceOrientationLandscapeRight;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	delete tuioSender;
    [super dealloc];
}

@end
