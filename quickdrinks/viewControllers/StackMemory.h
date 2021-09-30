//
//  StackMemory.h
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBCong.h"

@interface StackCartItem : NSObject
@property (nonatomic, retain)  DrinkItem * item;
@property (nonatomic, retain) NSString * sender_id;
@property (nonatomic, retain) NSString * owner_id;
@property (nonatomic, retain) NSString * sender_name;
@property (nonatomic, retain) NSString * owner_name;
@property (nonatomic, retain) NSString * item_name;
@property (atomic) float drink_price;
@property (atomic) float drink_count;
@property (nonatomic, retain) NSString * item_descrption;
@property (nonatomic, retain) NSString * item_drinkInstruction;

- (NSDictionary*) dataDict;
+ (StackCartItem*) itemFromDict:(NSDictionary*)dataDict;

@end

@interface StackMemory : NSObject

@property (nonatomic, retain) DBUsers  *  stack_signInItem;
@property (nonatomic, retain) NSMutableArray * stack_cartItems;

+ (id) createInstance;
+ (void) addItemToCart:(StackCartItem*)item;
+ (void) removeItemFromCart:(int)index;
+ (NSMutableArray*) getCartItems;
+ (void) removeCutItems;
+ (NSMutableArray * ) getDrinkTitlesFrom:(int)categoryId :(int)subCategoryId :(int)selectedType;
@end
