//
//  CCHVault.h
//  ContextHub
//
//  Created by Kevin Lee on 10/7/13.
//  Copyright (c) 2013 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContextHubVaultErrorDomain @"com.contexthub.vault.error"
/** 
 ContextHub Vault error codes.
 */
typedef NS_ENUM(NSInteger, CCHVaultErrorCode) {
    /**
     missing container error code.
     */
    CCHMissingContainer,
    /**
     missing item error code.
     */
    CCHMissingItem,
    /**
     missing vault id error code.
     */
    CCHMissingVaultId,
    /**
     missing vault information error code.
     */
    CCHInvalidVaultDictionary,
    /**
     invalid JSON object.
     */
    CCHInvalidVaultJSONObject
};

typedef void (^vaultCompletionBlock)(NSDictionary *response, NSError *error);
typedef void (^vaultListingCompletionBlock)(NSArray *responses, NSError *error);

/**
 The CCHVault is used to persist data on the ContextHub servers.  This class provides methods for storing data on ContextHub servers.  Data stored in the vault can be accessed inside the ContextRules.
 Once you persist data, you can retrieve it by Tag or id.
 @note It's a good idea to tag similar items with a common tag. For example, employee objects could be tagged as employees. You can add multiple tags to an item.
 
 Vault repsponses will contain a dictionary with a data key and a vault_info key.  The data key contains the JSON data that was used to create the record.
 The value of the vault_info key is used by the Vault Service to manage the data.
 
 Structure of vault_info
 
 | key       | value     |
 | --------- | --------- |
 | id        | unique id of the vault item on the ContextHub server |
 | created_on | the date/time the item was created on the server |
 | updated_on | the date/time that the item was last modified |
 | tags | an array of tags assigned to the item |
 */
@interface CCHVault : NSObject

/**
 @returns Returns the singleton instance of the the Vault.
 */
+ (instancetype)sharedInstance;

/**
 Creates items in the Vault.
 @param item The item you want to persist.  This item must be a valid JSON object. See NSJSONSerialization:isValidJSONObject.
 @param tags (optional) The tags to be applied to the item.
 @param completionHandler (optional) Called when the request completes. The block is passed an NSDictionary representation of the item. If an error occurs, the NSError will be passed to the block.
 @note The dictionary that is returned will have a vault_info key.  This object contains the id, tags, and other metadata that is used to work with the item on the ContextHub server.
 */
- (void)createItem:(id)item tags:(NSArray *)tags completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;

/**
 Gets an item from the Vault.
 @param vaultId The vault id of the item.  The id is found in the key path @"vault_info.id".
 @param completionHandler Called when the request completes.
 */
- (void)getItemWithId:(NSString *)vaultId completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;

/**
 Gets items stored in the Vault.
 @param tags (optional) The tags to be applied to the item.
 @param completionHandler Called when the request completes. The block is passed an NSArray of dictionaries that represent the items.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getItemsWithTags:(NSArray *)tags completionHandler:(void(^)(NSArray *responses, NSError *error))completionHandler;

/**
 Gets items stored in the Vault.
 @note If you pass a keyPath and a value, it will return all items that have the key path equal to the value.
 If you pass only a keyPath, it will return all items that conatin the keypath.  If you do not pass a keyPath, then both the keypath and value are ignored.
 @param tags (optional) The tags to be applied to the item.
 @param keyPath (optional) The keyPath that you want to look for.
 @param value (optional) The value that you want to find for the keyPath.
 @param completionHandler Called when the request completes. The block is passed an NSArray of dictionaries that represent the items.  If an error occurs, the NSError will be passed to the block.
 */
- (void)getItemsWithTags:(NSArray *)tags keyPath:(NSString *)keyPath value:(NSString *)value completionHandler:(vaultListingCompletionBlock)completionHandler;

/**
 Updates an item in the Vault.
 @param item The item to be updated.
 @param completionHandler (optional) Called when the request completes. The block is passed an NSDictionary representation of the item. If an error occurs, the NSError will be passed to the block.
 */
- (void)updateItem:(NSDictionary *)item completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;

/**
 Deletes an item from the Vault.
 @param item The item to be deleted;
 @param completionHandler (optional) Called when the request completes. If an error occurs, the NSError will be passed to the block.
 */
- (void)deleteItem:(NSDictionary *)item completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;


@end
