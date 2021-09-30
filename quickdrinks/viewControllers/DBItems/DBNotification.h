//
//  DBNotification.h
//  quickdrinks
//
//  Created by mojado on 7/3/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBUsers.h"
#import "StackMemory.h"


#define TBL_NOTIFICATION                      @"notifiation"
#define TBL_REPORT_SENDER_ID                @"row_send_userId"

@interface DBNotification : NSObject
@property (nonnull, retain) NSString * row_senduser_id;
@property (nonnull, retain) NSString * row_receiveuser_id;
@property (nonnull, retain) NSString * row_msg;

+ (void) sendNotification:(NSString *) toUser :(NSString*) message :(NSString *) container;
+ (void) sendNotificationToAdmin:(NSString*) message;
@end
