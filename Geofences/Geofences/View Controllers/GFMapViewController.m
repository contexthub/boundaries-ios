//
//  GFMapViewController.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFMapViewController.h"

#import "GFGeofenceStore.h"
#import "GFGeofence.h"

@interface GFMapViewController ()

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
    
    
    // Register to listen notifications about geofence sync being completed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:(NSString *)GFGeofenceSyncCompletedNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)removeGeofenceFromMap:(GFGeofence *)geofence {
    
}

- (void)addAllGeofences {
    NSArray *geofences = [GFGeofenceStore sharedInstance].geofenceArray;
    
    for (GFGeofence *geofence in geofences) {
        [self addGeofenceToMap:geofence];
    }
}

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

- (IBAction)addGeofenceAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entier name" message:@"What is the name of your geofence?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Events 

- (void)syncCompleted:(NSNotification *)notification {
    [self removeAllGeofences];
    [self addAllGeofences];
}

#pragma mark - Alert View Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        GFGeofence *newGeofence = [[GFGeofence alloc] initWithCenter:self.mapView.userLocation.coordinate radius:50 identifier:name];
        
        [[GFGeofenceStore sharedInstance] addGeofence:newGeofence];
        [self addGeofenceToMap:newGeofence];
    }
}


#pragma mark - Map View Methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        // Draw the circle on the map how we want it (cyan inside with blue border)
        MKCircleRenderer* aRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        
        aRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}


@end
