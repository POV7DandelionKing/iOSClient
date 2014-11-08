//
//  EncountersTests.m
//  EncountersTests
//
//  Created by Colin Rofls on 2014-11-08.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ServerHandler.h"
#import <AFNetworking/AFNetworking.h>

@interface EncountersTests : XCTestCase

@end

@implementation EncountersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testLobbyGet {
    XCTestExpectation *expectation = [self expectationWithDescription:@"get lobby"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [BASE_URL stringByAppendingString:@"lobby"];

    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [expectation fulfill];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"JSON: %@", error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


-(void)testJoin {
    XCTestExpectation *expectation = [self expectationWithDescription:@"join"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [BASE_URL stringByAppendingString:@"join"];
    NSDictionary *parameters = @{@"scene": @"basement", @"avatar": @"dude1"};

    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager POST:urlString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [expectation fulfill];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"JSON: %@", error);
             XCTFail(@"error");
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testBlahBlah {
    // This is an example of a functional test case.
    XCTestExpectation *expectation = [self expectationWithDescription:@"get prompt"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [BASE_URL stringByAppendingString:GET_QUESTIONS_URL_COMPONENT];

    //    [AFJSONResponseSerializer serializer];

    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [expectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [expectation fulfill];
    }];


    [self waitForExpectationsWithTimeout:5.0 handler:nil];


//    [[ServerHandler sharedInstance]nextPrompt];
    XCTAssert(YES, @"Pass");
}



@end
