//
//  VideoViewController.m
//  Encounters
//
//  Created by Amos Latteier on 2014-11-09.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"self" withExtension:@"mp4"];
    self.player = [AVPlayer playerWithURL:url];
    [self.player play];
}

@end
