//
//  PhotographersTableViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor on 10/28/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ImageListViewController.h"
#import "FavoritePhotosViewController.h"
#import "FlickrFetcher.h"
#import "Place.h"

@interface FavoritesViewController()
{
    NSManagedObjectContext *_context;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

@end

@implementation FavoritesViewController

@synthesize context = _context;

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
        self.context = context;
        
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		request.entity = [NSEntityDescription entityForName:@"Place"
                                     inManagedObjectContext:context];
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"city_name" ascending:YES]];
        
		request.predicate = [NSPredicate predicateWithFormat:@"has_favorites == YES"];
		request.fetchBatchSize = 20;
		
		NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
			initWithFetchRequest:request
			managedObjectContext:context
			  sectionNameKeyPath:nil
					   cacheName:nil];

		[request release];
		
		self.fetchedResultsController = frc;
		[frc release];
		
		self.titleKey = @"city_name";
        self.subtitleKey = @"region_name";
		self.searchKey = @"city_name";
	}
	return self;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
	Place *place = (Place *)managedObject;
    
    FavoritePhotosViewController *fpvc = [[FavoritePhotosViewController alloc] 
                                    initInManagedObjectContext:self.context withPlace:place];
    
    fpvc.title = place.city_name;
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:fpvc animated:YES];
    [fpvc release];
}

@end
