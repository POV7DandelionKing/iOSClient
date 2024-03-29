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
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) UIVisualEffectView* blurView;
@property (strong, nonatomic) UILabel* promptLabel;
@property (strong, nonatomic) NSArray* optionButtons;
@property (nonatomic, getter=isBlurred) BOOL blurred;
@property (strong, nonatomic) Prompt *currentPrompt;
@property (strong, nonatomic) Prompt* nextPrompt;
@property (strong, nonatomic) NSDate *shakeStart;
@property (strong, nonatomic) NSDictionary* responses;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *filmButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;



@end

@implementation ViewController

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupBlurView];
    self.promptLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.font = [UIFont boldSystemFontOfSize:22];
    self.promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.promptLabel.numberOfLines = 0;
    [self.view addSubview:self.promptLabel];

    [self setupOptionButtons];
    [self setupTV];
}

#define INTER_BUTTON_PADDING 2

-(void)setupBlurView {
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.backgroundImage.bounds;
    [self.backgroundImage addSubview:self.blurView];
    self.blurView.hidden = YES;
}

-(void)setupOptionButtons {

    NSMutableArray *optionsArray = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i;
        button.hidden = YES;
        button.tintColor = [UIColor whiteColor];
        button.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        [button addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [optionsArray addObject:button];
        [self.view addSubview:button];
    }
    self.optionButtons = [optionsArray copy];
}

- (void)setupTV
{
    NSMutableArray *images = [NSMutableArray array];
    for (int i=1; i <= 13; i++) {
        NSString *name = [NSString stringWithFormat:@"still%04d.jpg", i];
        UIImage *image = [UIImage imageNamed:name];
        [images addObject:image];
    }
    self.tvView.animationImages=images;
    self.tvView.animationRepeatCount = 0;
    self.tvView.animationDuration = 10.0;
    [self.tvView startAnimating];
}

-(void)layoutOptionButtons {
    CGPoint bottomLeft = CGPointMake(0, CGRectGetMaxY(self.view.bounds) + 20);
    for (int i = 3; i > -1; i--) {
        UIButton *button = self.optionButtons[i];
        [button sizeToFit];
        button.frame = CGRectInset(button.frame, 0, -20);
        button.frame = CGRectMake(0, bottomLeft.y - CGRectGetHeight(button.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(button.frame));
        bottomLeft = CGPointMake(0, button.frame.origin.y - INTER_BUTTON_PADDING);
    }
}

- (IBAction)startEncounterAction:(UIButton *)sender {
    ServerHandler *s = [ServerHandler sharedInstance];
    s.serverDelegate = self;
    [s fetchAvatars:^(NSArray *avatars, NSString *scene) {
        NSString *avatar = avatars[0];
        NSLog(@"joining as %@", avatar);
        [s joinWithAvatar:avatar scene:scene];
    }];

    [UIView animateWithDuration:0.5 animations:^{
        self.joinButton.alpha = 0.0;
        self.filmButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.joinButton.hidden = YES;
        self.filmButton.hidden = YES;
    }];
}

-(void)displayPrompt:(Prompt*)prompt {
    self.currentPrompt = prompt;
    self.blurView.hidden = NO;
    self.blurView.frame = self.backgroundImage.bounds;
    self.blurView.alpha = 0.0;

    self.promptLabel.hidden = NO;
    self.promptLabel.text = prompt.prompt;
    [self.promptLabel sizeToFit];
    self.promptLabel.center = CGPointMake(self.view.center.x, 60);

    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.blurView.alpha = 1.0;
                         self.promptLabel.alpha = 1.0;
                         self.tvFrame.alpha = 0;
                         self.tvView.alpha = 0;
                     } completion:^(BOOL finished) {

    int idx = 0;
    for (NSString* option in prompt.responses) {
        UIButton *button = self.optionButtons[idx];
        [button setTitle:option forState:UIControlStateNormal];
        [button sizeToFit];
        button.hidden = NO;
        idx++;
    }
                          [self layoutOptionButtons];
                         [UIView animateWithDuration:0.4
                                          animations:^{
                                              for (UIButton* button in self.optionButtons) {
                                                  button.alpha = 1.0;
                                              }
                                          }];
        }];
}

-(void)hidePrompt {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.promptLabel.frame = CGRectMake(CGRectGetMinX(self.promptLabel.frame), 0, CGRectGetWidth(self.promptLabel.frame), CGRectGetHeight(self.promptLabel.frame));
                         for (UIButton *button in self.optionButtons) {
                             button.alpha = 0.0;
                         }
                         self.blurView.alpha = 0.0;
                         self.tvView.alpha = 1.0;
                         self.tvFrame.alpha = 1.0;
                     } completion:^(BOOL finished) {
//                         self.promptLabel.hidden = YES;
                         self.blurView.hidden = YES;
                         for (UIButton *button in self.optionButtons) {
                             button.hidden = YES;
                         }
                     }];

}

