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

static BOOL _raiseExceptionForDesignatedInitialiser = NO;

#pragma mark Private API

@interface XSViewController ()
/*!
 This method is made private so users of the class can't (easily) set the children
 array whenever they want, they must use the indexed accessors provided. If this was 
 public then our methods that maintain the responder chain and pass the represented 
 object and window controller to the children would be subverted. Alternatively the 
 setter could set all the required variables on the objects in the newChildren array, 
 but the API then becomes a little clunkier.
 */
- (void)setRespondingChildren:(NSMutableArray *)newChildren;

- (void)configureViewController:(XSViewController *)viewController;
- (void)configureViewControllers:(NSArray *)viewControllers;

@property (strong, readwrite, nonatomic) XSProxyViewController *proxyViewController;

@end

#pragma mark -
#pragma mark Public API

@implementation XSViewController

@synthesize windowController = _windowController;

+ (BOOL)raiseExceptionForDesignatedInitialiser
{
    return _raiseExceptionForDesignatedInitialiser;
}

+ (void)setRaiseExceptionForDesignatedInitialiser:(BOOL)value
{
    _raiseExceptionForDesignatedInitialiser = value;
}

#pragma mark -
#pragma mark Life cycle

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(XSWindowController *)windowController
{
    self = [super initWithNibName:name bundle:bundle];
    
    if (self) {
        [self setupInstance];
        _windowController = windowController; // non-retained to avoid retain cycles
    }
    
	return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
    if ([[self class] raiseExceptionForDesignatedInitialiser]) {
        
        // Legacy support only!
        @throw [NSException exceptionWithName:@"XSViewControllerException"
                                       reason:@"An instance of an XSViewController concrete subclass was initialized using the NSViewController desigated initialiser method -initWithNibName:bundle: all view controllers in the ensuing tree will have no initial reference to an XSWindowController object however they may easily obtain one subsequently!. To allow calling of the designated initialiser set +raiseExceptionForDesignatedInitialiser = NO."
                                     userInfo:nil];
    }
    
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        [self setupInstance];
    }
    
	return self;
}

- (void)setupInstance
{
    _respondingChildren = [NSMutableArray array]; // set up a blank mutable array
    _alwaysQueryRootControllerForWindowController = NO;
}

#pragma mark Accessors

- (void)setWindowController:(XSWindowController *)controller
{
    _windowController = controller;
    [self patchResponderChain];
}

- (XSWindowController *)windowController
{
    XSWindowController *controller = nil;
    
    if (_windowController && !self.alwaysQueryRootControllerForWindowController) {
        controller = _windowController;
    } else if (self.parent) {
        
        // If no local controller instance available then query the root
        controller = [self.rootController windowController];
        
        // Cache the window controller if dynamic querying not required
        if (controller && !self.alwaysQueryRootControllerForWindowController) {
            _windowController = controller;
        }
    }
    
    return controller;
}

- (void)setView:(NSView *)view
{
    [super setView:view];

    if (self.proxyViewController) {
        self.proxyViewController.view = view;
    }
}

- (NSView *)view
{
    if (self.proxyViewController) {
        return self.proxyViewController.view;
    } else {
        return [super view];
    }
}

- (void)setProxyViewController:(XSProxyViewController *)proxyViewController
{
    _proxyViewController = proxyViewController;
 
    // contract
    NSAssert(_proxyViewController, @"invalid proxyViewController");
    NSAssert(self.view != nil && _proxyViewController.view == self.view, @"proxyViewController not correctly configured");
}

/*
 
- (void)setMenu:(NSMenu *)menu
{
    _menu = menu;
}

- (NSMenu *)menu
{
    return _menu;
}
*/

#pragma mark Indexed Accessors

- (NSUInteger)countOfRespondingChildren
{
	return [self.respondingChildren count];
}

- (XSViewController *)objectInRespondingChildrenAtIndex:(NSUInteger)index
{
	return [self.respondingChildren objectAtIndex:index];
}

- (void)addRespondingChild:(XSViewController *)viewController
{
    
    if ([self.respondingChildren containsObject:viewController]) {
        NSLog(@"%@ is already registered as a responding child of %@", viewController, self);
        return;
    }
    
	[self insertObject:viewController inRespondingChildrenAtIndex:[self.respondingChildren count]];
}

