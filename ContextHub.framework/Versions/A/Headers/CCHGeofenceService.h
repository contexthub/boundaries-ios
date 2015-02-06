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
    CCHInvalidGeofenceDictionary,
    /**
    You must pass a center.
    */
    CCHInvalidCenterParameter,
    /**
     Radius cannot be nil.
     */
    CCHInvalidRadiusParameter,
    /**
     Name cannot be nil.
     */
    CCHInvalidNameParameter,
    /**
     Geofence Id cannot be nil.
     */
    CCHInvalidIdParameter
};

/** 
 The Geofence Service is used to create, read, update, and delete geofences on ContextHub.
 
 Structure of geofence NSDictionary
 
 | key       | value     |
 | --------- | --------- |
 | id        | unique id of the geofence on the ContextHub server |
 | name      | name of the geofence |
 | latitude  | latitude of the geofence (must be between -90.0 and 90.0) |
 | longitude | longitude of the geofence (must be between -90.0 and 90.0) |
 | radius    | radius in meters of the geofence |
 | tags      | NSArray of tags associated with the geofence |
 
 */
@interface CCHGeofenceService : NSObject

/**
 @return The singleton instance of the CCHGeofenceService.
 */
+ (instancetype)sharedInstance;

/**
 Creates a new geofence on the ContextHub server.
 @note Tags are used to filter geofences and are used by the CCHSubscriptionService
 
 @param center CLLocationCoordinate2D The center coordinate of the geofence.
 @param radius The radius of to be applied to the geofence.
 @param name The name of the geofence.
 @param tags (optional) The tags to be applied to the geofence.
 @param completionHandler (optional) Called when the request completes.  The block is passed an NSDictionary object that represents the geofence.  If an error occurs, the NSError will be passed to the block.
 */
- (void)createGeofenceWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius name:(NSString *)name tags:(NSArray *)tags completionHandler:(void(^)(NSDictionary *geofence, NSError *error))completionHandler;

/**
 Gets a geofence from ContextHub using the geofence Id.

 @param geofenceId The id of the geofence stored in ContextHub.
 @param completionHandler Called when the request completes. The block is passed an NSDictionary object that represents the geofence.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getGeofenceWithId:(NSString *)geofenceId completionHandler:(void(^)(NSDictionary *geofence, NSError *error))completionHandler;

/**
 Gets geofences from ContextHub server.
 
 @param tags (optional) Tags of the geofences that you are interested in.  Passing nil will return geofences without tags.
 @param location (optional) Location is used to filter the results to the nearest geofences.  Passing nil will remove the location filter.
 @param radius (optional) Radius in meters around the location which ContextHub considers "nearby". Passing nil to location will cause this parameter to be ignored. Passing 0 will use the default radius of 50 miles (80437 meters)
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent geofences.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getGeofencesWithTags:(NSArray *)tags location:(CLLocation *)location radius:(CLLocationDistance)radius completionHandler:(void(^)(NSArray *geofences, NSError *error))completionHandler;

/**
 Gets geofences from ContextHub server.
 
 @param tags (optional) Tags of the geofences that you are interested in.  Passing nil will return geofences without tags.
 @param tagOperator (optional) Operator used to build the query with the tags.  Passing ANY will find all geofences that match any of the tags. Passing ALL will find geofences that have all of the tags provided.  Passing nil will use the default ALL operator.
 @param location (optional) Location is used to filter the results to the nearest geofences.  Passing nil will remove the location filter.
 @param radius (optional) Radius in meters around the location which ContextHub considers "nearby". Passing 0 to radius will cause this parameter to be ignored. Passing 0 will use the default radius of 50 miles (80437 meters)
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent geofences.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getGeofencesWithTags:(NSArray *)tags operator:(NSString *)tagOperator location:(CLLocation *)location radius:(CLLocationDistance)radius completionHandler:(void(^)(NSArray *geofences, NSError *error))completionHandler;

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
