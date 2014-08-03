//
//  GFMapViewController.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFMapViewController.h"

#import "GFGeofence.h"
#import "GFGeofenceStore.h"

#import "CLCircularRegion+ContextHub.h"

@interface GFMapViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation GFMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the map to where the user is located currently, and turn on tracking mode.
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1500, 1500);
    [self.mapView setRegion:newRegion animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    // Do initial data sync
    [[GFGeofenceStore sharedInstance] syncGeofences];
    
    // Register to listen to notifications about geofence sync being completed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:(NSString *)GFGeofenceSyncCompletedNotification object:nil];
    
    // Register to listen to notifications about geofence entering or leaving
    // Initialize location manager and get it to start updating our location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    // Register to listen to notification about sensor pipeline posting events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:CCHSensorPipelineDidPostEvent object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Stop listening to notifications about sensor pipeline events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCHSensorPipelineDidPostEvent object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Geofences

// Adds a geofence to the map
- (void)addGeofenceToMap:(GFGeofence *)geofence {
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
    NSArray *geofences = [GFGeofenceStore sharedInstance].geofences;
    
    for (GFGeofence *geofence in geofences) {
        [self addGeofenceToMap:geofence];
    }
}

// Removes a geofence from the map
- (void)removeGeofenceFromMap:(GFGeofence *)geofence {
    
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
        GFGeofence *geofence = [[GFGeofenceStore sharedInstance] findGeofenceInStoreWithID:fenceID];
        
        // Check and see if we know about this geofence
        if (geofence) {
            
            if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHGeofenceInEvent) {
                [[[UIAlertView alloc] initWithTitle:@"ContextHub" message:[NSString stringWithFormat:@"You have entered %@", geofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHGeofenceOutEvent)  {
                [[[UIAlertView alloc] initWithTitle:@"ContextHub" message:[NSString stringWithFormat:@"You have left %@", geofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }
    }
}

// Respond to synchronization finishing by removing and adding all geofences
- (void)syncCompleted:(NSNotification *)notification {
    [self removeAllGeofencesFromMap];
    [self addAllGeofencesToMap];
}

#pragma mark - Alert View Methods

// Add the geofence to the geofence store
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        
        // Create the geofence
        [[GFGeofenceStore sharedInstance] createGeofenceWithCenter:self.mapView.centerCoordinate radius:250 name:name completionHandler:^(GFGeofence *geofence, NSError *error) {
            
            if (!error) {
                // Add it to our map
                [self addGeofenceToMap:geofence];
            } else {
                // There was an error creating the geofence
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was a problem creating your %@ geofence in ContextHub", name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
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