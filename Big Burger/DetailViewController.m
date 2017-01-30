//
//  DetailViewController.m
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)reload:(NSNotification *) notification {
    
    NSDictionary* userInfo = notification.userInfo;
    NSString* itemId = [userInfo objectForKey:@"itemId"];

    
    if ([itemId isEqualToString:_item.ref]) {
        _itemImageView.image = [UIImage imageWithData:_item.image.image];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Register for notification to reload the image
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"imageDownloaded" object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleLabel.text =_item.title;
    _itemImageView.image = [UIImage imageWithData:_item.image.image];
    _descLabel.text = _item.desc;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
