//
//  CCHLog.h
//  ContextHub
//
//  Created by Kevin Lee on 7/15/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ContextHub CCHLog error codes.
 */
typedef NS_ENUM(NSInteger, CCHLogErrorCode) {
    /**
     Invalid JSON object.
     */
    CCHInvalidLogJSONObject,
    /**
     Missing message.
     */
    CCHMissingMessage
};

/**
 The CCHLog class is used to log information to the ContextHub server logs.
 @note These logs are not cached locally.  You must have an internet connection when this method is called if you want the logs to show on the server.
 */
@interface CCHLog : NSObject

/**
  @return The singleton instance of CCHLog.
 */
+ (instancetype)sharedInstance;

/**
 Creates a log on the ContextHub server.
 @param message The string message that you want to log.
 @param userInfo (optional) The user defined data that you want to log.  This item must be a valid JSON object. See NSJSONSerialization:isValidJSONObject.
 @param completionHandler (optional) Called when the request completes. If an error occurs, the NSError will be passed to the block.
 @note These logs are not cached locally.  You must have an internet connection when this method is called if you want the logs to show on the server.
 */
- (void)log:(NSString *)message userInfo:(NSDictionary *)userInfo completionHandler:(void(^)(NSError *error))completionHandler;

@end