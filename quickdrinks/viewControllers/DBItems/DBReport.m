//
//  DBReport.m
//  quickdrinks
//
//  Created by mojado on 6/27/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBReport.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"

/*
 #define TBL_REPORT                      @"report"
 #define TBL_REPORT_TARGET_ID             @"row_taget_userId"
 #define TBL_REPORT_TARGET_EMAIL             @"row_taget_email"
 #define TBL_REPORT_SENDER_ID             @"row_send_userId"
 #define TBL_REPORT_SENDER_EMAIL             @"row_send_userEmail"
 #define TBL_REPORT_REASON              @"row_reason"
 #define TBL_REPORT_VERIFIED              @"verified"

 */

@implementation DBReport
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBReport*)item
{
    if(!item)
        item = [DBReport new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.objectId = object.objectId;
    if(object[TBL_REPORT_SENDER_ID])
        item.row_send_userId = object[TBL_REPORT_SENDER_ID];
    if(object[TBL_REPORT_SENDER_NAME])
        item.row_send_userName = object[TBL_REPORT_SENDER_NAME];
    if(object[TBL_REPORT_SENDER_EMAIL])
        item.row_send_userEmail = object[TBL_REPORT_SENDER_EMAIL];
    if(object[TBL_REPORT_REASON])
        item.row_reason = object[TBL_REPORT_REASON];
    if(object[TBL_REPORT_VERIFIED])
        item.verified = [object[TBL_REPORT_VERIFIED] intValue];
    return item;
}

+ (void) addItem:(DBReport*) item
                :(void (^)(id returnItem, NSError * error))sucessblock
       failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_REPORT];
    obj[TBL_REPORT_SENDER_ID] = item.row_send_userId;
    obj[TBL_REPORT_SENDER_NAME] = item.row_send_userName;
    obj[TBL_REPORT_SENDER_EMAIL] = item.row_send_userEmail;
    obj[TBL_REPORT_REASON] = item.row_reason;
    obj[TBL_REPORT_VERIFIED] = [NSNumber numberWithInt:0];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) checkedReport:(DBReport*) item
                      :(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_REPORT];
    obj[TBL_REPORT_VERIFIED] = [NSNumber numberWithInt:1];
    obj.objectId = item.objectId;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
        
    }];
}

+ (void) deleteReport:(DBReport*) item
                     :(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock
{
    PFQuery * query = [PFQuery queryWithClassName:TBL_REPORT];
    [query whereKey:@"objectId" equalTo:item.objectId];
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

+ (void) getAllReport:(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_REPORT];
    [query whereKey:TBL_REPORT_VERIFIED equalTo:[NSNumber numberWithInt:0]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            for(PFObject * object in objects){
                DBReport * item = [DBReport createItemFromDictionary:object atItem:nil];
                [array addObject:item];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];

}
@end
