//
//  DBAssignItem.h
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TBL_NAME_ASSIGNITEMS                 @"asignItems"
#define TBL_ASSIGNITEMS_ROW_ID               @"objectId"
#define TBL_ASSIGNITEMS_USR_ID               @"usrid"
#define TBL_ASSIGNITEMS_TITLE                @"title"
#define TBL_ASSIGNITEMS_POSX                 @"pos_x"
#define TBL_ASSIGNITEMS_POSY                 @"pos_y"
#define TBL_ASSIGNITEMS_WIDTH                @"width"
#define TBL_ASSIGNITEMS_HEIGHT               @"heigth"
#define TBL_ASSIGNITEMS_TYPE                 @"type"


@interface DBAssignItem : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * title;
@property (atomic)            float      pos_x;
@property (atomic)            float      pos_y;
@property (atomic)            float      width;
@property (atomic)            float      height;
@property (atomic)            int        type;

+ (void) removeAsginItemInfo:(NSString*)userId
              sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                failBlock:(void (^)(NSError * error))failblock;

+ (void) addAsginItemInfo:(id)item :(void (^)(id returnItem, NSError * error))sucessblock;
+ (void) updateAsginItemInfo:(DBAssignItem*)item :(void (^)(BOOL res, NSError * error))block;
+ (void) removeAsginItemInfo:(NSString * )userid :(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock;

+ (void) removeAsginItemIndex:(NSString * )rowid :(void (^)(BOOL res, NSError * error))block;

+ (void) getAssignItemsWithUserId:(NSString*)userId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock;
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBAssignItem*)item;
@end
