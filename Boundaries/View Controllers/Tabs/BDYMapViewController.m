//
//  BDYMapViewController.m
//  Boundaries
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "BDYMapViewController.h"
#import <ContextHub/ContextHub.h>

#import "BDYGeofence.h"
#import "BDYConstants.h"

#import "CLCircularRegion+ContextHub.h"

@interface BDYMapViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation BDYMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the map to where the user is located currently, and turn on tracking mode.
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1500, 1500);
    [self.mapView setRegion:newRegion animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    self.geofenceArray = [NSMutableArray array];
    
    self.verboseContextHubLogging = YES; // Verbose logging shows all responses from ContextHub
    
    // Register to listen to notifications about geofence entering or leaving
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:CCHSensorPipelineDidPostEvent object:nil];
    
    // Initialize location manager and get it to start updating our location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    // Refresh all geofences
    [self refreshGeofences];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Geofences

// Refresh all geofences on the map
- (void)refreshGeofences {
    // If you have a location and particular radius of geofences you are interested in, you can fill those parameters to get back a smaller data set
    [[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[BDYGeofenceTag] location:nil radius:0 completionHandler:^(NSArray *geofences, NSError *error) {
        
        if (!error) {
            
            if (self.verboseContextHubLogging) {
                NSLog(@"BDY: [CCHGeofenceService getGeofencesWithTags: location: radius: completionHandler:] response: %@", geofences);
            }
            
            NSLog(@"BDY: Succesfully synced %d new geofences from ContextHub", geofences.count - self.geofenceArray.count);
            
            [self.geofenceArray removeAllObjects];
            
            for (NSDictionary *geofenceDict in geofences) {
                BDYGeofence *geofence = [[BDYGeofence alloc] initWithDictionary:geofenceDict];
                [self.geofenceArray addObject:geofence];
            }
            
            // Remove and re-add all geofences onto the map
            [self removeAllGeofencesFromMap];
            [self addAllGeofencesToMap];
        } else {
            NSLog(@"BDY: Could not sync geofences with ContextHub");
        }
    }];
}

#pragma mark - Map

// Adds a geofence to the map
- (void)addGeofenceToMap:(BDYGeofence *)geofence {
    // Add the pin
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = geofence.center;
    pin.title = geofence.name;
    pin.subtitle = [NSString stringWithFormat:@"Radius: %.2f meters", geofence.radius];
    [self.mapView addAnnotation:pin];
    
    // Add the circle indicating radius
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:geofence.center radius:geofence.radius];
    [self.mapView addOverlay:circle];
}

// Adds all geofences to the map
- (void)addAllGeofencesToMap {
    for (BDYGeofence *geofence in self.geofenceArray) {
        [self addGeofenceToMap:geofence];
    }
}

// Removes a geofence from the map
- (void)removeGeofenceFromMap:(BDYGeofence *)geofence {
    
    // Loop through all annotations to find our geofence pin to remove
    for (MKPointAnnotation *pin in self.mapView.annotations) {
        
        // Check if latitude and longitude match
        if ((pin.coordinate.latitude == geofence.center.latitude) && (pin.coordinate.longitude == geofence.center.longitude)) {
            [self.mapView removeAnnotation:pin];
        }
    }
    
    // Loop through all overlays to find our geofence circle to remove
    for (MKCircle *circle in self.mapView.overlays) {
        
        // Check if latitude and longitude match
        if ((circle.coordinate.latitude == geofence.center.latitude) && (circle.coordinate.longitude == geofence.center.longitude)) {
            [self.mapView removeOverlay:circle];
        }
    }
}

// Removes all geofences from the map
- (void)removeAllGeofencesFromMap {
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation];
    }
    [self.mapView removeAnnotations:pins];
    
    NSMutableArray *overlays = [[NSMutableArray alloc] initWithArray:[self.mapView overlays]];
    [self.mapView removeOverlays:overlays];
}

#pragma mark - Actions

// Pop an alert for the name of the geofence
- (IBAction)addGeofenceAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Geofence" message:@"Enter the name of your new geofence:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Events 

// Handle an event from ContextHub
- (void)handleEvent:(NSNotification *)notification {
    NSDictionary *event = notification.object;
    
    // Check and make sure its a geofence event
    if ([event valueForKeyPath:CCHGeofenceEventKeyPath]) {
        // Get the name of the geofence from the ID, look inside our store
        NSString *fenceID = [event valueForKeyPath:CCHGeofenceEventIDKeyPath];
        
        // Find the geofence we are interested in (if it exists)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.geofenceID like %@", fenceID];
        NSArray *filteredGeofences = [self.geofenceArray filteredArrayUsingPredicate:predicate];
        
        BDYGeofence *foundGeofence = nil;
        if ([filteredGeofences count] > 0) {
            foundGeofence = filteredGeofences[0];
        }
        
        // Check and see if we know about this found geofence
        if (foundGeofence) {
            
            if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHGeofenceInEvent) {
                [[[UIAlertView alloc] initWithTitle:@"ContextHub" message:[NSString stringWithFormat:@"You have entered %@", foundGeofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHGeofenceOutEvent)  {
                [[[UIAlertView alloc] initWithTitle:@"ContextHub" message:[NSString stringWithFormat:@"You have left %@", foundGeofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }
    }
}



#pragma mark - Alert View Methods

// Add the geofence to the geofence store
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        
        // Create the geofence
        [[CCHGeofenceService sharedInstance] createGeofenceWithCenter:self.mapView.centerCoordinate radius:250 name:name tags:@[BDYGeofenceTag] completionHandler:^(NSDictionary *geofence, NSError *error) {
            
            if (!error) {
                
                if (self.verboseContextHubLogging) {
                    NSLog(@"BDY: [CCHGeofenceService createGeofenceWithCenter: radius: tags: completionHandler:] response: %@", geofence);
                }
                
                BDYGeofence *createdGeofence = [[BDYGeofence alloc] initWithDictionary:geofence];
                [self.geofenceArray addObject:createdGeofence];
                
                // Synchronize newly created geofence with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"BDY: Successfully created and synchronized geofence %@ on ContextHub", createdGeofence.name);
                        
                        // Add it to our map
                        [self addGeofenceToMap:createdGeofence];
                    } else {
                        NSLog(@"BDY: Could not synchronize creation of geofence %@ on ContextHub", createdGeofence.name);
                    }
                }];
            } else {
                // There was an error creating the geofence
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was a problem creating your %@ geofence in ContextHub", name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                NSLog(@"BDY: Could not create geofence %@ on ContextHub", name);
            }
        }];
    }
}

#pragma mark - Location Manager Methods 

// Only update location once
- (void)locationManager:manager didUpdateLocations:(NSArray *)locations {
    
    // The location manager will update with null data (0, 0) until the Apple Location Services gets a fix
    if (!(self.locationManager.location.coordinate.latitude == 0 && self.locationManager.location.coordinate.longitude == 0)) {
        // Set the map to where the user is located currently, and turn on tracking mode.
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1500, 1500);
        [self.mapView setRegion:newRegion animated:YES];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
        
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - Map View Methods

// Draws a circle on a map which represents a geofence
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        // Draw the circle on the map how we want it (light blue inside with blue border)
        MKCircleRenderer* aRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        
        aRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

@end