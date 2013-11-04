//
//  Place.m
//  CDPlaces
//
//  Created by Jonathan Reeves on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"


@implementation Place

@dynamic city_name;
@dynamic has_favorites;
@dynamic latitude;
@dynamic longitude;
@dynamic place_id;
@dynamic region_name;
@dynamic favorite_photos_at_place;

+ (NSArray *)getPlaceNameAndDescription:(NSString *)fullPlace
{
    NSArray *fullStringDivided = [fullPlace componentsSeparatedByString:@","];
    NSString *placeName = [fullStringDivided objectAtIndex:0];

    NSMutableString *subtitle = [[[NSMutableString alloc] init] autorelease];

    if (fullStringDivided.count > 1)
    {
        [subtitle appendString:[fullStringDivided objectAtIndex:1]];
        int i;
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
    
    return [NSArray arrayWithObjects:placeName,subtitle,nil];
}




+ (Place *)placeWithFlickrInfo:(NSDictionary *)flickrData
           inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"place_id = %@",
                         [flickrData objectForKey:@"place_id"]];
	
	NSError *error = nil;
	place = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
    
    // if we get a photo back from the database, we've already viewed it.
    // Otherwise we need to create the entry.
	if (!error && !place) {
		place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:context];
        NSArray *nameAndDescription = [Place getPlaceNameAndDescription:[flickrData objectForKey:@"_content"]];
        
        place.city_name = [nameAndDescription objectAtIndex:0];
        place.has_favorites = [NSNumber numberWithBool:NO];
//        place.latitude = ;
//        place.longitude = ;
		place.place_id = [flickrData objectForKey:@"place_id"];
        place.region_name = [nameAndDescription objectAtIndex:1];
        // note that favorite_photos_at_place will be filled in as they are viewed and marked
	}
	
	return place;
}




+ (Place *)placeWithPlaceId:(NSString *)placeId andTitle:(NSString *)placeTitle
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"place_id = %@", placeId];
	
	NSError *error = nil;
	place = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
    
    // if we get a photo back from the database, we've already viewed it.
    // Otherwise we need to create the entry.
	if (!error && !place) {
		place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:context];
        NSArray *nameAndDescription = [Place getPlaceNameAndDescription:placeTitle];
        
        place.city_name = [nameAndDescription objectAtIndex:0];
        place.has_favorites = [NSNumber numberWithBool:NO];
        //        place.latitude = ;
        //        place.longitude = ;
		place.place_id = placeId;
        place.region_name = [nameAndDescription objectAtIndex:1];
        // note that favorite_photos_at_place will be filled in as they are viewed and marked
	}
	
	return place;
}


// This method will only return a Place object if it already exists in the database,
// unlike the methods above which will create it if it doesn't exist.
+ (Place *)existingPlaceWithPlaceId:(NSString *)placeId
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"place_id = %@", placeId];
	
	NSError *error = nil;
	place = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return place;
}

@end
