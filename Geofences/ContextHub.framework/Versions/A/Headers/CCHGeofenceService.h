//
//  CCHGeofenceService.h
//  ContextHub
//
//  Created by Kevin Lee on 10/29/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ContextHub.h"

#define kGeofenceErrorDomain @"com.contexthub.geofenceservice.error"
/**
 ContextHub GeofenceService error codes.
 */
typedef NS_ENUM(NSInteger, CCHGeofenceServiceErrorCode) {
    /**
     Dictionary can't be used to create a geofence.
     */
    CCHInvalidGeofenceDictionary = 0
};

/** 
 The Geofence Service is used to create, read, update, and delete geofences on ContextHub.
 */
@interface CCHGeofenceService : CLCircularRegion

/**
 @return The singleton instance of the CCHGeofenceService.
 */
+ (instancetype)sharedInstance;

/**
 Creates a new geofence on the ContextHub server.
 @note Tags are used to filter geofences and are used by the CCHSubscriptionService.
 @param region CLCircularRegion to be added to ContextHub.
 @param tags (optional) The tags to be applied to the geofence.
 @param completionHandler (optional) Called when the request completes.  The block is passed an NSDictionary object that represents the geofence.  If an error occurs, the NSError wil be passed to the block.
 */
- (void)createGeofence:(CLCircularRegion *)region tags:(NSArray *)tags completionHandler:(void(^)(NSDictionary *geofence, NSError *error))completionHandler;

/**
 Gets a geofence from ContextHub using the geofence Id.
 @param geofenceId The id of the geofence stored in ContextHub.
 @param completionHandler Called when the request completes. The block is passed an NSDictionary object that represents the geofence.  If an error occurs, the NSError wil be passed to the block.
 */
- (void)getGeofenceWithId:(NSString *)geofenceId completionHandler:(void(^)(NSDictionary *geofence, NSError *error))completionHandler;

/**
 Gets geofences from ContextHub server.
 @param tags (optional) Tags of the geofences that you are interested in.  Passing nil will return geofences without tags.
 @param location (optional) Locatoin is used to filter the results to the nearest geofences.  Passing nil will remove the location filter.
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent geofences.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getGeofencesWithTags:(NSArray *)tags location:(CLLocation *)location completionHandler:(void(^)(NSArray *geofences, NSError *error))completionHandler;

/**
 Updates a geofence on the ContextHub server.
 @param geofence The geofence to be updated on ContextHub.
 @param completionHandler Called when the request completes. If an error occurs, the NSError will be passed to the block.
 */
- (void)updateGeofence:(NSDictionary *)geofence completionHandler:(void(^)(NSError *error))completionHandler;

/**
 Deletes an existing geofence from ContextHub.
 @param geofence The geofence to be deleted from ContextHub.
 @param completionHandler Called when the request completes. If an error occurs, the NSError will be passed to the block.
 */
- (void)deleteGeofence:(NSDictionary *)geofence completionHandler:(void(^)(NSError *error))completionHandler;

/**
 Creates a CLCircularRegion from a geofence dictionary.
 @note This is intended to be used with the geofences that are returned in the CCHGeofenceService.
 @param geofence NSDictionary that contains geofence information.
 @return A CLCircularRegion from a geofence dictionary.
 */
+ (CLCircularRegion *)regionForGeofence:(NSDictionary *)geofence;
@end
