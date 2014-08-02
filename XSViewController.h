//
//  XSViewController.h
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

// XS for Xtra-Special!

@class XSWindowController;
@interface XSViewController : NSViewController

@property (weak) XSViewController *parent;

/*!
 
 The windowController property must resolve to an instance of XSWindowController in order for
 controllers to be patched into the responder chain.
 
 This property can be set explicitly during initialisation or later.
 Alternatively the property will be set automatically when it is added as a child responder.
 
 Commonly view controllers are instantiated in -awakeFromNib and may have no access to a window.
 If a given view controller has a nil -windowController then it requests the root controllers -windowController instance.
 
 Therefore, any given tree of controllers will be patched into the responder chain as long as the root controller
 has a valid window controller reference.
 
 */
@property (weak, nonatomic) XSWindowController *windowController;


@property BOOL alwaysQueryRootControllerForWindowController;

@property (readonly,copy) NSMutableArray *respondingChildren; // there's no mutableCopy keyword so this will be @synthesized in the implementation to get the default getter, but we'll write our own setter, otherwise mutability is lost

/*!
 If returns YES then calling the NSViewController designated initialiser results in an exception.
 Defaults to NO even though this will break compatibility with previous versions.
 
 The default setting of NO eases retro fitting to existing NSViewController subclasses.
 - windowController: will be resolved when adding the controller as a child either to XSWindowController or XVViewController or dynamically when required.
 */
+ (BOOL)raiseExceptionForDesignatedInitialiser;
+ (void)setRaiseExceptionForDesignatedInitialiser:(BOOL)value;

/*!
 Convenience initialiser. If +raiseExceptionForDesignatedInitialiser == YES then this method effectively becomes the designated initialiser.
 */
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(XSWindowController *)windowController;

- (NSUInteger)countOfRespondingChildren;
- (XSViewController *)objectInRespondingChildrenAtIndex:(NSUInteger)index;

/*!
 This will add a new XSViewController subclass to the end of the children array.
 
 In all methods that add child view controllers the added controllers will have their -windowController set to match the parents windowcontroller.
 This largely removes the necessity of manually managing this property at initialisation or elsewhere.

 NOTE:
 An action will potentially be sent to each responding sibling of the receiver.
 The receiver will not necessarily receive the action first.
 
 This behavior is powerful but can make figuring out which object will respond to an action difficult.
 In general then
 
 */
- (void)addRespondingChild:(XSViewController *)viewController;

/*
 
 Object management
 
 */
- (void)insertObject:(XSViewController *)viewController inRespondingChildrenAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)viewControllers inRespondingChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)insertObjects:(NSArray *)viewControllers inRespondingChildrenAtIndex:(NSUInteger)index;

- (void)removeRespondingChild:(XSViewController *)viewController;
- (void)removeObjectFromRespondingChildrenAtIndex:(NSUInteger)index;

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
- (NSArray *)respondingDescendants;

/*!
 Any manual KVO or bindings that you have set up (other than to the representedObject) 
 should be removed in this method.  It is called by the window controller on in the 
 -windowWillClose: method.  After this the window controller can safely call -dealloc 
 without any warnings that it is being deallocated while observers are still registered.
*/
- (void)removeObservations;

@end
