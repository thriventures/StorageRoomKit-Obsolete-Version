//
//  SRField.m
//  StorageRoomRestKit
//
//  Created by Sascha Konietzke on 7/13/11.
//  Copyright 2011 Thriventures. All rights reserved.
//

#import "SRField.h"

#import <objc/runtime.h>

#undef RKLogComponent
#define RKLogComponent lcl_cStorageRoomKitObjectMapping

id getterImplementation(id self, SEL _cmd);
void setterImplementation(id self, SEL _cmd, id aValue);

id getterImplementation(id self, SEL _cmd) {
    NSString *variableName = NSStringFromSelector(_cmd);
    void *value;
    object_getInstanceVariable(self, [variableName UTF8String], &value);
    RKLogTrace(@"Returning value through auto-generated accessor: '%@' value: %@", variableName, value);    
    return value;
}

void setterImplementation(id self, SEL _cmd, id aValue) {
    RKLogTrace(@"Setting value through auto-generated setter: '%@' value: %@", NSStringFromSelector(_cmd), aValue);
    NSString *methodName = NSStringFromSelector(_cmd);
    NSString *capitalizedName = [methodName substringWithRange:NSMakeRange(3, [methodName length] - 4)];
    NSString *variableName = [NSString stringWithFormat:@"%@%@", [[capitalizedName substringToIndex:1] lowercaseString], [capitalizedName substringFromIndex:1]];

    // release + retain
    void *value; 
    object_getInstanceVariable(self, [variableName UTF8String], &value);
    [(id)value release];
    
    [aValue retain];
    object_setInstanceVariable(self, [variableName UTF8String], aValue);
}

@implementation SRField

@synthesize name, identifier, hint, inputType, required, unique, maximumLength, minimumLength, minimumNumber, maximumNumber, minimumSize, maximumSize;

+ (NSArray *)attributeNames {
    return [[super attributeNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"name", @"identifier", @"hint", @"input_type", @"required", @"unique",
                                                                  @"maximum_length", @"minimum_length", @"minimum_number", @"maximum_number", @"minimum_size", @"maximum_size", nil]];
}

- (void)dealloc {
    self.name = nil;
    self.identifier = nil; 
    self.hint = nil; 
    self.inputType = nil; 
    self.required = nil;
    self.unique = nil;
    self.maximumLength = nil;
    self.minimumLength = nil;
    self.minimumNumber = nil;
    self.maximumNumber = nil;
    self.minimumSize = nil;
    self.maximumSize = nil;
    
    [super dealloc];
}


- (void)addToObjectMapping:(RKObjectMapping *)anObjectMapping {
    RKLogTrace(@"Adding Field '%@' to objectMapping", self.name);
}


- (BOOL)addToEntryClass:(Class)aClass {
    NSString *variableName = SRIdentifierToObjectiveC(self.identifier);
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:", [[variableName substringToIndex:1] uppercaseString], [variableName substringFromIndex:1]];
    NSString *className = NSStringFromClass(aClass);
    
    RKLogTrace(@"Adding instance variable '%@' to class '%@'", variableName, className);
    if (!class_addIvar(aClass, [variableName UTF8String], sizeof(id), rint(log2(sizeof(id))), @encode(id))) {
        RKLogCritical(@"Could not add instanceVariable '%@' to class '%@'", variableName, className);
        return NO;
    }
     
    RKLogTrace(@"Adding getter method '%@' to class '%@'", variableName, className);
    if (!class_addMethod(aClass, NSSelectorFromString(variableName), (IMP)getterImplementation, "@@:")) {
        RKLogCritical(@"Could not add getter '%@' to class '%@'", variableName, className); 
        return NO;
    }
    
    RKLogTrace(@"Adding setter method '%@' to class '%@'", setterName, className);
    if (!class_addMethod(aClass, NSSelectorFromString(setterName), (IMP)setterImplementation, "v@:")) {
        RKLogCritical(@"Could not add setter '%@' to class '%@'", setterName, className);
        return NO;        
    }
    
    return YES;
}

- (void)releaseFromAutoGeneratedEntry:(id)anEntry {
    RKLogTrace(@"Releasing: %@ from %@", self.identifier, anEntry);
    NSString *variableName = SRIdentifierToObjectiveC(self.identifier);
    void *value;
    object_getInstanceVariable(anEntry, [variableName UTF8String], &value);
    [(id)value release];
}

@end


