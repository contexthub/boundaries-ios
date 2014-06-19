//
//  GFGeofence.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofence.h"

@implementation GFGeofence

+ (NSDictionary *)dictionaryForGeofence:(GFGeofence *)geofence {
    NSDictionary *geofenceDict = @{@"id":[NSNumber numberWithInt:geofence.geofenceID], @"name":geofence.name, @"latitude":[NSNumber numberWithDouble:geofence.center.latitude], @"longitude":[NSNumber numberWithDouble:geofence.center.longitude], @"radius":[NSNumber numberWithDouble:geofence.radius], @"tags":geofence.tags};
    
    return geofenceDict;
}

@end
