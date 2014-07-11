//
//  CCHVaultAttachment.h
//  ContextHub
//
//  Created by Kevin Lee on 10/21/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 The CCHVaultAttachment is an object that should be used to provide information about a file that needs to be uploaded.
 */
@interface CCHVaultAttachment : NSObject <NSCoding>

/** 
 The name of the key that you want the url to be stored in.
 */
@property (nonatomic, strong) NSString *name;

/**
 The name of the file that you want to upload. ex: profile.jpg
 */
@property (nonatomic, strong) NSString *fileName;

/**
 The mime type of the file that you want to upload. ex: impage/jpeg
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 The data of the resource that you want to upload.
 */
@property (nonatomic, strong) NSData *data;

/**
 initilizer helper method
 @param name is the name of the key you want the url to be stored in
 @param fileName is the name of the file.
 @param mimeType is the mimetype of the file you are storing.
 @param data is the data that you want persisted.
 */
- (id)initWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType data:(NSData *)data;

@end
