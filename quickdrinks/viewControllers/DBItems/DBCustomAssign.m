//
//  DBCustomAssign.m
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBCustomAssign.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"

/*
 #define TBL_NAME_CUSTOMASSIGN                 @"customAssignItems"
 #define TBL_CUSTOMASSIGN_ROW_ID               @"objectId"
 #define TBL_CUSTOMASSIGN_USR_ID               @"usrid"
 #define TBL_CUSTOMASSIGN_NAME                 @"name"
 #define TBL_CUSTOMASSIGN_TABLES               @"tables"
 */


@implementation DBCustomAssign
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBCustomAssign*)item;
{
    if(!item)
        item = [DBCustomAssign new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_CUSTOMASSIGN_USR_ID])
        item.userId = object[TBL_CUSTOMASSIGN_USR_ID];
    if(object[TBL_CUSTOMASSIGN_NAME])
        item.row_name = object[TBL_CUSTOMASSIGN_NAME];
    if(object[TBL_CUSTOMASSIGN_TABLES])
        item.row_tableNumbers = object[TBL_CUSTOMASSIGN_TABLES];
    return item;
}

+ (void) getCustomAssignItemsWithUserId:(NSString*)userId :(void (^)(id returnItem, NSError * error))sucessblock
                              failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * data = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_CUSTOMASSIGN];
    [query whereKey:TBL_CUSTOMASSIGN_USR_ID equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for (PFObject * object in objects) {
                [data addObject:[DBCustomAssign createItemFromDictionary:object atItem:nil]];
            }
            sucessblock(data, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) removeAllAssignForUser:(NSString* )userId :(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_CUSTOMASSIGN];
    [query whereKey:TBL_CUSTOMASSIGN_USR_ID equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackground];
            }
            failblock(error);
        }else{
            failblock(error);
        }
        
    }];

}

+ (void) updateItemTableInfo:(DBCustomAssign*)item :(void (^)(BOOL res, NSError * error))block
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_CUSTOMASSIGN];
    obj[TBL_CUSTOMASSIGN_TABLES] = item.row_tableNumbers;
    obj.objectId = item.row_id;
    [obj saveEventually:^(BOOL res, NSError* error){
        block(res, error);
    }];
}

+ (void) removeAssignItem:(DBCustomAssign*)item
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_CUSTOMASSIGN];
    [query whereKey:TBL_CUSTOMASSIGN_ROW_ID equalTo:item.row_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackground];
            }
        }else{
        }
        
    }];
}
+ (void) addAsginItemInfo:(id)item
{
    DBCustomAssign * m_item = item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_CUSTOMASSIGN];
    obj[TBL_CUSTOMASSIGN_USR_ID] = m_item.userId;
    obj[TBL_CUSTOMASSIGN_NAME] = m_item.row_name;
    obj[TBL_CUSTOMASSIGN_TABLES] = m_item.row_tableNumbers;
    [obj saveInBackground];
}
@end
