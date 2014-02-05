//
//  JHYodaFormatter_Private.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHYodaFormatter.h"
#import <UNIRest.h>

@interface JHYodaFormatter ()

@property (nonatomic, weak) NSString *apiKey;

- (UNIHTTPRequest *)createAPIRequestWithInput:(NSString *)input;

@end
