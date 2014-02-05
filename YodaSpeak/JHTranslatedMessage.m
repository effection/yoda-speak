//
//  JHTranslatedMessage.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHTranslatedMessage.h"

@implementation JHTranslatedMessage

- (id)initWithOriginalText:(NSString *)original andTranslation:(NSString *)translation
{
	self = [super init];
	if(self) {
		self.originalText = original;
		self.translatedText =  translation;
	}
	
	return self;
}

@end
