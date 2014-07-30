//
//  GFGeofence.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofence.h"

@implementation GFGeofence

- (instancetype)initFromDictionary:(NSDictionary *)geofenceDict {
    // Pull the data out of the dictionary to create a CLCircularRegion
    CLLocationDegrees lat = [geofenceDict[@"latitude"] doubleValue];
    CLLocationDegrees lng = [geofenceDict[@"longitude"] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
    CLLocationDistance radius = [geofenceDict[@"radius"] doubleValue];
    NSString *identifier = geofenceDict[@"name"];
    self = [super initWithCenter:center radius:radius identifier:identifier];
    
    if (self) {
        _geofenceID = [geofenceDict[@"id"] integerValue];
        _tags = geofenceDict[@"tags"];
    }
    
    return self;
}

+ (NSDictionary *)dictionaryForGeofence:(GFGeofence *)geofence {
    NSDictionary *geofenceDict = @{@"id":[NSNumber numberWithInt:geofence.geofenceID], @"name":geofence.identifier, @"latitude":[NSNumber numberWithDouble:geofence.center.latitude], @"longitude":[NSNumber numberWithDouble:geofence.center.longitude], @"radius":[NSNumber numberWithDouble:geofence.radius], @"tags":geofence.tags};
    
    return geofenceDict;
}

@end
