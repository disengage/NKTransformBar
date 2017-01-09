//
//  NKTransitionNavBar.h
//  Narongsak kongpan
//
//  Created by Narongsak kongpan on 6/14/2558 BE.
//  Copyright (c) 2558 Narongsak kongpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NKTransitionNavBar_Protocol <NSObject>
@optional
-(void)onTransitionNavBarShow:(BOOL)showing;
@end

typedef enum {
    NKTransitionNavBarToggleView,
    NKTransitionNavBarPullView
} NKTransitionNavBarStyle;

@interface NKTransitionNavBar : UIView <UIGestureRecognizerDelegate>
-(instancetype)initWithRootViewController:(UIViewController*)rootViewController andBarButton:(UIBarButtonItem*)targetButton;
-(void)setContentViewController:(UIViewController*)view;
-(void)hide;
-(void)show;

@property (nonatomic) BOOL isShowing;
@property (nonatomic) CGFloat sideBarWidth;
@property (nonatomic) float sideBarDeley;
@property (nonatomic) NKTransitionNavBarStyle transitionStyle;
@property (nonatomic, retain) id<NKTransitionNavBar_Protocol> delegate;

@end
