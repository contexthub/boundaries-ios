//
//  GFGeofenceStore.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofenceStore.h"
#import "GFGeofence.h"
#import <ContextHub/ContextHub.h>

NSString const *GFGeofenceSyncCompletedNotification = @"GFGeofenceSyncCompletedNotification";

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

// Synchronizes geofences in ContextHub
- (void)syncGeofences {
    [[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[GFGeofenceTag] location:nil radius:1000 completionHandler:^(NSArray *geofences, NSError *error) {
        if (!error) {
            NSLog(@"GF: Succesfully synced %d new geofences from ContextHub", geofences.count - self.geofenceArray.count);
            
            [self.geofenceArray removeAllObjects];
            
            for (NSDictionary *geofenceDict in geofences) {
                GFGeofence *geofence = [[GFGeofence alloc] initFromDictionary:geofenceDict];
                [self.geofenceArray addObject:geofence];
            }
            
            // Post notification that sync is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)GFGeofenceSyncCompletedNotification object:nil];
        } else {
            NSLog(@"GF: Could not sync geofences with ContextHub");
        }
    }];
}

// Creates a geofence in ContextHub and keeps a copy in our store
- (void)addGeofence:(GFGeofence *)fence {
    // Add geofence to our array
    [self.geofenceArray addObject:fence];
    
    // Create it in ContextHub
    __block GFGeofence *__fence = fence;
    [[CCHGeofenceService sharedInstance] createGeofenceWithCenter:fence.center radius:fence.radius name:fence.identifier tags:@[GFGeofenceTag] completionHandler:^(NSDictionary *geofence, NSError *error) {
        
        if (!error) {
            __fence.geofenceID = (NSInteger)geofence[@"id"];
            __fence.tags = geofence[@"tags"];
            
            // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
            [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                
                if (!error) {
                    NSLog(@"GF: Successfully created geofence %@ on ContextHub", fence.identifier);
                } else {
                    NSLog(@"GF: Could not synchronize creation of geofence %@ on ContextHub", fence.identifier);
                }
            }];
        } else {
            NSLog(@"GF: Could not create geofence %@ on ContextHub", fence.identifier);
        }
    }];
}

// Delete a geofence in ContextHub and remove it from our store
- (void)removeGeofence:(GFGeofence *)geofence {
    // Remove geofence from our array
    if ([self.geofenceArray containsObject:geofence]) {
        [self.geofenceArray removeObject:geofence];
    }
    
    NSDictionary *geofenceDict = [GFGeofence dictionaryForGeofence:geofence];
    // Remove geofence from ContextHub
    [[CCHGeofenceService sharedInstance] deleteGeofence:geofenceDict completionHandler:^(NSError *error) {
        if (!error) {
            
            // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
            [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                
                if (!error) {
                    NSLog(@"GF: Successfully deleted geofence %@ on ContextHub", geofence.identifier);
                } else {
                    NSLog(@"GF: Could not synchronize deletion of geofence %@ on ContextHub", geofence.identifier);
                }
            }];
        } else {
            NSLog(@"GF: Could not delete geofence %@ on ContextHub", geofence.identifier);
        }
    }];
}

@end