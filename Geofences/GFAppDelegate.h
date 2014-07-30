//
//  GFAppDelegate.h
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContextHub/ContextHub.h>

@interface GFAppDelegate : UIResponder <UIApplicationDelegate, CCHSensorPipelineDataSource, CCHSensorPipelineDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
