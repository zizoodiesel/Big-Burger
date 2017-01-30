//
//  TableViewController.m
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)reloadTableView {
    
    NSError *error;
    if ([_controller performFetch:&error]) {
        
        [self.tableView reloadData];
        
    }
    
    _sumOfCheckedItems = [self sumOfCheckedItems];
    _numlabel.text = [@(_sumOfCheckedItems) stringValue];
    [_numlabel sizeToFit];
    
    if ([_numlabel.text intValue] == 0) {
        [_numlabel removeFromSuperview];
    }
}

- (void)add:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_controller objectAtIndexPath:indexPath];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    item.numberOfItems = item.numberOfItems + 1;
    
    ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(item.numberOfItems) stringValue];

    NSError *saveError;
    [context save:&saveError];
    
    
    if (_numlabel.superview == NULL) {
        _numlabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 20, 18)];
        _numlabel.backgroundColor = [UIColor redColor];
        _numlabel.layer.cornerRadius = 4.0;
        _numlabel.clipsToBounds = YES;
        _numlabel.textColor = [UIColor whiteColor];
        _numlabel.font = [UIFont systemFontOfSize:14];
        [_checkOutButton addSubview:_numlabel];
    }

    _numlabel.text = [@([_numlabel.text intValue] + 1) stringValue];
    _sumOfCheckedItems = [_numlabel.text intValue];
    [_numlabel sizeToFit];
    
    
}

- (void)remove:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_controller objectAtIndexPath:indexPath];
    
    if (item.numberOfItems > 0) {
    
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
        
        item.numberOfItems = item.numberOfItems - 1;
        
        ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(item.numberOfItems) stringValue];
        
        NSError *saveError;
        [context save:&saveError];
        
        if ([_numlabel.text intValue] > 1) {
            _numlabel.text = [@([_numlabel.text intValue] - 1) stringValue];
            _sumOfCheckedItems = [_numlabel.text intValue];
        }
        else if ([_numlabel.text intValue] == 1) {
            _numlabel.text = @"0";
            _sumOfCheckedItems = [_numlabel.text intValue];
            [_numlabel removeFromSuperview];
        }
        [_numlabel sizeToFit];
        
    }

    
}

- (void)bindDatas {
    
    NSLog(@"refreshingggg");
    
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..." attributes:attrsDictionary];
    
    self.refreshControl.attributedTitle = attributedTitle;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.refreshControl.attributedTitle = attributedTitle;
    }];
    
    [self beginRequest];
    
    

    
}

