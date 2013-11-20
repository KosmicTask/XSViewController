//
//  XSViewController.m
//  View Controllers
//
//  Created by Jonathan Dann and Cathy Shive on 14/04/2008.
//
// Copyright (c) 2008 Jonathan Dann and Cathy Shive
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
/*!
 This method is made private so users of the class can't (easily) set the children
 array whenever they want, they must use the indexed accessors provided. If this was 
 public then our methods that maintain the responder chain and pass the represented 
 object and window controller to the children would be subverted. Alternatively the 
 setter could set all the required variables on the objects in the newChildren array, 
 but the API then becomes a little clunkier.
 */
- (void)setChildren:(NSMutableArray *)newChildren;
@end

#pragma mark -
#pragma mark Public API

@implementation XSViewController

#pragma mark Accessors

@synthesize parent = _parent;
@synthesize windowController = _windowController;
@synthesize children = _children;

#pragma mark Designated Initialiser

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(XSWindowController *)windowController
{
	if (![super initWithNibName:name bundle:bundle])
		return nil;
	self.windowController = windowController; // non-retained to avoid retain cycles
	self.children = [NSMutableArray array]; // set up a blank mutable array
	return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
    
    @throw [NSException exceptionWithName:@"XSViewControllerException"
                                   reason:@"An instance of an XSViewController concrete subclass was initialized using the NSViewController method -initWithNibName:bundle: all view controllers in the ensuing tree will have no reference to an XSWindowController object and cannot be automatically added to the responder chain"
                                 userInfo:nil];
	return nil;
}


#pragma mark Indexed Accessors

- (NSUInteger)countOfChildren
{
	return [self.children count];
}

- (XSViewController *)objectInChildrenAtIndex:(NSUInteger)index
{
	return [self.children objectAtIndex:index];
}

- (void)addChild:(XSViewController *)viewController
{
	[self insertObject:viewController inChildrenAtIndex:[self.children count]];
}

- (void)removeChild:(XSViewController *)viewController
{
	[self.children removeObject:viewController];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index
{
	[self.children removeObjectAtIndex:index];
	[(XSWindowController *)self.windowController patchResponderChain]; // each time a controller is removed then the repsonder chain needs fixing
}

- (void)insertObject:(XSViewController *)viewController inChildrenAtIndex:(NSUInteger)index
{
	[self.children insertObject:viewController atIndex:index];
	[viewController setParent:self];
	[self.windowController patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndexes:(NSIndexSet *)indexes
{
	[self.children insertObjects:viewControllers atIndexes:indexes];
	[viewControllers makeObjectsPerformSelector:@selector(setParent:) withObject:self];
	[self.windowController patchResponderChain]; 
}

- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndex:(NSUInteger)index
{
	[self insertObjects:viewControllers inChildrenAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

# pragma mark Utilities

- (void)setChildren:(NSMutableArray *)newChildren
{
	if (_children == newChildren) {
		return;
    }
    
	NSMutableArray *newChildrenCopy = [newChildren mutableCopy];
	_children = newChildrenCopy;
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
	while (root.parent)
		root = root.parent;
	return root;
}

- (NSArray *)descendants
{
	NSMutableArray *array = [NSMutableArray array];
	for (XSViewController *child in self.children) {
		[array addObject:child];
		if ([child countOfChildren] > 0)
			[array addObjectsFromArray:[child descendants]];
	}
	return [array copy]; // return an immutable array
}

- (void)removeObservations
{
	[self.children makeObjectsPerformSelector:@selector(removeObservations)];
}

@end
