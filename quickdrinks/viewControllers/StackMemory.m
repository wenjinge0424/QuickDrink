//
//  StackMemory.m
//  quickdrinks
//
//  Created by mojado on 6/20/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "StackMemory.h"

@implementation StackCartItem
- (NSDictionary*) dataDict
{
    /*
     @property (nonatomic, retain)  DrinkItem * item;
     @property (nonatomic, retain) NSString * sender_id;
     @property (nonatomic, retain) NSString * owner_id;
     @property (nonatomic, retain) NSString * sender_name;
     @property (nonatomic, retain) NSString * owner_name;
     @property (nonatomic, retain) NSString * item_name;
     @property (atomic) float drink_price;
     @property (atomic) float drink_count;
     @property (nonatomic, retain) NSString * item_descrptio
     */
    NSMutableDictionary * dataDict = [NSMutableDictionary new];
    [dataDict setObject:self.sender_id forKey:@"sender_id"];
    [dataDict setObject:self.owner_id forKey:@"owner_id"];
    [dataDict setObject:self.sender_name forKey:@"sender_name"];
    [dataDict setObject:self.owner_name forKey:@"owner_name"];
    [dataDict setObject:self.item_name forKey:@"item_name"];
    [dataDict setObject:[NSNumber numberWithFloat:self.drink_price] forKey:@"drink_price"];
    [dataDict setObject:[NSNumber numberWithFloat:self.drink_count] forKey:@"drink_count"];
    [dataDict setObject:self.item_descrption forKey:@"item_descrption"];
    [dataDict setObject:self.item_drinkInstruction forKey:@"item_drinkInstruction"];
    NSDictionary * itemDict = [self.item dataDict];
    [dataDict setObject:itemDict forKey:@"item"];
    return dataDict;
}
+ (StackCartItem*) itemFromDict:(NSDictionary*)dataDict
{
    StackCartItem * item  = [StackCartItem new];
    item.sender_id = [dataDict objectForKey:@"sender_id"];
    item.owner_id = [dataDict objectForKey:@"owner_id"];
    item.sender_name = [dataDict objectForKey:@"sender_name"];
    item.owner_name = [dataDict objectForKey:@"owner_name"];
    item.item_name = [dataDict objectForKey:@"item_name"];
    item.drink_price = [[dataDict objectForKey:@"drink_price"] floatValue];
    item.drink_count = [[dataDict objectForKey:@"drink_count"] floatValue];
    item.item_descrption = [dataDict objectForKey:@"item_descrption"];
    item.item_drinkInstruction = [dataDict objectForKey:@"item_drinkInstruction"];
    NSDictionary * itemDict = [dataDict objectForKey:@"item"];;
    DrinkItem * drinkitem = [DrinkItem itemFromDict:itemDict];
    item.item = drinkitem;
    return item;
}
@end


