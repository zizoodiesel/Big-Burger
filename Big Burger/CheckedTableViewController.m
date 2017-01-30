//
//  CheckedTableViewController.m
//  Big Burger
//
//  Created by Zizoo diesel on 30/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "CheckedTableViewController.h"

@interface CheckedTableViewController ()

@end

@implementation CheckedTableViewController

@synthesize delegate;

- (IBAction)dismiss:(id)sender {
    
    //Reload the Main TableView
    [self.delegate reloadTableView];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)CheckOut:(id)sender {
    
    if ([[_controller fetchedObjects] count]) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Good Morning" message:@"Do you really need to purshase all these stuff!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
            
            
            [self clearBasket:nil];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Nah" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){

            
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    
    }
}

- (IBAction)clearBasket:(id)sender {
    
    //Clearing the basket using batchUpdate
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];

    
    NSBatchUpdateRequest *req = [[NSBatchUpdateRequest alloc] initWithEntityName:@"Item"];
    req.predicate = [NSPredicate predicateWithFormat:@"numberOfItems > %d", 0];
    req.propertiesToUpdate = @{
                               @"numberOfItems" : @(0)
                               };
    req.resultType = NSUpdatedObjectIDsResultType;
    NSBatchUpdateResult *res = (NSBatchUpdateResult *)[context executeRequest:req error:nil];
    
    [res.result enumerateObjectsUsingBlock:^(NSManagedObjectID *objId, NSUInteger idx, BOOL *stop) {
        NSManagedObject *obj = [context objectWithID:objId];
        if (!obj.isFault) {
            [context refreshObject:obj mergeChanges:YES];
        }
    }];

    
    NSError *error;
    if ([_controller performFetch:&error]) {
        
        [self.tableView reloadData];
        
    }
    
    _totalPrice = 0.;
    self.navigationItem.title = [[NSString stringWithFormat:@"%.2f €", _totalPrice / 100] stringByReplacingOccurrencesOfString:@"." withString:@","];
    [_numlabel removeFromSuperview];
    
    [self.delegate reloadTableView];
    
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
    [_numlabel sizeToFit];
    
    _totalPrice += item.price;
    self.navigationItem.title = [[NSString stringWithFormat:@"%.2f €", _totalPrice / 100] stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    
}

- (void)remove:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_controller objectAtIndexPath:indexPath];
    

        
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    item.numberOfItems = item.numberOfItems - 1;
    
    NSError *saveError;
    [context save:&saveError];
    
    NSError *error;
    if ([_controller performFetch:&error]) {
        
        if (item.numberOfItems == 0) {
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            
            //Update indexPaths assigned to the cell buttons
            for (UITableViewCell* cell in [self.tableView visibleCells]) {
                
                NSIndexPath* cellIndexPath = [self.tableView indexPathForCell:cell];
                
                AddRemoveButton* addButton = [cell viewWithTag:110];
                //keep track of the inedxPath of the cell
                addButton.cellIndexPath = cellIndexPath;
                
                
                AddRemoveButton* removeButton = [cell viewWithTag:112];
                //keep track of the inedxPath of the cell
                removeButton.cellIndexPath = cellIndexPath;
                
                AddRemoveButton* trashButton = [cell viewWithTag:113];
                //keep track of the inedxPath of the cell
                trashButton.cellIndexPath = cellIndexPath;
                
            }
            
        }
        else {
            ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(item.numberOfItems) stringValue];
        }
        
        
        
        if ([_numlabel.text intValue] > 1) {
            _numlabel.text = [@([_numlabel.text intValue] - 1) stringValue];
        }
        else if ([_numlabel.text intValue] == 1) {
            [_numlabel removeFromSuperview];
        }
        [_numlabel sizeToFit];
        
        _totalPrice -= item.price;
        self.navigationItem.title = [[NSString stringWithFormat:@"%.2f €", _totalPrice / 100] stringByReplacingOccurrencesOfString:@"." withString:@","];
        
    }
    
    
 

    
    
}

- (void)trash:(id)sender {
    
    AddRemoveButton* button = sender;
    NSIndexPath* indexPath = button.cellIndexPath;
    
    Item* item = [_controller objectAtIndexPath:indexPath];

        
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];

    int numberOfItemsToRemove = item.numberOfItems;
    item.numberOfItems = 0;
    
    ((UILabel*)[[self.tableView cellForRowAtIndexPath:button.cellIndexPath] viewWithTag:111]).text = [@(0) stringValue];
    
    NSError *saveError;
    [context save:&saveError];
    
    if ([_numlabel.text intValue] > 1) {
        _numlabel.text = [@([_numlabel.text intValue] - numberOfItemsToRemove) stringValue];
    }
    else if ([_numlabel.text intValue] == 1) {
        [_numlabel removeFromSuperview];
        
        
    }
    [_numlabel sizeToFit];
    
    NSError *error;
    if ([_controller performFetch:&error]) {
        
        NSLog(@"[[_controller fetchedObjects] count] : %d", [[_controller fetchedObjects] count]);
        
        
    }
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    //Update indexPaths assigned to the cell buttons
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        NSIndexPath* cellIndexPath = [self.tableView indexPathForCell:cell];
        
        AddRemoveButton* addButton = [cell viewWithTag:110];
        //keep track of the inedxPath of the cell
        addButton.cellIndexPath = cellIndexPath;

        
        AddRemoveButton* removeButton = [cell viewWithTag:112];
        //keep track of the inedxPath of the cell
        removeButton.cellIndexPath = cellIndexPath;
        
        AddRemoveButton* trashButton = [cell viewWithTag:113];
        //keep track of the inedxPath of the cell
        trashButton.cellIndexPath = cellIndexPath;
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Item"
                                                  inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDesc];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"numberOfItems > %d", 0]];
    
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
    
    //Get the total price
    _totalPrice = [self getTotalPrice];
    self.navigationItem.title = [[NSString stringWithFormat:@"%.2f €", _totalPrice / 100] stringByReplacingOccurrencesOfString:@"." withString:@","];
    
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
    
}

- (double)getTotalPrice {
    
    
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext:@"store.sqlite"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"numberOfItems > %d", 0]];
    
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = @[@"numberOfItems", @"price"];
    
    
    NSError* error;
    NSArray* objects = [context executeFetchRequest:fetchRequest
                                              error:&error];
    
    
    if (error)
    {
        return 0.;
    }
    else
    {
        
        
        double price = 0.;
        for (NSDictionary* resultDict in objects)
            price += [[resultDict objectForKey:@"numberOfItems"] intValue] * [[resultDict objectForKey:@"price"] doubleValue];
        
        return price;

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
    
    AddRemoveButton* trashButton = [cell viewWithTag:113];
    //keep track of the inedxPath of the cell
    trashButton.cellIndexPath = indexPath;
    [trashButton addTarget:self action:@selector(trash:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    // Configure the cell...
    [self configureCell:cell atIndex:indexPath];
    
    return cell;
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
