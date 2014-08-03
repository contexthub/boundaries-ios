//
//  GFGeofenceStore.h
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *GFGeofenceSyncCompletedNotification;

@class GFGeofence;

@interface GFGeofenceStore : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *geofences;

+ (GFGeofenceStore *)sharedInstance;

- (void)createGeofenceWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius name:(NSString *)name completionHandler:(void (^)(GFGeofence *geofence, NSError *error))completionHandler;
- (void)syncGeofences;
- (GFGeofence *)findGeofenceInStoreWithID:(NSString *)geofenceID;
- (void)updateGeofence:(GFGeofence *)geofence completionHandler:(void (^)(NSError *error))completionHandler;
- (void)deleteGeofence:(GFGeofence *)geofence completionHandler:(void (^)(NSError *error))completionHandler;

@end