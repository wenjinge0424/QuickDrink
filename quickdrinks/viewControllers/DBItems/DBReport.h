//
//  DBReport.h
//  quickdrinks
//
//  Created by mojado on 6/27/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TBL_REPORT                      @"report"
#define TBL_REPORT_SENDER_ID             @"row_send_userId"
#define TBL_REPORT_SENDER_NAME             @"row_send_userName"
#define TBL_REPORT_SENDER_EMAIL             @"row_send_userEmail"
#define TBL_REPORT_REASON              @"row_reason"
#define TBL_REPORT_VERIFIED              @"verified"

@interface DBReport : NSObject
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * row_send_userId;
@property (nonatomic, retain) NSString * row_send_userName;
@property (nonatomic, retain) NSString * row_send_userEmail;
@property (nonatomic, retain) NSString * row_reason;
@property (atomic) int verified;

+ (void) addItem:(DBReport*) item
                :(void (^)(id returnItem, NSError * error))sucessblock
       failBlock:(void (^)(NSError * error))failblock;


+ (void) checkedReport:(DBReport*) item
                      :(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock;

+ (void) deleteReport:(DBReport*) item
                      :(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock;

+ (void) getAllReport:(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBReport*)item;

@end
