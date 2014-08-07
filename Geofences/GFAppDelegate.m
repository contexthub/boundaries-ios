//
//  GFAppDelegate.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFAppDelegate.h"

@implementation GFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register with ContextHub
#ifdef DEBUG
    // This tells ContextHub that you are running a debug build.
    [[ContextHub sharedInstance] setDebug:TRUE];
#endif
    
    //Register the app id of the application you created on https://app.contexthub.com
    //[ContextHub registerWithAppId:@"YOUR-GEOFENCE-APP-ID-HERE"];
    [ContextHub registerWithAppId:@"4e0aad2a-b052-42e0-93ee-6f024d11de10"];
    
    //Set the app delegate as the Datasource and Delegate of the Sensor Pipeline so that we can tap into the events.
    [[CCHSensorPipeline sharedInstance] setDelegate:self];
    [[CCHSensorPipeline sharedInstance] setDataSource:self];
    
    //This tells ContextHub about the tags you will use to identify the Geofences that you want to automatically monitor.
    if (![[CCHSensorPipeline sharedInstance] addSubscriptionForTags:@[GFGeofenceTag]]) {
        NSLog(@"GF: Failed to add subscription to \"%@\" tag", GFGeofenceTag);
    }
    
    return YES;
}

#pragma mark - Sensor Pipeline Delegate

- (BOOL)sensorPipeline:(CCHSensorPipeline *)sensorPipeline shouldPostEvent:(NSDictionary *)event {
    // If you'd like to keep events from hitting the server, you can return NO here.
    // This is a good spot to filter events.
    NSLog(@"GF: Should post event %@", event);

    return YES;
}

- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline willPostEvent:(NSDictionary *)event {
    // If you want to access event data directl before it will be posted to the server, you can do that here
    NSLog(@"GF: Will post event %@", event);
}

- (void)sensorPipeline:(CCHSensorPipeline *)sensorPipeline didPostEvent:(NSDictionary *)event {
    // If you want to access event data directly after it has been posted to the server, you can do that here
    NSLog(@"GF: Did post event %@", event);
}

#pragma mark - Sensor Pipeline Data Source

- (NSDictionary *)sensorPipeline:(CCHSensorPipeline *)sensorPipeline payloadForEvent:(NSDictionary *)event {
    // Add custom data structures to the events, and they will end up on the server in the payload property
    return @{};
}

@end