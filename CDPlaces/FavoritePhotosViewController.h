//
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"
#import "Place.h"

@interface FavoritePhotosViewController : CoreDataTableViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context withPlace:(Place *)place;

@end
