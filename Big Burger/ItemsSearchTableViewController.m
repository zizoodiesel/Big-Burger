//
//  ItemsSearchTableViewController.m
//  Big Burger
//
//  Created by Zizoo diesel on 30/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "ItemsSearchTableViewController.h"
#import "Item.h"
#import "Image.h"


@interface ItemsSearchTableViewController ()

@end

@implementation ItemsSearchTableViewController

@synthesize delegate;

- (void)add:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_filteredItems objectAtIndex:indexPath.row];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    item.numberOfItems = item.numberOfItems + 1;
    
    ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(item.numberOfItems) stringValue];
    
    NSError *saveError;
    [context save:&saveError];
    
    
    if (self.delegate.numlabel.superview == NULL) {
        self.delegate.numlabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 20, 18)];
        self.delegate.numlabel.backgroundColor = [UIColor redColor];
        self.delegate.numlabel.layer.cornerRadius = 4.0;
        self.delegate.numlabel.clipsToBounds = YES;
        self.delegate.numlabel.textColor = [UIColor whiteColor];
        self.delegate.numlabel.font = [UIFont systemFontOfSize:14];
        [self.delegate.checkOutButton addSubview:self.delegate.numlabel];
    }
    
    self.delegate.numlabel.text = [@([self.delegate.numlabel.text intValue] + 1) stringValue];
    self.delegate.sumOfCheckedItems = [self.delegate.numlabel.text intValue];
    [self.delegate.numlabel sizeToFit];
    [((UITableViewController*)[self delegate]).tableView reloadData];
    
    
}

- (void)remove:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_filteredItems objectAtIndex:indexPath.row];
    
    if (item.numberOfItems > 0) {
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
        
        item.numberOfItems = item.numberOfItems - 1;
        
        ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(item.numberOfItems) stringValue];
        
        NSError *saveError;
        [context save:&saveError];
        
    }
    
    if ([self.delegate.numlabel.text intValue] > 1) {
        self.delegate.numlabel.text = [@([self.delegate.numlabel.text intValue] - 1) stringValue];
        self.delegate.sumOfCheckedItems = [self.delegate.numlabel.text intValue];
    }
    else if ([self.delegate.numlabel.text intValue] == 1) {
        self.delegate.numlabel.text = @"0";
        self.delegate.sumOfCheckedItems = [self.delegate.numlabel.text intValue];
        [self.delegate.numlabel removeFromSuperview];
    }
    [self.delegate.numlabel sizeToFit];
    [((UITableViewController*)[self delegate]).tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 73.0; // average cell height
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_filteredItems count];
}

- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath {
    
    Item* item = [_filteredItems objectAtIndex:indexPath.row];
    
    ((UILabel*)[cell viewWithTag:101]).text = item.title;
    ((UILabel*)[cell viewWithTag:102]).text = item.desc;
    ((UILabel*)[cell viewWithTag:104]).text = [[NSString stringWithFormat:@"%.2f €", item.price / 100] stringByReplacingOccurrencesOfString:@"." withString:@","];
    ((UILabel*)[cell viewWithTag:111]).text = [@(item.numberOfItems) stringValue];
    
    AddRemoveButton* addButton = [cell viewWithTag:110];
    //keep track of the inedxPath of the cell
    addButton.cellIndexPath = indexPath;
    [addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    AddRemoveButton* removeButton = [cell viewWithTag:112];
    //keep track of the inedxPath of the cell
    removeButton.cellIndexPath = indexPath;
    [removeButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    
    if (item.thumbnail) {
        ((ZGImage*)[cell viewWithTag:103]).image = [UIImage imageWithData:item.thumbnail];
    }
    else {
        
        ((ZGImage*)[cell viewWithTag:103]).image = nil;
        NSManagedObjectID* itemObjectId = item.objectID;
        
        [(ZGImage*)[cell viewWithTag:103] downloadWithUrlString:item.imageURL completitionHendler:^(NSData* imageData, NSError* error) {
            
            UIImage* thumbnail = [ZGImage thumbnailFromData:imageData withSize:((ZGImage*)[cell viewWithTag:103]).frame.size];
            
            //Check if the cell is visible before assigning the image to the cell.
            if ([[self.tableView visibleCells] containsObject:[self.tableView cellForRowAtIndexPath:indexPath]])
            ((ZGImage*)[cell viewWithTag:103]).image = thumbnail;
            
            // Save image Object inside a background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
                
                NSManagedObjectContext* bgContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [bgContext setParentContext:context];
                
                [bgContext performBlockAndWait:^{
                    
                    Item* theItem = [bgContext objectWithID:itemObjectId];
                    theItem.thumbnail = [ZGImage imageDataFromImage:thumbnail];
                    
                    //Create an image NSManagedObject
                    Image* image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:bgContext];
                    image.image = imageData;
                    
                    theItem.image = image;
                    
                    NSError *saveError;
                    [bgContext save:&saveError];
                    
                    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:theItem.ref forKey:@"itemId"];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //post notification for detailViewController to reload the image
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"imageDownloaded" object:nil userInfo:userInfo];
                    });
                    
                    
                }];
                
            });
            
        }];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndex:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    
    Item* item = [_filteredItems objectAtIndex:indexPath.row];
    detailViewController.item = item;
    
    [((UITableViewController*)[self delegate]).navigationController pushViewController:detailViewController animated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
//    _searchArray = [searchText componentsSeparatedByString:@" "];
    
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Item"
                inManagedObjectContext:context];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    [fetchRequest setEntity:entityDesc];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"title BEGINSWITH[cd] %@ OR desc BEGINSWITH[cd] %@", searchText, searchText];

    
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    _filteredItems = [context executeFetchRequest:fetchRequest
                                               error:&error];
    
    
    [self.tableView reloadData];
    
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)theSearchController
{

    NSString *searchString = theSearchController.searchBar.text;
    
    if ([searchString length])
    [self filterContentForSearchText:searchString
                               scope:[[theSearchController.searchBar scopeButtonTitles]
                                      objectAtIndex:[theSearchController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
