//
//  Photo.h
//  CDPlaces
//
//  Created by Jonathan Reeves on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * photo_id;
@property (nonatomic, retain) NSString * photo_url;
@property (nonatomic, retain) NSDate * last_viewed;
@property (nonatomic, retain) NSString * photographer;
@property (nonatomic, retain) Place * place_taken;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * title;

+ (Photo *)photoWithFlickrData:(NSDictionary *)flickrData andPlaceName:(NSString *)placeName inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)markFavorite:(BOOL)newVal;

@end
