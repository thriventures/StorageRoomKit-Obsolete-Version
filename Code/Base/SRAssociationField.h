//
//  SRAssociationField.h
//  StorageRoomRestKit
//
//  Created by Sascha Konietzke on 7/13/11.
//  Copyright 2011 Thriventures. All rights reserved.
//

#import "SRField.h"


/**
 * Abstract superclass for association Fields.
 */
@interface SRAssociationField : SRField {
    NSString *collectionUrl;
}

/**
 * The URL of the Collection of the associated Entries.
 *
 * @see SRCollection
 */
@property (nonatomic, copy) NSString *collectionUrl;



@end
