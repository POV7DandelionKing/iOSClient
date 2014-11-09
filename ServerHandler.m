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
@property (strong, nonatomic) NSMutableArray* notifiedResponses;
@property (strong, nonatomic) NSTimer *pollTimer;
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

- (void)startPolling
{
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(poll:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopPolling
{
    if (self.pollTimer) {
        [self.pollTimer invalidate];
    }
    self.pollTimer = nil;
}

- (void)poll:(NSTimer*)timer
{
    [self fetchResponses];
}

- (void)fetchAvatars:(void (^)(NSArray *avatars, NSString* scene))avatarsBlock
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_LOBBY_URL_COMPONENT];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             NSLog(@"response %@", responseObject);
             NSArray *sessions = [responseObject objectForKey:@"sessions"];
             NSDictionary *session = sessions[0];
             NSArray *avatars = session[@"avatars"];
             NSString *sceneId = session[@"id"];
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
              [self fetchQuestion];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure %@", error);
          }];
}

- (void)fetchQuestion
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_QUESTION_URL_COMPONENT];
    [manager GET:urlString
      parameters:nil
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
              NSLog(@"response %@", responseObject);
              self.notifiedResponses = [NSMutableArray array];
              if ([responseObject[@"question"] isKindOfClass:[NSNull class]]) {
                  [self.serverDelegate promptsDone];
              } else {
                  Prompt *prompt = [Prompt promptWithJSONObject:responseObject];
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
              [self fetchQuestion];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure %@", error);
          }];
}

- (void)fetchResponses
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_RESPONSES_URL_COMPOTENT];
    [manager POST:urlString
       parameters:@{@"question":self.currentPrompt.identifier}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"response %@", responseObject);
              [self parseResponses:responseObject[@"responses"]];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"failure %@", error);
          }];
}

- (void)parseResponses:(NSArray*)responses
{
    BOOL finished = YES;
    for (NSDictionary *response in responses) {
        NSString *userId = response[@"user"];
        NSString *answer = response[@"response"];
        if ([answer isKindOfClass:[NSNull class]]) {
            finished = NO;
        } else {
            if (![self.notifiedResponses containsObject:userId]) {
                [self.notifiedResponses addObject:userId];
                [self.serverDelegate responseReceivedForPrompt:self.currentPrompt avatar:userId response:answer];
            }
        }
    }
    if (finished) {
        [self stopPolling];
        [self.serverDelegate allResponsesReceivedForPrompt:self.currentPrompt];
        [self fetchQuestion];
    } else {
        [self startPolling];
    }
}


- (void)reset:(void (^)())success;
{
    AFHTTPRequestOperationManager *manager = [self manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_RESET_URL_COMPONTENT];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response %@", responseObject);
             success();
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"failure %@", error);
      }];
}


@end
