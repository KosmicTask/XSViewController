//
//  NSResponder+XSViewController.m
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

#import "NSResponder+XSViewController.h"

NSString *XSVChainTypeKey = @"ChainType";

@implementation NSResponder (XSViewController)

#pragma mark -
#pragma mark Event responder chain

- (NSArray *)xsv_eventResponderChain
{
    return [self xsv_eventResponderChainFromResponder:nil];
}

- (NSArray *)xsv_eventResponderChainFromSelf
{
    return [self xsv_eventResponderChainFromResponder:self];
}

- (NSArray *)xsv_eventResponderChainFromResponder:(NSResponder *)responder
{
    return [self xsv_responderChainFromResponder:responder options:@{XSVChainTypeKey: @(XSVEventChainType)}];
}

#pragma mark -
#pragma mark Action responder chain

- (NSArray *)xsv_actionResponderChain
{
    return [self xsv_actionResponderChainFromResponder:nil];
}

- (NSArray *)xsv_actionResponderChainFromSelf
{
    return [self xsv_actionResponderChainFromResponder:self];
}

- (NSArray *)xsv_actionResponderChainFromResponder:(NSResponder *)responder
{
    NSArray *responderChain = [self xsv_responderChainFromResponder:responder options:@{XSVChainTypeKey: @(XSVActionChainType)}];
    
    BOOL appResponderChainIsValid = [responderChain containsObject:NSApp];
    
    if (!appResponderChainIsValid) {
        NSLog(@"Application responder chain is incomplete.");
        //[self xsv_logResponderChainFromResponder:self]; // this can lead to a recursive loop
    }
    
    return responderChain;
}

#pragma mark -
#pragma mark Responder chain construction

- (NSArray *)xsv_responderChainFromResponder:(id)initialResponder options:(NSDictionary *)options
{
    // Chain should conform to description given here:
    // https://developer.apple.com/library/mac/documentation/cocoa/conceptual/eventoverview/EventArchitecture/EventArchitecture.html#//apple_ref/doc/uid/10000060i-CH3-SW2
    
    NSMutableArray *chain = [NSMutableArray arrayWithCapacity:10];
    
    // If no initial responder then use the window first responder
    if (!initialResponder) {
        if (![self respondsToSelector:@selector(window)]) {
            return chain;
        }
        NSWindow *window = [(id)self window];

        initialResponder = [window firstResponder];
    }
    
    // This is going nowhere...
    if (!initialResponder) {
        return chain;
    }
    
    // Probe the accessible chain. By default this will be the event chain
    NSResponder *responder = initialResponder;
    do {
        [chain addObject:responder];
    } while ((responder = responder.nextResponder));

    responder = [chain lastObject];
    
    // Append action responder chain items
    if ([(NSNumber *)options[XSVChainTypeKey] integerValue] == XSVActionChainType) {
        
        // A window is required
        if (![responder respondsToSelector:@selector(window)]) {
            return chain;
        }
        NSWindow *window = [(id)responder window];
        if (!window) {
            return chain;
        }
 
        // Append the top level action responder chain
        NSArray *actionTopLevelChain = [self xsv_actionResponderChainAboveControllerForWindow:window];
        [chain addObjectsFromArray:actionTopLevelChain];
    }

    return chain;
}

- (NSArray *)xsv_actionResponderChainAboveControllerForWindow:(NSWindow *)window
{
    // Chain should conform to description given here:
    // https://developer.apple.com/library/mac/documentation/cocoa/conceptual/eventoverview/EventArchitecture/EventArchitecture.html#//apple_ref/doc/uid/10000060i-CH3-SW2
    
    id windowDelegate  = [window delegate];
    NSWindowController *windowController = [window windowController];
    NSDocument *document = [windowController document];
    id appDelegate = [NSApp delegate];
    NSMutableArray *chain = [NSMutableArray arrayWithCapacity:5];
    
    if (!window) {
        return chain;
    }
    
    // we don't want to duplicate the window controller
    if (windowDelegate && windowDelegate != windowController) {
        [chain addObject:windowDelegate];
    }
    
    if (document) {
        [chain addObject:document];
    }
    
    [chain addObject:NSApp];
    
    if (appDelegate) {
        [chain addObject:appDelegate];
    }
    
    if (document) {
        [chain addObject:[NSDocumentController sharedDocumentController]];
    }

    return chain;
}

#pragma mark -
#pragma mark Action sending

- (void)xsv_sendAction:(SEL)action toAllRespondersInChainStartingFrom:(id)target from:(id)sender
{
    // The responder chain is quite delicate and memory access related crashes can occur
    // on some macOS versions if responders get deallocated while the chain is processing actions.
    // This has been observed in particular pre 10.13 when calling NSResponder -tryToPerform:
    // The @autoreleasepool usage here is a precaution.
    @autoreleasepool {
        NSArray *responderChain = [self xsv_actionResponderChainFromResponder:target];
        
        // send action to target if supported
        for (NSResponder *responder in responderChain) {
            if ([responder respondsToSelector:action]) {
                [NSApp sendAction:action to:target from:sender];
            }
        }
    }
}

- (void)xsv_sendAction:(SEL)action toAllChildRespondersInChainStartingFrom:(id)target from:(id)sender
{
    @autoreleasepool {
        NSArray *responderChain = [self xsv_actionResponderChainFromResponder:target];
        
        // send action to target if supported
        for (NSResponder *responder in responderChain) {
            
            // we are done when the receiver is located
            if (responder == self) {
                break;
            }
            if ([responder respondsToSelector:action]) {
                [NSApp sendAction:action to:target from:sender];
            }
        }
    }
}

#pragma mark -
#pragma mark Logging

- (void)xsv_logResponderChainFromResponder:(NSResponder *)responder
{
    NSArray *responderChain = [self xsv_actionResponderChainFromResponder:responder];
    
    NSLog(@"---------------------");
    for (NSResponder *responder in responderChain)  {
        NSLog(@"RESPONDER CHAIN ITEM: %@ %@", [responder className], responder);
    }
    NSLog(@"---------------------");
}

@end
