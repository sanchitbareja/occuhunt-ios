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

- (void)makeJSONCall:(NSString *)string andTag:(int)httpCallTag{
    if (!self.delegate) {
        NSLog(@"No delegate. Please check.");
    }
    NSLog(@"Making call to %@", string);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:string relativeToURL:manager.baseURL] absoluteString] parameters:nil error:nil];
//    [request setTimeoutInterval:[NSTimeInterval time]];
    if (httpCallTag == GETFAIRS || httpCallTag == GETMAPS) {
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    else {
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    

    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (self.delegate) {
            [self.delegate returnData:operation response:responseObject];
        }    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.responseString);
            if (self.delegate) {
                [self.delegate returnFailure:operation error:error];
            }
        }];
    operation.tag = httpCallTag;
    [manager.operationQueue addOperation:operation];
    return;

}

- (void)makeJSONPost:(NSString *)string andArgs:(NSDictionary *)args andTag:(int)httpCallTag{
    if (!self.delegate) {
        NSLog(@"No delegate. Please check.");
    }
    if ([[args allKeys] count] == 0) {
        NSLog(@"Empty dictionary");
        return;
    }
    NSLog(@"Making call to %@", string);
    
    NSMutableString *constructString = [NSMutableString stringWithString:@"{"];
    for (NSString *key in args) {
        NSString *object = [args objectForKey:key];
//        if ([key isEqualToString:@"unfavorite"]) {
//            if ([object isEqualToString:@"TRUE"]) {
//            [constructString appendFormat:@"\"%@\":%i,", key, [object boolValue]];
//            continue;
//            }
//            else if ([object isEqualToString:@"FALSE"]) {
//                [constructString appendFormat:@"\"%@\":%i,", key, [object boolValue]];
//                continue;
//            }
//        }
        [constructString appendFormat:@"\"%@\":%@,", key, object];
    }
    constructString = [NSMutableString stringWithString:[constructString substringToIndex:constructString.length-1]];
    [constructString appendString:@"}"];
    NSLog(@"construct string = %@", constructString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[constructString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.tag = httpCallTag;
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON responseObject: %@ ",responseObject);
        if (self.delegate) {
            [self.delegate returnData:operation response:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        if (self.delegate) {
            [self.delegate returnFailure:operation error:error];
        }
        
    }];
    [op start];
    return;
}

- (void)makeJSONPatch:(NSString *)string andArgs:(NSArray *)args andTag:(int)httpCallTag{
    if (!self.delegate) {
        NSLog(@"No delegate. Please check.");
    }
    if ([args count] == 0) {
        NSLog(@"Empty dictionary");
        return;
    }
    NSLog(@"Making call to %@", string);
    NSLog(@"args are %@",  args);
    NSMutableString *constructString = [NSMutableString stringWithString:@""];
    for (NSDictionary *dictionary in args) {
        [constructString appendFormat:@"{"];
        for (NSString *key in [dictionary allKeys]) {
            NSString *object = [dictionary objectForKey:key];
            if ([object isKindOfClass:[NSNumber class]]) {
                if ([object intValue] > 0) {
                    [constructString appendFormat:@"\"%@\":%i,", key, [object intValue]];
                    continue;
                }
            }
            [constructString appendFormat:@"\"%@\":%@,", key, object];
        }
        constructString = [NSMutableString stringWithString:[constructString substringToIndex:constructString.length-1]];
        [constructString appendFormat:@"},"];
    }
    constructString = [NSMutableString stringWithString:[constructString substringToIndex:constructString.length-1]];
//    [constructString appendString:@"}"];
    NSString *newString = [NSString stringWithFormat:@"{\"objects\":[%@]}", constructString];
    NSLog(@"new string = %@", newString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad  timeoutInterval:10];
    
    [request setHTTPMethod:@"PATCH"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[newString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.tag = httpCallTag;
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON responseObject: %@ ",responseObject);
        if (self.delegate) {
            [self.delegate returnData:operation response:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        if (self.delegate) {
            [self.delegate returnFailure:operation error:error];
        }
        
    }];
    [op start];
    return;
}

- (void)serverSanityCheck {
    NSString *url = @"http://occuhunt.com/";
    [self makeJSONCall:url andTag:SERVERSANITYCHECK];
}

- (void)getAccessToken {
//    NSURL *url = [NSURL URLWithString:@"http://example.com/"];
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
    [self makeJSONCall:url andTag:GETUSER];
}

- (void)getFairs {
    NSString *url = @"http://occuhunt.com/api/v1/fairs";
    [self makeJSONCall:url andTag:GETFAIRS];
}

- (void)getCompanies {
    NSString *url = @"http://occuhunt.com/api/v1/companies";
    [self makeJSONCall:url andTag:GETCOMPANIES];
}

- (void)getCompany:(NSString *)companyID {
    NSString *url = [NSString stringWithFormat:@"http://occuhunt.com/api/v1/companies/?id=%@", companyID];
    [self makeJSONCall:url andTag:GETCOMPANY];
}

- (void)getCategories {
    NSString *url = @"http://occuhunt.com/api/v1/categories";
    [self makeJSONCall:url andTag:GETCATEGORIES];
}

- (void)getMaps {
    NSString *url = @"http://occuhunt.com/api/v1/maps";
    [self makeJSONCall:url andTag:GETMAPS];
}

- (void)getHunts:(NSString *)userID{
    NSString *url = [NSString stringWithFormat:@"http://occuhunt.com/api/v1/hunts/?user_id=%@", userID];
    [self makeJSONCall:url andTag:GETHUNTS];
}

- (void)shareResumeWithRecruitersWithUserID:(NSString *)userID andFairID:(int)fairID andCompanyID:(NSString *)companyID andStatus:(NSString *)status {
    NSString *url = @"http://occuhunt.com/api/v1/applications/";
    [self makeJSONPost:url andArgs:@{@"user_id": userID, @"fair_id": [NSNumber numberWithInt:fairID], @"company_id": companyID, @"status": status} andTag:SHARERESUME];
}

- (void)shareResumeWithMultipleRecruitersWithUserID:(NSString *)userID andFairID:(int)fairID andCompanyIDs:(NSArray *)companyIDs andStatuses:(NSArray *)statuses {
    NSString *url = @"http://occuhunt.com/api/v1/applications/";
    if (companyIDs.count != statuses.count) {
        NSLog(@"Both company IDs and statuses are not equal length.");
        return;
    }
    NSMutableArray *listOfObjects = [[NSMutableArray alloc] init];
    for (int i = 0; i < companyIDs.count; i++) {
        [listOfObjects addObject:@{@"user_id": userID, @"fair_id":[NSNumber numberWithInt:fairID], @"company_id":[companyIDs objectAtIndex:i], @"status":[statuses objectAtIndex:i]}];
    }
    
    [self makeJSONPatch:url andArgs:listOfObjects andTag:SHARERESUMEMULTIPLE];
                                      
//    {"objects":[{"user_id":1,"company_id":302,"status":1},{"user_id":1,"company_id":301,"status":1},
//                {"user_id":1,"company_id":300,"status":1},
//                {"user_id":1,"company_id":299,"status":1}]}
}

- (void)favoriteWithUserID:(NSString *)userID andCompanyID:(NSString *)companyID {
    NSLog(@"Calling favorite");
    NSString *url = [NSString stringWithFormat:@"http://occuhunt.com/api/v1/favorites/"];
    [self makeJSONPost:url andArgs:@{@"user_id": userID, @"company_id": companyID, @"unfavorite": @"false"} andTag:FAVORITECOMPANY];
}

- (void)unfavoriteWithUserID:(NSString *)userID andCompanyID:(NSString *)companyID {
    NSLog(@"Calling unfavorite");
    NSString *url = [NSString stringWithFormat:@"http://occuhunt.com/api/v1/favorites/"];
    [self makeJSONPost:url andArgs:@{@"user_id": userID, @"company_id": companyID, @"unfavorite": @"true"} andTag:UNFAVORITECOMPANY];
}


@end
