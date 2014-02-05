//
//  JHViewController.m
//  YodaSpeak
//
//  Created by Jordan Hamill on 04/02/2014.
//  Copyright (c) 2014 Jordan Hamill. All rights reserved.
//

#import "JHViewController.h"
#import "JHYodaFormatter.h"
#import "JHTranslator.h"
#import "JHHistoryCell.h"


static NSString *CellIdentifier = @"JHHistoryCell";


@interface JHViewController ()
@property (weak, nonatomic) IBOutlet UIView *textboxBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textboxBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textInput;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *historyTable;

@property (strong, nonatomic) JHTranslator *translator;

- (void)sendMessage: (NSString *)message;

- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;

@end

@implementation JHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Style the view
	self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:75/255.0 green:105/255.0 blue:67/255.0 alpha:1.0];
	self.textboxBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbox-bg"]];
	
	self.textInput.delegate = self;
	self.historyTable.dataSource = self;
	self.historyTable.delegate = self;
	[self.historyTable registerClass:[JHHistoryCell class] forCellReuseIdentifier:CellIdentifier];
	
	//Register for keyboard hide and show
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	self.translator = [[JHTranslator alloc] initWithFormatter:[[JHYodaFormatter alloc] initWithAPIKey:@"dqjn0OEqqUJAORNMnboV6MISSUk8RZgM"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendMessage:(NSString *)message
{
	if(message == nil || message.length <= 0)
		return;
	
	self.textInput.enabled = NO;
	self.sendButton.enabled = NO;
	
	NSLog(@"Translating");
	
	[self.translator translate:message onSuccess:^(NSString *original, NSString *translated) {
		NSLog(@"Got translation");

		dispatch_async(dispatch_get_main_queue(), ^{
			self.textInput.text = @"";
			self.textInput.enabled = YES;
			self.sendButton.enabled = YES;
			
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.translator.history.count - 1 inSection:0];
			
			[self.historyTable beginUpdates];
			// Insert this new row into the table
			[self.historyTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									 withRowAnimation:UITableViewRowAnimationTop];
			
			[self.historyTable endUpdates];
			
			[self.historyTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		});

		
		
	} onError:^(NSString *original, NSError *error) {
		self.textInput.enabled = YES;
	}];
}

- (IBAction)sendButtonClicked:(id)sender
{
	[self sendMessage:self.textInput.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.translator.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JHHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	JHTranslatedMessage *msg = self.translator.history[indexPath.row];
	
	cell.originalText.text = msg.originalText;
	cell.translatedText.text = msg.translatedText;
	
	[cell.originalText sizeToFit];
	[cell.translatedText sizeToFit];
	cell.originalText.frame = CGRectMake(cell.originalText.frame.origin.x, cell.originalText.frame.origin.y, 300, cell.originalText.frame.size.height);
	
	cell.translatedText.frame = CGRectMake(cell.translatedText.frame.origin.x, cell.originalText.frame.origin.x + cell.originalText.frame.size.height + 10, 300, cell.translatedText.frame.size.height);
	
    return cell;//this is really long to force it into a multiline text box woo woo woo
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

	JHTranslatedMessage *msg = self.translator.history[indexPath.row];
	CGFloat height1 = [self sizeForText:msg.originalText withContainerSize:self.historyTable.bounds.size];
	CGFloat height2 = [self sizeForText:msg.translatedText withContainerSize:self.historyTable.bounds.size];
	
    return height1 + height2 + 30;
}


- (CGFloat)sizeForText:(NSString *)text withContainerSize:(CGSize)container
{
	//http://stackoverflow.com/questions/7174007/how-to-calculate-uilabel-height-dynamically/17956248#17956248
	
	CGFloat labelWidth = container.width - 20.0f;
	CGSize labelContraints = CGSizeMake(labelWidth, 100.0f);
	
	NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[UIFont systemFontOfSize:17], NSFontAttributeName,
								[NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
								nil];

	
	CGRect labelRect = [text boundingRectWithSize:labelContraints
										  options:NSStringDrawingUsesLineFragmentOrigin
									   attributes:attributes
								          context:context];
	CGFloat height = labelRect.size.height;
	
	return height;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[self sendMessage:textField.text];
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//Hide keyboard on touch outside
    for (UIView * txt in self.view.subviews){
        if (![txt isKindOfClass:[UITextField class]] && ![txt isFirstResponder]) {
            [self.textInput resignFirstResponder];
        }
    }
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
	self.textboxBottomConstraint.constant = keyboardFrame.size.height;
	[self.view updateConstraintsIfNeeded];
	[self.view layoutIfNeeded];
	
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
	self.textboxBottomConstraint.constant = 0;
	[self.view updateConstraintsIfNeeded];
	[self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
