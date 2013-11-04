//
//  ImageListViewController.m
//  Places
//
//  Created by Jonathan Reeves on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "ImageListViewController.h"
#import "Place.h"

@interface TopPlacesViewController()
{
    NSArray *_places;
    NSArray *_sections;
    NSManagedObjectContext *_context;
}

@property (nonatomic, retain) NSArray *places;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end


@implementation TopPlacesViewController

@synthesize places = _places;
@synthesize sections = _sections;
@synthesize context = _context;

- (NSArray *)places
{
    if (!_places)
    {
        // all Flickr queries should have network activity indicated:
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *unsortedPlaces = [FlickrFetcher topPlaces];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"_content" ascending:YES]autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sort,nil];
        _places = [[unsortedPlaces sortedArrayUsingDescriptors:sortDescriptors] retain];
        
        //NSLog(@"%@", _places);
    }
    return _places;
}

- (NSArray *)sections
{
	if (!_sections) {
// TODO: implement this...
//		sections = [[self.places sortedArrayUsingSelector:@selector(compare:)] retain];
	}
	return _sections;
}


- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.context = context;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.places = nil;
    self.context = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.places.count;
}

- (NSDictionary *)placeDataAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.places objectAtIndex:indexPath.row];
}

- (NSString *)placeAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.places objectAtIndex:indexPath.row] objectForKey:@"_content"];
}

- (NSString *)placeIDAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.places objectAtIndex:indexPath.row] objectForKey:@"place_id"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacesTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

//FIXME: this code is shared with Place.m, should probably go somewhere common.
    NSString *fullPlace = [self placeAtIndexPath:indexPath];
    NSArray *fullStringDivided = [fullPlace componentsSeparatedByString:@","];
	cell.textLabel.text = [fullStringDivided objectAtIndex:0];
    int i;
    NSMutableString *subtitle = [[[NSMutableString alloc] init] autorelease];
    
    if (fullStringDivided.count > 1)
    {
        [subtitle appendString:[fullStringDivided objectAtIndex:1]];
        for (i = 2; i < fullStringDivided.count; i++)
        {
            [subtitle appendString:[@"," stringByAppendingFormat:
                                    [fullStringDivided objectAtIndex:i]]];
        }
    }
    
    if (subtitle.length == 0)
    {
        [subtitle appendString:@"unknown"];
    }
    cell.detailTextLabel.text = subtitle;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageListViewController *ivc = [[ImageListViewController alloc] 
                                    initInManagedObjectContext:self.context];

    dispatch_queue_t downloadQueue = dispatch_queue_create("List Loader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *imageList = [FlickrFetcher photosAtPlace:[self placeIDAtIndexPath:indexPath]];
        dispatch_async(dispatch_get_main_queue(), ^{            
            ivc.imageList = imageList;
        });
    });
    dispatch_release(downloadQueue);
    
    
    ivc.title = [self placeAtIndexPath:indexPath];
    [self.navigationController pushViewController:ivc animated:YES];
    [ivc release];
}

@end
