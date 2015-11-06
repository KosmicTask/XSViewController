//
//  XSViewController.m
//  View Controllers
//
//  Created by Jonathan Dann and Cathy Shive on 14/04/2008.
//
// Copyright (c) 2008 Jonathan Dann and Cathy Shive
// Copyright (c) 2013 Jonathan Mitchell
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "View Controllers" by Jonathan Dann and Cathy Shive" will do.

#import "XSViewController.h"
#import "XSWindowController.h"

#pragma mark Private API

@interface XSViewController ()


@end

#pragma mark -
#pragma mark Public API

@implementation XSViewController

#pragma mark -
#pragma mark Life cycle

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        self.responder = [[XSActionResponder alloc] init];
    }
    
	return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setView:(NSView *)view
{
    [super setView:view];
    
    // ensure that the receiver is the view's next responder.
    // this occurs by default on 10.10 and above.
    if (self.view.nextResponder != self) {
        NSResponder *nextResponder = view.nextResponder;
        self.view.nextResponder = self;
        self.nextResponder = nextResponder;
    }
}

#pragma mark -
#pragma mark Legacy support

- (void)addRespondingChild:(XSViewController *)viewController
{
    [self.responder addRespondingChild:viewController.responder];
}

- (void)removeRespondingChild:(XSViewController *)viewController
{
    [self.responder removeRespondingChild:viewController.responder];
}

- (void)removeAllRespondingChildren
{
    [self.responder removeAllRespondingChildren];
}

- (XSWindowController *)windowController
{
    return self.responder.windowController;
}

- (void)setWindowController:(XSWindowController *)windowController
{
    self.responder.windowController = windowController;
}
@end
