//
//  BDYMapViewController.h
//  Boundaries
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDYMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *geofenceArray;
@property (nonatomic) BOOL verboseContextHubLogging;

@end