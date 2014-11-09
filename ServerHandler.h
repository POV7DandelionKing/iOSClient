//
//  ServerHandler.h
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BASE_URL @"http://104.200.31.209:6543/"
#define GET_LOBBY_URL_COMPONENT @"lobby"
#define GET_START_URL_COMPONENT @"start"
#define POST_JOIN_URL_COMPONENT @"join"
#define POST_RESPONSE_URL_COMPONTENT @"respond"


//typedef id (^SimpleResponse)(parameterTypes);

@class Prompt;

@protocol ServerDelegate
- (void)responseReceived:(NSDictionary*)responses forPrompt:(Prompt*)prompt;
- (void)nextPromptReceived:(Prompt*)prompt;
- (void)promptsDone;
@end


@interface ServerHandler : NSObject
@property (weak, nonatomic) id<ServerDelegate> serverDelegate;

+(instancetype)sharedInstance;
- (void)fetchAvatars:(void (^)(NSArray* avatars, NSString* scene))avatarsBlock;
- (void)joinWithAvatar:(NSString*)avatarId scene:(NSString*)scene;
- (void)respondToPrompt:(Prompt*)prompt withOption:(NSUInteger)option;
@end
