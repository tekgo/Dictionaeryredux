//
//  dictMasterViewController.h
//  Dictionaeryplus
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class dictDetailViewController;

@interface dictMasterViewController : UITableViewController

@property (strong, nonatomic) dictDetailViewController *detailViewController;

@end
