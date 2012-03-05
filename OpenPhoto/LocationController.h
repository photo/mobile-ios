/* 
 * Created by Adriaan Tijsseling
 * http://infinite-sushi.com
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or 
 * send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
 */
 
#import <CoreLocation/CoreLocation.h>

@protocol LocationControllerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation*)location; 
- (void)locationError:(NSError*)error;
@end

@interface LocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	id delegate;
}

@property(nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id <LocationControllerDelegate> delegate;

- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation;

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error;

@end
