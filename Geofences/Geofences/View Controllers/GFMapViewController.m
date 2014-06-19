//
//  GFMapViewController.m
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFMapViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
