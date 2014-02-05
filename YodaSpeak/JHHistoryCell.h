//
//  JHHistoryCell.h
//  YodaSpeak
//
//  Created by Jordan Hamill on 05/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHHistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *originalText;
@property (strong, nonatomic) IBOutlet UILabel *translatedText;

@end
