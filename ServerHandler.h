//
//  ServerHandler.h
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BASE_URL @"http://104.200.31.209:6543/"
#define GET_QUESTIONS_URL_COMPONENT @"question"
#define GET_RESPONSES_URL_COMPOTENT @"responses"
#define POST_RESPONSE_URL_COMPONTENT @"respond"

//typedef id (^SimpleResponse)(parameterTypes);

@class Prompt;

@interface ServerHandler : NSObject

+(instancetype)sharedInstance;

-(void)nextPrompt:(void (^)(Prompt *prompt))success;
-(id)responsesForPrompt:(Prompt*)prompt;
-(void)respondToPrompt:(Prompt*)prompt withOption:(NSUInteger)option;


@end
