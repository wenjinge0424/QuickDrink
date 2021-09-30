//
//  DBOrder.h
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_ORDER                     @"orders"
#define TBL_ORDER_USR_ID               @"usrid"
#define TBL_ORDER_OWNER_ID               @"ownerid"
#define TBL_ORDER_DRINK_ID               @"drinkid"
#define TBL_ORDER_ADD_COUNT               @"add_count"
#define TBL_ORDER_SEND_TYPE               @"send_type"
#define TBL_ORDER_CAUSE_NAMES               @"courseName"
#define TBL_ORDER_TABLE_NUMBERS               @"laneNum"
#define TBL_ORDER_SPECIALINSTRUCTION               @"specialinstruction"
#define TBL_ORDER_STEPS               @"steps"
#define TBL_ORDER_PRICE               @"price"

#define TBL_ORDER_DRINKNAME               @"drink_name"
#define TBL_ORDER_OWNERNAME               @"owner_name"
#define TBL_ORDER_USERNAME               @"user_name"

@interface DBOrder : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * row_user_id;
@property (nonatomic, retain) NSString * row_owner_id;
@property (nonatomic, retain) NSString * row_drink_id;
@property (nonatomic, retain) NSString * row_contain_id;
@property (atomic) int row_add_count;
@property (atomic) int row_sendType;
@property (nonatomic, retain) NSString * row_courseName;
@property (nonatomic, retain) NSString * row_laneNumber;
@property (nonatomic, retain) NSString * row_drinkname;
@property (nonatomic, retain) NSString * row_ownername;
@property (nonatomic, retain) NSString * row_username;
@property (nonatomic, retain) NSString * row_specialInstruction;
@property (nonatomic, retain) NSDate * editTime;
@property (atomic) int row_orderStep;
@property (atomic) float row_orderPrice;


+ (void) addItemWith:(DBOrder*) item
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) addItemsWith:(NSMutableArray*) items :(NSString * ) containerId 
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) getItemWith:(NSString*) userId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) getCurrentItemWith:(NSString*) userId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) setOderArray:(NSMutableArray*)orderIds :(int)step
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock;

+ (void) getOderArrayFromContainerIds:(NSMutableArray*)orderIds
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock;


+ (void) getItemWithOwner:(NSString*) userId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) setOrderStep:(NSString*)orderId :(int)toStep
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock;


+ (void) getHistoryFrom:(NSDate*)stDate :(NSDate*)edDate
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBOrder*)item;

@end
