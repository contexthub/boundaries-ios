//
//  GFGeofenceStore.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFGeofenceStore.h"

#import "GFGeofence.h"

NSString const *GFGeofenceSyncCompletedNotification = @"GFGeofenceSyncCompletedNotification";

@interface GFGeofenceStore ()
@property (nonatomic, readwrite, strong) NSMutableArray *geofences;
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
        _geofences = [NSMutableArray array];
    }
    
    return self;
}

// Creates a geofence in ContextHub and keeps a copy in our store
- (void)createGeofenceWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius name:(NSString *)name completionHandler:(void (^)(GFGeofence *geofence, NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHGeofenceService sharedInstance] createGeofenceWithCenter:center radius:radius name:name tags:@[GFGeofenceTag] completionHandler:^(NSDictionary *geofence, NSError *error) {
            
            if (!error) {
                GFGeofence *createdGeofence = [[GFGeofence alloc] initWithDictionary:geofence];
                [self.geofences addObject:createdGeofence];
                
                // Synchronize newly created geofence with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"GF: Successfully created and synchronized geofence %@ on ContextHub", createdGeofence.name);
                        completionHandler (createdGeofence, nil);
                    } else {
                        NSLog(@"GF: Could not synchronize creation of geofence %@ on ContextHub", createdGeofence.name);
                        completionHandler (nil, error);
                    }
                }];
            } else {
                NSLog(@"GF: Could not create geofence %@ on ContextHub", name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Synchronizes geofences from ContextHub
- (void)syncGeofences {
    // If you have a location and particular radius of geofences you are interested in, you can fill those parameters to get back a smaller data set
    [[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[GFGeofenceTag] location:nil radius:0 completionHandler:^(NSArray *geofences, NSError *error) {
        
        if (!error) {
            NSLog(@"GF: Succesfully synced %d new geofences from ContextHub", geofences.count - self.geofences.count);
            
            [self.geofences removeAllObjects];
            
            for (NSDictionary *geofenceDict in geofences) {
                GFGeofence *geofence = [[GFGeofence alloc] initWithDictionary:geofenceDict];
                [self.geofences addObject:geofence];
            }
            
            // Post notification that sync is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)GFGeofenceSyncCompletedNotification object:nil];
        } else {
            NSLog(@"GF: Could not sync geofences with ContextHub");
        }
    }];
}

// Find a geofence with a specific ID in our geofence store if it exists
- (GFGeofence *)findGeofenceInStoreWithID:(NSString *)geofenceID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.geofenceID like %@", geofenceID];
    NSArray *filteredGeofences = [self.geofences filteredArrayUsingPredicate:predicate];
    
    if ([filteredGeofences count] > 0) {
        GFGeofence *foundGeofence = filteredGeofences[0];
        
        return foundGeofence;
    }
    
    return nil;
}

// Updates a geofence in ContextHub and in our store
- (void)updateGeofence:(GFGeofence *)geofence completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHGeofenceService sharedInstance] updateGeofence:[geofence dictionaryForGeofence] completionHandler:^(NSError *error) {
           
            if (!error) {
                // Synchronize updated geofence with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"GF: Successfully updated and synchronized geofence %@ on ContextHub", geofence.name);
                        completionHandler (nil);
                    } else {
                        NSLog(@"GF: Could not synchronize update of geofence %@ on ContextHub", geofence.name);
                        completionHandler (error);
                    }
                }];
            } else {
                NSLog(@"GF: Could not update geofence %@ on ContextHub", geofence.name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Delete a geofence in ContextHub and remove it from our store
- (void)deleteGeofence:(GFGeofence *)geofence completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        
        // Remove geofence from our array
        if ([self.geofences containsObject:geofence]) {
            [self.geofences removeObject:geofence];
        }
        
        // Remove geofence from ContextHub
        [[CCHGeofenceService sharedInstance] deleteGeofence:[geofence dictionaryForGeofence] completionHandler:^(NSError *error) {
            if (!error) {
                
                // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"GF: Successfully deleted geofence %@ on ContextHub", geofence.name);
                        completionHandler(nil);
                    } else {
                        NSLog(@"GF: Could not synchronize deletion of geofence %@ on ContextHub", geofence.name);
                        completionHandler(error);
                    }
                }];
            } else {
                NSLog(@"GF: Could not delete geofence %@ on ContextHub", geofence.name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

@end