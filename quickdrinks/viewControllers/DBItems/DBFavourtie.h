//
//  DBFavourtie.h
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_FAVOURITE                 @"favourite"
#define TBL_FAVOURITE_ROW_ID               @"objectId"
#define TBL_FAVOURITE_USR_ID               @"usrid"
#define TBL_FAVOURITE_DRINK_ID             @"drinkid"

@interface DBFavourtie : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * drink_id;

+ (void) addItemWith:(NSString*) userId :(NSString*)drinkId
        :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) deleteItemWith:(NSString*) userId :(NSString*)drinkId
                    :(void (^)(id returnItem, NSError * error))sucessblock
           failBlock:(void (^)(NSError * error))failblock;

+ (void) checkItemWith:(NSString*) userId :(NSString*)drinkId
                       :(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (void) favouriteItems:(NSString*) userId
                                   :(void (^)(id returnItem, NSError * error))sucessblock
                          failBlock:(void (^)(NSError * error))failblock;

+ (void) allFavouriteIds:(NSString*) userId
                        :(void (^)(id returnItem, NSError * error))sucessblock
               failBlock:(void (^)(NSError * error))failblock;

+ (void) allFavouriteItems:(NSString*) userId
                          :(void (^)(id returnItem, NSError * error))sucessblock
                 failBlock:(void (^)(NSError * error))failblock;
+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DBFavourtie*)item;
@end
