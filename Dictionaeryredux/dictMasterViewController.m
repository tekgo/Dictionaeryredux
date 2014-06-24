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

    if(!_objects) {
        _objects = [[dictDataStore sharedDataStore] DataforFilter:Nil maxLength:2];
    }
    else
    {

        self.tableView.tableHeaderView = nil;
        
    }
    if(!_filteredObjects) {
        _filteredObjects = [NSArray new];
    }
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
        dictTraumaeWord *object = _objects[indexPath.row];
        
        if(currentFilter) {
            if([currentFilter isEqualToString:object.traumae]) {
                NSString *str = [object.alternatives componentsJoinedByString:@"\n"];
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
    
    
    
    dictTraumaeWord *object;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        object = _filteredObjects[indexPath.row];
        
    }
    else {
        
        object = _objects[indexPath.row];
        
        if(currentFilter) {
            if([currentFilter isEqualToString:object.traumae]) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor blackColor];
                UILabel* detailsTraumae = (UILabel*)[cell viewWithTag:100];
                UIFont *font =[UIFont fontWithName:@"Septambres-Revisit" size:24];
                detailsTraumae.font = font;
                detailsTraumae.text = object.qwertyString;
                
                ((UILabel*)[cell viewWithTag:300]).text = object.traumae ;
                
                ((UILabel*)[cell viewWithTag:400]).text = [object.adultspeak uppercaseString] ;
                ((UILabel*)[cell viewWithTag:400]).font = [UIFont fontWithName:@"Didot-Bold" size:28];
                
                if(object.alternatives) {
                    ((UILabel*)[cell viewWithTag:200]).text = [object.alternatives componentsJoinedByString:@"\n"];
                    [((UILabel*)[cell viewWithTag:200]) sizeToFit];
                }
                //[cell sizeToFit];
                return cell;
            }
            
            
        }
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    
        
    }
    
    cell.textLabel.text = object.traumae;
    if(object.english) {
        cell.detailTextLabel.text = object.english;
    }
    
    
    
    
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return indexPath;
    }
    
    dictTraumaeWord *object = _objects[indexPath.row];
    
    if(currentFilter) {
        if([currentFilter isEqualToString:object.traumae])
            return nil;
    }

    
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        dictTraumaeWord *object = _objects[indexPath.row];
        
        [(dictMasterViewController*)[segue destinationViewController] setFilter:object.traumae];
    }
    if ([[segue identifier] isEqualToString:@"searchDetail"]) {
        dictTraumaeWord *object = [_filteredObjects objectAtIndex: self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
        [(dictMasterViewController*)[segue destinationViewController] setFilter:object.traumae];
    }
}

-(void)setFilter:(NSString*)filter {
    if(filter) {
        _objects = [[dictDataStore sharedDataStore] DataforFilter:filter maxLength:(int)filter.length+2];
        
        [self setTitle:[filter capitalizedString]];
        currentFilter = filter;
        [self.tableView reloadData];
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    _filteredObjects = [[dictDataStore sharedDataStore] DataForSearch:[searchText lowercaseString]];
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


@end
