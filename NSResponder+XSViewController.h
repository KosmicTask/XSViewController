//
//  NSResponder+XSViewController.h
//  View Controllers
//
// Created by Jonathan Mitchell on 27/11/2013.
//
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

#import <Cocoa/Cocoa.h>

extern NSString *XSVChainTypeKey;

NS_ENUM(NSInteger, XSVChainType) {
    XSVEventChainType,
    XSVActionChainType,
};

@interface NSResponder (XSViewController)


/*!
 
 Get the event responder chain starting from the initial first responder.
 
 */
- (NSArray *)xsv_eventResponderChain;

/*!
 
 Get the event responder chain starting from self.
 
 */
- (NSArray *)xsv_eventResponderChainFromSelf;

/*!
 
 Get the event responder chain starting from the given responder.
 
 */
- (NSArray *)xsv_eventResponderChainFromResponder:(NSResponder *)responder;

/*!
 
 Get the action responder chain starting from the initial first responder.
 
 */
- (NSArray *)xsv_actionResponderChain;

/*!
 
 Get the action responder chain starting from self.
 
 */
- (NSArray *)xsv_actionResponderChainFromSelf;


/*!
 
 Get the action responder chain starting from the given responder.
 
 */
- (NSArray *)xsv_actionResponderChainFromResponder:(NSResponder *)responder;

/*!
 
 Get the responder chain starting from the given responder using the specified options.
 
 */
- (NSArray *)xsv_responderChainFromResponder:(id)initialResponder options:(NSDictionary *)options;


/*!
 
 Get the action responder chain above from the given window's controller.
 The first possible item in the chain is the window delegate.
 
 */
- (NSArray *)xsv_actionResponderChainAboveControllerForWindow:(NSWindow *)window;
@end
