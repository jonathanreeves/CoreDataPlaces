//
//  Place.h
//  CDPlaces
//
//  Created by Jonathan Reeves on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * city_name;
@property (nonatomic, retain) NSNumber * has_favorites;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSString * region_name;
@property (nonatomic, retain) NSSet *favorite_photos_at_place;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addFavorite_photos_at_placeObject:(NSManagedObject *)value;
- (void)removeFavorite_photos_at_placeObject:(NSManagedObject *)value;
- (void)addFavorite_photos_at_place:(NSSet *)values;
- (void)removeFavorite_photos_at_place:(NSSet *)values;

+ (Place *)placeWithFlickrInfo:(NSDictionary *)flickrData
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)placeWithPlaceId:(NSString *)placeId andTitle:(NSString *)placeTitle
     inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)existingPlaceWithPlaceId:(NSString *)placeId
             inManagedObjectContext:(NSManagedObjectContext *)context;

@end
