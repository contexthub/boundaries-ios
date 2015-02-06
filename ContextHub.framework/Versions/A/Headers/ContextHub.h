//
//  ContextHub.h
//  ContextHub
//
//  Created by Travis Fischer on 9/18/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//
//  Version 1.6.0
//

#import <Foundation/Foundation.h>

//Event Services
#import "CCHSensorPipeline.h"

//Element Services
#import "CCHBeaconService.h"
#import "CCHGeofenceService.h"
#import "CCHSubscriptionService.h"
#import "CCHLog.h"

//Application Services
#import "CCHPush.h"
#import "CCHContextHubPush.h"
#import "CCHVault.h"
#import "CCHDevice.h"

/**
 * The primary interface with the ContextHub SDK
 */
@interface ContextHub : NSObject

/**
 * Returns the default instance of ContextHub
 */
+ (ContextHub *)sharedInstance;

/**
 * Registers the app with ContextHub. This call should be made on app launch.
 * You must register your app with the ContextHub SDK before you use any of the other API's provided in this SDK.
 * @param appId The application id that is assigned on ContextHub.
 */
+ (void)registerWithAppId:(NSString *)appId;

/**
 * The application's ID registered with ContextHub.
 */
+ (NSString *)applicationId;

/**
 * The Vendor device ID.
 */
+ (NSString *)deviceId;

/** 
 If you are using Push Notifications, set this value to YES for debug builds.  This will tell ContextHub that the push token for the device should be used with the Sandbox push service.
 */
@property (nonatomic, assign) BOOL debug;

/**
 build version
 */
extern NSString * const CCHVersion;

@end
