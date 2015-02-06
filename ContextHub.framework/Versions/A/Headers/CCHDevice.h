//
//  CCHDevice.h
//  ContextHub
//
//  Created by Kevin Lee on 7/24/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kDeviceErrorDomain @"com.contexthub.device.error"
/**
 ContextHub Device error codes.
 */
typedef NS_ENUM(NSInteger, CCHDeviceErrorCode) {
    /** 
     Device id cannot be nil 
     */
    CCHInvalidDeviceIdParameter,
    /**
     Alias cannot be nil
     */
    CCHInvalidDeviceAliasParameter,
    /**
     Tags cannot be nil
     */
    CCHInvalidDeviceTagsParameter
};

/**
 The CCHDevice class is used work with devices.

 Structure of device NSDictionary
 
 | key       | value     |
 | --------- | --------- |
 | additional_info | NSDictionary of device specific information (not always present) |
 | alias | alias that is set for the device (not always present) |
 | device_type | describes the device, often pulled for the user agent  |
 | id | database id for the device |
 | last_profile | NSDictionary of contextual information from the last time the device was seen by the server |
 | push_token | push token assigned to the device (not always present) |
 | tag_string | a comma separated string of the tags associated with the device |
 | tags | NSArray of tags associated with the device |
 */
@interface CCHDevice : NSObject

/**
 @return The singleton instance of CCHDevice.
 */
+ (instancetype)sharedInstance;

/**
 @return The vendor device id as UUIDString.
 */
- (NSString *)deviceId;

/**
 Gets a device from ContextHub using the device Id.
 
 @param deviceId The id of the device stored in ContextHub.
 @param completionHandler Called when the request completes. The block is passed an NSDictionary object that represents the device.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getDeviceWithId:(NSString *)deviceId completionHandler:(void(^)(NSDictionary *device, NSError *error))completionHandler;

/**
 Gets devices from ContextHub using the device alias.
 
 @param alias The alias associated with the devices that you are interested in.
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent the devices.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getDevicesWithAlias:(NSString *)alias completionHandler:(void(^)(NSArray *devices, NSError *error))completionHandler;

/**
 Gets devices from ContextHub using tags.
 
 @param tags Tags of the devices that you are interested in.
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent the devices.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getDevicesWithTags:(NSArray *)tags completionHandler:(void(^)(NSArray *devices, NSError *error))completionHandler;

/**
 Gets devices from ContextHub using tags.
 
 @param tags Tags of the devices that you are interested in.
 @param tagOperator (optional) Operator used to build the query with the tags.  Passing ANY will find all devices that match any of the tags. Passing ALL will find devices that have all of the tags provided.  Passing nil will use the default ALL operator.
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent the devices.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getDevicesWithTags:(NSArray *)tags operator:(NSString *)tagOperator completionHandler:(void(^)(NSArray *devices, NSError *error))completionHandler;

/**
 Gets devices from ContextHub using tags and location information.
 
 @param tags Tags of the devices that you are interested in.  Passing nil will return devices without tags.
 @param tagOperator (optional) Operator used to build the query with the tags.  Passing ANY will find all devices that match any of the tags. Passing ALL will find geofences that have all of the tags provided.  Passing nil will use the default ALL operator.
 @param location (optional) Location is used to filter the results.  Passing nil will remove the location filter.
 @param radius Radius in meters around the location which ContextHub considers "nearby". Passing 0 will use the default radius of 50 miles (80437 meters).  If the location parameter is nil, the radius parameter is ignored.
 @param completionHandler Called when the request completes. The block is passed an NSArray of NSDictionary objects that represent geofences.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getDevicesWithTags:(NSArray *)tags operator:(NSString *)tagOperator location:(CLLocation *)location radius:(CLLocationDistance)radius completionHandler:(void(^)(NSArray *devices, NSError *error))completionHandler;

/**
 Updates the device record on contexthub.
 @param alias (optional) The alias associated with the device.
 @param tags (optional) The tags to be applied to the device.
 @param completionHandler Called when the request completes. The block is passed an NSDictionary object that represents the device.  If an error occurs, the NSError will be passed to the block.
 @note This method updates the data for the current device.  The tags and alias that are set here can be used with CCHPush.  The tags can also be used with the CCHSubscriptionService.  This method gathers meta-data about the device and sends it to ContextHub along with the alias and tags.  You can call this method multiple times.
 */
- (void)setDeviceAlias:(NSString *)alias tags:(NSArray *)tags completionHandler:(void(^)(NSDictionary *device, NSError *error))completionHandler;

@end
