StorageRoomKit
==============================

StorageRoomKit is a framework for iOS and OS X that provides helper methods and classes to make it easier to use RestKit (http://restkit.org + https://github.com/restkit/restkit) with the StorageRoom API (http://storageroomapp.com).


Main Features
------------------------------

* Works with NSObjects and NSManagedObjects
* Supports the GET, POST, PUT and DELETE HTTP methods
* Comes with classes and mappings for all StorageRoom Resources
* Helper methods to generate StorageRoom paths
* ... and many more handy features that RestKit offers


Installation into your Project
------------------------------

1. Load the submodules with Git
  * Add StorageRoomKit to your project: `git submodule add git://github.com/thriventures/StorageRoomKit.git StorageRoomKit`
  * Go to the StorageRoomKit directory: `cd StorageRoomKit`
  * Check out the nested submodules (RestKit): `git submodule update --init --recursive`
1. Add cross-project reference by dragging **StorageRoomKit.xcodeproj** to your project
1. Open build settings editor for your project
  * Add **Other Linker Flags** for `-ObjC -all_load`
  * Add the following **Header Search Paths**:
    * `"$(SOURCE_ROOT)/StorageRoomKit/Build/include"`
    * `"$(SOURCE_ROOT)/StorageRoomKit/Vendor/RestKit/Build"`
1. Open target settings editor for the target you want to link StorageRoomKit into
  * Add direct dependency on the **StorageRoomKit** aggregate target
  * Link against required frameworks:
    * **CFNetwork.framework** (iOS)
    * **CoreData.framework** (optional)
    * **MobileCoreServices.framework** (iOS)
    * **SystemConfiguration.framework**
    * Link against StorageRoomKit static library product:
      * **libStorageRoomKitBase.a**
      * **libStorageRoomKitCoreData.a** (optional)
1. Import the StorageRoomKit headers
  * `#import <StorageRoomKit/StorageRoomKit.h>`
  * `#import <StorageRoomKit/CoreData/CoreData.h>` (optional)
1. Build the project to verify installation is successful.


Run the Catalog Demo App
------------------------------

1. Initialize the repository with Git
  * Clone StorageRoomKit: `git clone git://github.com/thriventures/StorageRoomKit.git StorageRoomKit`
  * Go to the StorageRoomKit directory: `cd StorageRoomKit`
  * Check out the nested submodules (RestKit): `git submodule update --init --recursive`
1. Open the StorageRoomCatalog Xcode project in Examples/StorageRoomCatalog
1. Run the StorageRoomCatalog scheme


Basic Usage
------------------------------


This is a walkthrough with all steps for a simple usage scenario of the library.

1. Import the headers

        #import <StorageRoomKit/StorageRoomKit.h>
        #import <StorageRoomKit/CoreData/CoreData.h> // optionally include CoreData

1. Add the SREntry protocol to your custom class

        @interface Announcement : NSObject <SREntry> {

        }

        @property (nonatomic, retain) NSString * text;
        @property (nonatomic, retain) NSString * mUrl;

        @end

1. Implement the SREntry protocol methods

        + (RKObjectMapping *)objectMapping {
            RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];

            [mapping mapSRAttributes:@"text", nil];
            [mapping mapSRMetaData:@"url", nil]; // will map to mUrl

            return mapping;
        }

        + (NSString *)entryType {
            return @"Announcement";
        }

1. Create the ObjectManager

        [SRObjectManager objectManagerForAccountId:@"STORAGE_ROOM_ACCOUNT_ID" authenticationToken:@"AUTHENTICATION_TOKEN"];

1. Work with API Resources

        [[RKObjectManager sharedManager] loadObjectsAtResourcePath:SRCollectionEntriesPath(@"COLLECTION_ID") delegate:self];    

1. Do something with the returned object(s) in the delegate

        - (void)objectLoader:(RKObjectLoader *)anObjectLoader didLoadObject:(Announcement *)anAnnouncement {
            self.announcementLabel.text = anAnnouncement.text;
        }


Meta Data
------------------------------

The JSON representations of Resources in the StorageRoom API contain meta data attributes that are prefixed with an "@" character. An example for this is the 
"@created_at" meta data attribute, which shows the time at which a Resource was created on the server.

RestKit relies heavily on Key-Value Coding (KVC), but "@" is an invalid character in KVC. The StorageRoom API therefore allows to change the prefix used for 
meta data. StorageRoomKit changes this prefix for you from "@" to "m_". In the internal classes used by StorageRoom meta data attributes are mapped to an
instance variable with the "m" prefix (e.g. "m_created_at" will be mapped to "mCreatedAt"). You can follow this convention in your own Entry classes,
but you are not required to.


Documentation
------------------------------

Run "rake docs:install" to generate the AppleDoc from the source files and install it into Xcode.

The StorageRoom API Documentation (http://storageroomapp.com/developers) contains further information about the web service.


StorageRoom without StorageRoomKit
------------------------------

If you just need a small amount of content in your app and think this library is to heavy-weight you can also parse the JSON manually without StorageRoomKit. An example for this is on https://github.com/thriventures/simple_iphone_example.


Usage Examples
------------------------------

The Example folder contains detailed examples on how to use StorageRoomKit.

Running Specs
------------------------------

StorageRoomKit comes with Kiwi Specs. Run the Specs with Product > Test.


TODO
------------------------------

Please refer to TODO file.


Bugs and Feedback
------------------------------

Please create an issue on GitHub if you discover any bugs.

http://github.com/thriventures/StorageRoomKit/issues

License
------------------------------

MIT License. Copyright 2011 Thriventures UG (haftungsbeschränkt) - http://www.thriventures.com
