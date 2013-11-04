//
//  Photo.m
//  CDPlaces
//
//  Created by Jonathan Reeves on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "Place.h"
#import "FlickrFetcher.h"


@implementation Photo

@dynamic favorite;
@dynamic photo_id;
@dynamic photo_url;
@dynamic last_viewed;
@dynamic photographer;
@dynamic place_taken;
@dynamic thumbnail;
@dynamic title;

+ (Photo *)photoWithFlickrData:(NSDictionary *)flickrData andPlaceName:(NSString *)placeName inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"photo_id = %@", 
                         [flickrData objectForKey:@"id"]];
	
	NSError *error = nil;
	photo = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
    
    // if we get a photo back from the database, we've already viewed it.
    // Otherwise we need to create the entry.
	if (!error && !photo) {
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        
        photo.favorite = [NSNumber numberWithBool:NO];
		photo.photo_id = [flickrData objectForKey:@"id"];

		photo.photo_url = [FlickrFetcher urlStringForPhotoWithFlickrInfo:flickrData format:FlickrFetcherPhotoFormatLarge];
        photo.last_viewed = [NSDate date];
        photo.photographer = [flickrData objectForKey:@"ownername"];
        
        // find this place in the database as well, or create it if it doesn't exist:
        photo.place_taken = [Place placeWithPlaceId:[flickrData objectForKey:@"place_id"] andTitle:placeName inManagedObjectContext:context];
        
        // queue up an image download so we don't block the main thread.
        photo.thumbnail = nil;
        dispatch_queue_t downloadQueue = dispatch_queue_create("Thumb downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *imageData = [FlickrFetcher imageDataForPhotoWithFlickrInfo:flickrData format:FlickrFetcherPhotoFormatSquare];
            dispatch_async(dispatch_get_main_queue(), ^{
                photo.thumbnail = imageData;
            });
        });
        dispatch_release(downloadQueue);
        
        photo.title = [flickrData objectForKey:@"title"];
	}
	
	return photo;
}



// since the "Place" object has a field to tell if it has any favorites, we need to have a
// special method for setting the "favorite" attribute of this managed object, and then
// look at the place via the inverse relationship, setting its "has_favorites" field
// appropriately.
- (void)markFavorite:(BOOL)newVal
{
    BOOL curVal = [self.favorite boolValue];
    
    // ignore requests to set the same value (i.e. doing nothing)
    if (curVal != newVal)
    {
        self.favorite = [NSNumber numberWithBool:newVal];
        
        if (newVal)
        {
            self.place_taken.has_favorites = [NSNumber numberWithBool:YES];
            [self.place_taken addFavorite_photos_at_placeObject:self];
        }
        else
        {
            // we're going to remove this photo as a favorite. Assume it's the last one,
            // in which case we would remove the "has_favorites" attribute. Then test that
            // assumption and cancel if there are still others.
            NSSet *photoList = self.place_taken.favorite_photos_at_place;
            BOOL hasFavorites = NO;
            for (Photo *photo in photoList)
            {
                if ([photo.favorite boolValue])
                {
                    hasFavorites = YES;
                }
            }
            
            if (!hasFavorites)
            {
                self.place_taken.has_favorites = [NSNumber numberWithBool:NO];
            }
        }
    }

}

@end
