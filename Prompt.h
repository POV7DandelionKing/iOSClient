//
//  Prompt.h
//  Encounters
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prompt : NSObject
@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* prompt;
@property (strong, nonatomic) NSArray* responses;


+(instancetype)_debugResponse;
+(instancetype)promptWithJSONObject:(NSDictionary*)json;
- (BOOL)canShake;
@end
