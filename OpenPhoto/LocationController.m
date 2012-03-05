/* 
 * Created by Adriaan Tijsseling
 * http://infinite-sushi.com
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or 
 * send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
 */
 
#import "LocationController.h"

@implementation LocationController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	if ((self = [super init])) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // send loc updates to myself
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		locationManager.distanceFilter = 500;
	}
	return self;
}

- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation {
	[self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error {
	[self.delegate locationError:error];
}

- (void)dealloc {
	[self.locationManager release];
    [super dealloc];
}

@end