-(void)optionButtonPressed:(UIButton*)sender {
    [[ServerHandler sharedInstance] respondToPrompt:self.currentPrompt withOption:sender.tag];
    [self hidePrompt];
    [self performSelector:@selector(showResponses) withObject:nil afterDelay:2.0];
}

#pragma mark - showing responses

-(void)showResponses {
    NSTimeInterval displayPeriod = 5.0;
    NSTimeInterval delayForNextResponse = 0.0;
    NSArray *responseAvatars = [self.responses allKeys];
    for (NSString *avatarIdentifier in responseAvatars) {
        [self performSelector:@selector(showResponseforAvatar:) withObject:avatarIdentifier afterDelay:delayForNextResponse];
        delayForNextResponse += displayPeriod;
    }
    [self performSelector:@selector(displayPrompt:) withObject:self.nextPrompt afterDelay:delayForNextResponse];
}

-(void)showResponseforAvatar:(NSString*)avatarIdentifier {
    NSString *response = self.responses[avatarIdentifier];
    UIImageView *headView = [[UIImageView alloc]initWithImage:[self imageForAvatarIdentifier:avatarIdentifier]];
    headView.center = self.view.center;
    headView.frame = CGRectOffset(headView.frame, -CGRectGetWidth(self.view.frame), 0);
    [self.view addSubview:headView];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         headView.center = self.view.center;
                     } completion:^(BOOL finished) {
                         [self displayResponse:response forImageView:headView];
                         [UIView animateWithDuration:0.5
                                               delay:3.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              headView.frame = CGRectOffset(headView.frame, CGRectGetWidth(self.view.frame), 0);
                                          } completion:NULL];
                          }];
}

-(void)displayResponse:(NSString*)response forImageView:(UIImageView*)view {

    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    textLabel.text = response;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    textLabel.alpha = 0.0;
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:textLabel];
    [textLabel sizeToFit];
    textLabel.frame = CGRectMake(0, CGRectGetMinX(textLabel.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(textLabel.frame));
    textLabel.frame = CGRectInset(textLabel.frame, 0, -20);
    textLabel.center = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMaxY(view.frame) + 40);


    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         textLabel.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:3.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              textLabel.alpha = 0.0;
                                          } completion:^(BOOL finished) {
                                              [textLabel removeFromSuperview];
                                          }];
                     }];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(0.1);
                     } completion:NULL];

}

-(UIImage*)imageForAvatarIdentifier:(NSString*)avatarIdentifier {
        NSDictionary *imageNamesForIdentifiers = @{@"mac": @"MacHead",
                                                  @"roberta": @"RobertaHead",
                                                  @"arlene": @"ArleneHead",
                                                  @"jeannette": @"Jeanette",
                                                  @"maria": @"MariaHead"
                                                   };

    return [UIImage imageNamed:imageNamesForIdentifiers[avatarIdentifier]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)playSound:(NSString*)filename
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"aac"];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.audioPlayer play];
}


# pragma mark shake

- (void)shake:(CGFloat)seconds
{
    if (self.blurView.hidden) {
        NSLog(@"Shake, but not ready to respond");
        return;
    }
    if (![self.currentPrompt canShake]) {
        NSLog(@"Shake, but question doesn't allow shaking");
        return;
    }
    NSLog(@"shake of magnitude %f", seconds);
    if (seconds < 0.5) {
        [self playSound:@"Disappointment"];
    } else {
        [self playSound:@"Grunt"];
    }
    // XXX when you groan you respond with the first option
    if (self.currentPrompt) {
        [[ServerHandler sharedInstance] respondToPrompt:self.currentPrompt withOption:0];
        [self hidePrompt];
        [self performSelector:@selector(showResponses) withObject:nil afterDelay:2.0];
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    self.shakeStart = [NSDate date];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    CGFloat duration = fabsf([self.shakeStart timeIntervalSinceNow]);
    [self shake:duration];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    CGFloat duration = fabsf([self.shakeStart timeIntervalSinceNow]);
    [self shake:duration];
}

- (IBAction)showVideo:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark ServerDelegate

- (void)responseReceived:(NSDictionary *)responses forPrompt:(Prompt *)prompt
{
    NSLog(@"got response for %@ %@", responses, prompt);
    self.responses = responses;
}


- (void)nextPromptReceived:(Prompt*)prompt
{
    if (!self.currentPrompt) {
        [self displayPrompt:prompt];
    }

    self.nextPrompt = prompt;
}

- (void)promptsDone
{
    NSLog(@"done");
}


@end
