//
//  GFAppDelegate.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFAppDelegate.h"

#import "GFGeofenceStore.h"

@implementation GFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register with ContextHub
#ifdef DEBUG
    // This tells ContextHub that you are running a debug build.
    [[ContextHub sharedInstance] setDebug:TRUE];
#endif
    
    //Register the app id of the application you created on https://app.contexthub.com
    [ContextHub registerWithAppId:@"YOUR-GEOFENCE-APP-ID-HERE"];
    
    
    CCHSensorPipeline *sensorPipeline = [CCHSensorPipeline sharedInstance];

    //This tells ContextHub about the tags you will use to identify the Geofences that you want to automatically monitor.
    if (![sensorPipeline addSubscriptionForTags:@[GFGeofenceTagName]]) {
        NSLog(@"GF: Failed to add subscription to \"%@\" tag", GFGeofenceTagName);
    }
    
    //Set the app delegate as the Datasource and Delegate of the Sensor Pipeline so that we can tap into the events.
    [sensorPipeline setDelegate:self];
    [sensorPipeline setDataSource:self];
    
    return YES;
}

#pragma mark - CCHSensorPipelineDelegate

/*
 Sometimes you may want to keep an event from posting to the ContextHub service.  This method gives you the opportunity to stop the call.
 If you return NO, none of the other delegate methods will get called, and the event will be discarded.
*/
- (BOOL)sensorPipeline:(CCHSensorPipeline *)sensorPipeline shouldPostEvent:(NSDictionary *)event {
    NSLog(@"GH: Should post event %@", event);

    return YES;
}

/*
 Called before an event was sent to ContextHub.
 */
- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline willPostEvent:(NSDictionary *)event {
    NSLog(@"GH: Will post event %@", event);
}

/*
 Called after an event was sent to ContextHub.
 */
- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline didPostEvent:(NSDictionary *)event {
    NSLog(@"GH: Did post event %@", event);
}

#pragma mark - CCHSensorPipelineDataSource

/*
 You can add custom data to the event before it gets sent to the ContextHub Server.
 Return a serializable dictionary that will get added to context event payload property.
 */
- (NSDictionary *)sensorPipeline:(CCHSensorPipeline *)sensorPipeline payloadForEvent:(NSDictionary *)event {
    return @{@"custom":@"data"};
}

#pragma mark - Application Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
