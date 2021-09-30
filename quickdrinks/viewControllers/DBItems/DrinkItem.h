//
//  DrinkItem.h
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TBL_NAME_DRINKS                 @"drinks"
#define TBL_DRINKS_ROW_ID               @"objectId"
#define TBL_DRINKS_USR_ID               @"usrid"
#define TBL_DRINKS_CATEGORYID           @"category_id"
#define TBL_DRINKS_SUB_CATEGORYID       @"sub_category_id"
#define TBL_DRINKS_SELECTED_TYPE        @"selected_type"
#define TBL_DRINKS_SELECTED_TYPENAME    @"selected_name"
#define TBL_DRINKS_NAME                 @"name"
#define TBL_DRINKS_PRICE                @"price"
#define TBL_DRINKS_DESCRIPTION          @"description"
#define TBL_DRINKS_IMAGE                @"img"
#define TBL_DRINKS_INSTRUCTION          @"instruction"

@interface DrinkItem : NSObject
@property (nonatomic, retain) NSString * row_id;
@property (nonatomic, retain) NSString * user_id;
@property (atomic)            int        row_category_id;
@property (atomic)            int        row_subcategory_id;
@property (atomic)            int        row_selected_type;
@property (atomic)            NSString*  row_selected_typeName;
@property (nonatomic, retain) NSString * row_name;
@property (atomic)            float      row_price;
@property (nonatomic, retain) NSString * row_description;
@property (nonatomic, retain) NSString * row_img;
@property (nonatomic, retain) NSString * row_instruction;
@property (atomic)  int row_isTemporarily;

- (NSDictionary*) dataDict;
+ (DrinkItem*) itemFromDict:(NSDictionary*)dataDict;

+ (void) checkDrinkInfo:(id)item
                  sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                    failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkItemFromId:(NSString*)drinkId
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;

+ (void) addDrinkInfo:(id)item :(NSString*)user_id
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;
+ (void) editDrinkInfo:(id)item
          sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock;
+ (void) addPhotoInfoTo:(id) item :(NSData*)image
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkArray:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkArrayWithCategoryId:(int)categoryId :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkArrayWithCategoryId:(int)categoryId withSubCategory:(int)subCategoryid  :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkArrayWithCategoryId:(int)categoryId withSubCategory:(int)subCategoryid withType:(int)typedid :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock;

+ (void) getDrinkItemFromId:(NSMutableArray*)idex :(void (^)(id returnItem, NSError * error))sucessblock
                failBlock:(void (^)(NSError * error))failblock;

+ (void) deleteDrinkItem:(DrinkItem*)item
             sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
               failBlock:(void (^)(NSError * error))failblock;

+ (void) setTemprarilyState:(int)state :(DrinkItem*)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock;

+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DrinkItem*)item;
@end
