//
//  Prompt.m
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "Prompt.h"

@implementation Prompt

+(instancetype)_debugResponse {
    Prompt *prompt = [[Prompt alloc]init];
    prompt.identifier = @1;
    prompt.prompt = @"Do you like multiple choice questions?";
    prompt.responses = @[@"I do indeed!",
                         @"I'm on the fence",
                         @"I'm not a crook",
                         @"I abstain."];
    return prompt;
}

+(instancetype)promptWithJSONObject:(NSDictionary*)json {
    Prompt *prompt = [[Prompt alloc]init];
    json = json[@"question"];
    prompt.identifier = json[@"id"];
    prompt.prompt = json[@"prompt"];

    NSMutableArray *responses = [NSMutableArray new];
    for (NSDictionary *dict in (NSArray*)json[@"responses"]) {
        [responses addObject:dict[@"text"]];
    }
    prompt.responses = [responses copy];

    return prompt;
}

@end
