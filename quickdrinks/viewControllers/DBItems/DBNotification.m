//
//  DBNotification.m
//  quickdrinks
//
//  Created by mojado on 7/3/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBNotification.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"

@implementation DBNotification
+ (void) sendNotification:(NSString *) toUser :(NSString*) message :(NSString *) container;
{
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:@"objectId" equalTo:toUser];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
        [Util sendPushNotification:item.row_userEmail message:message type:1];
        
        PFObject *obj = [PFObject objectWithClassName:@"db_notification"];
        obj[@"toUser"] = toUser;
        obj[@"toUserId"] = item.row_id;
        obj[@"fromUser"] = defaultUser.row_userName;
        obj[@"fromUserId"] = defaultUser.row_id;
        obj[@"message"] = message;
        obj[@"orderId"] = container;
        [obj saveInBackground];
        
    }];
}

+ (void) sendNotificationToAdmin:(NSString*) message
{
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE equalTo:@"2"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
            [Util sendPushNotification:item.row_userEmail message:message type:1];
            
            PFObject *obj = [PFObject objectWithClassName:@"db_notification"];
            obj[@"toUser"] = @"Admin";
            obj[@"toUserId"] = item.row_id;
            obj[@"fromUser"] = defaultUser.row_userName;
            obj[@"toUserId"] = defaultUser.row_id;
            obj[@"message"] = message;
            [obj saveInBackground];
            
        }else{
        }
    }];
}
@end
