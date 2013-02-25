//
//  ViewController.h
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> ;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) NSArray *dataSource;


@end
