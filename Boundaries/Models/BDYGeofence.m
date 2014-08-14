//
//  BDYGeofence.m
//  Boundaries
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "BDYGeofence.h"

@interface BDYGeofence ()
@property (nonatomic, strong) NSMutableDictionary *geofenceDict;
@end

@implementation BDYGeofence

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    // Pull the data out of the dictionary to create a CLCircularRegion
    CLLocationDegrees lat = [dictionary[@"latitude"] doubleValue];
    CLLocationDegrees lng = [dictionary[@"longitude"] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
    CLLocationDistance radius = [dictionary[@"radius"] doubleValue];
    NSString *identifier = dictionary[@"name"];
    self = [super initWithCenter:center radius:radius identifier:identifier];
    
    if (self) {
        _geofenceID = [NSString stringWithFormat:@"%ld", (long)[dictionary[@"id"] integerValue]];
        _name = dictionary[@"name"];
        _tags = dictionary[@"tags"];
        
        // Make a mutable copy which dictionaryForGeofence will update
        _geofenceDict = [dictionary mutableCopy];
    }
    
    return self;
}

@end