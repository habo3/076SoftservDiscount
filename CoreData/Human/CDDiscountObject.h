#import "_CDDiscountObject.h"

@interface CDDiscountObject : _CDDiscountObject {}
// Custom logic goes here.

+(id)createWithDictionary:object andContext:managedObjectContext;

+(CDDiscountObject*)checkDiscountExistForDictionary:(NSDictionary*)object andContext:(id)managedObjectContext elseCreateNew:(BOOL)createNew;

@end
