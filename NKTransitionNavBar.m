//
//  NKTransitionNavBar.m
//  TransitionNavBar-Test
//
//  Created by Narongsak kongpan on 6/14/2558 BE.
//  Copyright (c) 2558 Narongsak kongpan. All rights reserved.
//

#import "NKTransitionNavBar.h"

@implementation NKTransitionNavBar
{
	UIViewController *_rootViewController;
	UIBarButtonItem *_barButton;
	CGRect rootViewRect;

	CGRect sideBarRect;
	UIView *sideBarView;

	UISwipeGestureRecognizer *swipeGestureToLeft;
	UISwipeGestureRecognizer *swipeGestureToRight;
}

@synthesize isShowing = _isShowing;
@synthesize delegate = _delegate;
@synthesize sideBarWidth = _sideBarWidth;
@synthesize sideBarDeley = _sideBarDeley;

-(instancetype)initWithRootViewController:(UIViewController*)rootViewController andBarButton:(UIBarButtonItem*)targetButton{
	self = [super initWithFrame:rootViewController.view.frame];
	if (self) {
		_rootViewController = rootViewController;
		_barButton = targetButton;
		rootViewRect = rootViewController.view.frame;

		swipeGestureToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGestureRecognizer:)];
		[swipeGestureToLeft setDelegate:self];
		[swipeGestureToLeft setNumberOfTouchesRequired:1];
		[swipeGestureToLeft setDirection:UISwipeGestureRecognizerDirectionLeft];

		swipeGestureToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGestureRecognizer:)];
		[swipeGestureToRight setDelegate:self];
		[swipeGestureToRight setNumberOfTouchesRequired:1];
		[swipeGestureToRight setDirection:UISwipeGestureRecognizerDirectionRight];

		[targetButton setTarget:self];
		[targetButton setAction:@selector(onClickBtnTarget:)];
		[rootViewController.view addSubview:self];

		[self setBackgroundColor:[UIColor clearColor]];
		[self addGestureRecognizer:swipeGestureToLeft];
		[self addGestureRecognizer:swipeGestureToRight];
		self.sideBarDeley = 0.1;

		[rootViewController.view addGestureRecognizer:swipeGestureToRight];

		[self wantToShow:NO];
	}
	return self;
}

-(void)onSwipeGestureRecognizer:(UISwipeGestureRecognizer*)gestureRecognizer{
	if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
		if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight) {
			[self wantToShow:YES];
		}else if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft){
			[self wantToShow:NO];
		}
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	if ([[gestureRecognizer view] isKindOfClass:[self class]]) {
		return YES;
	}
	if ([[gestureRecognizer view] isEqual:_rootViewController.view]) {
		return YES;
	}
	return NO;
}

-(void)wantToShow:(BOOL)show{
	if (show) {
		if (self.sideBarWidth == 0) {
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ||
				UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomUnspecified) {
				self.sideBarWidth = 100;
			}else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				self.sideBarWidth = 320;
			}
		}
		if (!sideBarView) {
			sideBarRect = CGRectMake(0, 0, self.sideBarWidth, rootViewRect.size.height);
			sideBarView = [[UIView alloc] initWithFrame:sideBarRect];
			[sideBarView setBackgroundColor:[UIColor whiteColor]];
			[sideBarView.layer setShadowColor:[UIColor blackColor].CGColor];
			[sideBarView.layer setShadowOffset:CGSizeMake(0, 10)];
			[sideBarView.layer setShadowOpacity:1];
			[self addSubview:sideBarView];
		}

		[UIView animateWithDuration:0 animations:^{
			sideBarView.transform = CGAffineTransformMakeTranslation(-sideBarView.frame.size.width, 0);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:self.sideBarDeley animations:^{
				_rootViewController.view.transform = CGAffineTransformMakeTranslation(sideBarView.frame.size.width, 0);
			} completion:^(BOOL finished) {
				[self setUserInteractionEnabled:YES];

				self.isShowing = YES;
				[sideBarView.layer setShadowRadius:10];
				[self showDelegate];
			}];
		}];
	}else{
		[UIView animateWithDuration:self.sideBarDeley
						 animations:^{
			_rootViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
		} completion:^(BOOL finished) {
			[self setUserInteractionEnabled:NO];

			sideBarView.transform = CGAffineTransformMakeTranslation(-sideBarView.frame.size.width, 0);
			self.isShowing = NO;
			[sideBarView.layer setShadowRadius:0];

			[self showDelegate];
		}];
	}
}

-(void)showDelegate{
	if ([self.delegate respondsToSelector:@selector(onTransitionNavBarShow:)]) {
		[self.delegate onTransitionNavBarShow:self.isShowing];
	}
}

-(void)onClickBtnTarget:(UIBarButtonItem*)sender{
	[self wantToShow:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
