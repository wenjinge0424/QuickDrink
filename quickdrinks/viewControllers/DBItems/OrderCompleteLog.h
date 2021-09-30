//
//  OrderCompleteLog.h
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_ORDERHISTORY                       @"orders_history"
#define TBL_ORDERHISTORY_USR_ID                     @"usrid"
#define TBL_ORDERHISTORY_OWNER_ID                   @"ownerid"
#define TBL_ORDERHISTORY_DRINK_ID                   @"drinkid"
#define TBL_ORDERHISTORY_USR_NAME                   @"usrname"
#define TBL_ORDERHISTORY_OWNER_NAME                   @"ownername"
#define TBL_ORDERHISTORY_DRINK_NAME                   @"drinkname"
#define TBL_ORDERHISTORY_PRICE                   @"price"

@interface OrderCompleteLog : NSObject
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * salerId;
@property (nonatomic, retain) NSString * buyerId;
@property (nonatomic, retain) NSString * drinkId;
@property (nonatomic, retain) NSString * salerName;
@property (nonatomic, retain) NSString * buyerName;
@property (nonatomic, retain) NSString * drinkName;
@property (atomic) float    price;
@property (nonatomic, retain) NSDate * date;

+ (void) addItemWith:(OrderCompleteLog*) item
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) getHistoryFrom:(NSDate*)stDate :(NSDate*)edDate
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(OrderCompleteLog*)item;
@end
