//
//  ServerHandler.m
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "ServerHandler.h"
#import "Prompt.h"

@implementation ServerHandler

+(instancetype)sharedInstance {
    static ServerHandler *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc]init];
    });
    return singleton;
}

-(Prompt *)nextPrompt {
    Prompt* prompt = nil;
    // stuff

    return prompt;
}

-(void)respondToPrompt:(Prompt *)prompt withOption:(NSUInteger)option {

}

-(id)responsesForPrompt:(Prompt *)prompt {
    return nil;
}

@end
