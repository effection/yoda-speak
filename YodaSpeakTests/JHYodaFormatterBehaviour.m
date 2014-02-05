//
//  JHTranslatorTests.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "Kiwi.h"
#import "JHYodaFormatter_Private.h"
#import "JHErrors.h"
#import <UNIRest.h>
#import <UNIHTTPStringResponse.h>

SPEC_BEGIN(YodaFormatterSpec)

describe(@"Yoda Formatter", ^{
	NSString *API_KEY = @"SAMPLE_KEY";
	__block JHYodaFormatter *formatter = nil;
	
	beforeEach(^{
		formatter = [[JHYodaFormatter alloc] initWithAPIKey:API_KEY];
	});
	
	afterEach(^{
		formatter = nil;
	});
	
	context(@"when creating a new instance", ^{
		it(@"should exist", ^{
			[formatter shouldNotBeNil];
		});
		
		it(@"should conform to JHFormatter", ^{
			[[formatter should] conformToProtocol:@protocol(JHFormatter)];
		});

		it(@"should respond to format:onSuccess", ^{
			[[formatter should] respondToSelector:@selector(format:onSuccess:)];
		});
		
		it(@"should respond to format:onSuccess:onError", ^{
			[[formatter should] respondToSelector:@selector(format:onSuccess:onError:)];
		});
		
		it(@"should contain the correct API key", ^{
			[[formatter.apiKey should] equal: API_KEY];
		});
	});
	
	context(@"formatting text", ^{
		
		__block NSString *const kSampleInput = @"This is a sentence to translate";
		__block NSString *const kSampleOutput = @"Sentence to translate, this is. Yes, hmmm";
		
		context(@"creating a new request", ^{
			
			__block UNIHTTPRequest *request = nil;
			
			beforeEach(^{
				request = [formatter createAPIRequestWithInput:kSampleInput];
			});
			
			afterEach(^{
				request = nil;
			});
			
			it(@"should exist", ^ {
				[[request shouldNot] beNil];
			});
			
			it(@"should be a GET request to mashape", ^{
				[[theValue(request.httpMethod) should] equal:[NSNumber numberWithInt:GET]];
				NSURL *url = [NSURL URLWithString:request.url];
				//https://yoda.p.mashape.com/yoda?sentence=%@
				[[url.host should] equal:@"yoda.p.mashape.com"];
				[[url.path should] equal:@"/yoda"];
			});
			
			it(@"should have the API key in the headers", ^{
				[[request.headers should] haveCountOfAtLeast:1];
				[[[request.headers allKeys] should] containObjects: @"x-mashape-authorization", nil];
				[[[request.headers allValues] should] containObjects:API_KEY, nil];
			});
			
			it(@"should have the input text in the request", ^{
				NSURL *url = [NSURL URLWithString:request.url];
				[[url.query should] equal:[NSString stringWithFormat:@"sentence=%@", [kSampleInput stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
			});
			
			it(@"should return the correct translation as a string upon sync request", ^{
				UNIHTTPStringResponse *response = [[UNIHTTPStringResponse alloc] init];
				response.body = kSampleOutput;
				[[request stubAndReturn:response] asString];
				
				[[[request asString].body should] equal:kSampleOutput];
			});
			
			it(@"should return the correct translation as a string upon async request", ^{
				UNIHTTPStringResponse *response = [[UNIHTTPStringResponse alloc] init];
				response.body = kSampleOutput;
				
				__block NSString *responseBody = nil;
				
				[[request stub] asStringAsync:any()];
				KWCaptureSpy *spy = [request captureArgument:@selector(asStringAsync:) atIndex:0];
				
				[request asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
					responseBody = stringResponse.body;
				}];
				
				void (^block)(UNIHTTPStringResponse *stringResponse, NSError *error) = spy.argument;
				block(response, nil);
				
				[[expectFutureValue(responseBody) should] equal:kSampleOutput];
			});
		});
		
		it(@"should call success block when it makes a successful web request", ^{
			__block BOOL successCalled = NO;

			//Create a real request object then stub out the asStringJSON so we can capture the block argument and call it without a web request happening
			UNIHTTPStringResponse *fakeResponse = [[UNIHTTPStringResponse alloc] init];
			fakeResponse.body = kSampleOutput;
			
			UNIHTTPRequest *fakeHTTPRequest = [formatter createAPIRequestWithInput:kSampleInput];
			[[fakeHTTPRequest stub] asStringAsync:any()];
			KWCaptureSpy *spy = [fakeHTTPRequest captureArgument:@selector(asStringAsync:) atIndex:0];
			
			[[formatter stubAndReturn:fakeHTTPRequest] createAPIRequestWithInput:kSampleInput];
			
			
			[formatter format:kSampleInput onSuccess:^(NSString *original, NSString *formatted) {
				successCalled = YES;
			} onError:^(NSString *original, NSError *error) {
			}];
			
			void (^block)(UNIHTTPStringResponse *stringResponse, NSError *error) = spy.argument;
			block(fakeResponse, nil);
			
			[[expectFutureValue([NSNumber numberWithBool: successCalled]) shouldEventually] equal:@(YES)];
		});
		
		it(@"should call error block when it makes a unsuccessful web request", ^{
			__block BOOL errorCalled = NO;

			//Create a real request object then stub out the asStringJSON so we can capture the block argument and call it without a web request happening
			NSError *fakeError = [NSError errorWithDomain:@"" code:0 userInfo:nil];
			
			UNIHTTPRequest *fakeHTTPRequest = [formatter createAPIRequestWithInput:kSampleInput];
			[[fakeHTTPRequest stub] asStringAsync:any()];
			KWCaptureSpy *spy = [fakeHTTPRequest captureArgument:@selector(asStringAsync:) atIndex:0];
			
			[[formatter stubAndReturn:fakeHTTPRequest] createAPIRequestWithInput:kSampleInput];
			
			
			[formatter format:kSampleInput onSuccess:^(NSString *original, NSString *formatted) {
				
			} onError:^(NSString *original, NSError *error) {
				errorCalled = YES;
			}];
			
			void (^block)(UNIHTTPStringResponse *stringResponse, NSError *error) = spy.argument;
			block(nil, fakeError);
			
			[[expectFutureValue([NSNumber numberWithBool: errorCalled]) shouldEventually] equal:@(YES)];
		});
		
		it(@"should respond with an input error when the input is empty", ^{
			__block NSError *err = nil;
			[formatter format:@"" onSuccess:^(NSString *original, NSString *formatted) {
				
			} onError:^(NSString *original, NSError *error) {
				err = error;
			}];
			
			[[err shouldNot] beNil];
			[[theValue(err.code) should] equal:[NSNumber numberWithInteger:JHEmptyInputError]];
		});
		
		it(@"should call success block with the correct translated text for Yoda", ^{
			__block NSString *realResponse = nil;
			
			//Create a real request object then stub out the asStringJSON so we can capture the block argument and call it without a web request happening
			UNIHTTPStringResponse *fakeResponse = [[UNIHTTPStringResponse alloc] init];
			fakeResponse.body = kSampleOutput;
			
			UNIHTTPRequest *fakeHTTPRequest = [formatter createAPIRequestWithInput:kSampleInput];
			[[fakeHTTPRequest stub] asStringAsync:any()];
			KWCaptureSpy *spy = [fakeHTTPRequest captureArgument:@selector(asStringAsync:) atIndex:0];
			
			[[formatter stubAndReturn:fakeHTTPRequest] createAPIRequestWithInput:kSampleInput];
			
			
			[formatter format:kSampleInput onSuccess:^(NSString *original, NSString *formatted) {
				realResponse = formatted;
			} onError:^(NSString *original, NSError *error) {
			}];
			
			void (^block)(UNIHTTPStringResponse *stringResponse, NSError *error) = spy.argument;
			block(fakeResponse, nil);
			
			[[expectFutureValue(realResponse) shouldEventually] equal:kSampleOutput];
		});
	});
});

SPEC_END