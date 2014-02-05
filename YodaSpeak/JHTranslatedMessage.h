//
//  JHTranslatedMessage.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHTranslatedMessage : NSObject

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSString *translatedText;

- (id)initWithOriginalText: (NSString *)original andTranslation: (NSString *)translation;

@end
