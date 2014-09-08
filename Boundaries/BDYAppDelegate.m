//
//  BDYAppDelegate.m
//  Boundaries
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "BDYAppDelegate.h"

@implementation BDYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register with ContextHub
#ifdef DEBUG
    // This tells ContextHub that you are running a debug build.
    [[ContextHub sharedInstance] setDebug:TRUE];
#endif
    
    //Register the app id of the application you created on https://app.contexthub.com
    [ContextHub registerWithAppId:@"YOUR-GEOFENCE-APP-ID-HERE"];
    
    //Set the app delegate as the Datasource and Delegate of the Sensor Pipeline so that we can tap into the events.
    [[CCHSensorPipeline sharedInstance] setDelegate:self];
    [[CCHSensorPipeline sharedInstance] setDataSource:self];
    
    //This tells ContextHub about the tags you will use to identify the geofences that you want to automatically monitor.
    if (![[CCHSensorPipeline sharedInstance] addElementsWithTags:@[BDYGeofenceTag]]) {
        NSLog(@"BDY: Failed to add subscription to \"%@\" tag", BDYGeofenceTag);
    }
    
    return YES;
}

#pragma mark - Sensor Pipeline Delegate

- (BOOL)sensorPipeline:(CCHSensorPipeline *)sensorPipeline shouldPostEvent:(NSDictionary *)event {
    // If you'd like to keep events from hitting the server, you can return NO here.
    // This is a good spot to filter events.
    NSLog(@"BDY: Should post event %@", event);

    return YES;
}

- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline willPostEvent:(NSDictionary *)event {
    // If you want to access event data directl before it will be posted to the server, you can do that here
    NSLog(@"BDY: Will post event %@", event);
}

- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline didPostEvent:(NSDictionary *)event {
    // If you want to access event data directly after it has been posted to the server, you can do that here
    NSLog(@"BDY: Did post event %@", event);
}

#pragma mark - Sensor Pipeline Data Source

- (NSDictionary *)sensorPipeline:(CCHSensorPipeline *)sensorPipeline payloadForEvent:(NSDictionary *)event {
    // Add custom data structures to the events, and they will end up on the server in the payload property
    return @{};
}

@end