//
//  JHFormatter.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JHFormatter <NSObject>

@required
- (void)format:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *formatted))callback;

- (void)format:(NSString *)input onSuccess:(void (^)(NSString *original, NSString *formatted))callback onError:(void (^)(NSString *original, NSError *error))errorCallback;

@end
