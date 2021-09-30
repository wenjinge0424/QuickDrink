//
//  DBPaymentHistory.m
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBPaymentHistory.h"

/*
 #define TBL_PAYMENTHISOTORY     @"PaymentHistory"
 #define TBL_PAYMENTHISOTORY_SENDER      @"fromUser"
 #define TBL_PAYMENTHISOTORY_RECEIVER      @"toUser"
 #define TBL_PAYMENTHISOTORY_AMOUNT      @"amount"
 */

@implementation DBPaymentHistory
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBPaymentHistory*)item
{
    if(!item)
        item = [DBPaymentHistory new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.objectId = object.objectId;
    if(object[TBL_PAYMENTHISOTORY_SENDER])
        item.senderId = object[TBL_PAYMENTHISOTORY_SENDER];
    if(object[TBL_PAYMENTHISOTORY_RECEIVER])
        item.receiverId = object[TBL_PAYMENTHISOTORY_RECEIVER];
    if(object[TBL_PAYMENTHISOTORY_AMOUNT])
        item.amount = [object[TBL_PAYMENTHISOTORY_AMOUNT] floatValue];
    item.modifyDate = object.updatedAt;
    return item;
}

+ (void) addItem:(DBPaymentHistory*) item
                :(void (^)(id returnItem, NSError * error))sucessblock
       failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_PAYMENTHISOTORY];
    obj[TBL_PAYMENTHISOTORY_SENDER] = item.senderId;
    obj[TBL_PAYMENTHISOTORY_RECEIVER] = item.receiverId;
    obj[TBL_PAYMENTHISOTORY_AMOUNT] = [NSNumber numberWithFloat:item.amount];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}
@end