@implementation StackMemory
static StackMemory * _StackMemory;
+ (id) createInstance
{
    if(!_StackMemory){
        _StackMemory = [StackMemory new];
    }
    return _StackMemory;
}
+ (void) addItemToCart:(StackCartItem*)item
{
    StackMemory * memory = [StackMemory createInstance];
    if(!memory.stack_cartItems){
        memory.stack_cartItems = [NSMutableArray new];
    }
    [memory.stack_cartItems addObject:item];
    
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dataDict = [[userDefault dictionaryForKey:@"addItemToCart"] mutableCopy];
    if(!dataDict)
        dataDict = [NSMutableDictionary new];
    NSMutableArray * ownerDict = [[dataDict objectForKey:item.owner_id] mutableCopy];
    if(!ownerDict)
        ownerDict = [NSMutableArray new];
    NSDictionary * itemDict = [item dataDict];
    [ownerDict addObject:itemDict];
    [dataDict setObject:ownerDict forKey:item.owner_id];
    [userDefault setObject:dataDict forKey:@"addItemToCart"];
    [userDefault synchronize];
}
+ (void) removeItemFromCart:(int)index
{
//    StackMemory * memory = [StackMemory createInstance];
//    if(!memory.stack_cartItems){
//        memory.stack_cartItems = [NSMutableArray new];
//    }
//    if(index > memory.stack_cartItems.count)
//        return;
//    [memory.stack_cartItems removeObjectAtIndex:index];
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dataDict = [[userDefault dictionaryForKey:@"addItemToCart"] mutableCopy];
    if(!dataDict)
        dataDict = [NSMutableDictionary new];
    NSArray * allKeys = dataDict.allKeys;
    if(allKeys.count > 0){
        NSString * ownerId = [allKeys firstObject];
        NSMutableArray * ownerDict = [[dataDict objectForKey:ownerId] mutableCopy];
        if(!ownerDict)
            ownerDict = [NSMutableArray new];
        [ownerDict removeObjectAtIndex:index];
        [dataDict setObject:ownerDict forKey:ownerId];
        [userDefault setObject:dataDict forKey:@"addItemToCart"];
        [userDefault synchronize];
    }
}
+ (NSMutableArray*) getCartItems
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dataDict = [[userDefault dictionaryForKey:@"addItemToCart"] mutableCopy];
    NSArray * allKeys = dataDict.allKeys;
    if(allKeys.count > 0){
        NSString * ownerId = [allKeys firstObject];
        NSMutableArray * dataArray = [dataDict objectForKey:ownerId];
        NSMutableArray * convertedArray = [NSMutableArray new];
        for(NSDictionary * dict in dataArray){
            StackCartItem * item =  [StackCartItem itemFromDict:dict];
            [convertedArray addObject:item];
        }
        return convertedArray;
    }
    return [NSMutableArray new];
}
+ (void) removeCutItems
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dataDict = [[userDefault dictionaryForKey:@"addItemToCart"] mutableCopy];
    NSArray * allKeys = dataDict.allKeys;
    if(allKeys.count > 0){
        NSString * ownerId = [allKeys firstObject];
        [dataDict removeObjectForKey:ownerId];
        [userDefault setObject:dataDict forKey:@"addItemToCart"];
        [userDefault synchronize];
    }
}


+ (NSMutableArray * ) getDrinkTitlesFrom:(int)categoryId :(int)subCategoryId :(int)selectedType
{
    NSMutableArray * categoryList = [[NSMutableArray alloc] initWithObjects:@"Beers", @"Cocktails",@"Wines",@"Speciality Drinks", @"Non-Alcoholic Drinks", nil];
    NSMutableArray * subCategoryList = [[NSMutableArray alloc] initWithObjects:@"Draft", @"Bottle", @"Can", nil];
    NSMutableArray * selectedTypeList = [[NSMutableArray alloc] initWithObjects:@"Draft", @"Bottle", @"Can", nil];
    
    NSString * categoryName = [categoryList objectAtIndex:categoryId - 1];
    if(categoryId == 1){
        subCategoryList = [NSMutableArray new];
        selectedTypeList = [[NSMutableArray alloc] initWithObjects:@"Draft", @"Bottle", @"Can", nil];
    }else if(categoryId == 2){
        subCategoryList = [[NSMutableArray alloc] initWithObjects:@"Brandy",@"Cognac",@"Schnapps",@"Gin",@"Rum",@"Tequila",@"Vodka",@"Whisky",@"Bourbon", @"Scotch",nil];
        selectedTypeList = [[NSMutableArray alloc] initWithObjects:@"Bloody Mary", @"Cosmopolitan", @"Martini",nil];
    }else if(categoryId == 3){
        subCategoryList = [[NSMutableArray alloc] initWithObjects:@"Bottle", @"Glass",nil];
        selectedTypeList = [[NSMutableArray alloc] initWithObjects:@"Chardonnay", @"Riesling", @"Pinot Gris" , @"Sauvignon Blanc", @"Merlot", @"Cabernet Sauvignon", @"Pinot Noir", @"Shiraz", @"Sangiovese", @"Nebbiolo", @"Malbec", @"Tempranillo", @"Gamay", @"Zinfandel", nil];
    }else if(categoryId == 4){
        subCategoryList = [NSMutableArray new];
        selectedTypeList = [[NSMutableArray alloc] initWithObjects:@"Vodka", @"Bourbon", @"Rum", @"Whiskey", @"Tequila", @"Wine", nil];
    }else if(categoryId == 5){
        subCategoryList = [NSMutableArray new];
        selectedTypeList = [NSMutableArray new];
    }
    NSString * subCategoryName = @"";
    if([subCategoryList count] > 0)
        subCategoryName = [subCategoryList objectAtIndex:subCategoryId];
    NSString * selectTypeName = @"";
    if([selectedTypeList count] > 0)
        selectTypeName = [selectedTypeList objectAtIndex:selectedType];
    
    return [[NSMutableArray alloc] initWithObjects:categoryName,subCategoryName,selectTypeName , nil];
}

@end
