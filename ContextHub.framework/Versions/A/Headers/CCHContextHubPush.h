//
//  CCHPushObject.h
//  ContextHub
//
//  Created by Kevin Lee on 10/31/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The CCHContextHubPush object
 */
@interface CCHContextHubPush : NSObject

/**
 The NSDictionary representation of the resource that triggered the push.
 */
@property (nonatomic, strong) NSDictionary *object;

/**
 The userInfo dictionary that contains the 'action' and 'resource' that triggered the push.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 The name of the NSNotification that is posted to the defualt NSNotificationCenter for the action and resource.
 */
@property (nonatomic, strong) NSString *name;

/**
 Initializes the CCHContextHubPush object.
 @param object The NSDictionary representation of the resource that triggered the push.
 @param userInfo The userInfo dictionary that contains the 'action' and 'resource' that triggered the push.
 @param name The name of the NSNotification that is posted to the defualt NSNotificationCenter for the action and resource.
*/
- (instancetype)initWithObject:(NSDictionary *)object userInfo:(NSDictionary *)userInfo name:(NSString *)name;

@end
