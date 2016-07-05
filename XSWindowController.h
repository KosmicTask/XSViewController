//
//  XSWindowController.h
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

#import <Cocoa/Cocoa.h>

@class XSViewController;

@interface XSWindowController : NSWindowController

/*!
 
 The object that will serve as the root for building the patched responder chain.
 This will generally either be the NSWindowController or NSWindow instances or nil (default).
 If set to an object other than any of the above than a warning is logged.
 
 If the property value is nil then responder patching begins at the window rathe than the window controller.
 
 Defaults to nil even though this breaks compatibility with previous versions.
 To me it seems more logical to have the window controller queried after its child view controllers.
 
 */
@property (weak, nonatomic) NSResponder *responderChainPatchRoot;

/*
 The top level view controllers managed by this window.
 */
@property (nonatomic,copy,readonly)  NSMutableArray *respondingViewControllers;

/*
 If YES then controllers are added to the responder chain starting with the furthest child.
 IF NO then controllers are added to the responder chain starting with the top parent.
 
 Defaults to YES even though this breaks compatibility with the original version.
 Searching up through the view controllers in the same order as the views that
 they manage seems to make more sense to me.
 
 */
+ (BOOL)addControllersToResponderChainInAscendingOrder;
+ (void)setAddControllersToResponderChainInAscendingOrder:(BOOL)value;

- (NSUInteger)countOfRespondingViewControllers;
- (XSViewController *)objectInRespondingViewControllersAtIndex:(NSUInteger)index;

/*!
 Add a view controller to the controllers array.
 */
- (void)addRespondingViewController:(XSViewController *)viewController;
- (void)insertObject:(XSViewController *)viewController inRespondingViewControllersAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndexes:(NSIndexSet *)indexes;
- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndex:(NSUInteger)index;

/*!
 
 It should be noted that if we remove an object from the view controllers
 array then the whole tree that descends from it will go too.
 
 */
- (void)removeRespondingViewController:(XSViewController *)viewController;
- (void)removeObjectFromRespondingViewControllersAtIndex:(NSUInteger)index;
- (void)removeAllRespondingViewControllers;

/*!
 An array of all descendant responders sorted according to -addControllersToResponderChainInAscendingOrder
 */
- (NSArray *)respondingDescendants;

/*!
 This method creates an array containing all the view controllers,
 then adds them to the responder chain in sequence.
 The last view controller in the array has nextResponder == nil.
 */
- (void)patchResponderChain;
+ (void)patchResponderChain:(XSViewController * )viewController;

/*!
 Log the responder chain to the console.
 */
- (void)logResponderChain;
@end
