//
//  JHTranslatedMessageBehaviour.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "Kiwi.h"
#import "JHTranslatedMessage.h"


SPEC_BEGIN(TranslatedMessageSpec)

describe(@"Translated Message", ^{
	context(@"when creating a new instance", ^{
		
		__block NSString *const kSampleInput = @"This is a sentence to translate";
		__block NSString *const kSampleOutput = @"Sentence to translate, this is. Yes, hmmm";
		
		__block JHTranslatedMessage *message = nil;
		
		
		beforeEach(^{
			message = [[JHTranslatedMessage alloc] initWithOriginalText:kSampleInput andTranslation:kSampleOutput];
		});
		
		afterEach(^{
			message = nil;
		});

		it(@"should exist", ^{
			[message shouldNotBeNil];
		});
		
		it(@"should contain the original text", ^{
			[[message.originalText should] equal:kSampleInput];
		});
		
		it(@"should contain the translated text", ^{
			[[message.translatedText should] equal:kSampleOutput];
		});
	});
});

SPEC_END