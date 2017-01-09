//
//  NKTransitionNavBar.m
//  Narongsak kongpan
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
    UITapGestureRecognizer *singleTapGesture;
    
    UIViewController *_contentController;
}

@synthesize isShowing = _isShowing;
@synthesize delegate = _delegate;
@synthesize sideBarWidth = _sideBarWidth;
@synthesize sideBarDeley = _sideBarDeley;
@synthesize transitionStyle = _transitionStyle;

-(instancetype)initWithRootViewController:(UIViewController*)rootViewController andBarButton:(UIBarButtonItem*)targetButton{
	//self = [super initWithFrame:rootViewController.view.frame];
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
	if (self) {
		_rootViewController = rootViewController;
		_barButton = targetButton;
        _transitionStyle = NKTransitionNavBarToggleView;
        //rootViewRect = rootViewController.view.frame;
        rootViewRect = [UIScreen mainScreen].bounds;

		swipeGestureToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(onSwipeGestureRecognizer:)];
		[swipeGestureToLeft setDelegate:self];
		[swipeGestureToLeft setNumberOfTouchesRequired:1];
		[swipeGestureToLeft setDirection:UISwipeGestureRecognizerDirectionLeft];

		swipeGestureToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(onSwipeGestureRecognizer:)];
		[swipeGestureToRight setDelegate:self];
		[swipeGestureToRight setNumberOfTouchesRequired:1];
		[swipeGestureToRight setDirection:UISwipeGestureRecognizerDirectionRight];
        
        singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(onSingleTapGestureRecognizer:)];
        [singleTapGesture setDelegate:self];
        [singleTapGesture setNumberOfTapsRequired:1];
        [singleTapGesture setNumberOfTouchesRequired:1];
        
		[targetButton setTarget:self];
		[targetButton setAction:@selector(onClickBtnTarget:)];
		[rootViewController.view addSubview:self];

		[self setBackgroundColor:[UIColor clearColor]];
		[self addGestureRecognizer:swipeGestureToLeft];
		[self addGestureRecognizer:swipeGestureToRight];
        [self addGestureRecognizer:singleTapGesture];
		self.sideBarDeley = 0.1;

		[rootViewController.view addGestureRecognizer:swipeGestureToRight];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hide)
                                                     name:@"applicationDidEnterBackground"
                                                   object:nil];
		[self wantToShow:NO];
	}
	return self;
}

-(void)onSingleTapGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer{
    if (self.isShowing) {
        [self wantToShow:NO];
    }
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
    BOOL innerRect = CGRectContainsPoint(sideBarView.frame, [touch locationInView:self]);
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        if (self.isShowing) {
            if (!innerRect) {
                if ([[gestureRecognizer view] isKindOfClass:[self class]]) {
                    return YES;
                }
            }
        }
    }else if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        if (self.isShowing) {
            if (!innerRect) {
                if ([[gestureRecognizer view] isKindOfClass:[self class]]) {
                    return YES;
                }
            }
        }else{
            return YES;
        }
    }
	return NO;
}

-(void)wantToShow:(BOOL)show{
	if (show) {
		if (self.sideBarWidth == 0) {
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				self.sideBarWidth = 260;
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
            
            if (_contentController) {
                [_contentController.view setFrame:CGRectMake(0, 0, self.sideBarWidth, rootViewRect.size.height)];
                [sideBarView addSubview:_contentController.view];
                [sideBarView setBackgroundColor:_contentController.view.backgroundColor];
            }
		}
        
        switch (self.transitionStyle) {
            case NKTransitionNavBarToggleView:{
                [UIView animateWithDuration:self.sideBarDeley animations:^{
                    sideBarView.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    [self _isActive:YES];
                }];
            }
                break;
            case NKTransitionNavBarPullView:{
                [UIView animateWithDuration:0 animations:^{
                    sideBarView.transform = CGAffineTransformMakeTranslation(sideBarView.frame.size.width, 0);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:self.sideBarDeley animations:^{
                        _rootViewController.view.transform = CGAffineTransformMakeTranslation(sideBarView.frame.size.width, 0);
                    } completion:^(BOOL finished) {
                        [self _isActive:YES];
                    }];
                }];
            }
                break;
        }
	}else{
        switch (self.transitionStyle) {
            case NKTransitionNavBarToggleView:{
                [UIView animateWithDuration:self.sideBarDeley animations:^{
                    sideBarView.transform = CGAffineTransformMakeTranslation(-sideBarView.frame.size.width, 0);
                } completion:^(BOOL finished) {
                    [self _isActive:NO];
                }];
            }
                break;
            case NKTransitionNavBarPullView:{
                [UIView animateWithDuration:self.sideBarDeley animations:^{
                    _rootViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    [self _isActive:NO];
                }];
            }
                break;
        }
	}
}

-(void)_isActive:(BOOL)active{
    [self setUserInteractionEnabled:active];
    self.isShowing = active;
    
    [sideBarView.layer setShadowRadius:(active) ? 10 : 0];
    if (self.transitionStyle == NKTransitionNavBarPullView && !active) {
        sideBarView.transform = CGAffineTransformMakeTranslation(-sideBarView.frame.size.width, 0);
    }
    [self showDelegate];
}

-(void)showDelegate{
	if ([self.delegate respondsToSelector:@selector(onTransitionNavBarShow:)]) {
		[self.delegate onTransitionNavBarShow:self.isShowing];
	}
}

-(void)onClickBtnTarget:(UIBarButtonItem*)sender{
	[self wantToShow:YES];
}

-(void)show{
    [self wantToShow:YES];
}

-(void)hide{
    [self wantToShow:NO];
}

-(void)setContentViewController:(UIViewController *)view{
    _contentController = view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
