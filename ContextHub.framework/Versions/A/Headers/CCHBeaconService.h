//
//  CCHBeaconService.h
//  ContextHub
//
//  Created by Kevin Lee on 11/7/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kBeaconErrorDomain @"com.contexthub.beaconservice.error"

/**
 ContextHub BeaconService error codes.
 */
typedef NS_ENUM(NSInteger, CCHBeaconServiceErrorCode) {
    /**
     The Dictionary can't be used to create a beacon.
     */
    CCHInvalidBeaconDictionary,
    /**
     UUID cannot be nil and must be  a valid NSUUID.
     */
    CCHInvalidBeaconUUIDParameter,
    /**
     Name cannot be nil.
     */
    CCHInvalidBeaconNameParameter,
    /**
     Beacon id cannot be nil.
     */
    CCHInvalidBeaconIdParameter
};

/**
 The Beacon Service is used to create, read, update, and delete beacons on ContextHub.
 
 Structure of the beacon NSDictionary
 
 | key   | value |
 | ----- | ----- |
 | id    | unique id of the beacon on the ContextHub server |
 | name  | name of the beacon |
 | uuid  | UUID of the beacon |
 | major | major value of the beacon |
 | minor | minor value of the beacon |
 | tags  | NSArray of tags associated with the beacon |
 
 */
@interface CCHBeaconService : NSObject

/**
 @return The singleton instance of the CCHBeaconService.
 */
+ (instancetype)sharedInstance;

/**
 Creates a new beacon on the ContextHub server.
 @note Tags are used to filter beacons and are used by the CCHSubscriptionService.
 
 @param proximityUUID The uuid for the iBeacon.
 @param major (optional) The major value for the iBeacon.
 @param minor (optional) The minor value for the iBeacon.
 @param name The name of the iBeacon.
 @param tags (optional) The tags to be applied to the beacon.
 @param completionHandler (optional) Called when the request completes.  The block is passed an NSDictionary object that represents the beacon. If an error occurs, the NSError will be passed to the block.
 */
- (void)createBeaconWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor name:(NSString *)name tags:(NSArray *)tags completionHandler:(void(^)(NSDictionary *beacon, NSError *error))completionHandler;

/**
 Gets a beacon from ContextHub using the beacon Id.
 
 @param beaconId The id of the beacon stored in ContextHub.
 @param completionHandler Called when the request completes.  The block is passed an NSDictionary object that represents the beacon. If an error occurs, the NSError will be passed to the block.
 */
- (void)getBeaconWithId:(NSString *)beaconId completionHandler:(void(^)(NSDictionary *beacon, NSError *error))completionHandler;

/**
 Gets beacons from the ContextHub server.
 @param tags (optional) Tags of the beacons that you are interested in.  Passing nil will return beacons without tags.
 @param completionHandler Called when the request completes.  The block is passed an NSArray of NSDictionary objects that represent iBeacons.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getBeaconsWithTags:(NSArray *)tags completionHandler:(void (^)(NSArray *beacons, NSError *error))completionHandler;

/**
 Gets beacons from the ContextHub server.
 @param tags (optional) Tags of the beacons that you are interested in.  Passing nil will return beacons without tags.
 @param tagOperator (optional) Operator used to build the query with the tags.  Passing ANY will find all geofences that match any of the tags. Passing ALL will find geofences that have all of the tags provided.  Passing nil will use the default ALL operator.
 @param completionHandler Called when the request completes.  The block is passed an NSArray of NSDictionary objects that represent iBeacons.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getBeaconsWithTags:(NSArray *)tags operator:(NSString *)tagOperator completionHandler:(void (^)(NSArray *beacons, NSError *error))completionHandler;

/**
 Updates a beacon on the ContextHub server.
 @param beacon The beacon to be updated on ContextHub.
 @param completionHandler Called when the request completes.  If an error occurs, the NSError will be passed to the block.
 */
- (void)updateBeacon:(NSDictionary *)beacon completionHandler:(void(^)(NSError *error))completionHandler;

/**
 Deletes an existing beacon from ContextHub.
 @param beacon The beacon to be deleted from ContextHub.
 @param completionHandler Called when the request completes.  If an error occurs, the NSError will be passed to the block.
 */
- (void)deleteBeacon:(NSDictionary *)beacon completionHandler:(void(^)(NSError *error))completionHandler;

/**
 Creates a CLBeaconRegion from a beacon dictionary. 
 @note This is intended to be used with the beacons that are returned in the CCHBeaconService.
 @param beacon NSDictionary that contains beacon information.
 @return A CLBeaconRegion from a beacon dictionary.
 */
+ (CLBeaconRegion *)regionForBeacon:(NSDictionary *)beacon;

@end