//
//  CLCircularRegion+ContextHub.m
//  Concierge
//
//  Created by Jeff Kibuule on 7/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "CLCircularRegion+ContextHub.h"

NSString * const CCHEventNameKeyPath = @"event.name";
NSString * const CCHEventStateKeyPath = @"event.data.state";

NSString * const CCHGeofenceInEvent = @"geofence_in";
NSString * const CCHGeofenceOutEvent = @"geofence_out";
NSString * const CCHGeofenceEventKeyPath = @"event.data.fence";
NSString * const CCHGeofenceEventIDKeyPath = @"event.data.fence.id";
NSString * const CCHGeofenceEventLatitudeKeyPath = @"event.data.fence.latitude";
NSString * const CCHGeofenceEventLongitudeKeyPath = @"event.data.fence.longitude";
NSString * const CCHGeofenceEventRadiusKeyPath = @"event.data.fence.radius";

@implementation CLCircularRegion (ContextHub)

// Creates a geofence from a notification object's data
+ (instancetype)geofenceFromNotification:(NSNotification *)notification {
    NSDictionary *event = notification.object;
    
    // Make sure this event is a geofence event before trying to create a geofence
    NSDictionary *geofenceEvent = [event valueForKeyPath:CCHGeofenceEventKeyPath];
    
    if (!geofenceEvent) {
        return nil;
    }
    
    // Grab latitude and longitude from event
    CLLocationDegrees latitude = [[event valueForKeyPath:CCHGeofenceEventLatitudeKeyPath] doubleValue];
    CLLocationDegrees longitude = [[event valueForKeyPath:CCHGeofenceEventLongitudeKeyPath] doubleValue];
    CLLocationDistance radius = [[event valueForKeyPath:CCHGeofenceEventRadiusKeyPath] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLCircularRegion *geofence = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:@""];
    
    return geofence;
}

// Tests to see if two geofences are the same based on their latitude, longitude, and radius
- (BOOL)isSameGeofence:(CLCircularRegion *)otherGeofence {
    
    if ((self.center.latitude == otherGeofence.center.latitude) && (self.center.longitude == otherGeofence.center.longitude) && (self.radius == otherGeofence.radius)) {
        return true;
    }
    
    return false;
}

// Determines what state a geofence is in (in, out) based on the notification trigged by a geofence
- (BOOL)isSameGeofenceFromNotification:(NSNotification *)notification withEvent:(NSString *)geofenceEvent {
    CLCircularRegion *notificationGeofence = [CLCircularRegion geofenceFromNotification:notification];

    // Event isn't a geofence event
    if (!notificationGeofence) {
        return false;
    }
    
    // Event isn't from the same geofence this class instance is
    if (![self isSameGeofence:notificationGeofence]) {
        return false;
    }
    
    // Determine if the event was from a @"geofence_in" or @"geofence_out"
    NSDictionary *event = notification.object;
    NSString *eventName = [event valueForKeyPath:CCHEventNameKeyPath];
    
    if ([geofenceEvent isEqualToString:CCHGeofenceInEvent]) {
        return [eventName isEqualToString:CCHGeofenceInEvent];
    } else if ([geofenceEvent isEqualToString:CCHGeofenceOutEvent]) {
        return [eventName isEqualToString:CCHGeofenceOutEvent];
    }
    
    return false;
}

#pragma mark - Helper methods

- (NSString *)description {
    return [NSString stringWithFormat:@"Geofence: %@, Latitude: %.4f, Longitude: %.4f, Radius: %.4f meters", self.identifier, self.center.latitude, self.center.longitude, self.radius];
}

@end