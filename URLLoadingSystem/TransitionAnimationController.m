//
//  TransitionAnimationController.m
//  URLLoadingSystem
//
//  Created by Darya Klochkova on 14/05/2019.
//  Copyright © 2019 Darya Klochkova. All rights reserved.
//

#import "TransitionAnimationController.h"

@implementation TransitionAnimationController

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    NSLog(@"animateTransition");
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[NSString alloc] init];
}



@end
