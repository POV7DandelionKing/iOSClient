//
//  SplashViewController.m
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chapterButtonHeight;


@end
@implementation SplashViewController
-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat totalHeight = round(CGRectGetHeight(self.view.bounds) + 20);
    self.chapterButtonHeight.constant = totalHeight/4;
}
- (IBAction)chapterTwoButton:(id)sender {
    
}
@end
