//
//  GFGeofence.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofence.h"

@interface GFGeofence()
@property (nonatomic, strong) NSMutableDictionary *geofenceDict;
@end

@implementation GFGeofence

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

- (NSDictionary *)dictionaryForGeofence {
    [self.geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.center.latitude] forKey:@"latitude"];
    [self.geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.center.longitude] forKey:@"longitude"];
    [self.geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.radius] forKey:@"radius"];
    [self.geofenceDict setValue:self.name forKey:@"name"];
    
    [self.geofenceDict setValue:self.tags forKey:@"tags"];
    
    return self.geofenceDict;
}

@end