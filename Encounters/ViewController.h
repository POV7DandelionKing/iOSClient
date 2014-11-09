//
//  ViewController.h
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerHandler.h"
@interface ViewController : UIViewController <ServerDelegate>
@property(nonatomic, weak) IBOutlet UIImageView *tvView;
- (IBAction)showVideo:(id)sender;
@end

