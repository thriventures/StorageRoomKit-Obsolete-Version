//
//  SRCollection.m
//  StorageRoomRestKit
//
//  Created by Sascha Konietzke on 7/13/11.
//  Copyright 2011 Thriventures. All rights reserved.
//

#import "SRCollection.h"
#import "SRCollection+Private.h"

#import <objc/message.h>
#import <objc/runtime.h>


#import "SRField.h"
#import "SREmbedded.h"
#import "SREntry.h"
#import "SRObject+Private.h"
#import "SRObjectManager.h"

#undef RKLogComponent
#define RKLogComponent lcl_cStorageRoomKitObjectMapping

void deallocImplementation(id self, SEL _cmd);

void deallocImplementation(id self, SEL _cmd) {
    RKLogTrace(@"Executing custom dealloc for auto-generated Entry");
    SRCollection *collection = [[self class] collection];
    
    for (SRField *field in collection.fields) {
        [field releaseFromAutoGeneratedEntry:self];
    }       
    
    // call [super dealloc]
    Class parentClass = class_getSuperclass(object_getClass(self));
    
    struct objc_super obS = { self, parentClass };
    objc_msgSendSuper(&obS, @selector(dealloc));
}


@implementation SRCollection

@synthesize name, entryType, primaryFieldIdentifier, fields, webhookDefinitions, mAccountUrl, mEntriesUrl;

#pragma mark -
#pragma mark Class Methods

+ (NSArray *)attributeNames {
    return [[super attributeNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"name", @"entry_type", @"primary_field_identifier", nil]];
}

+ (NSArray *)metaDataNames {
    return [[super metaDataNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"account_url", @"entries_url", nil]];
}

+ (NSString *)objectKeyPath {
    return @"collection";
}

+ (NSMutableDictionary *)relationships {
    NSMutableDictionary *relationships = [super relationships];
    
    [relationships setObject:[SREmbedded class] forKey:@"fields"];
    [relationships setObject:[SREmbedded class] forKey:@"webhook_definitions"];
    
    return relationships;
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    self.name = nil;
    self.entryType = nil;
    self.primaryFieldIdentifier = nil;
    self.fields = nil;
    self.webhookDefinitions = nil;
    
    self.mAccountUrl = nil;
    self.mEntriesUrl = nil;    
    
    [super dealloc];
}

#pragma mark - 
#pragma mark Auto Generation of Entry Class

- (RKObjectMapping *)entryObjectMappingForClass:(Class)aClass {
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:aClass];
    
    RKLogDebug(@"Creating mapping from '%@' collection for class '%@'", self.entryType, NSStringFromClass(aClass));
    
    for (SRField *field in self.fields) {
        [field addToObjectMapping:objectMapping];
    }
        
    [[self class] addMetaData:[SREntry metaDataNames] toObjectMapping:objectMapping];
        
    return objectMapping;
}

- (RKObjectMapping *)entryObjectMappingForAutoGeneratedClass {
    return [self entryObjectMappingForClass:[self autoGeneratedEntryClass]];
}

- (Class)autoGeneratedEntryClass {
    NSString *className = [self autoGeneratedEntryClassName];
    Class class = NSClassFromString(className);
    
    RKLogDebug(@"Auto-generating EntryClass: '%@'", className);
    
    if (!class) {
        class = objc_allocateClassPair([SREntry class], [className UTF8String], 0);
        
        for (SRField *field in self.fields) {
            [field addToEntryClass:class];
        }
        
        class_addMethod(class, @selector(dealloc), (IMP)deallocImplementation, "v@:");
        
        objc_registerClassPair(class);
    }
    
    [class setCollection:self];
    
    return class;
}

- (NSString *)autoGeneratedEntryClassName {
    return [NSString stringWithFormat:@"SREntryClass_%@", SRIdFromUrl(self.mUrl)];
}

- (void)createAndRegisterEntryClass {    
    [SRObjectManager addEntryObjectMapping:[self entryObjectMappingForAutoGeneratedClass] forType:self.entryType];
}



@end