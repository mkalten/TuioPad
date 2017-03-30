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

#include "TpSettings.h"

#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>

@implementation TpSettings

#pragma mark ----- Utility -----


- (NSString *)getIpAddress { 
	NSString *address = @"127.0.0.1";
	BOOL connected = [self connectedToNetwork];
	if (!connected) return address;
	
	struct ifaddrs *interfaces = NULL; 
	struct ifaddrs *temp_addr = NULL;
	int success = getifaddrs(&interfaces); 
	if (success == 0)  { 
		// Loop through linked list of interfaces  
		temp_addr = interfaces; 
		while(temp_addr != NULL)  { 
			if(temp_addr->ifa_addr->sa_family == AF_INET)  { 
				// Get NSString from C String  
				address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; 
				// Check if interface is en0 which is the wifi connection on the iPhone  
				NSLog(@"TpSettings::found network device %s",temp_addr->ifa_name);
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] rangeOfString:@"en"].location != NSNotFound) break;
			} 
			temp_addr = temp_addr->ifa_next; 
		} 
	} 
	// Free memory  
	freeifaddrs(interfaces); 
	return address; 
}

- (NSString *)getBroadcastAddress { 
	NSString *address = [self getIpAddress]; 
	NSArray *chunks = [address componentsSeparatedByString: @"."];
	address = [NSString stringWithFormat:@"%@.%@.%@.%i",  [chunks objectAtIndex: 0],[chunks objectAtIndex: 1],[chunks objectAtIndex: 2],255];

	return address; 
}

- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
		NSLog(@"TpSettings::Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	if (!isReachable) NSLog(@"TpSettings::Network is unreachable");
	if (needsConnection) NSLog(@"TpSettings::Network needs connection");
			
	return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark ----- Getters -----

-(id)getDefaultFor:(NSString*)key {
	return [defaults objectForKey:key];
}


-(float)getFloat:(NSString*)key {
	return [[current objectForKey:key] floatValue];
}

-(int)getInt:(NSString*)key {
	return [[current objectForKey:key] intValue];
}

-(NSString*)getString:(NSString*)key {
	return [current objectForKey:key];
}

/*-(const char*)getCString:(NSString*)key {
	return [[current objectForKey:key] UTF8String];
}*/




#pragma mark ----- Setters -----

-(void)setFloat:(float)d forKey:(NSString*)key {
	[current setObject:[NSNumber numberWithFloat:d] forKey:key];
	//[self saveSettings];
}


-(void)setInt:(int)d forKey:(NSString*)key {
	[current setObject:[NSNumber numberWithInt:d] forKey:key];
	//[self saveSettings];
}

-(void)setString:(NSString*)d forKey:(NSString*)key {
	[current setObject:d forKey:key];
	//[self saveSettings];
}

/*
-(void)setCString:(char*)d forKey:(NSString*)key {
	[current setObject:[NSString stringWithCString:d] forKey:key];
	//[self saveSettings];
}
*/



#pragma mark ----- Save & load -----

-(void)loadSettings {
	NSLog(@"TpSettings::loadSettings");
	[current release];
	current = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettings_Key] mutableCopy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



-(void)saveSettings {
	NSLog(@"TpSettings::saveSettings");
	[[NSUserDefaults standardUserDefaults] setObject:current forKey:kSettings_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark ----- System -----

-(void)awakeFromNib {
	NSLog(@"TpSettings::awakeFromNib");
	
	defaults = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				[self getBroadcastAddress], kSetting_HostIP,
				[NSNumber numberWithInt:3333], kSetting_Port,
				[NSNumber numberWithInt:0], kSetting_Packet,
				[NSNumber numberWithInt:0], kSetting_Orientation, 
				[NSNumber numberWithInt:1], kSetting_PeriodicUpdates, 
				[NSNumber numberWithInt:1], kSetting_FullUpdates, 
				nil];

    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:defaults forKey:kSettings_Key]];
    [[NSUserDefaults standardUserDefaults] synchronize];

	[self loadSettings];
	[super awakeFromNib];
}


-(void)dealloc {
	NSLog(@"TpSettings::dealloc");
	[defaults release];
	[current release];
	[super dealloc];
}



@end
