//
//  DBAssignItem.m
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBAssignItem.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
/*
 #define TBL_ASSIGNITEMS_ROW_ID               @"objectId"
 #define TBL_ASSIGNITEMS_USR_ID               @"usrid"
 #define TBL_ASSIGNITEMS_TITLE                @"title"
 #define TBL_ASSIGNITEMS_POSX                 @"pos_x"
 #define TBL_ASSIGNITEMS_POSY                 @"pos_y"
 #define TBL_ASSIGNITEMS_WIDTH                @"width"
 #define TBL_ASSIGNITEMS_HEIGHT               @"heigth"
 #define TBL_ASSIGNITEMS_TYPE                 @"type"
 */

@implementation DBAssignItem
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBAssignItem*)item
{
    if(!item)
        item = [DBAssignItem new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_ASSIGNITEMS_USR_ID])
        item.user_id = object[TBL_ASSIGNITEMS_USR_ID];
    if(object[TBL_ASSIGNITEMS_TITLE])
        item.title = object[TBL_ASSIGNITEMS_TITLE];
    if(object[TBL_ASSIGNITEMS_POSX])
        item.pos_x = [object[TBL_ASSIGNITEMS_POSX] floatValue];
    if(object[TBL_ASSIGNITEMS_POSY])
        item.pos_y = [object[TBL_ASSIGNITEMS_POSY] floatValue];
    if(object[TBL_ASSIGNITEMS_WIDTH])
        item.width = [object[TBL_ASSIGNITEMS_WIDTH] floatValue];
    if(object[TBL_ASSIGNITEMS_HEIGHT])
        item.height = [object[TBL_ASSIGNITEMS_HEIGHT] floatValue];
    if(object[TBL_ASSIGNITEMS_TYPE])
        item.type = [object[TBL_ASSIGNITEMS_TYPE] intValue];
    return item;
}
+ (void) removeAsginItemInfo:(NSString*)userId
                 sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ASSIGNITEMS];
    [query whereKey:TBL_ASSIGNITEMS_USR_ID equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackground];
            }
        }else{
            failblock(error);
        }
    }];
}
+ (void) addAsginItemInfo:(id)item :(void (^)(id returnItem, NSError * error))sucessblock
{
    DBAssignItem * m_item = item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_ASSIGNITEMS];
    obj[TBL_ASSIGNITEMS_USR_ID] = m_item.user_id;
    obj[TBL_ASSIGNITEMS_TITLE] = m_item.title;
    obj[TBL_ASSIGNITEMS_POSX] = [NSNumber numberWithFloat:m_item.pos_x];
    obj[TBL_ASSIGNITEMS_POSY] = [NSNumber numberWithFloat:m_item.pos_y];
    obj[TBL_ASSIGNITEMS_WIDTH] = [NSNumber numberWithFloat:m_item.width];
    obj[TBL_ASSIGNITEMS_HEIGHT] = [NSNumber numberWithFloat:m_item.height];
    obj[TBL_ASSIGNITEMS_TYPE] = [NSNumber numberWithInt:m_item.type];
    [obj saveInBackgroundWithBlock:^(BOOL sucess, NSError* error){
        sucessblock(nil, error);
    }];
}
+ (void) updateAsginItemInfo:(DBAssignItem*)item :(void (^)(BOOL res, NSError * error))block
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_ASSIGNITEMS];
    obj[@"title"] = item.title;
    obj.objectId = item.row_id;
    obj[TBL_ASSIGNITEMS_POSX] = [NSNumber numberWithFloat:item.pos_x];
    obj[TBL_ASSIGNITEMS_POSY] = [NSNumber numberWithFloat:item.pos_y];
    obj[TBL_ASSIGNITEMS_WIDTH] = [NSNumber numberWithFloat:item.width];
    obj[TBL_ASSIGNITEMS_HEIGHT] = [NSNumber numberWithFloat:item.height];
    [obj saveEventually:^(BOOL res, NSError* error){
        block(res, error);
    }];
    
}
+ (void) removeAsginItemInfo:(NSString * )userid :(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ASSIGNITEMS];
    [query whereKey:TBL_ASSIGNITEMS_USR_ID equalTo:userid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackground];
            }
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) removeAsginItemIndex:(NSString * )rowid :(void (^)(BOOL res, NSError * error))block;
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ASSIGNITEMS];
    [query whereKey:TBL_ASSIGNITEMS_ROW_ID equalTo:rowid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackgroundWithBlock:^(BOOL sucess, NSError* error){
                    block(sucess, error);
                }];
            }
        }else{
            block(NO, error);
        }
        
    }];
}
+ (void) getAssignItemsWithUserId:(NSString*)userId :(void (^)(id returnItem, NSError * error))sucessblock
                        failBlock:(void (^)(NSError * error))failblock;
{
    NSMutableArray * data = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ASSIGNITEMS];
    [query whereKey:TBL_ASSIGNITEMS_USR_ID equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for (PFObject * object in objects) {
                [data addObject:[DBAssignItem createItemFromDictionary:object atItem:nil]];
            }
            sucessblock(data, error);
        }else{
            failblock(error);
        }
    }];
}
@end
