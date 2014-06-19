//
//  GFGeofenceStore.h
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *GeofenceTagName;
extern NSString const *GeofenceSyncCompletedNotification;

@class GFGeofence;

@interface GFGeofenceStore : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *geofences;

+ (GFGeofenceStore *)sharedInstance;

- (void)syncGeofences;
- (void)addGeofence:(GFGeofence *)geofence;
- (void)removeGeofence:(GFGeofence *)geofence;

@end
