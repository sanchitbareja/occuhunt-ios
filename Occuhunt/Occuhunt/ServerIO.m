//
//  ServerIO.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/4/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

// Managing many NSURLRequests: http://stackoverflow.com/questions/332276/managing-multiple-asynchronous-nsurlconnection-connections

#import "ServerIO.h"

#define kClientID @""
#define kClientSecret @""

@implementation ServerIO

@synthesize delegate;

- (void)makeJSONCall:(NSString *)string{
    if (!self.delegate) {
        NSLog(@"No delegate. Please check.");
    }
    NSLog(@"Making call to %@", string);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (self.delegate) {
            [self.delegate returnData:operation response:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (self.delegate) {
            [self.delegate returnFailure:operation error:error];
        }
    }];

}

- (void)serverSanityCheck {
    NSString *url = @"http://occuhunt.com/";
    [self makeJSONCall:url];
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


- (void)getUser:(NSString *)userID{
    NSMutableString *url = [NSMutableString stringWithString:@"http://occuhunt.com/api/v1/users"];
    [url appendFormat:@"/?linkedin_uid=%@", userID];
    [self makeJSONCall:url];
}

- (void)getFairs {
    NSString *url = @"http://occuhunt.com/api/v1/fairs";
    [self makeJSONCall:url];
}

- (void)getCompanies {
    NSString *url = @"http://occuhunt.com/api/v1/companies";
    [self makeJSONCall:url];
}

- (void)getCategories {
    NSString *url = @"http://occuhunt.com/api/v1/categories";
    [self makeJSONCall:url];
}

- (void)getMaps {
    NSString *url = @"http://occuhunt.com/api/v1/maps";
    [self makeJSONCall:url];
}

@end
