//
//  DrinkItem.m
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DrinkItem.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "Config.h"

@implementation DrinkItem

- (NSDictionary*) dataDict
{
    /*
     property (nonatomic, retain) NSString * row_id;
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
     */
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.row_id forKey:@"row_id"];
    [dict setObject:self.user_id forKey:@"user_id"];
    [dict setObject:[NSNumber numberWithInt:self.row_category_id] forKey:@"row_category_id"];
    [dict setObject:[NSNumber numberWithInt:self.row_subcategory_id] forKey:@"row_subcategory_id"];
    [dict setObject:[NSNumber numberWithInt:self.row_selected_type] forKey:@"row_selected_type"];
    [dict setObject:self.row_selected_typeName forKey:@"row_selected_typeName"];
    [dict setObject:self.row_name forKey:@"row_name"];
    [dict setObject:[NSNumber numberWithFloat:self.row_price] forKey:@"row_price"];
    [dict setObject:self.row_description forKey:@"row_description"];
    if(self.row_img)
        [dict setObject:self.row_img forKey:@"row_img"];
    if(self.row_instruction)
        [dict setObject:self.row_instruction forKey:@"row_instruction"];
    [dict setObject:[NSNumber numberWithInt:self.row_isTemporarily] forKey:@"row_isTemporarily"];
    return dict;
}
+ (DrinkItem*) itemFromDict:(NSDictionary*)dataDict
{
    DrinkItem * item = [DrinkItem new];
    item.row_id = [dataDict objectForKey:@"row_id"];
    item.user_id = [dataDict objectForKey:@"user_id"];
    item.row_category_id = [[dataDict objectForKey:@"row_category_id"] intValue];
    item.row_subcategory_id = [[dataDict objectForKey:@"row_subcategory_id"] intValue];
    item.row_selected_type = [[dataDict objectForKey:@"row_selected_type"] intValue];
    item.row_selected_typeName = [dataDict objectForKey:@"row_selected_typeName"];
    item.row_name = [dataDict objectForKey:@"row_name"];
    item.row_price = [[dataDict objectForKey:@"row_price"] floatValue];
    item.row_description = [dataDict objectForKey:@"row_description"];
    item.row_img = [dataDict objectForKey:@"row_img"];
    item.row_instruction = [dataDict objectForKey:@"row_instruction"];
    item.row_isTemporarily = [[dataDict objectForKey:@"row_isTemporarily"] intValue];
    return item;
}


+ (id) createItemFromDictionary:(NSObject*)dict atItem:(DrinkItem*)item
{
    if(!item)
        item = [DrinkItem new];
    PFObject *object = (PFObject*)dict;
    if(object.objectId)
        item.row_id = object.objectId;
    if(object[TBL_DRINKS_CATEGORYID])
        item.row_category_id = [object[TBL_DRINKS_CATEGORYID] intValue];
    if(object[TBL_DRINKS_SUB_CATEGORYID])
        item.row_subcategory_id = [object[TBL_DRINKS_SUB_CATEGORYID] intValue];
    if(object[TBL_DRINKS_SELECTED_TYPE])
        item.row_selected_type = [object[TBL_DRINKS_SELECTED_TYPE] intValue];
    if(object[TBL_DRINKS_SELECTED_TYPENAME])
        item.row_selected_typeName = object[TBL_DRINKS_SELECTED_TYPENAME];
    if(object[TBL_DRINKS_NAME])
        item.row_name = object[TBL_DRINKS_NAME];
    if(object[TBL_DRINKS_PRICE])
        item.row_price = [object[TBL_DRINKS_PRICE] floatValue];
    if(object[TBL_DRINKS_DESCRIPTION])
        item.row_description = object[TBL_DRINKS_DESCRIPTION];
    if(object[TBL_DRINKS_IMAGE]){
        PFFile * file = object[TBL_DRINKS_IMAGE];
        item.row_img = file.url;
    }
    if(object[TBL_DRINKS_INSTRUCTION])
        item.row_instruction = object[TBL_DRINKS_INSTRUCTION];
    if(object[@"tmprorily"])
        item.row_isTemporarily = [object[@"tmprorily"] intValue];
    if(object[TBL_DRINKS_USR_ID])
        item.user_id = object[TBL_DRINKS_USR_ID];
    return item;
}


+ (void) setTemprarilyState:(int)state :(DrinkItem*)item
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:@"objectId" equalTo:item.row_id];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            object[@"tmprorily"] = [NSNumber numberWithInteger:state];
            [object saveInBackground];
            sucessblock(item, error);
            
        }else{
            failblock(error);
        }
    }];
}

