//
//  ImageListViewController.m
//
//  Created by Jonathan Reeves on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageListViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "Place.h"
#import "Photo.h"

@interface ImageListViewController()
{
    NSArray *_sections;
    NSManagedObjectContext *_context;
}

@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end


@implementation ImageListViewController

@synthesize imageList;
@synthesize sections = _sections;
@synthesize context = _context;

- (void)setImageList:(NSArray *)anImageList
{
    [imageList release];
    imageList = [anImageList copy];
    [self.tableView reloadData];
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
    self.imageList = nil;
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
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageList.count;
}

- (NSString *)imageTitleAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.imageList objectAtIndex:indexPath.row] objectForKey:@"title"];
}

- (NSString *)imageDescriptionAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[self.imageList objectAtIndex:indexPath.row] objectForKey:@"description"] objectForKey:@"_content"];
}

- (NSDictionary *)imageInfoAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.imageList objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageListTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *title = [self imageTitleAtIndexPath:indexPath];
    NSString *desc = [self imageDescriptionAtIndexPath:indexPath];
   
    if (desc.length == 0 && title.length == 0)
    {
        title = @"unknown";
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = desc;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (!cell.imageView.image)
    {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *imageData = [FlickrFetcher imageDataForPhotoWithFlickrInfo:[self imageInfoAtIndexPath:indexPath] format:FlickrFetcherPhotoFormatSquare];
            dispatch_async(dispatch_get_main_queue(), ^{            
                UIImage *image = [UIImage imageWithData:imageData];
                cell.imageView.image = image;
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
        dispatch_release(downloadQueue);
    }
    
//    UIImage *thumbnail = [UIImage imageWithData:[FlickrFetcher imageDataForPhotoWithFlickrInfo:[self imageInfoAtIndexPath:indexPath] format:FlickrFetcherPhotoFormatSquare]];
//    cell.imageView.image = thumbnail;
    
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


- (void)saveContext {
    
    NSError *error = nil;
    if (self.context != nil) {
        if ([self.context hasChanges] && ![self.context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *flickrInfo = [self imageInfoAtIndexPath:indexPath];
    ImageViewController *imageVC = [[ImageViewController alloc] init];
        
    // Get this photo from the database or add it if it doesn't exist.
    Photo *curPhoto = [Photo photoWithFlickrData:flickrInfo andPlaceName:self.title
        inManagedObjectContext:self.context];
    
    imageVC.photo = curPhoto;
    
    [self saveContext];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:imageVC animated:YES];
    [imageVC release];
}

@end
