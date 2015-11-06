//
//  XSActionResponder.h
//
//  Created by Jonathan Mitchell on 05/11/2015.
//  Copyright (c) 2015 Thesaurus Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XSWindowController.h"

@interface XSActionResponder : NSResponder

@property (weak) XSActionResponder *parent;

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

@property (readonly,copy) NSMutableArray *actionResponders; // there's no mutableCopy keyword so this will be @synthesized in the implementation to get the default getter, but we'll write our own setter, otherwise mutability is lost

- (NSUInteger)countOfActionResponders;
- (XSActionResponder *)objectInActionRespondersAtIndex:(NSUInteger)index;

/*!
 This will add a new XSResponder subclass to the end of the children array.
 
 In all methods that add child view controllers the added controllers will have their -windowController set to match the parents windowcontroller.
 This largely removes the necessity of manually managing this property at initialisation or elsewhere.
 
 NOTE:
 An action will potentially be sent to each responding sibling of the receiver.
 The receiver will not necessarily receive the action first.
 
 This behavior is powerful but can make figuring out which object will respond to an action difficult.
 
 */
- (void)addRespondingChild:(XSActionResponder *)actionResponder;

/*
 
 Object management
 
 */
- (void)insertObject:(XSActionResponder *)actionResponder inActionRespondersAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndexes:(NSIndexSet *)indexes;

- (void)removeRespondingChild:(XSActionResponder *)actionResponder;
- (void)removeAllRespondingChildren;
- (void)removeObjectFromActionRespondersAtIndex:(NSUInteger)index;

/*!
 This method is not used in the example but does demonstrates an important
 point of our setup: the root controller in the tree should have parent = nil.
 If you'd rather set the parent of the root node to the window controller,
 this method must be modified to check the class of the parent object.
 */
- (XSActionResponder *)rootController;

/*!
 A top-down tree sorting method.
 
 Recursively calls itself to build up an array of all the nodes in the tree.
 If one thinks of a file and folder setup, then this would add all the contents
 of a folder to the array (ad infinitum) to the array before moving on to the
 next folder at the same level
 */
- (NSArray *)respondingDescendants;
@end
