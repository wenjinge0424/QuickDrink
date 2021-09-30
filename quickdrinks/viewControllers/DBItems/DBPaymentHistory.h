//
//  DBPaymentHistory.h
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"


#define TBL_PAYMENTHISOTORY     @"PaymentHistory"
#define TBL_PAYMENTHISOTORY_SENDER      @"fromUser"
#define TBL_PAYMENTHISOTORY_RECEIVER      @"toUser"
#define TBL_PAYMENTHISOTORY_AMOUNT      @"amount"

@interface DBPaymentHistory : NSObject
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) PFObject * senderId;
@property (nonatomic, retain) PFObject * receiverId;
@property (atomic) float  amount;
@property (nonatomic, retain) NSDate * modifyDate;

+ (void) addItem:(DBPaymentHistory*) item
                :(void (^)(id returnItem, NSError * error))sucessblock
       failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBPaymentHistory*)item;
@end
