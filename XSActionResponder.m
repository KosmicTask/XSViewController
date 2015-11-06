//
//  XSActionResponder.m
//
//  Created by Jonathan Mitchell on 05/11/2015.
//  Copyright (c) 2015 Thesaurus Software Limited. All rights reserved.
//

#import "XSActionResponder.h"

@interface XSActionResponder()
- (void)setActionResponders:(NSMutableArray *)newChildren;
- (void)configureActionResponder:(XSActionResponder *)actionResponder;
- (void)configureActionResponders:(NSArray *)actionResponders;
@end

@implementation XSActionResponder

@synthesize windowController = _windowController;

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        _actionResponders = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark -
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

#pragma mark -
#pragma mark Indexed Accessors

- (NSUInteger)countOfActionResponders
{
    return [self.actionResponders count];
}

- (XSActionResponder *)objectInActionRespondersAtIndex:(NSUInteger)index
{
    return [self.actionResponders objectAtIndex:index];
}

- (void)addRespondingChild:(XSActionResponder *)actionResponder
{
    
    if ([self.actionResponders containsObject:actionResponder]) {
        NSLog(@"%@ is already registered as a responding child of %@", actionResponder, self);
        return;
    }
    
    [self insertObject:actionResponder inActionRespondersAtIndex:[self.actionResponders count]];
}

- (void)removeRespondingChild:(XSActionResponder *)actionResponder
{
    [self.actionResponders removeObject:actionResponder];
    actionResponder.parent = nil;
    [self patchResponderChain];
}

- (void)removeAllRespondingChildren
{
    if (self.actionResponders.count == 0) {
        return;
    }
    
    // remove all the child
    for (XSActionResponder * child in [self.actionResponders copy]) {
        [self.actionResponders removeObject:child];
        child.parent = nil;
    }
    
    // patch the chain
    [self patchResponderChain];
}

- (void)removeObjectFromActionRespondersAtIndex:(NSUInteger)index
{
    [self.actionResponders removeObjectAtIndex:index];
    [self patchResponderChain];
}

- (void)insertObject:(XSActionResponder *)actionResponder inActionRespondersAtIndex:(NSUInteger)index
{
    [self configureActionResponder:actionResponder];
    [self.actionResponders insertObject:actionResponder atIndex:index];
    [actionResponder setParent:self];
    [self patchResponderChain];
}

- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndexes:(NSIndexSet *)indexes
{
    [self configureActionResponders:actionResponders];
    [self.actionResponders insertObjects:actionResponders atIndexes:indexes];
    [actionResponders makeObjectsPerformSelector:@selector(setParent:) withObject:self];
    [self patchResponderChain];
}

- (void)insertObjects:(NSArray *)actionResponders inActionRespondersAtIndex:(NSUInteger)index
{
    [self insertObjects:actionResponders inActionRespondersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

#pragma mark -
# pragma mark Action responder configuration

- (void)configureActionResponder:(XSActionResponder *)actionResponders
{
    // Assign the window controller if available and dynamic window controller resolution is off
    if (actionResponders.windowController != self.windowController && !self.alwaysQueryRootControllerForWindowController) {
        actionResponders.windowController = self.windowController;
    }
}

- (void)configureActionResponders:(NSArray *)actionResponders
{
    for (XSActionResponder *actionResponder in actionResponders) {
        [self configureActionResponder:actionResponder];
    }
}

#pragma mark -
# pragma mark Responder chain management

- (void)patchResponderChain
{
    [self.windowController patchResponderChain];
}

#pragma mark -
# pragma mark Utilities

- (void)setActionResponders:(NSMutableArray *)newChildren
{
    if (_actionResponders == newChildren) {
        return;
    }
    
    NSMutableArray *newChildrenCopy = [newChildren mutableCopy];
    _actionResponders = newChildrenCopy;
}

- (XSActionResponder *)rootController
{
    XSActionResponder *root = self.parent;
    
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
    
    for (XSActionResponder *child in self.actionResponders) {
        [array addObject:child];
        if ([child countOfActionResponders] > 0)
            [array addObjectsFromArray:[child respondingDescendants]];
    }
    return [array copy]; // return an immutable array
}

@end
