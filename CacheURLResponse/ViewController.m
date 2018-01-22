//
//  ViewController.m
//  CacheURLResponse
//
//  Created by Karthi A on 21/01/18.
//  Copyright © 2018 Karthi A. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *responseWebview;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchGoButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)buttonGoClicked:(id)sender {
    
    if ([self.searchTextField isFirstResponder]) {
        [self.searchTextField resignFirstResponder];
    }
    
    [self sendRequest];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self sendRequest];
    
    return YES;
}

#pragma mark - Private

- (void) sendRequest {
    
    NSString *text = self.searchTextField.text;
    if (![text isEqualToString:@""]) {
        
        NSURL *url = [NSURL URLWithString:text];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.responseWebview loadRequest:request];
        
    }
    
}

@end
