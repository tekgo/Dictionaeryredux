//
//  dictMasterViewController.h
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class dictDetailViewController;

@interface dictMasterViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    NSString *currentFilter;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)setFilter:(NSString*)filter;

@end
