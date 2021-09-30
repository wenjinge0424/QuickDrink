//
//  DBOrder.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBOrder.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
#import "StackMemory.h"
#import "CommonAPI.h"
/*
 
 #define TBL_NAME_ORDER                     @"orders"
 #define TBL_ORDER_USR_ID               @"usrid"
 #define TBL_ORDER_DRINK_ID               @"drinkid"
 #define TBL_ORDER_ADD_COUNT               @"add_count"
 #define TBL_ORDER_SEND_TYPE               @"send_type"
 #define TBL_ORDER_TABLE_NUMBERS               @"tablenum"
 #define TBL_ORDER_SPECIALINSTRUCTION               @"specialinstruction"
 */
@implementation DBOrder
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBOrder*)item
{
    if(!item)
        item = [DBOrder new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_ORDER_USR_ID])
        item.row_user_id = object[TBL_ORDER_USR_ID];
    if(object[TBL_ORDER_OWNER_ID])
        item.row_owner_id = object[TBL_ORDER_OWNER_ID];
    if(object[TBL_ORDER_DRINK_ID])
        item.row_drink_id = object[TBL_ORDER_DRINK_ID];
    if(object[TBL_ORDER_ADD_COUNT])
        item.row_add_count = [object[TBL_ORDER_ADD_COUNT] intValue];
    if(object[TBL_ORDER_SEND_TYPE])
        item.row_sendType = [object[TBL_ORDER_SEND_TYPE] intValue];
    if(object[TBL_ORDER_CAUSE_NAMES])
        item.row_courseName = object[TBL_ORDER_CAUSE_NAMES];
    if(object[TBL_ORDER_TABLE_NUMBERS])
        item.row_laneNumber = object[TBL_ORDER_TABLE_NUMBERS];
    if(object[TBL_ORDER_SPECIALINSTRUCTION])
        item.row_specialInstruction = object[TBL_ORDER_SPECIALINSTRUCTION];
    if(object[TBL_ORDER_STEPS])
        item.row_orderStep = [object[TBL_ORDER_STEPS] intValue];
    if(object[TBL_ORDER_PRICE])
        item.row_orderPrice = [object[TBL_ORDER_PRICE] floatValue];
    if(object[TBL_ORDER_DRINKNAME])
        item.row_drinkname = object[TBL_ORDER_DRINKNAME];
    if(object[TBL_ORDER_OWNERNAME])
        item.row_ownername = object[TBL_ORDER_OWNERNAME];
    if(object[TBL_ORDER_USERNAME])
        item.row_username = object[TBL_ORDER_USERNAME];
    if(object[@"ContainsId"])
        item.row_contain_id = object[@"ContainsId"];
    item.editTime = object.updatedAt;
    return item;
}

+ (void) addItemWith:(DBOrder*) item
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_ORDER];
    obj[TBL_ORDER_USR_ID] = item.row_user_id;
    obj[TBL_ORDER_OWNER_ID] = item.row_owner_id;
    obj[TBL_ORDER_DRINK_ID] = item.row_drink_id;
    obj[TBL_ORDER_DRINKNAME] = item.row_drinkname;
    obj[TBL_ORDER_OWNERNAME] = item.row_ownername;
    obj[TBL_ORDER_USERNAME] = item.row_username;
    obj[TBL_ORDER_ADD_COUNT] =  [NSNumber numberWithInt:item.row_add_count];
    obj[TBL_ORDER_SEND_TYPE] =  [NSNumber numberWithInt:item.row_sendType];
    obj[TBL_ORDER_CAUSE_NAMES] = item.row_courseName;
    obj[TBL_ORDER_TABLE_NUMBERS] = item.row_laneNumber;
    obj[TBL_ORDER_SPECIALINSTRUCTION] = item.row_specialInstruction;
    obj[TBL_ORDER_STEPS] = [NSNumber numberWithInt:0];
    obj[TBL_ORDER_PRICE] = [NSNumber numberWithFloat:item.row_orderPrice];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}

+ (void) addItemsWith:(NSMutableArray*) items :(NSString * ) containerId
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock
{
    for (DBOrder * item in items) {
        PFObject *obj = [PFObject objectWithClassName:TBL_NAME_ORDER];
        obj[TBL_ORDER_USR_ID] = item.row_user_id;
        obj[TBL_ORDER_OWNER_ID] = item.row_owner_id;
        obj[TBL_ORDER_DRINK_ID] = item.row_drink_id;
        obj[TBL_ORDER_ADD_COUNT] =  [NSNumber numberWithInt:item.row_add_count];
        obj[TBL_ORDER_SEND_TYPE] =  [NSNumber numberWithInt:item.row_sendType];
        obj[TBL_ORDER_OWNERNAME] = item.row_ownername;
        obj[TBL_ORDER_USERNAME] = item.row_username;
        obj[TBL_ORDER_SPECIALINSTRUCTION] = item.row_specialInstruction;
        obj[TBL_ORDER_STEPS] = [NSNumber numberWithInt:0];
        obj[TBL_ORDER_PRICE] = [NSNumber numberWithFloat:item.row_orderPrice];
        obj[TBL_ORDER_DRINKNAME] = item.row_drinkname;
        obj[TBL_ORDER_OWNERNAME] = item.row_ownername;
        obj[TBL_ORDER_USERNAME] = item.row_username;
        obj[@"ContainsId"] = containerId;
        [obj saveInBackground];
    }
    sucessblock(nil, nil);
}

+ (void) setOrderStep:(NSString*)orderId :(int)toStep
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:@"ContainsId" equalTo:orderId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject * object = [objects objectAtIndex:i];
                object[TBL_ORDER_STEPS] = [NSNumber numberWithInt:toStep];
                [object saveInBackground];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) setOderArray:(NSMutableArray*)orderIds :(int)step
                     :(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:@"objectId" containedIn:orderIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject * object = [objects objectAtIndex:i];
                object[TBL_ORDER_STEPS] = [NSNumber numberWithInt:step];
                [object saveInBackground];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}


+ (void) getOderArrayFromContainerIds:(NSMutableArray*)orderIds
                                     :(void (^)(id returnItem, NSError * error))sucessblock
                            failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:@"ContainsId" containedIn:orderIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBOrder createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}


+ (void) getItemWith:(NSString*) userId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:TBL_ORDER_USR_ID equalTo:userId];
    [query whereKey:TBL_ORDER_STEPS equalTo:[NSNumber numberWithInt:3]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBOrder createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getCurrentItemWith:(NSString*) userId
                           :(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:TBL_ORDER_USR_ID equalTo:userId];
    [query whereKey:TBL_ORDER_STEPS equalTo:[NSNumber numberWithInt:5]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBOrder createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getItemWithOwner:(NSString*) userId
                         :(void (^)(id returnItem, NSError * error))sucessblock
                failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:TBL_ORDER_OWNER_ID equalTo:userId];
    [query whereKey:TBL_ORDER_STEPS lessThan:[NSNumber numberWithInt:3]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBOrder createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}


+ (void) getHistoryFrom:(NSDate*)stDate :(NSDate*)edDate
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
//    stDate = [CommonAPI getStartTimeOfDate:stDate];
    edDate = [CommonAPI getEndTimeOfDate:edDate];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:@"updatedAt" greaterThan:stDate];
    [query whereKey:@"updatedAt" lessThan:edDate];
    [query whereKey:TBL_ORDER_OWNER_ID equalTo:defaultUser.row_id];
//    [query whereKey:TBL_ORDER_STEPS equalTo:[NSNumber numberWithInt:3]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBOrder createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
@end
