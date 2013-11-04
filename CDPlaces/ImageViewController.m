//
//  ImageViewController.m
//  Places
//
//  Created by Jonathan Reeves on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"

@interface ImageViewController()
{
    UIImageView *imageView;
    UIScrollView *scrollView;
    UIButton *favButton;
    NSData *imgData;
    UIActivityIndicatorView *spinningWheel; 
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIButton *favButton;
@property (nonatomic, retain) NSData *imgData;
@property (nonatomic, retain) UIActivityIndicatorView *spinningWheel;

@end

@implementation ImageViewController

@synthesize photo = _photo;
@synthesize imageView;
@synthesize scrollView;
@synthesize favButton;
@synthesize imgData;
@synthesize spinningWheel;


// utility functions:
- (BOOL) saveFileWithPhoto:(Photo *)photo
{
    NSString *pathBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject];
    NSString *path = [pathBase stringByAppendingPathComponent:photo.photo_id];
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL status = [fm createFileAtPath:path contents:self.imgData attributes:nil];
    
    if (!status)
    {
        NSLog(@"error: couldn't create cache file at path:%@", path);
    }
    [fm release];
    return status;
}

- (BOOL) removeFileWithPhoto:(Photo *)photo
{
    NSString *pathBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject];
    NSString *path = [pathBase stringByAppendingPathComponent:photo.photo_id];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL status = [fm removeItemAtPath:path error:&error];
    BOOL trueStatus = YES;
    
    if (!status && !error)
    {
        NSLog(@"error: couldn't remove file at path:%@", path);
        trueStatus = NO;
    }
    [fm release];
    return trueStatus;
}

- (NSData *)readFileWithPhoto:(Photo *)photo
{
    NSString *pathBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject];
    NSString *path = [pathBase stringByAppendingPathComponent:photo.photo_id];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSData *data = [fm contentsAtPath:path];
    [fm release];
    return data;
}



- (UIImageView *)imageView
{
    if (!imageView)
    {
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        imageView = [[UIImageView alloc] initWithFrame:applicationFrame];
    }
    return imageView;
}

- (UIActivityIndicatorView *)spinningWheel
{
    if (!spinningWheel)
    {
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        spinningWheel = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinningWheel.frame = applicationFrame;
    }
    return spinningWheel;
}

- (UIScrollView *)scrollView
{
    if (!scrollView)
    {
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        scrollView = [[UIScrollView alloc] initWithFrame:applicationFrame];
        
        scrollView.bounces = YES;
        
        scrollView.delegate = self;
        [scrollView addSubview:self.imageView];
    }
    return scrollView;
}

- (void)toggleSpinningWheel
{
    if (self.spinningWheel.hidden)
    {
        self.spinningWheel.hidden = NO;
        self.scrollView.hidden = YES;
        [self.spinningWheel startAnimating];
    }
    else
    {
        [self.spinningWheel stopAnimating];    
        self.spinningWheel.hidden = YES;
        self.scrollView.hidden = NO;
    }
}

