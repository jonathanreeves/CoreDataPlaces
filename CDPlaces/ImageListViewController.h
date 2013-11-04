//
//  ImageListViewController.h
//  Places
//
//  Created by Jonathan Reeves on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageListViewController : UITableViewController
{
    NSArray *imageList; // this is the "model"
}

@property (nonatomic, copy) NSArray *imageList;

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
