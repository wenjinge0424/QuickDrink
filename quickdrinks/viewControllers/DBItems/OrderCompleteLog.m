//
//  OrderCompleteLog.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OrderCompleteLog.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
/*
 #define TBL_NAME_ORDERHISTORY                       @"orders_history"
 #define TBL_ORDERHISTORY_USR_ID                     @"usrid"
 #define TBL_ORDERHISTORY_OWNER_ID                   @"ownerid"
 #define TBL_ORDERHISTORY_DRINK_ID                   @"drinkid"
 #define TBL_ORDERHISTORY_USR_NAME                   @"usrname"
 #define TBL_ORDERHISTORY_OWNER_NAME                   @"ownername"
 #define TBL_ORDERHISTORY_DRINK_NAME                   @"drinkname"
 #define TBL_ORDERHISTORY_PRICE                   @"price"
 */
@implementation OrderCompleteLog
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(OrderCompleteLog*)item
{
    if(!item)
        item = [OrderCompleteLog new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.objectId = object.objectId;
    if(object[TBL_ORDERHISTORY_USR_ID])
        item.buyerId = object[TBL_ORDERHISTORY_USR_ID];
    if(object[TBL_ORDERHISTORY_OWNER_ID])
        item.salerId = object[TBL_ORDERHISTORY_OWNER_ID];
    if(object[TBL_ORDERHISTORY_DRINK_ID])
        item.drinkId = object[TBL_ORDERHISTORY_DRINK_ID];
    if(object[TBL_ORDERHISTORY_USR_NAME])
        item.buyerName = object[TBL_ORDERHISTORY_USR_NAME];
    if(object[TBL_ORDERHISTORY_OWNER_NAME])
        item.salerName = object[TBL_ORDERHISTORY_OWNER_NAME];
    if(object[TBL_ORDERHISTORY_DRINK_NAME])
        item.drinkName = object[TBL_ORDERHISTORY_DRINK_NAME];
    if(object[TBL_ORDERHISTORY_PRICE])
        item.price = [object[TBL_ORDERHISTORY_PRICE] floatValue];
    item.date = object.updatedAt;
    return item;
}

+ (void) addItemWith:(OrderCompleteLog*) item
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_ORDERHISTORY];
    obj[TBL_ORDERHISTORY_USR_ID] = item.buyerId;
    obj[TBL_ORDERHISTORY_OWNER_ID] = item.salerId;
    obj[TBL_ORDERHISTORY_DRINK_ID] = item.drinkId;
    obj[TBL_ORDERHISTORY_USR_NAME] =  item.buyerName;
    obj[TBL_ORDERHISTORY_OWNER_NAME] =  item.salerName;
    obj[TBL_ORDERHISTORY_DRINK_NAME] =  item.drinkName;
    obj[TBL_ORDERHISTORY_PRICE] = [NSNumber numberWithInt:item.price];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) getHistoryFrom:(NSDate*)stDate :(NSDate*)edDate
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_ORDERHISTORY];
    [query whereKey:@"updatedAt" greaterThan:stDate];
    [query whereKey:@"updatedAt" lessThan:edDate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[OrderCompleteLog createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
@end
