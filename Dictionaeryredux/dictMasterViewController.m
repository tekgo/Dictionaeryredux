//
//  dictMasterViewController.m
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import "dictMasterViewController.h"
#import "dictDataStore.h"


@interface dictMasterViewController () {
    NSArray *_objects;
    NSArray *_filteredObjects;
}
@end

@implementation dictMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    if(!_objects)
        _objects = [[dictDataStore sharedDataStore] DataforFilter:Nil maxLength:2];
    else
    {
        float delta = self.searchBar.frame.size.height;
        self.searchBar.frame = CGRectOffset(self.searchBar.frame, 0.0, -delta);
        self.searchBar.hidden = YES;
        [self.tableView setContentInset:UIEdgeInsetsMake(-delta,0,0,0)];
    }
    if(!_filteredObjects)
        _filteredObjects = [NSArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredObjects.count;
    }
    else {
        return _objects.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 44;
    }
    else {
        NSDictionary *object = _objects[indexPath.row];
        
        if(currentFilter) {
            if([currentFilter isEqualToString:object[@"traumae"]]) {
                NSString *str = [(NSArray*)object[@"englishWords"] componentsJoinedByString:@"\n"];
                UILabel *gettingSizeLabel = [[UILabel alloc] init];
                gettingSizeLabel.font = [UIFont systemFontOfSize:17.0];
                gettingSizeLabel.text = str;
                gettingSizeLabel.numberOfLines = 0;
                gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
                CGSize maximumLabelSize = CGSizeMake(310, 9999);
                
                CGSize size = [gettingSizeLabel sizeThatFits:maximumLabelSize];
                return size.height + 66;
               // return 88;
            }
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    
    NSDictionary *object;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        object = _filteredObjects[indexPath.row];
    }
    else {
        
        object = _objects[indexPath.row];
        
        if(currentFilter) {
            if([currentFilter isEqualToString:object[@"traumae"]]) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
                UILabel* detailsTraumae = (UILabel*)[cell viewWithTag:100];
                detailsTraumae.font = [UIFont fontWithName:@"Septambres-Revisit" size:24];
                detailsTraumae.text = [self toQwerty:object[@"traumae"]];
                
                ((UILabel*)[cell viewWithTag:300]).text = object[@"traumae"];
                
                ((UILabel*)[cell viewWithTag:400]).text = [(NSString*)object[@"adultspeak"] uppercaseString] ;
                ((UILabel*)[cell viewWithTag:400]).font = [UIFont fontWithName:@"Didot-Bold" size:28];
                
                if(object[@"englishWords"]) {
                    ((UILabel*)[cell viewWithTag:200]).text = [(NSArray*)object[@"englishWords"] componentsJoinedByString:@"\n"];
                    [((UILabel*)[cell viewWithTag:200]) sizeToFit];
                }
                [cell sizeToFit];
                
            }
            
        }
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
        
        /*if([object[@"children"] intValue] == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }*/
        
    }
    
    cell.textLabel.text = object[@"traumae"];
    if(object[@"english"]) {
        cell.detailTextLabel.text = object[@"english"];
    }
    
    
    
    
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *object;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return indexPath;
    }
    else {
        object = _objects[indexPath.row];
    }
    
    if(currentFilter) {
        if([currentFilter isEqualToString:object[@"traumae"]])
            return nil;
    }
    /*if([object[@"children"] intValue] == 0) {
        return nil;
    }*/
    
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSDictionary *object;
        if (self.searchDisplayController.active) {
            object = [_filteredObjects objectAtIndex: self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            object = _objects[indexPath.row];
        }
        
        [(dictMasterViewController*)[segue destinationViewController] setFilter:object[@"traumae"]];
    }
}

-(void)setFilter:(NSString*)filter {
    if(filter) {
    _objects = [[dictDataStore sharedDataStore] DataforFilter:filter maxLength:(int)filter.length+2];
    
    [self setTitle:filter];
    currentFilter = filter;
        [self.tableView reloadData];
        //self.searchBar.hidden=true;
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    _filteredObjects = [[dictDataStore sharedDataStore] DataForSearch:searchText];
    /*
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredCandyArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    filteredCandyArray = [NSMutableArray arrayWithArray:[candyArray filteredArrayUsingPredicate:predicate]];
     */
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (NSString*) toQwerty :(NSString*)traumae
{
	NSString *fixed = traumae;
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xi" withString:@"w"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"di" withString:@"t"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bi" withString:@"i"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xa" withString:@"s"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"da" withString:@"g"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ba" withString:@"k"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xo" withString:@"x"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"do" withString:@"b"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bo" withString:@","];
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ki" withString:@"q"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ti" withString:@"r"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pi" withString:@"u"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ka" withString:@"a"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ta" withString:@"f"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pa" withString:@"j"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ko" withString:@"z"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"to" withString:@"v"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"po" withString:@"m"];
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"si" withString:@"e"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"li" withString:@"y"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vi" withString:@"o"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"sa" withString:@"d"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"la" withString:@"h"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"va" withString:@"l"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"so" withString:@"c"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"lo" withString:@"n"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vo" withString:@"."];
    
	return fixed;
	
}

@end
