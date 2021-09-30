//
//  DBPaymentInfos.h
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_PAYMENTINFO                  @"tbl_paymentinfo"
#define TBL_PAYMENTINFO_USERID                @"userId"
#define TBL_PAYMENTINFO_NUM                   @"num"
#define TBL_PAYMENTINFO_EXPIRE                @"expire"
#define TBL_PAYMENTINFO_CVV                   @"cvv"

@interface DBPaymentInfos : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * row_credit_userId;
@property (nonatomic, retain) NSString * row_credit_num;
@property (nonatomic, retain) NSString * row_credit_expiry;
@property (nonatomic, retain) NSString * row_credit_cvv;

+ (void) checkUserPaymentInfo:(id)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) addUserPaymentInfo:(id)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) editUserPaymentInfo:(id)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBPaymentInfos*)item;
@end
