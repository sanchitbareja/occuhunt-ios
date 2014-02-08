//
//  ServerIO.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/4/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerIODelegate;

@interface ServerIO : NSObject

- (void)serverSanityCheck;
- (void)getAccessToken;
- (void)getFairs;
- (void)getCompanies;
- (void)getCompany:(NSString *)companyID;
- (void)getCategories;
- (void)getMaps;
- (void)getUser:(NSString *)userID;
- (void)getHunts:(NSString *)userID;
- (void)checkInWithUserID:(NSString *)userID andEventID:(NSString *)eventID;
- (void)shareResumeWithRecruitersWithUserID:(NSString *)userID andCompanyID:(NSString *)companyID andStatus:(NSString *)status;
- (void)favoriteWithUserID:(NSString *)userID andCompanyID:(NSString *)companyID;

@property (nonatomic, assign) id <ServerIODelegate> delegate;

@end


#pragma mark - Delegate definition

@protocol ServerIODelegate
@required
- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response;
- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error;
@end