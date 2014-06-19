//
//  GFGeofenceStore.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofenceStore.h"

#import "GFGeofence.h"

NSString const *geofenceTagName = @"geofences";

@interface GFGeofenceStore ()

@property (nonatomic, readwrite, strong) NSMutableArray *geofenceArray;

@end

@implementation GFGeofenceStore

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static GFGeofenceStore *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GFGeofenceStore alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _geofenceArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)syncGeofences {
    [[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[geofenceTagName] location:nil completionHandler:^(NSArray *geofences, NSError *error) {
        if (!error) {
            NSLog(@"GF: Succesfully synced %d new geofences from ContextHub", self.geofenceArray.count - geofences.count);
        } else {
            NSLog(@"GF: Could not sync geofences with ContextHub");
        }
    }];
}

- (void)addGeofence:(GFGeofence *)geofence {
    // Add geofence to our array
    [self.geofenceArray addObject:geofence];
    
    // Create it in ContextHub
    [[CCHGeofenceService sharedInstance] createGeofence:(CLCircularRegion *)geofence tags:@[geofenceTagName] completionHandler:^(NSDictionary *createdGeofence, NSError *error) {
        if (!error) {
            geofence.geofenceID = (NSInteger)createdGeofence[@"id"];
            geofence.tags = createdGeofence[@"tags"];
            NSLog(@"GF: Successfully created geofence %@ on ContextHub", geofence.name);
        } else {
            NSLog(@"GF: Could not create geofence %@ on ContextHub", geofence.name);
        }
    }];
}


- (void)removeGeofence:(GFGeofence *)geofence {
    // Remove geofence from our array
    if ([self.geofenceArray containsObject:geofence]) {
        [self.geofenceArray removeObject:geofence];
    }
    
    NSDictionary *geofenceDict = [GFGeofence dictionaryForGeofence:geofence];
    // Remove geofence from ContextHub
    [[CCHGeofenceService sharedInstance] deleteGeofence:geofenceDict completionHandler:^(NSError *error) {
        if (!error) {
            NSLog(@"GF: Successfully deleted geofence %@ on ContextHub", geofence.name);
        } else {
            NSLog(@"GF: Could not delete geofence %@ on ContextHub", geofence.name);
        }
    }];
}

@end
