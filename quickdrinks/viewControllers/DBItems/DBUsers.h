//
//  DBUsers.h
//  quickdrinks
//
//  Created by mojado on 6/16/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TBL_NAME_USERS                  @"Users"
#define TBL_USERS_ROW_ID                @"objectId"
#define TBL_USERS_USERTYPE              @"user_type"
#define TBL_USERS_EMAIL                 @"user_email"
#define TBL_USERS_PWD                   @"user_pwd"
#define TBL_USERS_CPWD                  @"user_cpwd"
#define TBL_USERS_NAME                  @"user_name"
#define TBL_USERS_BUSS_STTIME           @"user_businees_sttime"
#define TBL_USERS_BUSS_EDTIME           @"user_businees_edtime"
#define TBL_USERS_BUSS_LOCATION         @"user_business_lcoation"
#define TBL_USERS_BUSS_CONTACNUM        @"user_business_contactnum"
#define TBL_USERS_DESCRIPTION           @"user_business_description"
#define TBL_USERS_PHOTO                 @"user_photo"
#define TBL_USERS_AGE                   @"user_age"
#define TBL_USERS_GENDER                @"user_gender"
#define TBL_USERS_POSISTION_LAT         @"user_position_lat"
#define TBL_USERS_POSISTION_LNG         @"user_position_lng"

#define TBL_USERS_AGREE                 @"user_agree"
#define TBL_USERS_BAN                @"user_ban"

#define TBL_USERS_BAN                @"user_ban"
#define TBL_USERS_ACCOUNT_ID              @"accountId"

#define TBL_USER_LINKEDID           @"user_linked_id"


@interface DBUsers : NSObject
@property (nonatomic, retain) NSString*  row_id;
@property (atomic)            int        row_userType;
@property (nonatomic, retain) NSString * row_userEmail;
@property (nonatomic, retain) NSString * row_userPassword;
@property (nonatomic, retain) NSString * row_userName;
@property (nonatomic, retain) NSString * row_business_stTime;
@property (nonatomic, retain) NSString * row_business_edTime;
@property (nonatomic, retain) NSString * row_userLocation;
@property (nonatomic, retain) NSString * row_userContactNumber;
@property (nonatomic, retain) NSString * row_userDescription;
@property (nonatomic, retain) NSString * row_userPhoto;

@property (atomic)            int        row_age;
@property (nonatomic, retain) NSString * row_gender;
@property (atomic)            int        row_agree;
@property (atomic)            float      row_position_lat;
@property (atomic)            float      row_position_lng;
@property (atomic)            int        row_ban;
@property (nonatomic, retain) NSString * row_accountId;
@property (nonatomic, retain) NSDate *   row_createdTime;


@property (nonatomic, retain) UIImage * profile_image;
@property (atomic)  int isSocialUser;

+ (void) checkUserWithEmail:(NSString*)name userType:(int)type
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock;

+ (void) getUserInfoFromUserId:(NSString*)userId
                   sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                     failBlock:(void (^)(NSError * error))failblock;

+ (void) getUserInfoFromUserIds:(NSMutableArray*)userIds
                   sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                     failBlock:(void (^)(NSError * error))failblock;

+ (void) creatBussinessItem:(NSString*)email password:(NSString*)pwd
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) addInfoToBussinessItem:(id) userItem
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) addAgreeInfoTo:(id) userItem
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;
+ (void) addPhotoInfoTo:(id) userItem :(NSData*)image
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;
+ (void) creatCustomerItem:(id) userItem
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) editBussinessUser:(id)useritem
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock;

+ (void) editCustomerUser:(id)useritem
               sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock;


+ (void) getAllBusinessArray:(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock;

+ (void) getAllBusinessArrayUpdateFrom:(NSDate*)date :(void (^)(id returnItem, NSError * error))sucessblock
                   failBlock:(void (^)(NSError * error))failblock;

+ (void) changePassword:(DBUsers*)item :(NSString*)newPassword
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (void) getAllUsers:(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) getAllBanUsers:(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) setUserBan:(DBUsers*)item
                   :(void (^)(id returnItem, NSError * error))sucessblock
          failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBUsers*)item;

+ (void) removeUser:(DBUsers*)user;

@end
