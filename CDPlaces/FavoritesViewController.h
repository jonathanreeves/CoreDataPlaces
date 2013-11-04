//
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"

@interface FavoritesViewController : CoreDataTableViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
