//
//  ServerHandler.h
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Prompt;
@interface ServerHandler : NSObject

+(instancetype)sharedInstance;

-(Prompt*)nextPrompt;
-(id)responsesForPrompt:(Prompt*)prompt;
-(void)respondToPrompt:(Prompt*)prompt withOption:(NSUInteger)option;


@end
