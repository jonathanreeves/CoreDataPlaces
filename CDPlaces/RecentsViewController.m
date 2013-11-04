//
//  PhotographersTableViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor on 10/28/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "RecentsViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "Photo.h"

@implementation RecentsViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Photo"
                                     inManagedObjectContext:context];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"last_viewed" ascending:NO]];
        
        // only show stuff from within the last 48 hours:
        NSDate *twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*48];
		request.predicate = [NSPredicate predicateWithFormat:@"last_viewed >= %@", twoDaysAgo];
		request.fetchBatchSize = 20;
		
		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
			initWithFetchRequest:request
			managedObjectContext:context
			  sectionNameKeyPath:nil
					   cacheName:nil];

		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"title";
		self.searchKey = @"title";
	}
	return self;
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
    Photo *photo = (Photo *)managedObject;
    return [UIImage imageWithData:photo.thumbnail];
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
	Photo *photo = (Photo *)managedObject;
    
    // update the "last_viewed" property:
    photo.last_viewed = [NSDate date]; // FIXME: save context?
    
    // and show a viewer for this image:
    ImageViewController *imageVC = [[ImageViewController alloc] init];
    
    imageVC.photo = photo;
    
    // Pass the selected object to the image view controller.
    [self.navigationController pushViewController:imageVC animated:YES];
    [imageVC release];
}

@end
