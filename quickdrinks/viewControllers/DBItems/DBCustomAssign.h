//
//  DBCustomAssign.h
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_CUSTOMASSIGN                 @"customAssignItems"
#define TBL_CUSTOMASSIGN_ROW_ID               @"objectId"
#define TBL_CUSTOMASSIGN_USR_ID               @"usrid"
#define TBL_CUSTOMASSIGN_NAME                 @"name"
#define TBL_CUSTOMASSIGN_TABLES               @"tables"

@interface DBCustomAssign : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * row_name;
@property (nonatomic, retain) NSString * row_tableNumbers;
@property (nonatomic, retain) NSString * userId;

+ (void) addAsginItemInfo:(id)item;

+ (void) getCustomAssignItemsWithUserId:(NSString*)userId :(void (^)(id returnItem, NSError * error))sucessblock
                        failBlock:(void (^)(NSError * error))failblock;

+ (void) updateItemTableInfo:(DBCustomAssign*)item :(void (^)(BOOL res, NSError * error))block;

+ (void) removeAllAssignForUser:(NSString* )userId :(void (^)(NSError * error))failblock;

+ (void) removeAssignItem:(DBCustomAssign*)item;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBCustomAssign*)item;
@end
