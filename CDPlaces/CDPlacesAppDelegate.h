//
//  CDPlacesAppDelegate.h
//  CDPlaces
//
//  Created by Jonathan Reeves on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDPlacesAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UITabBarController *_rootTabBar;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) UITabBarController *rootTabBar;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
