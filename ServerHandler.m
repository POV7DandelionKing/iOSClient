//
//  ServerHandler.m
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import "ServerHandler.h"
#import "Prompt.h"
#import <AFNetworking/AFNetworking.h>


@interface ServerHandler ()
@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) Prompt* currentPrompt;
@end

@implementation ServerHandler

+(instancetype)sharedInstance {
    static ServerHandler *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc]init];
    });
    return singleton;
}


- (AFHTTPRequestOperationManager*)manager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json"
                     forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (self.token) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.token]
                         forHTTPHeaderField:@"Authorization"];
    }
    return manager;
}


- (void)fetchAvatars:(void (^)(NSArray *avatars, NSString* scene))avatarsBlock
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_LOBBY_URL_COMPONENT];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             NSLog(@"response %@", responseObject);
             NSArray *scenes = [responseObject objectForKey:@"scenes"];
             NSDictionary *scene = scenes[0];
             NSArray *avatars = scene[@"avatars"];
             NSString *sceneId = scene[@"id"];
             avatarsBlock(avatars, sceneId);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"failure %@", error);
         }];
}


- (void)joinWithAvatar:(NSString*)avatarId scene:(NSString *)scene
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:POST_JOIN_URL_COMPONENT];
    [manager POST:urlString
       parameters:@{@"avatar":avatarId, @"scene":scene}
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
              NSLog(@"response %@", responseObject);
              self.token = [responseObject objectForKey:@"token"];
              [self start];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure %@", error);
          }];
}

- (void)start
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_START_URL_COMPONENT];
    [manager GET:urlString
      parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
         NSLog(@"response %@", responseObject);
         [self parseQuestion:responseObject[@"question"]];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"failure %@", error);
     }];
}

- (void)respondToPrompt:(Prompt*)prompt withOption:(NSUInteger)option
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:POST_RESPONSE_URL_COMPONTENT];
    [manager POST:urlString
       parameters:@{@"question":prompt.identifier, @"response":[NSString stringWithFormat:@"%zd", option]}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"response %@", responseObject);
              [self parseResponses:responseObject[@"responses"]];
              [self parseQuestion:responseObject[@"next-question"]];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure %@", error);
          }];
}

- (void)parseQuestion:(NSDictionary*)question
{
    if ([question isKindOfClass:[NSNull class]]) {
        [self.serverDelegate promptsDone];
    } else {
        Prompt *prompt = [Prompt promptWithJSONObject:question];
        if (!self.currentPrompt) {
            self.currentPrompt = prompt;
            [self.serverDelegate nextPromptReceived:prompt];
        } else {
            if (![self.currentPrompt.identifier isEqualToString:prompt.identifier]) {
                self.currentPrompt = prompt;
                [self.serverDelegate nextPromptReceived:prompt];
            }
        }
    }
}

- (void)parseResponses:(NSArray*)responses
{
    for (NSDictionary *response in responses) {
        NSString *userId = response[@"user"];
        NSString *answer = response[@"response"];
        if (![answer isKindOfClass:[NSNull class]]) {
            [self.serverDelegate responseReceivedForPrompt:self.currentPrompt avatar:userId response:answer];
        }
    }
    [self.serverDelegate allResponsesReceivedForPrompt:self.currentPrompt];
}


@end