+ (void) checkDrinkInfo:(id)item
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock
{
    DrinkItem * userInfo = (DrinkItem*)item;
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:TBL_DRINKS_NAME equalTo:userInfo.row_name];
    [query whereKey:TBL_DRINKS_CATEGORYID equalTo:[NSNumber numberWithInt:userInfo.row_category_id]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DrinkItem * item = [DrinkItem createItemFromDictionary:object atItem:nil];
            sucessblock(item, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getDrinkItemFromId:(NSString*)drinkId
                sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
                  failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:@"objectId" equalTo:drinkId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            DrinkItem * item = [DrinkItem createItemFromDictionary:object atItem:nil];
            sucessblock(item, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) addDrinkInfo:(id)item :(NSString*)user_id
          sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
            failBlock:(void (^)(NSError * error))failblock;
{
    DrinkItem * userInfo = (DrinkItem*)item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_DRINKS];
    obj[TBL_DRINKS_USR_ID] = user_id;
    obj[TBL_DRINKS_CATEGORYID] = [NSNumber numberWithInt:userInfo.row_category_id];
    obj[TBL_DRINKS_SUB_CATEGORYID] = [NSNumber numberWithInt:userInfo.row_subcategory_id];
    obj[TBL_DRINKS_SELECTED_TYPE] = [NSNumber numberWithInt:userInfo.row_selected_type];
    obj[TBL_DRINKS_SELECTED_TYPENAME] = userInfo.row_selected_typeName;
    obj[TBL_DRINKS_NAME] = userInfo.row_name;
    obj[TBL_DRINKS_PRICE] = [NSNumber numberWithFloat:userInfo.row_price];
    obj[TBL_DRINKS_DESCRIPTION] = userInfo.row_description;
    if(userInfo.row_instruction)
        obj[TBL_DRINKS_INSTRUCTION] = userInfo.row_instruction;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            userInfo.row_id = obj.objectId;
            sucessblock(userInfo, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) editDrinkInfo:(id)item
           sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock
{
    DrinkItem * userInfo = (DrinkItem*)item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_DRINKS];
    obj[TBL_DRINKS_CATEGORYID] = [NSNumber numberWithInt:userInfo.row_category_id];
    obj[TBL_DRINKS_SUB_CATEGORYID] = [NSNumber numberWithInt:userInfo.row_subcategory_id];
    obj[TBL_DRINKS_SELECTED_TYPE] = [NSNumber numberWithInt:userInfo.row_selected_type];
    obj[TBL_DRINKS_SELECTED_TYPENAME] = userInfo.row_selected_typeName;
    obj[TBL_DRINKS_NAME] = userInfo.row_name;
    obj[TBL_DRINKS_PRICE] = [NSNumber numberWithFloat:userInfo.row_price];
    obj[TBL_DRINKS_DESCRIPTION] = userInfo.row_description;
    if(userInfo.row_instruction)
        obj[TBL_DRINKS_INSTRUCTION] = userInfo.row_instruction;
    obj.objectId = userInfo.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            userInfo.row_id = obj.objectId;
            sucessblock(userInfo, error);
        }else{
            failblock(error);
        }
        
    }];
}
+ (void) addPhotoInfoTo:(id) item :(NSData*)image
            sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
              failBlock:(void (^)(NSError * error))failblock;
{
    DrinkItem * _item = (DrinkItem*)item;
    PFObject *obj = [PFObject objectWithClassName:TBL_NAME_DRINKS];
    obj[TBL_DRINKS_IMAGE] = [PFFile fileWithData:image];
    obj.objectId = _item.row_id;
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if(succeed){
            sucessblock(_item, error);
        }else{
            failblock(error);
        }
        
    }];

}

+ (void) deleteDrinkItem:(DrinkItem*)item
             sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock
               failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:@"objectId" equalTo:item.row_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [obj deleteInBackground];
            }
            sucessblock(nil, error);
        }else{
            failblock(error);
        }
    }];
}

+ (void) getDrinkArray:(void (^)(id returnItem, NSError * error))sucessblock
             failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DrinkItem createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getDrinkArrayWithCategoryId:(int)categoryId  :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock;
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:TBL_DRINKS_CATEGORYID equalTo:[NSNumber numberWithInt:categoryId]];
    [query whereKey:TBL_DRINKS_USR_ID equalTo:ownerId];
    [query addAscendingOrder:TBL_DRINKS_SELECTED_TYPE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DrinkItem createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getDrinkArrayWithCategoryId:(int)categoryId withSubCategory:(int)subCategoryid  :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:TBL_DRINKS_CATEGORYID equalTo:[NSNumber numberWithInt:categoryId]];
    [query whereKey:TBL_DRINKS_SUB_CATEGORYID equalTo:[NSNumber numberWithInt:subCategoryid]];
    [query whereKey:TBL_DRINKS_USR_ID equalTo:ownerId];
    [query addAscendingOrder:TBL_DRINKS_SELECTED_TYPE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DrinkItem createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getDrinkArrayWithCategoryId:(int)categoryId withSubCategory:(int)subCategoryid withType:(int)typedid :(NSString*)ownerId :(void (^)(id returnItem, NSError * error))sucessblock
                           failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:TBL_DRINKS_CATEGORYID equalTo:[NSNumber numberWithInt:categoryId]];
    [query whereKey:TBL_DRINKS_SUB_CATEGORYID equalTo:[NSNumber numberWithInt:subCategoryid]];
    [query whereKey:TBL_DRINKS_SELECTED_TYPE equalTo:[NSNumber numberWithInt:typedid]];
    [query whereKey:TBL_DRINKS_USR_ID equalTo:ownerId];
    [query addAscendingOrder:TBL_DRINKS_SELECTED_TYPE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DrinkItem createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
+ (void) getDrinkItemFromId:(NSMutableArray*)idex :(void (^)(id returnItem, NSError * error))sucessblock
                failBlock:(void (^)(NSError * error))failblock
{
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_DRINKS];
    [query whereKey:@"objectId" containedIn:idex];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:[DrinkItem createItemFromDictionary:obj atItem:nil]];
            }
            sucessblock(array, error);
        }else{
            failblock(error);
        }
    }];
}
@end
