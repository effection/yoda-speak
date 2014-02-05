//
//  JHYodaFormatter.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHFormatter.h"

@interface JHYodaFormatter : NSObject<JHFormatter>

- (id)initWithAPIKey:(NSString *)key;

- (void)format:(NSString *)input onSuccess:(void (^)(NSString *, NSString *))callback;

- (void)format:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *formatted))callback onError:(void (^)(NSString *original, NSError *error))errorCallback;
@end
