//
//  DBFavourtie.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBFavourtie.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
#import "DrinkItem.h"

/*
 #define TBL_NAME_FAVOURITE                 @"favourite"
 #define TBL_FAVOURITE_ROW_ID               @"objectId"
 #define TBL_FAVOURITE_USR_ID               @"usrid"
 #define TBL_FAVOURITE_DRINK_ID             @"drinkid"
 */

@implementation DBFavourtie
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBFavourtie*)item;
{
    if(!item)
        item = [DBFavourtie new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_FAVOURITE_USR_ID])
        item.user_id = object[TBL_FAVOURITE_USR_ID];
    if(object[TBL_FAVOURITE_DRINK_ID])
        item.drink_id = object[TBL_FAVOURITE_DRINK_ID];
    return item;
}

+ (void) addItemWith:(NSString*) userId :(NSString*)drinkId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_FAVOURITE];
    obj[TBL_FAVOURITE_USR_ID] = userId;
    obj[TBL_FAVOURITE_DRINK_ID] = drinkId;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) deleteItemWith:(NSString*) userId :(NSString*)drinkId
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
//    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_FAVOURITE];
//    obj[TBL_FAVOURITE_USR_ID] = userId;
//    obj[TBL_FAVOURITE_DRINK_ID] = drinkId;
//    [obj deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
//        if(succeed){
//            sucessblock(nil, error);
//        }else{
//            failblock(error);
//        }
//    }];
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_FAVOURITE];
    [query whereKey:TBL_FAVOURITE_USR_ID equalTo:userId];
    [query whereKey:TBL_FAVOURITE_DRINK_ID equalTo:drinkId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            for(PFObject * object in objects){
                [object deleteInBackground];
            }
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) checkItemWith:(NSString*) userId :(NSString*)drinkId
                      :(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock
{
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_FAVOURITE];
    [query whereKey:TBL_FAVOURITE_USR_ID equalTo:userId];
    [query whereKey:TBL_FAVOURITE_DRINK_ID equalTo:drinkId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            if(objects.count > 0)
                sucessblock(nil, error);
            else{
                failblock(error);
            }
        }else{
            failblock(error);
        }
    }];
}
+ (void) favouriteItems:(NSString*) userId
                                   :(void (^)(id returnItem, NSError * error))sucessblock
                          failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_FAVOURITE];
    [query whereKey:TBL_FAVOURITE_USR_ID equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            for(PFObject * object in objects){
                DBFavourtie * item = [DBFavourtie createItemFromDictionary:object atItem:nil];
                [array addObject:item.drink_id];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) allFavouriteIds:(NSString*) userId
                        :(void (^)(id returnItem, NSError * error))sucessblock
               failBlock:(void (^)(NSError * error))failblock
{
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_FAVOURITE];
    [query whereKey:TBL_FAVOURITE_USR_ID equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            NSMutableArray * itemArray = [NSMutableArray new];
            for(PFObject * object in objects){
                DBFavourtie * item = [DBFavourtie createItemFromDictionary:object atItem:nil];
                [itemArray addObject:item.drink_id];
            }
            sucessblock(itemArray, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) allFavouriteItems:(NSString*) userId
                          :(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock
{
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_FAVOURITE];
    [query whereKey:TBL_FAVOURITE_USR_ID equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            NSMutableArray * itemArray = [NSMutableArray new];
            for(PFObject * object in objects){
                DBFavourtie * item = [DBFavourtie createItemFromDictionary:object atItem:nil];
                [itemArray addObject:item.drink_id];
            }
            [DrinkItem getDrinkItemFromId:itemArray :^(id returnVal, NSError * error){
                sucessblock(returnVal, error);
            } failBlock:^(NSError * error){
                sucessblock(nil, error);
            }];
            
        }else{
            failblock(error);
        }
    }];
}
@end
