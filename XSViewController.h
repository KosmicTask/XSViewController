//
//  XSViewController.h
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

#import <Cocoa/Cocoa.h>

// XS for Xtra-Special!

@class XSWindowController;
@interface XSViewController : NSViewController

@property (weak) XSViewController *parent;
@property (weak, nonatomic) XSWindowController *windowController;
@property (readonly,copy) NSMutableArray *children; // there's no mutableCopy keyword so this will be @synthesized in the implementation to get the default getter, but we'll write our own setter, otherwise mutability is lost

/*!
 If returns YES then calling the NSViewController designated initialiser results in an exception.
 Defaults to YES to retain compatibility with previous versions.
 
 This can be set to NO to ease retro fitting to existing NSViewCOntroller subclasses.
 The subclas will have to call setWindowController: before view controllers can be inserted into the responder chain.
 */
+ (BOOL)raiseExceptionForDesignatedInitialiser;
+ (void)setRaiseExceptionForDesignatedInitialiser:(BOOL)value;

/*!
 Convenience initialiser. If +raiseExceptionForDesignatedInitialiser == YES then this method effectively becomes the designated initialiser.
 */
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(XSWindowController *)windowController;

- (NSUInteger)countOfChildren;
- (XSViewController *)objectInChildrenAtIndex:(NSUInteger)index;

/*!
 This will add a new XSViewController subclass to the end of the children array.
*/
- (void)addChild:(XSViewController *)viewController;
- (void)insertObject:(XSViewController *)viewController inChildrenAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndex:(NSUInteger)index;

- (void)removeChild:(XSViewController *)viewController;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

/*!
 This method is not used in the example but does demonstrates an important 
 point of our setup: the root controller in the tree should have parent = nil.  
 If you'd rather set the parent of the root node to the window controller, 
 this method must be modified to check the class of the parent object.
*/
- (XSViewController *)rootController;

/*!
 A top-down tree sorting method.  
 
 Recursively calls itself to build up an array of all the nodes in the tree. 
 If one thinks of a file and folder setup, then this would add all the contents 
 of a folder to the array (ad infinitum) to the array before moving on to the 
 next folder at the same level
*/
- (NSArray *)descendants;

/*!
 Any manual KVO or bindings that you have set up (other than to the representedObject) 
 should be removed in this method.  It is called by the window controller on in the 
 -windowWillClose: method.  After this the window controller can safely call -dealloc 
 without any warnings that it is being deallocated while observers are still registered.
*/
- (void)removeObservations;

@end
