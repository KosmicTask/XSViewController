//
//  XSWindowController.m
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

#import "XSWindowController.h"
#import "XSViewController.h"

@interface XSWindowController ()
@property(nonatomic,copy) NSMutableArray *viewControllers;
@end

@implementation XSWindowController

#pragma mark -
#pragma mark Setup

- (id)initWithWindowNibName:(NSString *)nibName
{
	if (![super initWithWindowNibName:nibName])
		return nil;
	self.viewControllers = [NSMutableArray array];
	return self;
}

#pragma mark -
#pragma mark Window management

- (void)windowWillClose:(NSNotification *)notification
{
	[self.viewControllers makeObjectsPerformSelector:@selector(removeObservations)];
}

#pragma mark -
#pragma mark View controller management

- (void)setViewControllers:(NSMutableArray *)newViewControllers
{
	if (_viewControllers == newViewControllers)
		return;
	NSMutableArray *newViewControllersCopy = [newViewControllers mutableCopy];
	_viewControllers = newViewControllersCopy;
}

- (NSUInteger)countOfViewControllers
{
	return [self.viewControllers count];
}

- (XSViewController *)objectInViewControllersAtIndex:(NSUInteger)index
{
	return [self.viewControllers objectAtIndex:index];
}

- (void)addViewController:(XSViewController *)viewController
{
	[self.viewControllers insertObject:viewController atIndex:[self.viewControllers count]];
	[self patchResponderChain];
}

- (void)insertObject:(XSViewController *)viewController inViewControllersAtIndex:(NSUInteger)index
{
	[self.viewControllers insertObject:viewController atIndex:index];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndexes:(NSIndexSet *)indexes
{
	[self.viewControllers insertObjects:viewControllers atIndexes:indexes];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndex:(NSUInteger)index
{
	[self insertObjects:viewControllers inViewControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeViewController:(XSViewController *)viewController
{    
	[self.viewControllers removeObject:viewController];
	[self patchResponderChain];
}

- (void)removeObjectFromViewControllersAtIndex:(NSUInteger)index
{
	[self.viewControllers removeObjectAtIndex:index];
	[self patchResponderChain];
}

#pragma mark -
#pragma mark Responder chain management

- (void)patchResponderChain
{    
    // we're being called by view controllers at the beginning of creating the tree,
    // most likely load time and the root of the tree hasn't been added to our list of controllers.
	if ([self.viewControllers count] == 0) {
		return;
    }
    
	NSMutableArray *flatViewControllers = [NSMutableArray array];
	for (XSViewController *viewController in self.viewControllers) { // flatten the view controllers into an array
		[flatViewControllers addObject:viewController];
		[flatViewControllers addObjectsFromArray:[viewController descendants]];
	}
	
    [self setNextResponder:[flatViewControllers objectAtIndex:0]];
	
    NSUInteger index = 0;
	NSUInteger viewControllerCount = [flatViewControllers count] - 1;
    
    // set the next responder of each controller to the next, the last in the array has no next responder.
	for (index = 0; index < viewControllerCount ; index++) {
		[[flatViewControllers objectAtIndex:index] setNextResponder:[flatViewControllers objectAtIndex:index + 1]];
	}
}

@end
