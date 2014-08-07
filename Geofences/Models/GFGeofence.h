//
//  GFGeofence.h
//  Geofences
//
//  Created by Joefrey Kibuule on 6/19/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFGeofence : CLCircularRegion

@property (nonatomic, readonly) NSString *geofenceID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *tags;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end