- (void)beginRequest {
    
    NSString* urlString = @"https://bigburger.useradgents.com/catalog";
    
    [AsyncConnection sendAsyncRequestWithUrl:urlString completitionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(self.refreshControl != nil && self.refreshControl.isRefreshing == TRUE)
        {
            [self.refreshControl endRefreshing];
            
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                        forKey:NSForegroundColorAttributeName];
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh" attributes:attrsDictionary];
            
            self.refreshControl.attributedTitle = attributedTitle;
            
        }
        
        if (!error) {
            
            NSError *jsonError = nil;
            NSArray* itemsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            
            AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
            
            
            
            //Remove the nonExistants items from the persistant store.
            NSArray* refs = [itemsArray valueForKeyPath:@"ref"];
            if ([refs count])
            [self removeItemsNonexistantsInRefs:refs];
            
            
            //Retrieve the existants items from the persistant store.
            NSArray* existantsRefs = [self existantsRefs];
            NSLog(@"existantsRefs: %@", existantsRefs);
            
            for (NSDictionary* dict in itemsArray) {
                
                
                //check if item already exists in the store
                if (![existantsRefs containsObject:[dict objectForKey:@"ref"]]) {
                    
                    
                    Item* item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:context];
                    
                    item.ref = [dict objectForKey:@"ref"];
                    item.title = [dict objectForKey:@"title"];
                    item.desc = [dict objectForKey:@"description"];
                    item.imageURL = [dict objectForKey:@"thumbnail"];
                    item.price = [[dict objectForKey:@"price"] doubleValue];
                    
                }
                
                
            }
            
            if ([context hasChanges]) {
                
                NSError *error = nil;
                [context save:&error];
                
                if ([_controller performFetch:&error]) {
                    
                    [self.tableView reloadData];
                    
                }
                
            }
            
        }
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //Create a search tableVIew
    ItemsSearchTableViewController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"itemsSearchTableViewController"];
    searchResultsController.delegate = (id)self;
    
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.mySearchController.searchResultsUpdater = searchResultsController;
    self.mySearchController.dimsBackgroundDuringPresentation = YES;
    self.mySearchController.definesPresentationContext = true;
    
    
    [self.mySearchController.searchBar sizeToFit];
    
    
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
    
    
    /*******************************************/
    /*                                         */
    /* We suppose attribute ref is a unique id */
    /*                                         */
    /*******************************************/
    
    
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Item"
                                                  inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDesc];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
   

    
    _controller = [[NSFetchedResultsController alloc]
                  initWithFetchRequest:fetchRequest
                  managedObjectContext:context
                  sectionNameKeyPath:nil
                  cacheName:nil];
    
    NSError *error;
    if ([_controller performFetch:&error]) {
        
        NSLog(@"[[_controller fetchedObjects] count] : %d", [[_controller fetchedObjects] count]);
        
    }

    //get the sum of checked items
    _sumOfCheckedItems = [self sumOfCheckedItems];
    
    if (_sumOfCheckedItems) {
        _numlabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 20, 18)];
        _numlabel.backgroundColor = [UIColor redColor];
        _numlabel.layer.cornerRadius = 4.0;
        _numlabel.clipsToBounds = YES;
        _numlabel.textColor = [UIColor whiteColor];
        _numlabel.font = [UIFont systemFontOfSize:14];
        [_checkOutButton addSubview:_numlabel];
        _numlabel.text = [@(_sumOfCheckedItems) stringValue];
        [_numlabel sizeToFit];
    }

    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 73.0; // average cell height
    
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh" attributes:attrsDictionary];
    
    refreshControl.attributedTitle = attributedTitle;
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(bindDatas) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    
    [self beginRequest];
    

}

- (void)removeItemsNonexistantsInRefs:(NSArray*)refsArray {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];

    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context]];

    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (ref IN %@)", refsArray]];

    NSError* error;
    NSArray* objects = [context executeFetchRequest:fetchRequest
                                           error:&error];
    
    for (Item* item in objects) {
        
        [context deleteObject:item];
        
    }
    
    if ([context hasChanges]) {
        
        NSError *error = nil;
        [context save:&error];

    }

}

- (NSArray*)existantsRefs {
    
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context]];

    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = @[@"ref"];
    

    NSError* error;
    NSArray* objects = [context executeFetchRequest:fetchRequest
                                           error:&error];
    
    
    
    return [objects valueForKeyPath:@"ref"];
}

- (int)sumOfCheckedItems {
    
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    expressionDescription.name = @"sumOfAmounts";
    expressionDescription.expression = [NSExpression expressionForKeyPath:@"@sum.numberOfItems"];
    expressionDescription.expressionResultType = NSDecimalAttributeType;
    
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = @[expressionDescription];
    
    
    NSError* error;
    NSArray* objects = [context executeFetchRequest:fetchRequest
                                              error:&error];
    
    
    if (error)
    {
        return 0;
    }
    else
    {
        return [[[objects objectAtIndex:0] objectForKey:@"sumOfAmounts"] intValue];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[_controller sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[_controller sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath {
    
    Item* item = [_controller objectAtIndexPath:indexPath];
    
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
    
    Item* item = [_controller objectAtIndexPath:indexPath];
    detailViewController.item = item;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"checkoutView"]) {
        
        CheckedTableViewController* checkedViewController = [[(UINavigationController*)[segue destinationViewController] viewControllers] objectAtIndex:0];
        checkedViewController.sumOfCheckedItems = _sumOfCheckedItems;
        checkedViewController.delegate = (id)self;
    }
    
}




@end
