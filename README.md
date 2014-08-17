# Boundaries (Geofences) Sample app

The Boundaries sample app that introduces you to the geofence features of the ContextHub iOS SDK and developer portal.

### Table of Contents

1. **[Purpose](#purpose)**
2. **[ContextHub Use Case](#contexthub-use-case)**
3. **[Background](#background)**
4. **[Getting Started](#getting-started)**
5. **[Create a Geofence](#create-a-geofence)**
6. **[Developer Portal](#developer-portal)**
7. **[Creating a New Context](#creating-a-new-context)**
8. **[Simulating Movement](#simulating-movement)**
8. **[Xcode Console](#xcode-console)**
10. **[Sample Code](#sample-code)**
11. **[Usage](#usage)**
  - **[Creating a Geofence](#creating-a-geofence)**
  - **[Retrieving Geofences by Tag](#retrieving-geofences-by-tag)**
  - **[Retrieving a Geofence by ID](#retrieving-a-geofence-by-id)**
  - **[Updating a Geofence](#updating-a-geofence)**
  - **[Deleting a Geofence](#deleting-a-geofence)**
  - **[Response](#response)**
  - **[Handling an Event](#handling-an-event)
12. **[Final Words](#final-words)**

## Purpose
This sample application will show you how to create, retrieve, update, and delete (CRUD) geofences as well as respond to geofence in and out events in ContextHub.

## ContextHub Use Case
In this sample application, we use ContextHub to interact with geofences we are are of by registering them in the app with a tag so they autotomatically appear on every device registered with that same tag. ContextHub takes care of setting up and monitoring geofences automatically after creation and synchronization.

## Background

Geofences allow your application to wake up and respond to a user entering or exiting a particular location based on the WiFi and cellular triangulation constantly running on a user's device. This allows you to provide more contextual information through foreground notifications or run code for a brief period of time (approx 10 seconds) so your app feels more responsive to the user at next launch. With contextual rules in ContextHub, this event processing can become more powerful allowing you to build even more contextually aware applications (see upcoming context rule sample app on how to write context rules)

## Getting Started

1. Get started by either forking or cloning the Boundaries repo. Visit [GitHub Help](https://help.github.com/articles/fork-a-repo) if you need help.
2. Go to [ContextHub](http://app.contexthub.com) and create a new Boundaries application.
3. Find the app id associated with the application you just created. Its format looks something like this: `13e7e6b4-9f33-4e97-b11c-79ed1470fc1d`.
4. Open up your Xcode project and put the app id into the `[ContextHub registerWithAppId:]` method call.
5. Build and run the project in the simulator.

## Create a Geofence

1. In the simulator you'll see a map view that is centered at the current location.  Lets set your location to one of the major cities XCode provides (click on the location arrow in the debug controls area of XCode in the bottom). Zoom in as closely as possible to street level where the location circle appears on the map.
2. Tap the "+" located at the top right of the application to create a new geofence.  Give it a name and tap okay.  This will create a geofence on the ContextHub server.

## Developer Portal

1. Go to the [developer portal](https://app.contexthub.com) and click on your Boundaries app to access its data.
2. Click on the "Geofences" tab.  You should see the geofence that you just created in the simulator.  From here you can create, update, and delete geofences as well as change its tag.
3. Try to make a new geofence that's located close to where you are. Stop and restart the simulator to see the geofence appear on your device.

## Creating a New Context

1. Contexts let you change how the server will respond to events triggered by devices. The real power of ContextHub comes from collecting and reacting these events to perform complex actions. Let's go ahead and create a new context.
2. Click on "Contexts" tab, then click the "New Context" button to start making a new context rule.
3. Enter a name for this context which will be easy for you to remember. For now, name it "Geofence In".
4. Select the `"geofence_in"` event type. Now any event of type `"geofence_in"` will trigger this rule. You can have multiple rules with the same event type, which is why the name of events should be descriptive of the rule.
5. The Context Rule text box is where you can write a rule telling ContextHub what actions to take in response to an event triggered with the specific event type. This code is Javascript, and you have access to some context objects: event, push, vault, http, and console. For now, leave the Code box blank and then click save.
6. Create `"geofence_out"` rule as well in the portal. A rule must exist in ContextHub.com before a device will generate that specific event type automatically, so this is necessary to get those type of events to fire as well.

## Simulating Movement

1. Back in Xcode, stop and restart the simulator.
2. Simulate a location change in the device to one of the major cities Xcode provides.
3. Change the simulated location in XCode back to where you previously were and you should see a `"geofence_in"` event triggered and printed to the console. 
4. In the ContextHub [developer portal](http://app.contexthub.com), you should be able to see events generated by your device appear under "Latest events", no extra code needed!

## Xcode Console

1. The sample app will log events into the debug console to get an idea of the JSON structure posted to ContextHub. Use shortcut `Shift-⌘-Y` if your console is not already visible.
2. You should see the message "CCH: Device has successfully registered your application ID with ContextHub" at the top.
3. Within the application delegate are 4 methods defined by the `CCHSensorPipelineDataSource` and `CCHSensorPipelineDelegate` which allow you hook into the pipeline of events generated by the device sensors. You can get notified when an event will post and has been posted, as well as control if an event should be posted and add extra payload data to an event. These 4 methods allow a lot of flexibility in controlling what events get sent to the server.
4. Check out the ContextHub [documentation](http://docs.contexthub.com) for more information about the event service.

## Sample Code

In this sample, most of the important code that deals with CRUDing geofences occurs in `GFListTableViewController.m`. Each method goes though a single operation you'll need to use `CCHGeofenceService`. After each CUD operation, a synchronization call is made so that `CCHSensorPipeline` is up to date with the latest data. This method becomes unnecessary if you have properly implemented push as background notifications will take care of synchronization for you.

In addition, `GFMapViewController` responds to any events created from the sensor pipeline through the `CCHSensorPipelineDidPostEvent` notification. At that point, you'll be able to filter whether the event was a geofence event which you were interested in and respond accordingly. There are several pre-defined keys that let you access information stored in an event, such as event name, state, type, etc..

## Usage

##### Creating a Geofence
```objc
// Creating a geofence with name "Geofence", lat/lng of ChaiOne, tag "geofence-tag", radius 250 meters
NSString *name = @"Geofence";
CLLocationDegrees lat = 29.763638f;
CLLocationDegrees lng = -95.461874f;
CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
CLLLocationDistance radius = 250.0f; // in meters
NSString *geofenceTag = @"geofence-tag";
[[CCHGeofenceService sharedInstance] createGeofenceWithCenter:center radius:radius tags:@[geofenceTag] competionHandler:^(NSDictionary *geofence, NSError *error) {

    if (!error) {
        // Standard CLCircularRegion class
        CLCircularRegion *createdGeofence = [CCHGeofenceService regionForGeofence:geofence];

        // If you do not have push properly set up, you need to explicitly call synchronize on CCHSensorPipeline so it will generate events if it applies to this device
        [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {

            if (!error) {
                NSLog(@"Successfully synchronized with ContextHub");
            } else {
            NSLog(@"Could not synchronize withContextHub");
            }
        }];
    } else {
        NSLog(@"Could not create geofence %@ on ContextHub", name);
    }
}];
```

##### Retrieving Geofences by Tag
```objc
// Getting all geofences with the tag "geofence-tag" near our location in 2000 meter radius
// currentLocation is our current location from CLLLocationManager 
NSString *geofenceTag = @"geofence-tag";
[[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[geofenceTag] location:currentLocation radius:2000 completionHandler:^(NSArray *geofences, NSError *error) {

    if (!error) {
        for (NSDictionary *geofenceDict in geofences) {
            CLCircularRegion *geofenceRegion = [CCHGeofenceService regionForGeofence:geofenceDict];
        }
    } else {
        NSLog(@"Could not get geofences from ContextHub");
    }
}];
```

##### Retrieving a Geofence by ID
```objc
// Getting a geofence with a specific ID
NSString *geofenceID = @"1000";
[[CCHGeofenceService sharedInstance] getGeofenceWithId:geofenceID completionHandler:^(NSDictionary *geofence, NSError *error)completionHandler {

    if (!error) {
        CLCircularRegion *geofenceRegion = [CCHGeofenceService regionForGeofence:geofence];
    } else {
        NSLog(@"Could not get geofence from ContextHub");
    }
}];
```

##### Updating a Geofence
```objc
// Updating a geofence with the name "Geofence 2" and adding the tag "office"
// In order to update a geofence, you need to pass in a dictionary with the same dictionary structure as from either the create or get methods
// Note, this is where a custom class is very helpful in taking the information in a CLCircularRegion (which is marked partly read-only by Apple) and updating it
// See GFGeofence in Geofences sample app for more information
NSString *name = @"Geofence 2";
CLLocationDegrees lat = 29.742964f;
CLLocationDegrees lng = -95.353605f;
CLLLocationDistance radius = 250.0f; // in meters
NSString *geofenceTag = @"geofence-tag";
NSString *geofenceTag2 = @"office";

NSString *latString = [NSString stringWithFormat: @"%.6f", lat];
NSString *lngString = [NSString stringWithFormat: @"%.6f", lng];
NSString *radString = [NSString stringWithFormat: @"%.6f", radius];
NSNumber *geofenceID = @1000;

NSDictionary *geofenceDict = @{ @"id":geofenceID, @"name":name, @"latitude":latString, @"longitude":lngString, @"radius":radString,  @"tags":@[geofenceTag, geofenceTag2] };
[[CCHGeofenceService sharedInstance] updateGeofence:geofenceDict completionHandler:^(NSError *error) {

    if (!error) {
        NSLog(@"Updated geofence in ContextHub");

        // If you do not have push properly set up, you need to explicitly call synchronize on CCHSensorPipeline so it will start/stop generate events if it applies to this device
        [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {

                if (!error) {
            NSLog(@"Successfully synchronized with ContextHub");
            } else {
                NSLog(@"Could not synchronize withContextHub");
            }
        }];
    } else {
        NSLog(@"Could not update geofence in ContextHub");
    }
}];
```

##### Deleting a Geofence
```objc
// Deleting a geofence takes the same NSDictionary structure as the response from creating, getting or updating one
[[CCHGeofenceService sharedInstance] deleteGeofence:geofence completionHandler:^(NSError *error) {

    if (!error) {
        NSLog(@"Deleted geofence in ContextHub");

        // If you do not have push properly set up, you need to explicitly call synchronize on CCHSensorPipeline so it will start/stop generate events if it applies to this device
        [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {

            if (!error) {
                    NSLog(@"Successfully synchronized with ContextHub");
            } else {
                NSLog(@"Could not synchronize withContextHub");
            }
        }];
    } else {
        NSLog(@"Could not delete geofence in ContextHub");
    }
}];
```

##### Response
Here is what a response from create and get calls looks like:
```
{
    id = 5989;
    latitude = "29.76363799999999";
    longitude = "-95.46187399999999";
    name = ChaiOne;
    radius = 250;
    "tag_string" = "geofence-tag";
    tags =     (
        "geofence-tag"
    );
}
```

##### Handling an Event
```objc
- (void)viewDidAppear:(BOOL animated) {
    [super viewDidAppear:animated];
    
    // Start listening to event notifications about sensor pipeline posting events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:CCHSensorPipelineDidPostEvent object:nil];
}

- (void)viewDidDisappear:(BOOL animated) {
    [super viewDidDisappear:animated];
    
    // Stop listening to event notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCHSensorPipelineDidPostEvent object:nil];
}
    
// Handle an event from ContextHub
- (void)handleEvent:(NSNotification *)notification {
    NSDictionary *event = notification.object;
        
    // Check and make sure it's a geofence event
    if ([event valueForKeyPath:CCHGeofenceEventKeyPath]) {
        NSString *geofenceID = [event valueForKeyPath:CCHGeofenceEventIDKeyPath];

        if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameGeofenceIn) {
            // We entered range of a monitored geofence region

        } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameGeofenceOut) {
            // We exited range of a monitored geofence region
        }
    }
}
```

That's it! Hopefully this sample application showed you how easy it is to work with geofences in ContextHub to present contextual information based on location.