- (void)removeRespondingChild:(XSViewController *)viewController
{
	[self.respondingChildren removeObject:viewController];
    viewController.parent = nil;
    [self patchResponderChain];
}

- (void)removeAllRespondingChildren
{
    if (self.respondingChildren.count == 0) {
        return;
    }
    
    // remove all the child
    for (XSViewController * child in [self.respondingChildren copy]) {
        [self.respondingChildren removeObject:child];
        child.parent = nil;
    }
    
    // patch the chain
    [self patchResponderChain];
}

- (void)removeObjectFromRespondingChildrenAtIndex:(NSUInteger)index
{
	[self.respondingChildren removeObjectAtIndex:index];
	[self patchResponderChain];
}

- (void)insertObject:(XSViewController *)viewController inRespondingChildrenAtIndex:(NSUInteger)index
{
    [self configureViewController:viewController];
    
    // Note: the viewController is strongly retained.
    // it might be prefereable to retain a zeroing weak reference instead.
	[self.respondingChildren insertObject:viewController atIndex:index];
	[viewController setParent:self];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inRespondingChildrenAtIndexes:(NSIndexSet *)indexes
{
    [self configureViewControllers:viewControllers];
	[self.respondingChildren insertObjects:viewControllers atIndexes:indexes];
	[viewControllers makeObjectsPerformSelector:@selector(setParent:) withObject:self];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inRespondingChildrenAtIndex:(NSUInteger)index
{
	[self insertObjects:viewControllers inRespondingChildrenAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

# pragma mark View controller configuration

- (void)configureViewController:(XSViewController *)viewController
{
    // Assign the window controller if available and dynamic window controller resolution is off
    if (viewController.windowController != self.windowController && !self.alwaysQueryRootControllerForWindowController) {
        viewController.windowController = self.windowController;
    }
    
    // On 10.10 and above AppKit inserts NSViewController into the responder chain above the controller view.
    // This clearly interfers with the XSViewController design philosophy of placing controllers
    // between the NSWindow and NSWindowController.
    // Just manipulating the view's nextResponder directly doesn't seem to work - the view wants to retain its controller as its nextReponder.
    // Hence we allocate a controller proxy to serve as the view's next responder.
    // This leaves the proxy parent free to be inserted elsewhere in the chain.
    if (!viewController.proxyViewController) {
        [viewController createProxyViewControllerWithClass:[XSProxyViewController class]];
    }
}

- (void)configureViewControllers:(NSArray *)viewControllers
{
    for (XSViewController *viewController in viewControllers) {
        [self configureViewController:viewController];
    }
}

- (void)createProxyViewControllerWithClass:(Class)proxyViewControllerClass
{
    // subclasses can override to provide proxy class customisation
    
    // contract
    NSAssert(self.view, @"invalid view");
    NSAssert([proxyViewControllerClass isSubclassOfClass:[XSProxyViewController class]], @"invalid proxy view controller class");
    
    // create proxy view controller
    self.proxyViewController = [[proxyViewControllerClass alloc] initWithView:self.view];
}

# pragma mark Responder chain management

- (void)patchResponderChain
{
    [self.windowController patchResponderChain];
}

# pragma mark Utilities

- (void)setRespondingChildren:(NSMutableArray *)newChildren
{
	if (_respondingChildren == newChildren) {
		return;
    }
    
	NSMutableArray *newChildrenCopy = [newChildren mutableCopy];
	_respondingChildren = newChildrenCopy;
}

- (XSViewController *)rootController
{
	XSViewController *root = self.parent;
	
    // we are the top of the tree
    if (!root) {
		return self;
    }
    
    // if this is nil then there is no parent, the whole system is based on the idea
    // that the top of the tree has nil parent, not the windowController as its parent.
	while (root.parent) {
		root = root.parent;
    }
    
	return root;
}

- (NSArray *)respondingDescendants
{
	NSMutableArray *array = [NSMutableArray array];
    
	for (XSViewController *child in self.respondingChildren) {
		[array addObject:child];
		if ([child countOfRespondingChildren] > 0)
			[array addObjectsFromArray:[child respondingDescendants]];
	}
	return [array copy]; // return an immutable array
}

- (void)removeObservations
{
	[self.respondingChildren makeObjectsPerformSelector:@selector(removeObservations)];
}

@end
