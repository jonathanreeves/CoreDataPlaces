//
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"

@interface RecentsViewController : CoreDataTableViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
