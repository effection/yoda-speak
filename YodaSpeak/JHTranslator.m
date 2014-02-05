//
//  JHTranslator.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHTranslator.h"
#import "JHErrors.h"

@implementation JHTranslator

-(id)initWithFormatter:(id<JHFormatter>)formatter
{
	self = [super init];
	if(self) {
		self.outputFormatter = formatter;
		self.history = [[NSMutableArray alloc] initWithCapacity:5];
	}
	return self;
}

- (void)translate:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *translated))callback
{
	[self translate:input onSuccess:callback onError:^(NSString *original, NSError *error) {
		
	}];
}

- (void)translate:(NSString *)input onSuccess:(void (^)(NSString *, NSString *))callback onError:(void (^)(NSString *, NSError *))errorCallback
{
	if(input.length <= 0) {
		if(errorCallback) {
			errorCallback(input, [NSError errorWithDomain: JHErrorDomain code: JHEmptyInputError userInfo: nil]);
		}
	}
	[self.outputFormatter format:input onSuccess:^(NSString *original, NSString *formatted) {
		[self.history addObject:[[JHTranslatedMessage alloc] initWithOriginalText: original andTranslation: formatted ]];
		
		if(callback) {
			callback(original, formatted);
		}
	} onError:^(NSString *original, NSError *error) {
		[self.history addObject:[[JHTranslatedMessage alloc] initWithOriginalText: original andTranslation: [NSString stringWithFormat:@"Whoops! Could not translate %@ ", original]]];
		if(errorCallback) {
			errorCallback(original, error);
		}
	}];
}
@end
