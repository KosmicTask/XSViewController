//
//  XSProxyViewController.m
//  BrightPay
//
//  Created by Jonathan Mitchell on 06/11/2015.
//  Copyright (c) 2015 Thesaurus Software Limited. All rights reserved.
//

#import "XSProxyViewController.h"

@interface XSProxyViewController ()

@end

@implementation XSProxyViewController

#pragma mark -
#pragma mark Lifecycle

- (id)initWithView:(NSView *)view
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.view = view;
    }
    
    return self;
}

- (void)loadView
{
    // this is a no-op
}

@end
