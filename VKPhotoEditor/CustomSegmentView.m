//
//  CustomSegmentView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CustomSegmentView.h"
#import "CustomSegmentButton.h"
#import "UIView+Helpers.h"

@interface CustomSegmentView ()
- (void)onCellClicked:(CustomSegmentButton*)cell;
@end

@implementation CustomSegmentView{
	NSMutableArray* items;
}
@synthesize delegate;
@synthesize selectedSegmentIndex;
@synthesize leftBgImage;
@synthesize leftBgImageSelected;
@synthesize rightBgImage;
@synthesize rightBgImageSelected;
@synthesize bgImage;
@synthesize bgImageSelected;;
@synthesize segmentSize;

- (void)_init
{
    selectedSegmentIndex = -1;
    items = [NSMutableArray new];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)addItems:(NSArray *)_items
{
    // TODO: add items as images and check for type
    [items removeAllObjects];
    
    UIImage *segmentBackground;
    UIImage *segmentBackgroundSelected;
    
    for (int index = 0; index < _items.count; index++) {
        
        if (!index) {
            segmentBackground = leftBgImage;
            segmentBackgroundSelected = leftBgImageSelected;
        } else if (index == _items.count - 1) {
            segmentBackground = rightBgImage;
            segmentBackgroundSelected = rightBgImageSelected;
        } else {
            segmentBackground = bgImage;
            segmentBackgroundSelected = bgImageSelected;
        }
        
		CustomSegmentButton* cell = [[CustomSegmentButton alloc] initWithNormalImage:segmentBackground selectedImage:segmentBackgroundSelected size:segmentSize];
        [cell setTitle:[_items objectAtIndex:index] forState:UIControlStateNormal];
        
        [cell moveTo: CGPointMake(segmentSize.width*index, 0)];
        [cell addTarget:self action:@selector(onCellClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cell];
        [items addObject:cell];
	}    
}

- (void)setFont:(UIFont *)font forSegmentAtIndex:(NSUInteger)segment
{
    CustomSegmentButton *segmentButton = [items objectAtIndex:segment];
    segmentButton.titleLabel.font = font;
}

- (void)setSelectedSegmentIndex:(NSInteger)segment
{
    if (segment == selectedSegmentIndex) return;

	int previousIndex = selectedSegmentIndex;
	selectedSegmentIndex = segment;
    [[items objectAtIndex:selectedSegmentIndex] setSelected:YES];
	
    if (previousIndex != -1) [[items objectAtIndex:previousIndex] setSelected:NO];
}

- (void)onCellClicked:(CustomSegmentButton*)cell
{
	self.selectedSegmentIndex = [items indexOfObject:cell];
	
	if ([self.delegate respondsToSelector:@selector(segmentView:selectSegmentAtIndex:)]) {
		[self.delegate segmentView:self selectSegmentAtIndex:selectedSegmentIndex];
	}
}

@end
