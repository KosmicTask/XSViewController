//
//  XSWindowController.m
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

#import "XSWindowController.h"
#import "XSViewController.h"

@interface NSMutableArray(XSViewController)
- (NSMutableArray *)xsv_reverse;
@end

@interface XSWindowController ()
@property(nonatomic,copy) NSMutableArray *respondingViewControllers;

- (void)configureViewController:(XSViewController *)viewController;
- (void)configureViewControllers:(NSArray *)viewControllers;

@end

@implementation XSWindowController

@synthesize responderChainPatchRoot = _responderChainPatchRoot;

#pragma mark -
#pragma mark Lifecycle

- (id)initWithWindowNibName:(NSString *)nibName
{
    self = [super initWithWindowNibName:nibName];
	
    if (self) {
        _respondingViewControllers = [NSMutableArray array];
        _addControllersToResponderChainInAscendingOrder = YES;
    }
    
	return self;
}

- (void)dealloc
{
    NSInteger respondingViewControllers = [self countOfRespondingViewControllers];
    if (respondingViewControllers != 0) {
        NSLog(@"%@ - Warning: controllers are still present in the responder chain.", [self className]);
    }
}

#pragma mark -
#pragma mark Window management

- (void)windowWillClose:(NSNotification *)notification
{
	[self.respondingViewControllers makeObjectsPerformSelector:@selector(removeObservations)];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self patchResponderChain];
}

#pragma mark -
#pragma mark View controller management

- (void)setRespondingViewControllers:(NSMutableArray *)newViewControllers
{
	if (_respondingViewControllers == newViewControllers) {
		return;
    }
    
	NSMutableArray *newViewControllersCopy = [newViewControllers mutableCopy];
	_respondingViewControllers = newViewControllersCopy;
}

- (NSUInteger)countOfRespondingViewControllers
{
	return [self.respondingViewControllers count];
}

- (XSViewController *)objectInRespondingViewControllersAtIndex:(NSUInteger)index
{
	return [self.respondingViewControllers objectAtIndex:index];
}

- (void)addRespondingViewController:(XSViewController *)viewController
{
    [self configureViewController:viewController];
	[self.respondingViewControllers insertObject:viewController atIndex:[self.respondingViewControllers count]];
	[self patchResponderChain];
}

- (void)insertObject:(XSViewController *)viewController inRespondingViewControllersAtIndex:(NSUInteger)index
{
    [self configureViewController:viewController];
	[self.respondingViewControllers insertObject:viewController atIndex:index];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndexes:(NSIndexSet *)indexes
{
    [self configureViewControllers:viewControllers];
	[self.respondingViewControllers insertObjects:viewControllers atIndexes:indexes];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndex:(NSUInteger)index
{
    [self configureViewControllers:viewControllers];
	[self insertObjects:viewControllers inViewControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeRespondingViewController:(XSViewController *)viewController
{
    if ([self.respondingViewControllers containsObject:viewController]) {
        [self.respondingViewControllers removeObject:viewController];
    }
	[self patchResponderChain];
}

- (void)removeAllRespondingViewControllers
{
    if (self.respondingViewControllers.count == 0) {
        return;
    }
    
    [self.respondingViewControllers removeAllObjects];
    [self patchResponderChain];
}

- (void)removeObjectFromRespondingViewControllersAtIndex:(NSUInteger)index
{
	[self.respondingViewControllers removeObjectAtIndex:index];
	[self patchResponderChain];
}

#pragma mark -
#pragma mark View controller configuration

- (void)configureViewController:(XSViewController *)viewController
{
    NSAssert([viewController isKindOfClass:[XSViewController class]], @"Invalid view controller class");
    if (viewController.windowController != self) {
        viewController.windowController = self;
    }
}

- (void)configureViewControllers:(NSArray *)viewControllers
{
    for (XSViewController *viewController in viewControllers) {
        [self configureViewController:viewController];
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
    // note that the declaration for nextresponder is @property (nullable, assign) NSResponder *nextResponder;
    // this is not the same as weak; it is the same as __unsafe_unretained.
    // hence we need to ensure that controllers get removed from the chain before they deallocate.
    // otherwise we start talking to zombies.
    
    // We are being called by view controllers at the beginning of creating the tree,
    // most likely load time and the root of the tree hasn't been added to our list of controllers.
	if ([self.respondingViewControllers count] == 0) {
        
        if (self.responderChainPatchRoot == self.window) {
            
            if (self.responderChainPatchRoot.nextResponder != self) {
                self.responderChainPatchRoot.nextResponder = self;
            }
        }
        
		return;
    }
    
    // Get the responders
	NSArray *flatViewControllers = [self respondingDescendants];
    
    // Start building from the patch root
    XSViewController *nextViewController = [flatViewControllers objectAtIndex:0];
    [self.responderChainPatchRoot setNextResponder:nextViewController];
	
    NSUInteger index = 0;
	NSUInteger viewControllerCount = [flatViewControllers count] - 1;
    
    // Set the next responder of each controller to the next, the last in the array has no default next responder.
	for (index = 0; index < viewControllerCount ; index++) {
        nextViewController = [flatViewControllers objectAtIndex:index + 1];
		[[flatViewControllers objectAtIndex:index] setNextResponder:nextViewController];
	}
    
    // Append the window controller to the chain when building from the window
    if (self.responderChainPatchRoot == self.window) {
        if (self.responderChainPatchRoot.nextResponder != self) {
            nextViewController.nextResponder = self;
        }
    }
}

- (NSArray *)respondingDescendants
{
    NSMutableArray *flatViewControllers = [NSMutableArray array];
    
    // flatten the view controllers into an array
	for (XSViewController *viewController in self.respondingViewControllers) {
		[flatViewControllers addObject:viewController];
		[flatViewControllers addObjectsFromArray:[viewController respondingDescendants]];
	}
    
    // reverse the order to build from the children up
    if (self.addControllersToResponderChainInAscendingOrder) {
        flatViewControllers = [flatViewControllers xsv_reverse];
    }

    // Yes, it's mutable, but callers should respect the return type
    return flatViewControllers;
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
    // 1. The actually responders called will of course on the view controller hierarchy and its configuration.
    // 2. This method generally reports an event style responder chain.
    //
    NSResponder *responder = [self.window firstResponder];
    NSLog(@"First responder: %@", responder);
    while ((responder = [responder nextResponder])) {
        NSLog(@"%@ responder: %@", ([responder nextResponder] ? @"Next" : @"Last"), responder);
    }
}
@end



@implementation NSMutableArray(XSViewController)

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
