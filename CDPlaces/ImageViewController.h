//
//  ImageViewController.h
//  Places
//
//  Created by Jonathan Reeves on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate>
{
    Photo *_photo;
}

@property (nonatomic, retain) Photo *photo;

@end
