//
//  JHTranslator.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHFormatter.h"
#import "JHTranslatedMessage.h"

@interface JHTranslator : NSObject

@property (nonatomic, strong) id<JHFormatter> outputFormatter;

@property (nonatomic, strong) NSMutableArray *history;

-(id)initWithFormatter:(id<JHFormatter>)formatter;

- (void)translate:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *translated))callback;

- (void)translate:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *translated))callback onError:(void (^)(NSString *original, NSError *error))errorCallback;

@end
