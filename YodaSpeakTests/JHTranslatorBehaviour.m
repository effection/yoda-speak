//
//  JHTranslatorBehaviour.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "Kiwi.h"
#import "JHFormatter.h"
#import "JHTranslator.h"
#import "JHErrors.h"

SPEC_BEGIN(TranslatorSpec)

describe(@"translator", ^{
	
	__block JHTranslator *translator = nil;
	__block id formatterMock = nil;
	
	beforeEach(^{
		formatterMock = [KWMock mockForProtocol:@protocol(JHFormatter)];
		translator = [[JHTranslator alloc] initWithFormatter: formatterMock];
	});
	
	afterEach(^{
		formatterMock = nil;
		translator = nil;
	});
	
	
	context(@"when creating a new instance", ^{
		it(@"should exist", ^{
			[[translator shouldNot] beNil];
		});
		
		it(@"should have the correct output formatter", ^{
			[[formatterMock should] equal:translator.outputFormatter];
		});
		
		it(@"should have an empty history", ^{
			[[translator.history should] beEmpty];
		});
		
		it(@"should respond to translate:onSuccess", ^{
			[[translator should] respondToSelector:@selector(translate:onSuccess:)];
		});
		
		it(@"should respond to translate:onSuccess:onError", ^{
			[[translator should] respondToSelector:@selector(translate:onSuccess:onError:)];
		});
	});
	
	context(@"when translating text", ^{
		
		__block NSString *const kSampleInput = @"This is a sentence to translate";
		__block NSString *const kSampleOutput = @"Sentence to translate, this is. Yes, hmmm";
		
		__block NSString *formatterInputArg = nil;
		__block BOOL formatterShouldSucceed = YES;
		
		beforeEach(^ {
			//NOT HERE [[[formatterMock should] receive] format:@"This is a sentence to translate" withCallback:any()];
			[formatterMock stub:@selector(format:onSuccess:)
				withBlock:^id(NSArray *params) {
					formatterInputArg = params[0];
					if(params.count == 2 && params[1] != nil) {
						void (^blockCallback)(NSString *original, NSString *translated) = params[1];
						if(formatterShouldSucceed)
							blockCallback(formatterInputArg, kSampleOutput);
					}
					return nil;
				}];
			
			[formatterMock stub:@selector(format:onSuccess:onError:)
					  withBlock:^id(NSArray *params) {
						  formatterInputArg = params[0];
						  if(params.count == 3 && params[1] != nil && params[2] != nil) {
							  void (^successCallback)(NSString *original, NSString *translated) = params[1];
							  void (^errorCallback)(NSString *original, NSError *error) = params[2];
							  
							  if(formatterShouldSucceed)
								  successCallback(formatterInputArg, kSampleOutput);
							  else
								  errorCallback(formatterInputArg, [NSError errorWithDomain:JHErrorDomain code:JHUnknownError userInfo:nil]);
						  }
						  return nil;
					  }];
		});
		
		afterEach(^{
			formatterInputArg = nil;
			formatterShouldSucceed = YES;
		});
		
		it(@"should call the formatter's format function with the input", ^{
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {}];
			
			[[formatterInputArg should] equal:kSampleInput];
		});
		
		it(@"should call the success block upon a successful translation", ^{
			__block BOOL successInvoked = NO;
			
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {
				successInvoked = YES;
			} onError:^(NSString *original, NSError *error) {
				
			}];
			
			[[theValue(successInvoked) should] beTrue];
			
		});
		
		it(@"should call the error block upon a unsuccessful translation", ^{
			formatterShouldSucceed = NO;
			__block BOOL errorInvoked = NO;
			
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {
				
			} onError:^(NSString *original, NSError *error) {
				errorInvoked = YES;
			}];
			
			[[theValue(errorInvoked) should] beTrue];
		});
		
		it(@"should respond with an input error when the input is empty", ^{
			__block NSError *err = nil;
			[translator translate:@"" onSuccess:^(NSString *original, NSString *translated) {
				
			} onError:^(NSString *original, NSError *error) {
				err = error;
			}];
			
			[[err shouldNot] beNil];
			[[theValue(err.code) should] equal:[NSNumber numberWithInteger:JHEmptyInputError]];
		});
		
		it(@"history should have 1 value", ^{
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {}];
			[[translator.history should] haveCountOf:1];
		});
		
		it(@"history should contain the correctly translated text", ^{
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {}];
			JHTranslatedMessage *msg = translator.history[0];
			
			[[msg.originalText should] equal:kSampleInput];
			[[msg.translatedText should] equal:kSampleOutput];
		});
		
		it(@"the input text should match the callback original text ", ^{
			__block NSString *originalText = nil;
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {
				originalText = original;
			}];
			
			[[originalText should] equal:kSampleInput];
		});
		
		it(@"should return the correctly translated text", ^{
			__block NSString *translatedText = nil;
			[translator translate:kSampleInput onSuccess:^(NSString *original, NSString *translated) {
				translatedText = translated;
			}];
			[[translatedText should] equal:kSampleOutput];
		});
		
		
	});
});

SPEC_END