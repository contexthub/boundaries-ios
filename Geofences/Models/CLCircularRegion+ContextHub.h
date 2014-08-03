//
//  CLCircularRegion+ContextHub.h
//  Concierge
//
//  Created by Jeff Kibuule on 7/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

extern NSString * const CCHEventNameKeyPath;
extern NSString * const CCHEventStateKeyPath;

extern NSString * const CCHGeofenceInEvent;
extern NSString * const CCHGeofenceOutEvent;
extern NSString * const CCHGeofenceEventKeyPath;
extern NSString * const CCHGeofenceEventIDKeyPath;
extern NSString * const CCHGeofenceEventLatitudeKeyPath;
extern NSString * const CCHGeofenceEventLongitudeKeyPath;
extern NSString * const CCHGeofenceEventRadiusKeyPath;

/**
 The ContextHub category extensions to CLCircularRegion allow for easy retrieval and comparison of geofences generated from CCHSensorPipeline events
 */
@interface CLCircularRegion (ContextHub)

/**
 Create a CLCircularRegion object from a NSNotification object made when ContextHub has an event triggered from a geofence
 @param notification notification object containing information about the geofence which triggered an event
 */
+ (instancetype)geofenceFromNotification:(NSNotification *)notification;

/**
 Determines whether this CLCiruclarRegion and another CLCiruclarRegion are the same based on latitude, longitude, and radius
 @param otherGeofence geofence to be compared against
 */
- (BOOL)isSameGeofence:(CLCircularRegion *)otherGeofence;

/**
 Determines what state a geofence is in (in, out) based on the notification trigged by a geofence
 @param notification notification object containing information about the geofence which triggered an event
 @param geofenceEvent event name for the beacon (kBeaconInEvent, kBeaconOutEvent, kBeaconChangedEvent)
 */
- (BOOL)isSameGeofenceFromNotification:(NSNotification *)notification withEvent:(NSString *)geofenceEvent;

@end