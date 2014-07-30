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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[GFGeofenceStore sharedInstance] syncGeofences];
    });
    
    // Register to listen to notifications about geofence sync being completed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:(NSString *)GFGeofenceSyncCompletedNotification object:nil];
    
    // Register to listen to notifications about geofence entering or leaving
    // Initialize location manager and get it to start updating our location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
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
    pin.title = geofence.identifier;
    pin.subtitle = [NSString stringWithFormat:@"Radius: %.2f meters", geofence.radius];
    [self.mapView addAnnotation:pin];
    
    // Add the circle indicating radius
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:geofence.center radius:geofence.radius];
    [self.mapView addOverlay:circle];
    
    NSLog(@"GF Map View: Added \"%@\" geofence to map", geofence.identifier);
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

// Adds all geofences to the map
- (void)addAllGeofences {
    NSArray *geofences = [GFGeofenceStore sharedInstance].geofenceArray;
    
    for (GFGeofence *geofence in geofences) {
        [self addGeofenceToMap:geofence];
    }
}

// Removes all geofences from the map
- (void)removeAllGeofences {
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter name" message:@"What is the name of your geofence?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Events 

// Respond to synchronization finishing by removing and adding all geofences
- (void)syncCompleted:(NSNotification *)notification {
    [self removeAllGeofences];
    [self addAllGeofences];
}

#pragma mark - Alert View Methods

// Add the geofence to the geofence store
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        GFGeofence *newGeofence = [[GFGeofence alloc] initWithCenter:self.mapView.centerCoordinate radius:250 identifier:name];
        
        [[GFGeofenceStore sharedInstance] addGeofence:newGeofence];
        [self addGeofenceToMap:newGeofence];
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