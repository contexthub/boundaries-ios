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
    CCHSensorPipelineTimeOutError,
    /**
     The custom event is nil.
     */
    CCHSensorPipelineMissingEventError,
    /**
     The custom event is missing a name key
     */
    CCHSensorPipelineMissingNameKeyError
    
};

@class CCHSensorPipeline;
/**
 Implement the delegate if you want to take action before or after an event is sent to ContextHub.  You can also decide keep an event from firing.
 */
@protocol CCHSensorPipelineDelegate <NSObject>

@optional
/** 
 Called when events are detected on the device.
 @param sensorPipeline The CCHSensorPipeline.
 @param event The event that was triggered.
 */
- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline
        didDetectEvent:(NSDictionary *)event;

/**
 Sometimes you may want to keep an event from posting to the ContextHub service.  This method gives you the opportunity to stop the call.
 If you return NO, none of the other delegate methods will get called, and the event will be discarded.
 @note No history of the event will be captured if you return NO here.
 @returns boolean indicating if the event should be posted to ContextHUB
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
 Posted when an event is detected
 */
extern NSString * const CCHSensorPipelineDidDetectEvent;

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
 The CCHSensorPipeline monitors events as they are triggered.  You can use the CCHSensorPipeline to gain access to the events before and after they are sent to the server.  The CCHSensorPipelineDelegate and CCHSensorPipelineDataSource give you the ability to filter events and add custom data to events before they are sent to the ContextHub server.
 As events are triggered on the device, the framework will assemble a context dictionary that includes data about the event.
 The CCHSensorPipeline will call datasource and delegate life cycle methods and post lifecycle notifications.
 
 ## Notifications
 
 The following life cycle notifications are posted.  The notifications are called before the associated delegate methods are called.

 ### CCHSensorPipelineDidDetectEvent
 The object is the assembled context event.  The userInfo object is not set.
 
 ### CCHSensorPipelineWillPostEvent
 The object is the assembled context event.  The userInfo object is not set.

 ### CCHSensorPipelineDidPostEvent
 The object is the assembled context event.  The userInfo object is not set.
 
 ### CCHSensorPipelineDidCancelEvent
 The object is the assembled context event.  The userInfo object is not set.
 
*/
@interface CCHSensorPipeline : NSObject

/**
 Returns the singleton instanace of the CCHSensorPipeline
 */
+ (instancetype)sharedInstance;

/**
 This method give you the ability to trigger custom events on the ContextHub sensor pipeline
 @param event The event that you want to send to the server.
 @param completionHandler (optional) Called when the event is created.  If an error occurs, the NSError will be passed to the block.
 @note The event must contain a name key.  If you want to pass contextual information along with the event, you can do so by setting a data key for the event.
 */
- (void)triggerEvent:(NSDictionary *)event completionHandler:(void(^)(NSError *error))completionHandler;

/**
 Calling synchronize will tell the SDK to check for server-side context changes and will update monitored regions.
 The method gives you a way to load new context information if you are not using background push notifications.
 @param completionHandler (optional) Called when the synchronization completes.  If an error occurs, the NSError will be passed to the block.
 */
- (void)synchronize:(void(^)(NSError *error))completionHandler;

/** 
 To enable automatic region monitoring for geofences and iBeacons you must add the tags of the elements to the sensor pipeline.
 @param tags The tags of the elements that you want to monitor.
 @return Returns A boolean indicating that the tags were added successfully.
 */
- (BOOL)addElementsWithTags:(NSArray *)tags;

/**
 To disable automatic region monitoring for geofences and beacons, you must remove the tags from the sensor pipeline.
  @param tags The tags of the elements that you want to stop monitoring.
  @return Returns A boolean indicating that the tags were removed successfully.
 */
- (BOOL)removeElementsWithTags:(NSArray *)tags;

/**
 @return Returns an array of the tags that the pipeline is tracking.
 */
- (NSArray *)elementTags;

/**
 The CCHSensorPipelineDelegate
 */
@property (nonatomic, strong) id<CCHSensorPipelineDelegate> delegate;

/**
 The CCHSensorPipelineDataSource
 */
@property (nonatomic, strong) id<CCHSensorPipelineDataSource> dataSource;

@end


