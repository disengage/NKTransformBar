//
//  NKTransitionNavBar.h
//  TransitionNavBar-Test
//
//  Created by Narongsak kongpan on 6/14/2558 BE.
//  Copyright (c) 2558 Narongsak kongpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NKTransitionNavBar_Protocol <NSObject>
-(void)onTransitionNavBarShow:(BOOL)showing;
@end

@interface NKTransitionNavBar : UIView <UIGestureRecognizerDelegate>
-(instancetype)initWithRootViewController:(UIViewController*)rootViewController andBarButton:(UIBarButtonItem*)targetButton;

@property (nonatomic) BOOL isShowing;
@property (nonatomic) CGFloat sideBarWidth;
@property (nonatomic) float sideBarDeley;
@property (nonatomic, retain) id<NKTransitionNavBar_Protocol> delegate;

@end
