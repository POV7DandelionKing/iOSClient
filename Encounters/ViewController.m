//
//  ViewController.m
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "ViewController.h"
#import "Prompt.h"
#import "ServerHandler.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) UIVisualEffectView* blurView;
@property (strong, nonatomic) UILabel* promptLabel;
@property (strong, nonatomic) NSArray* optionButtons;
@property (nonatomic, getter=isBlurred) BOOL blurred;
@property (strong, nonatomic) Prompt *currentPrompt;
@end

@implementation ViewController

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ServerHandler *s = [ServerHandler sharedInstance];
    s.serverDelegate = self;
    [s reset:^{
        NSLog(@"resetted");
        [s fetchAvatars:^(NSArray *avatars, NSString *scene) {
            NSString *avatar = avatars[0];
            NSLog(@"joining as %@", avatar);
            [s joinWithAvatar:avatar scene:scene];
        }];
    }];
  
    
    // Do any additional setup after loading the view, typically from a nib.
    [self setupBlurView];
    self.promptLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.promptLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.promptLabel];

    NSMutableArray *optionsArray = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i;
        button.hidden = YES;
        button.tintColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [optionsArray addObject:button];
        [self.view addSubview:button];
    }
    self.optionButtons = [optionsArray copy];
}

#define INTER_BUTTON_PADDING 10

-(void)setupBlurView {
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.backgroundImage.bounds;
    [self.backgroundImage addSubview:self.blurView];
    self.blurView.hidden = YES;
}


-(void)displayPrompt:(Prompt*)prompt {
    // XXX doesn't work when called a second time, why?
    self.currentPrompt = prompt;

    self.blurView.hidden = NO;
    self.blurView.frame = self.backgroundImage.bounds;
    self.blurView.alpha = 0.0;
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.blurView.alpha = 1.0;
                     } completion:^(BOOL finished) {

    self.promptLabel.text = prompt.prompt;
    [self.promptLabel sizeToFit];
    self.promptLabel.center = CGPointMake(self.view.center.x, 60);
    self.promptLabel.hidden = NO;

    int idx = 0;
    CGPoint nextButtonCenter = CGPointMake(self.view.center.x, CGRectGetMaxY(self.promptLabel.frame) + 60);
    for (NSString* option in prompt.responses) {
        UIButton *button = self.optionButtons[idx];
        [button setTitle:option forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = nextButtonCenter;
        button.hidden = NO;

        nextButtonCenter.y = CGRectGetMaxY(button.frame) + INTER_BUTTON_PADDING;
        idx++;
    }
                         }];
}

-(void)hidePrompt {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.promptLabel.alpha = 0.0;
                         for (UIButton *button in self.optionButtons) {
                             button.alpha = 0.0;
                         }
                         self.blurView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.promptLabel.hidden = YES;
                         self.blurView.hidden = YES;
                         for (UIButton *button in self.optionButtons) {
                             button.hidden = YES;
                         }
                     }];

}

-(void)optionButtonPressed:(UIButton*)sender {
    [[ServerHandler sharedInstance] respondToPrompt:self.currentPrompt withOption:sender.tag];
    [self hidePrompt];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ServerDelegate

- (void)responseReceivedForPrompt:(Prompt*)prompt avatar:(NSString*)avatar response:(NSString*)response
{
    NSLog(@"got response for %@ %@", avatar, response);
}

- (void)allResponsesReceivedForPrompt:(Prompt*)prompt
{
    NSLog(@"done with question");
}

- (void)nextPromptReceived:(Prompt*)prompt
{
    [self performSelector:@selector(displayPrompt:) withObject:prompt afterDelay:1.0];
}

- (void)promptsDone
{
    NSLog(@"done");
}


@end
