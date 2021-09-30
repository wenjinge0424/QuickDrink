//
//  DBPaymentInfos.m
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBPaymentInfos.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
#import "DBUsers.h"

@implementation DBPaymentInfos
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBPaymentInfos*)item
{
    if(!item)
        item = [DBPaymentInfos new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_PAYMENTINFO_USERID])
        item.row_credit_userId = object[TBL_PAYMENTINFO_USERID];
    if(object[TBL_PAYMENTINFO_NUM])
        item.row_credit_num = object[TBL_PAYMENTINFO_NUM];
    if(object[TBL_PAYMENTINFO_EXPIRE])
        item.row_credit_expiry = object[TBL_PAYMENTINFO_EXPIRE];
    if(object[TBL_PAYMENTINFO_CVV])
        item.row_credit_cvv = object[TBL_PAYMENTINFO_CVV];
    return item;
}

+ (void) checkUserPaymentInfo:(id)item
                  sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                    failBlock:(void (^)(NSError * error))failblock
{
    DBUsers * userInfo = (DBUsers*)item;
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_PAYMENTINFO];
    [query whereKey:TBL_PAYMENTINFO_USERID equalTo:userInfo.row_id];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DBPaymentInfos * item = [DBPaymentInfos createItemFromDictionary:object atItem:nil];
            sucessblock(item, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) addUserPaymentInfo:(id)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock
{
    DBPaymentInfos * info = (DBPaymentInfos*)item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_PAYMENTINFO];
    obj[TBL_PAYMENTINFO_USERID] = info.row_credit_userId;
    obj[TBL_PAYMENTINFO_NUM] = info.row_credit_num;
    obj[TBL_PAYMENTINFO_EXPIRE] = info.row_credit_expiry;
    obj[TBL_PAYMENTINFO_CVV] = info.row_credit_cvv;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            info.row_id = obj.objectId;
            sucessblock(info, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) editUserPaymentInfo:(id)item
                 sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock
{
    DBPaymentInfos * info = (DBPaymentInfos*)item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_PAYMENTINFO];
    obj[TBL_PAYMENTINFO_USERID] = info.row_credit_userId;
    obj[TBL_PAYMENTINFO_NUM] = info.row_credit_num;
    obj[TBL_PAYMENTINFO_EXPIRE] = info.row_credit_expiry;
    obj[TBL_PAYMENTINFO_CVV] = info.row_credit_cvv;
    obj.objectId = info.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            info.row_id = obj.objectId;
            sucessblock(info, error);
        }else{
            failblock(error);
        }
        
    }];
}
@end
