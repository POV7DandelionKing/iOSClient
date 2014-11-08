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
@end

@implementation ServerHandler

+(instancetype)sharedInstance {
    static ServerHandler *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc]init];
        [singleton _fetchToken];
    });
    return singleton;
}

-(void)_fetchToken {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [BASE_URL stringByAppendingString:@"join"];
    NSDictionary *parameters = @{@"scene": @"basement", @"avatar": @"dude1"};

    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager POST:urlString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              NSDictionary *responseDict = (NSDictionary*)responseObject;
              self.token = responseDict[@"token"];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"JSON: %@", error);
          }];
}



-(void)nextPrompt:(void (^)(Prompt *prompt))success {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_QUESTIONS_URL_COMPONENT];

    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        Prompt *prompt = [Prompt promptWithJSONObject: responseObject];
        success(prompt);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)respondToPrompt:(Prompt *)prompt withOption:(NSUInteger)option {

}

-(id)responsesForPrompt:(Prompt *)prompt {
    return nil;
}


@end
