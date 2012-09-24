//
//  SizePopover.h
//  Mascotte
//
//  Created by Ekaterina Petrova on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewPopoverDelegate;
@protocol TableViewPopoverDataSource;


@interface TableViewPopover : UIView
@property (nonatomic, assign) id<TableViewPopoverDelegate> delegate;
@property (nonatomic, assign) id<TableViewPopoverDataSource> dataSource;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, assign, readonly) BOOL isShown;
@property (nonatomic, assign) CGFloat margin;

- (void)show:(BOOL)show;
- (void)reloadData;
@end

@protocol TableViewPopoverDataSource
- (UITableViewCell*)tableViewPopover:(TableViewPopover*)view cellForRowAtIndex:(NSInteger)index inTableView:(UITableView*)tableView;
- (NSInteger)tableViewPopoverRowsNumber:(TableViewPopover *)view;
@end

@protocol TableViewPopoverDelegate
- (void)tableViewPopover:(TableViewPopover*)view didSelectRowAtIndex:(NSInteger)index;
@end