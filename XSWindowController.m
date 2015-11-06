//
//  XSWindowController.m
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

#import "XSWindowController.h"
#import "XSActionResponder.h"

@interface NSMutableArray(XSResponder)
- (NSMutableArray *)xsv_reverse;
@end

@interface XSWindowController ()
@property(nonatomic,copy) NSMutableArray *actionResponders;

- (void)configureActionResponder:(XSActionResponder *)actionResponder;
- (void)configureActionResponders:(NSArray *)actionResponders;

@end

@implementation XSWindowController

@synthesize responderChainPatchRoot = _responderChainPatchRoot;

#pragma mark -
#pragma mark Lifecycle

- (id)initWithWindowNibName:(NSString *)nibName
{
    self = [super initWithWindowNibName:nibName];
	
    if (self) {
        _actionResponders = [NSMutableArray array];
        _addControllersToResponderChainInAscendingOrder = YES;
    }
    
	return self;
}

- (void)dealloc
{
    NSInteger actionResponders = [self countOfActionResponders];
    if (actionResponders != 0) {
        NSLog(@"%@ - Warning: action responders are still present in the responder chain.", [self className]);
    }
}

#pragma mark -
#pragma mark Window management

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self patchResponderChain];
}

#pragma mark -
#pragma mark Action responder management

- (void)setActionResponders:(NSMutableArray *)newActionResponders
{
	if (_actionResponders == newActionResponders) {
		return;
    }
    
	NSMutableArray *newActionRespondersCopy = [newActionResponders mutableCopy];
	_actionResponders = newActionRespondersCopy;
}

- (NSUInteger)countOfActionResponders
{
	return [self.actionResponders count];
}

- (XSActionResponder *)objectInActionRespondersAtIndex:(NSUInteger)index
{
	return [self.actionResponders objectAtIndex:index];
}

- (void)addActionResponder:(XSActionResponder *)actionResponder
{
    [self configureActionResponder:actionResponder];
	[self.actionResponders insertObject:actionResponder atIndex:[self.actionResponders count]];
	[self patchResponderChain];
}

- (void)insertObject:(XSActionResponder *)actionResponder inActionRespondersAtIndex:(NSUInteger)index
{
    [self configureActionResponder:actionResponder];
	[self.actionResponders insertObject:actionResponder atIndex:index];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndexes:(NSIndexSet *)indexes
{
    [self configureActionResponders:actionResponders];
	[self.actionResponders insertObjects:actionResponders atIndexes:indexes];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndex:(NSUInteger)index
{
    [self configureActionResponders:actionResponders];
	[self insertObjects:actionResponders inActionRespondersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeActionResponder:(XSActionResponder *)actionResponder
{
    if ([self.actionResponders containsObject:actionResponder]) {
        [self.actionResponders removeObject:actionResponder];
    }
	[self patchResponderChain];
}

- (void)removeAllActionResponders
{
    if (self.actionResponders.count == 0) {
        return;
    }
    
    [self.actionResponders removeAllObjects];
    [self patchResponderChain];
}

- (void)removeObjectFromActionRespondersAtIndex:(NSUInteger)index
{
	[self.actionResponders removeObjectAtIndex:index];
	[self patchResponderChain];
}

#pragma mark -
#pragma mark Action responder configuration

- (void)configureActionResponder:(XSActionResponder *)actionResponder
{
    NSAssert([actionResponder isKindOfClass:[XSActionResponder class]], @"Invalid action responder class");
    if (actionResponder.windowController != self) {
        actionResponder.windowController = self;
    }
}

- (void)configureActionResponders:(NSArray *)actionResponders
{
    for (XSActionResponder *actionResponder in actionResponders) {
        [self configureActionResponder:actionResponder];
    }
}

#pragma mark -
#pragma mark Responder chain management

- (void)setResponderChainPatchRoot:(NSResponder *)rootResponder
{
    _responderChainPatchRoot = rootResponder;
    if (_responderChainPatchRoot != self && _responderChainPatchRoot != self.window && _responderChainPatchRoot != nil) {
        NSLog(@"The responder chain patch root has been set to an unanticipated object: %@", rootResponder);
    }
    [self patchResponderChain];
}

- (NSResponder *)responderChainPatchRoot
{
    // Default to patching from the window
    if (!_responderChainPatchRoot) {
        return [self window];
    }
    
    return _responderChainPatchRoot;
}

- (void)patchResponderChain
{    
    // We are being called by action responders at the beginning of creating the tree,
    // most likely load time and the root of the tree hasn't been added to our list of responders.
	if ([self.actionResponders count] == 0) {
        
        if (self.responderChainPatchRoot == self.window) {
            
            if (self.responderChainPatchRoot.nextResponder != self) {
                self.responderChainPatchRoot.nextResponder = self;
            }
        }
        
		return;
    }
    
    // Get the responders
	NSArray *flatActionResponders = [self respondingDescendants];
    
    // Start building from the patch root
    XSActionResponder *nextActionResponder = [flatActionResponders objectAtIndex:0];
    [self.responderChainPatchRoot setNextResponder:nextActionResponder];
	
    NSUInteger index = 0;
	NSUInteger actionResponderCount = [flatActionResponders count] - 1;
    
    // Set the next responder of each action responder to the next, the last in the array has no default next responder.
	for (index = 0; index < actionResponderCount ; index++) {
        nextActionResponder = [flatActionResponders objectAtIndex:index + 1];
		[[flatActionResponders objectAtIndex:index] setNextResponder:nextActionResponder];
	}
    
    // Append the window controller to the chain when building from the window
    if (self.responderChainPatchRoot == self.window) {
        if (self.responderChainPatchRoot.nextResponder != self) {
            nextActionResponder.nextResponder = self;
        }
    }
}

- (NSArray *)respondingDescendants
{
    NSMutableArray *flatActionResponders = [NSMutableArray array];
    
    // flatten the action responders into an array
	for (XSActionResponder *actionResponder in self.actionResponders) {
		[flatActionResponders addObject:actionResponder];
		[flatActionResponders addObjectsFromArray:[actionResponder respondingDescendants]];
	}
    
    // reverse the order to build from the children up
    if (self.addControllersToResponderChainInAscendingOrder) {
        flatActionResponders = [flatActionResponders xsv_reverse];
    }

    // Yes, it's mutable, but callers should respect the return type
    return flatActionResponders;
}

- (void)logResponderChain
{
    // Note that for events the responder chain naturally terminates with the window controller:
    // NSView -> .. -> NSView -> NSWindow -> NSWindowController
    //
    // For action messages the chain is more elaborate, eg: document based app:
    // NSView -> .. -> NSView -> NSWindow -> NSWindowController -> NSWindow delegate -> NSDocument -> NSApp -> AppDelegate -> NSDocumentController
    //
    // Notes:
    // 1. This method generally reports an event style responder chain.
    //
    NSResponder *responder = [self.window firstResponder];
    NSLog(@"First responder: %@", responder);
    while ((responder = [responder nextResponder])) {
        NSLog(@"%@ responder: %@", ([responder nextResponder] ? @"Next" : @"Last"), responder);
    }
}
@end

@implementation NSMutableArray(XSResponder)

- (NSMutableArray *)xsv_reverse
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
