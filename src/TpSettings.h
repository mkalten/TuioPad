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
#import <SystemConfiguration/SystemConfiguration.h>
#include <ifaddrs.h>

#define kSetting_HostIP				@"HostIP"
#define kSetting_Port				@"Port"
#define kSetting_Packet				@"Packet"
#define kSetting_Orientation		@"Orientation"
#define kSetting_PeriodicUpdates	@"PeriodicUpdates"
#define kSetting_FullUpdates		@"FullUpdates"
#define kSetting_BlobMessages		@"BlobMessages"

#define kSettings_Key				@"TuioPadSettings"


@interface TpSettings : NSObject {
	NSMutableDictionary* current;
	NSMutableDictionary* defaults;
}

-(void)loadSettings;
-(void)saveSettings;

-(id)getDefaultFor:(NSString*)key;

-(float)getFloat:(NSString*)key;
-(int)getInt:(NSString*)key;
//-(const char*)getCString:(NSString*)key;
-(NSString*)getString:(NSString*)key;

-(void)setFloat:(float)d forKey:(NSString*)key;
-(void)setInt:(int)d forKey:(NSString*)key;
//-(void)setCString:(char*)d forKey:(NSString*)key;
-(void)setString:(NSString*)d forKey:(NSString*)key;

-(BOOL)connectedToNetwork;
-(NSString *)getBroadcastAddress;
-(NSString *)getIpAddress;

@end
