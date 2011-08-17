//
//  SREmbedded.m
//  StorageRoomRestKit
//
//  Created by Sascha Konietzke on 7/13/11.
//  Copyright 2011 Thriventures. All rights reserved.
//

#import "SREmbedded.h"


@implementation SREmbedded

@synthesize mType;

+ (BOOL)shouldRegisterInMappingProvider {
    return NO;
}

@end
