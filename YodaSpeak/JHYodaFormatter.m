//
//  JHYodaFormatter.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHYodaFormatter.h"
#import "JHErrors.h"
#import <UNIRest.h>

@interface JHYodaFormatter ()

@property (nonatomic, copy) NSString *apiKey;

- (UNIHTTPRequest *)createAPIRequestWithInput:(NSString *)input;

@end

@implementation JHYodaFormatter

- (id)initWithAPIKey:(NSString *)key
{
	self = [super init];
	if(self) {
		self.apiKey = key;
	}
	
	return self;
}

- (void)format:(NSString *)input onSuccess:(void (^)(NSString *, NSString *))callback
{
	[self format:input onSuccess:callback onError:nil];
}

- (void)format:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *formatted))callback onError:(void (^)(NSString *original, NSError *error))errorCallback
{
	if(input.length <= 0) {
		if(errorCallback) {
			errorCallback(input, [NSError errorWithDomain: JHErrorDomain code: JHEmptyInputError userInfo: nil]);
		}
	}
	
	UNIHTTPRequest*req = [self createAPIRequestWithInput:input];
	
	[req asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
		if(error != nil && errorCallback) {
			return errorCallback(input, error);
		}
		if(callback) {
			callback(input, stringResponse.body);
		}
	}];
}

- (UNIHTTPRequest *)createAPIRequestWithInput:(NSString *)input
{
	NSDictionary* headers = @{@"X-Mashape-Authorization": self.apiKey};
	
	return [UNIRest get:^(UNISimpleRequest* request) {
		[request setUrl:[NSString stringWithFormat:@"https://yoda.p.mashape.com/yoda?sentence=%@", [input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		
		[request setHeaders:headers];
		[request setParameters:@{}];
	}];
}

@end
