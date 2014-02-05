//
//  JHHistoryCell.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHHistoryCell.h"

@interface JHHistoryCell()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation JHHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.originalText = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320 - 20, 20)];
		self.translatedText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320 - 20, 20)];
		
		self.originalText.numberOfLines = 0;
		self.originalText.textAlignment = NSTextAlignmentRight;
		self.originalText.textColor = [UIColor colorWithRed:101/255.0 green:67/255.0 blue:105/255.0 alpha:1.0];
		
		self.translatedText.numberOfLines = 0;
		self.translatedText.textAlignment = NSTextAlignmentLeft;
		self.translatedText.textColor = [UIColor colorWithRed:75/255.0 green:105/255.0 blue:67/255.0 alpha:1.0];
		
		[self.contentView addSubview:self.originalText];
		[self.contentView addSubview:self.translatedText];

    }
    return self;
}


@end
