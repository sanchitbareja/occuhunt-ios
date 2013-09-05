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
- (void)getCategories;
- (void)getMaps;

@property (nonatomic, assign) id <ServerIODelegate> delegate;

@end


#pragma mark - Delegate definition

@protocol ServerIODelegate
@required
- (void)returnData:(NSDictionary *)data;
- (void)returnFailure:(NSDictionary *)details;
@end