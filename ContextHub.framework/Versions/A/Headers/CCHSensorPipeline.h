//
//  CCHSensorPipeline.h
//  ContextHub
//
//  Created by Kevin Lee on 10/25/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContextHubSensorPipelineErrorDomain @"com.contexthub.sensorpipeline.error"
/**
 ContextHub Pipeline error codes.
 */
typedef NS_ENUM(NSInteger, CCHSensorPipelineErrorCode) {
    /**
     Synchronization timeout error code.
     */
    CCHSensorPipelineTimeOutError = 0
};

@class CCHSensorPipeline;
/**
 Implement the delegate if you want to take action before or after an event is sent to ContextHub.  You can also decide keep an event from firing.
 */
@protocol CCHSensorPipelineDelegate <NSObject>

@optional
/**
 Sometimes you may want to keep an event from posting to the ContextHub service.  This method gives you the opportunity to stop the call.
 If you return NO, none of the other delegate methods will git called, and the event will be discarded.
 @note No history of the event will be captured if you return NO here.
 returns boolean indicating if the event should be posted to ContextHUB
 @param sensorPipeline The CCHSensorPipeline.
 @param event The event that was triggered.
 */
- (BOOL)sensorPipeline:(CCHSensorPipeline *)sensorPipeline
            shouldPostEvent:(NSDictionary *)event;


/**
 Called before an event was sent to ContextHub.
 @param sensorPipeline the CCHSensorPipeline.
 @param event The event that was triggered.
 */
- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline
              willPostEvent:(NSDictionary *)event;


/**
 Called after an event was sent to ContextHub.
 @param sensorPipeline The CCHSensorPipeline.
 @param event The event that was triggered.
 */
- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline
               didPostEvent:(NSDictionary *)event;


@end


/**
 Implement the data source when you want to add custom data to the context event.
 */
@protocol CCHSensorPipelineDataSource <NSObject>

@optional


/**
 Return a serializable dictionary that will get added to context event payload property.
 @param event The event that was triggered.
 @param sensorPipeline The CCHSensorPipeline.
 */
- (NSDictionary *)sensorPipeline:(CCHSensorPipeline *)sensorPipeline payloadForEvent:(NSDictionary *)event;

@end



///--------------------
/// @name Notifications
///--------------------

/**
 Posted before an event is posted to ContextHub
 */
extern NSString * const CCHSensorPipelineWillPostEvent;

/**
 Posted after an event has been posted to ContextHub
 */
extern NSString * const CCHSensorPipelineDidPostEvent;

/**
 Posted when the event was cancelled.
 */
extern NSString * const CCHSensorPipelineDidCancelEvent;

/**
 Represents untagged elements.
 */
extern NSString * const CCHUntaggedElements;

/**
 The CCHSensorPipeline monitors events as they are triggered.  You can use the CCHSensorPipline to gain access to the events before and after they are sent to the server, and gives you the ability to filter events and add custom data to events before they are sent to the ContextHub server.
 As events are triggered on the device, the framework will take assemble a dictionary of that includes data about the event.  
 The CCHSensorPipeline will call datasource and delegate lifecycle methods and post lifecycle notifications.
 
 ## Notifications
 
 The following life-cycle notifications are posted.  The notifications are called before the associated delegate methods are called.

 ### CCHSensorPipelineWillPostEvent
 The object is the assembled context event.  The userInfo object is not set.

 ### CCHSensorPipelineDidPostEvent
 The object is the assembled context event.  The userInfo object is not set.
 
 ### CCHSensorPipelineDidCancelEvent
 The object is the assembled context event.  The userInfo object is not set.
 
*/
@interface CCHSensorPipeline : NSObject

/**
 Returns the singleton instnace of the CCHSensorPipeline
 */
+ (instancetype)sharedInstance;

/**
 Calling synchronize will tell the SDK to check for server-side context changes and will update monitored regions.
 The method gives you a way to load new context information if you are not using background push notifictions.
 @param completionHandler (optional) Called when the synchronization completes.  If an error occurs, the NSError wil be passed to the block.
 */
- (void)synchronize:(void(^)(NSError *error))completionHandler;

/** 
 To enable automatic region monitoring for geofences and iBeacons you must subscribe to their tags.
 @param tags The tags of the elements that you want to monitor.
 @return Returns A boolean indicating that the tags were added successfully.
 */
- (BOOL)addSubscriptionForTags:(NSArray *)tags;

/**
 To disable automatic region monitoring for geofences and beacons, you must remove subscriptions.
  @param tags The tags of the elements that you want to stop monitoring.
  @return Returns A boolean indicating that the tags were removed successfully.
 */
- (BOOL)removeSubscriptionForTags:(NSArray *)tags;

/**
 @return Returns an array of the tags that you have subscribed to.
 */
- (NSArray *)subscriptions;

/**
 The CCHSensorPipelineDelegate
 */
@property (nonatomic, strong) id<CCHSensorPipelineDelegate> delegate;

/**
 The CCHSensorPipelineDataSource
 */
@property (nonatomic, strong) id<CCHSensorPipelineDataSource> dataSource;

@end


