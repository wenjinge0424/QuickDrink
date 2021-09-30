//
//  DBUsers.m
//  quickdrinks
//
//  Created by mojado on 6/16/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DBUsers.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"
/*
 @property (atomic)            int        row_id;
 @property (atomic)            int        row_userType;
 @property (nonatomic, retain) NSString * row_userEmail;
 @property (nonatomic, retain) NSString * row_userPassword;
 @property (nonatomic, retain) NSString * row_userName;
 @property (nonatomic, retain) NSString * row_business_stTime;
 @property (nonatomic, retain) NSString * row_business_edTime;
 @property (nonatomic, retain) NSString * row_userLocation;
 @property (nonatomic, retain) NSString * row_userContactNumber;
 @property (nonatomic, retain) NSString * row_userDescription;
 @property (nonatomic, retain) UIImage  * row_userPhoto;
 
 @property (atomic)            int        row_age;
 @property (atomic)            int        row_gender;

 */
@implementation DBUsers

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBUsers*)item
{
    if(!item)
        item = [DBUsers new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_USERS_USERTYPE])
        item.row_userType = [object[TBL_USERS_USERTYPE] intValue];
    if(object[TBL_USERS_EMAIL])
        item.row_userEmail = object[TBL_USERS_EMAIL];
    if(object[TBL_USERS_PWD])
        item.row_userPassword = object[TBL_USERS_PWD];
    if(object[TBL_USERS_NAME])
        item.row_userName = object[TBL_USERS_NAME];
    if(object[TBL_USERS_BUSS_STTIME])
        item.row_business_stTime = object[TBL_USERS_BUSS_STTIME];
    if(object[TBL_USERS_BUSS_EDTIME])
        item.row_business_edTime = object[TBL_USERS_BUSS_EDTIME];
    if(object[TBL_USERS_BUSS_LOCATION])
        item.row_userLocation = object[TBL_USERS_BUSS_LOCATION];
    if(object[TBL_USERS_BUSS_CONTACNUM])
        item.row_userContactNumber = object[TBL_USERS_BUSS_CONTACNUM];
    if(object[TBL_USERS_DESCRIPTION])
        item.row_userDescription = object[TBL_USERS_DESCRIPTION];
    if(object[TBL_USERS_PHOTO]){
        PFFile * file = object[TBL_USERS_PHOTO];
        item.row_userPhoto = file.url;
    }
    if(object[TBL_USERS_AGE])
        item.row_age = [object[TBL_USERS_AGE] intValue];
    if(object[TBL_USERS_GENDER])
        item.row_gender = object[TBL_USERS_GENDER];
    if(object[TBL_USERS_AGREE])
        item.row_agree = [object[TBL_USERS_AGREE] intValue];
    if(object[TBL_USERS_POSISTION_LAT])
        item.row_position_lat = [object[TBL_USERS_POSISTION_LAT] floatValue];
    if(object[TBL_USERS_POSISTION_LNG])
        item.row_position_lng = [object[TBL_USERS_POSISTION_LNG] floatValue];
    if(object[TBL_USERS_BAN])
        item.row_ban = [object[TBL_USERS_BAN] intValue];
    if(object[TBL_USERS_ACCOUNT_ID])
        item.row_accountId = object[TBL_USERS_ACCOUNT_ID];
    item.row_createdTime = object.createdAt;
    return item;
}

+ (void) checkUserWithEmail:(NSString*)name userType:(int)type
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_EMAIL equalTo:name];
    [query includeKey:TBL_USERS_PWD];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
            sucessblock(item, error);
//            if(type ==5){
                //            }else{
//                sucessblock(item, error);
//            }
        }else{
            failblock(error);
        }
    }];
}

+ (void) getUserInfoFromUserId:(NSString*)userId
                   sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                     failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:@"objectId" equalTo:userId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
            sucessblock(item, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getUserInfoFromUserIds:(NSMutableArray*)userIds
                    sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                      failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:@"objectId" containedIn:userIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DBUsers createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) creatBussinessItem:(NSString*)email password:(NSString*)pwd
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_EMAIL] = email;
    obj[TBL_USERS_PWD] = pwd;
    obj[TBL_USERS_USERTYPE] = @"0";
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            DBUsers * item = [DBUsers new];
            item.row_userEmail = email;
            item.row_userPassword = pwd;
            item.row_id = obj.objectId;
            PFUser * user = [PFUser new];
            user.email = email;
            user.username = email;
            user.password = pwd;
            user[TBL_USER_LINKEDID] = obj.objectId;
            
            [user signUpInBackground];
            sucessblock(item, error);
            