- (void)setPhoto:(Photo *)photo
{
    
    [_photo release];
    _photo = [photo retain];
    
    // Get the photo data. If this photo is a favorite, then it should be loaded from the
    // cache. If it's not, get it from Flickr. Any Flickr query should have network activity
    // indicated:
    
    if ([photo.favorite boolValue])
    {
        self.imgData = [self readFileWithPhoto:photo];
        UIImage *image = [UIImage imageWithData:self.imgData];
        self.imageView.image = image;
        
        [self.imageView sizeToFit];
        self.scrollView.contentSize = self.imageView.image.size;
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.contentOffset = CGPointZero;
        
        [self.view setNeedsDisplay];
    }
    else
    {        
        NSString *urlCopy = photo.photo_url;
        dispatch_queue_t downloadQueue = dispatch_queue_create("Image downloader", NULL);
        
        [self toggleSpinningWheel];
        dispatch_async(downloadQueue, ^{
            NSData *imageData = [FlickrFetcher imageDataForPhotoWithURLString:urlCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgData = imageData;
                UIImage *image = [UIImage imageWithData:self.imgData];
                self.imageView.image = image;
                
                [self.imageView sizeToFit];
                self.scrollView.contentSize = self.imageView.image.size;
                self.scrollView.contentInset = UIEdgeInsetsZero;
                self.scrollView.contentOffset = CGPointZero;
                
                [self toggleSpinningWheel];
                
                [self.view setNeedsDisplay];
            });
        });
        
        dispatch_release(downloadQueue);
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




- (void) buttonPressed
{
    BOOL curValue = [self.photo.favorite boolValue];
    curValue = !curValue;
    
    // if we're about to mark this photo as a favorite, we need to cache it.
    // otherwise we need to delete the cached photo which is already there.
    if (curValue)
    {
        if (![self saveFileWithPhoto:self.photo])
        {
            // exception
        }
    }
    else
    {
        if (![self removeFileWithPhoto:self.photo])
        {
            // exception
        }
    }
    
    [self.photo markFavorite:curValue];
    self.favButton.selected = curValue;
}

#pragma mark - View lifecycle

#define FAV_BUTTON_HEIGHT 30
#define FAV_BUTTON_WIDTH 100

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    
    self.favButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //set the position of the button
    self.favButton.frame = CGRectMake(0, 0, FAV_BUTTON_WIDTH, FAV_BUTTON_HEIGHT);
    
    //set the button's title
    [self.favButton setTitle:@"Favorite" forState:UIControlStateNormal];
    
    //listen for clicks
    [self.favButton addTarget:self action:@selector(buttonPressed) 
             forControlEvents:UIControlEventTouchUpInside];
    
    self.favButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin;
    
    [self.favButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateSelected];
    [self.favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    //add the button to the view
    [self.view addSubview:self.favButton];
    
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleHeight);
    
    self.spinningWheel.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin);

    [self.view addSubview:self.spinningWheel];
    [self.view addSubview:self.scrollView];
    
    self.spinningWheel.hidden = YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}



- (void)centerImageInScrollView:(UIScrollView *)scrollView
{
	CGFloat offsetX, offsetY;
    
    if (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)
    {
        offsetX = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5;
    }
    else
    {
        offsetX = 0.0;
    }
    
    if (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)
    {
        offsetY = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5;
    }
    else
    {
        offsetY = 0.0;
    }
    
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, 
                                   self.scrollView.contentSize.height * 0.5 + offsetY);	
}


- (void)setInitialZoom:(UIScrollView *)scrollView
{
	CGSize scrollSize = self.scrollView.bounds.size;
	CGFloat widthRatio = scrollSize.width / self.imageView.image.size.width;
	CGFloat heightRatio = scrollSize.height / self.imageView.image.size.height;
	CGFloat initialZoom;
    
    if (widthRatio > heightRatio)
    {
        initialZoom = heightRatio;
    }
    else
    {
        initialZoom = widthRatio;
    }
    
	self.scrollView.minimumZoomScale = initialZoom;
	self.scrollView.maximumZoomScale = 2.0;
	self.scrollView.zoomScale = initialZoom;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale
{
    [self centerImageInScrollView:aScrollView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat favButtonX = (self.view.bounds.size.width - FAV_BUTTON_WIDTH)/2;
    CGFloat favButtonY = (self.view.bounds.size.height - FAV_BUTTON_HEIGHT);
    self.favButton.frame = CGRectMake(favButtonX, favButtonY, FAV_BUTTON_WIDTH, FAV_BUTTON_HEIGHT);
    
    if (self.photo)
    {
        self.favButton.selected = [self.photo.favorite boolValue];
    }
    
    CGFloat scrollWidth = self.view.bounds.size.width;
    CGFloat scrollHeight = self.view.bounds.size.height - FAV_BUTTON_HEIGHT;
    self.scrollView.frame = CGRectMake(0, 0, scrollWidth, scrollHeight); 
    
    [self setInitialZoom:self.scrollView];
    [self centerImageInScrollView:self.scrollView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.scrollView = nil;
    self.favButton = nil;
    self.spinningWheel = nil;
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setInitialZoom:self.scrollView];
	[self centerImageInScrollView:self.scrollView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
