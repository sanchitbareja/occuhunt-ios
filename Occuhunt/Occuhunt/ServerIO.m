//
//  ServerIO.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/4/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

// Managing many NSURLRequests: http://stackoverflow.com/questions/332276/managing-multiple-asynchronous-nsurlconnection-connections

#import "ServerIO.h"
//#import <AFOAuth2Client/AFOAuth2Client.h>
//#import <AFNetworking/AFJSONRequestOperation.h>

#define kClientID @""
#define kClientSecret @""

@implementation ServerIO

@synthesize delegate;

- (void)makeJSONCall:(NSURLRequest *)request{
    if (!self.delegate) {
        NSLog(@"No delegate. Please check.");
    }
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        if (self.delegate) {
//            [self.delegate returnData:@{request:@"request", response:@"response", JSON:@"json"}];
//        }
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
//        if (self.delegate) {
//            [self.delegate returnFailure:@{request:@"request", error:@"error", JSON:@"json"}];
//        }
//    }];
//    [operation start];
}

- (void)serverSanityCheck {
    NSURL *url = [NSURL URLWithString:@"http://occuhunt.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeJSONCall:request];
}

- (void)getAccessToken {
    NSURL *url = [NSURL URLWithString:@"http://example.com/"];
//    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
//    
//    [oauthClient authenticateUsingOAuthWithPath:@"/oauth/token"
//                                       username:@"username"
//                                       password:@"password"
//                                          scope:@"email"
//                                        success:^(AFOAuthCredential *credential) {
//                                            NSLog(@"I have a token! %@", credential.accessToken);
//                                            [AFOAuthCredential storeCredential:credential withIdentifier:oauthClient.serviceProviderIdentifier];
//                                        }
//                                        failure:^(NSError *error) {
//                                            NSLog(@"Error: %@", error);
//                                        }];
    
}

- (void)getFairs {
    NSURL *url = [NSURL URLWithString:@"http://occuhunt.com/api/v1/fairs"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeJSONCall:request];
}

- (void)getCompanies {
    NSURL *url = [NSURL URLWithString:@"http://occuhunt.com/api/v1/companies"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeJSONCall:request];
}

- (void)getCategories {
    NSURL *url = [NSURL URLWithString:@"http://occuhunt.com/api/v1/categories"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeJSONCall:request];
}

- (void)getMaps {
    NSURL *url = [NSURL URLWithString:@"http://occuhunt.com/api/v1/maps"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeJSONCall:request];
}

@end