//            [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
//                if(!error){
//                    [user signUpInBackground];
//                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
//                    [[PFInstallation currentInstallation] saveEventually];
//                    sucessblock(item, error);
//                }else{
//                    failblock(error);
//                }
//            }];
            
        }else{
            failblock(error);
        }
    
    }];
}
+ (void) addInfoToBussinessItem:(id) userItem
                    sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                      failBlock:(void (^)(NSError * error))failblock;
{
    DBUsers * item = (DBUsers*)userItem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_NAME] = item.row_userName;
    obj[TBL_USERS_BUSS_STTIME] = item.row_business_stTime;
    obj[TBL_USERS_BUSS_EDTIME] = item.row_business_edTime;
    obj[TBL_USERS_BUSS_LOCATION] = item.row_userLocation;
    obj[TBL_USERS_BUSS_CONTACNUM] = item.row_userContactNumber;
    obj[TBL_USERS_DESCRIPTION] = item.row_userDescription;
    obj[TBL_USERS_POSISTION_LAT] = [NSNumber numberWithFloat:item.row_position_lat];
    obj[TBL_USERS_POSISTION_LNG] = [NSNumber numberWithFloat:item.row_position_lng];
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) addAgreeInfoTo:(id) userItem
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
    DBUsers * item = (DBUsers*)userItem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_AGREE] = [NSString stringWithFormat:@"%d", item.row_agree];
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];

}
+ (void) addPhotoInfoTo:(id) userItem :(NSData*)image
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;
{
    DBUsers * item = (DBUsers*)userItem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_PHOTO] = [PFFile fileWithData:image];
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) changePassword:(DBUsers*)item :(NSString*)newPassword
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_PWD] = newPassword;
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) creatCustomerItem:(id) userItem
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock;
{
    DBUsers * item = (DBUsers*)userItem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_EMAIL] = item.row_userEmail;
    obj[TBL_USERS_PWD] = item.row_userPassword;
    obj[TBL_USERS_NAME] = item.row_userName;
    obj[TBL_USERS_AGE] = [NSString stringWithFormat:@"%d", item.row_age];
    if(item.row_gender)
        obj[TBL_USERS_GENDER] = item.row_gender;
    obj[TBL_USERS_USERTYPE] = @"1";
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            item.row_id = obj.objectId;
            
            PFUser * user = [PFUser new];
            user.email = item.row_userEmail;
            user.username = item.row_userEmail;
            user.password = item.row_userPassword;
            user[TBL_USER_LINKEDID] = obj.objectId;
            
            [user signUpInBackground];
            sucessblock(item, error);
            
//            [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
//                if(!error){
//                    [user signUpInBackground];
//                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
//                    [[PFInstallation currentInstallation] saveEventually];
//                    sucessblock(item, error);
//                }else{
//                    failblock(error);
//                }
//            }];
        }else{
            failblock(error);
        }
        
    }];
}

+ (void) editBussinessUser:(id)useritem
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock
{
    DBUsers * item = (DBUsers*)useritem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_NAME] = item.row_userName;
    obj[TBL_USERS_BUSS_STTIME] = item.row_business_stTime;
    obj[TBL_USERS_BUSS_EDTIME] = item.row_business_edTime;
    obj[TBL_USERS_BUSS_LOCATION] = item.row_userLocation;
    obj[TBL_USERS_BUSS_CONTACNUM] = item.row_userContactNumber;
    obj[TBL_USERS_EMAIL] = item.row_userEmail;
    obj[TBL_USERS_PWD] = item.row_userPassword;
    obj[TBL_USERS_DESCRIPTION] = item.row_userDescription;
    obj[TBL_USERS_POSISTION_LAT] = [NSNumber numberWithFloat:item.row_position_lat];
    obj[TBL_USERS_POSISTION_LNG] = [NSNumber numberWithFloat:item.row_position_lng];
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];
}

+ (void) editCustomerUser:(id)useritem
              sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                failBlock:(void (^)(NSError * error))failblock
{
    DBUsers * item = (DBUsers*)useritem;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_NAME] = item.row_userName;
    obj[TBL_USERS_AGE] = [NSString stringWithFormat:@"%d", item.row_age];
    obj[TBL_USERS_GENDER] = item.row_gender;
    obj[TBL_USERS_PWD] = item.row_userPassword;
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];

}

+ (void) setUserBan:(DBUsers*)item
                   :(void (^)(id returnItem, NSError * error))sucessblock
          failBlock:(void (^)(NSError * error))failblock
{
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_USERS];
    obj[TBL_USERS_BAN] = [NSNumber numberWithInt:1];
    obj.objectId = item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(item, error);
        }else{
            failblock(error);
        }
        
    }];
}

+ (void) getAllBusinessArray:(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE equalTo:@"0"];
    [query whereKey:TBL_USERS_AGREE equalTo:@"1"];
    [query whereKey:TBL_USERS_BAN notEqualTo:@"1"];
    [query orderByAscending:TBL_USERS_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            for(PFObject * object in objects){
                DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
                [array addObject:item];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getAllBusinessArrayUpdateFrom:(NSDate*)date :(void (^)(id returnItem, NSError * error))sucessblock
                             failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE equalTo:@"0"];
    [query whereKey:TBL_USERS_AGREE equalTo:@"1"];
    [query whereKey:TBL_USERS_BAN notEqualTo:@"1"];
    [query whereKey:@"updatedAt" greaterThan:date];
    [query orderByAscending:TBL_USERS_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            for(PFObject * object in objects){
                DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
                [array addObject:item];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getAllUsers:(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE notEqualTo:@"2"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            for(PFObject * object in objects){
                DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
                [array addObject:item];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getAllBanUsers:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
    NSMutableArray * array = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE notEqualTo:@"2"];
    [query whereKey:TBL_USERS_BAN equalTo:[NSNumber numberWithInt:1]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            for(PFObject * object in objects){
                DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
                [array addObject:item];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) removeUser:(DBUsers*)user
{
    PFQuery * query = [PFUser query];
    [query whereKey:@"username" equalTo:user.row_userEmail];
    PFObject * obj = [[query findObjects] firstObject];
    [obj deleteInBackground];
    
    query = [PFQuery queryWithClassName:@"TBL_NAME_USERS"];
    [query whereKey:@"objectId" equalTo:user.row_id];
    obj = [[query findObjects] firstObject];
    [obj deleteInBackground];
}
@end
