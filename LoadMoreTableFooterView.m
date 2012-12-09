//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "LoadMoreTableFooterView.h"


@interface LoadMoreTableFooterView (Private)
- (void)setState:(EGOPullState)aState;
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView;
- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView;
@end

@implementation LoadMoreTableFooterView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        isLoading = NO;
        
        CGFloat midY = PULL_AREA_HEIGTH/2;
        CGFloat midX = frame.size.width/2;
        
        /* Config Status Updated Label */
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 10, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
		_activityView = [[[UIImageView alloc] initWithFrame:CGRectMake(midX - 10, midY - 8, 20.0f, 20.0f)] autorelease];
		[self addSubview:_activityView];
        _activityView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"],
                                         [UIImage imageNamed:@"4"],[UIImage imageNamed:@"5"],[UIImage imageNamed:@"6"],
                                         [UIImage imageNamed:@"7"],[UIImage imageNamed:@"8"],[UIImage imageNamed:@"9"],
                                         [UIImage imageNamed:@"10"],[UIImage imageNamed:@"11"],[UIImage imageNamed:@"12"],
                                         [UIImage imageNamed:@"13"],[UIImage imageNamed:@"14"],[UIImage imageNamed:@"15"],
                                         [UIImage imageNamed:@"16"],[UIImage imageNamed:@"17"],[UIImage imageNamed:@"18"],
                                         [UIImage imageNamed:@"19"],[UIImage imageNamed:@"20"],[UIImage imageNamed:@"21"],
                                         [UIImage imageNamed:@"22"],[UIImage imageNamed:@"23"],[UIImage imageNamed:@"24"],nil];
        _activityView.animationDuration = 0.5;
		
		[self setState:EGOOPullNormal]; // Also transform the image
        
        /* Configure the default colors and arrow image */
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
		
    }
	
    return self;
	
}

#pragma mark - Util
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight -scrolledDistance;
    
    return normalizedOffset;
    
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    return (scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height));
}


#pragma mark -
#pragma mark Setters


- (void)setState:(EGOPullState)aState{
	
	switch (aState) {
		case EGOOPullPulling:
			
			//_statusLabel.text = NSLocalizedStringFromTable(@"Release to load more...",@"PullTableViewLan", @"Release to load more status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_activityView.layer.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullNormal:
			
			if (_state == EGOOPullPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_activityView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
				[CATransaction commit];
			}
			
			//_statusLabel.text = NSLocalizedStringFromTable(@"Pull up to load more...", @"PullTableViewLan",@"Pull down to load more status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_activityView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
            
			break;
		case EGOOPullLoading:
			_activityView.alpha = 1;
			[_activityView startAnimating];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage
{
    self.backgroundColor = backgroundColor? backgroundColor : DEFAULT_BACKGROUND_COLOR;
    _statusLabel.textColor = textColor? textColor: DEFAULT_TEXT_COLOR;
    _statusLabel.shadowColor = [_statusLabel.textColor colorWithAlphaComponent:0.1f];
    _activityView.image = arrowImage ? arrowImage : DEFAULT_ARROW_IMAGE;
}


#pragma mark -
#pragma mark ScrollView Methods


- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
    CGFloat bottomOffset = [self scrollViewOffsetFromBottom:scrollView];
	if (_state == EGOOPullLoading) {
        
		CGFloat offset = MAX(bottomOffset * -1, 0);
		offset = MIN(offset, PULL_AREA_HEIGTH);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom = offset? offset + [self visibleTableHeightDiffWithBoundsHeight:scrollView]: 0;
        scrollView.contentInset = currentInsets;
		
	} else if (scrollView.isDragging) {
		if (_state == EGOOPullPulling && bottomOffset > -PULL_TRIGGER_HEIGHT && bottomOffset < 0.0f && !isLoading) {
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && bottomOffset < -PULL_TRIGGER_HEIGHT && !isLoading) {
			[self setState:EGOOPullPulling];
            
		}
		
		if (scrollView.contentInset.bottom != 0) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.bottom = 0;
            scrollView.contentInset = currentInsets;
		}
		
	}
	if (scrollView.contentOffset.y > 0 && _activityView.alpha < 1) {
        _activityView.alpha += 0.02;
    }
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    isLoading = YES;
    [self setState:EGOOPullLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = PULL_AREA_HEIGTH + [self visibleTableHeightDiffWithBoundsHeight:scrollView];
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    if([self scrollViewOffsetFromBottom:scrollView] == 0){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + PULL_TRIGGER_HEIGHT) animated:YES];
    }
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	
	if ([self scrollViewOffsetFromBottom:scrollView] <= - PULL_TRIGGER_HEIGHT && !isLoading) {
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerLoadMore:)]) {
            [_delegate loadMoreTableFooterDidTriggerLoadMore:self];
        }
        [self startAnimatingWithScrollView:scrollView];
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
    isLoading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = 0;
    scrollView.contentInset = currentInsets;
	[UIView commitAnimations];
	
	[self setState:EGOOPullNormal];
    
}

- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _activityView.alpha = 0;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	[_activityView release];
	[_statusLabel release];
    [super dealloc];
}


@end
