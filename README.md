XSViewController
================

A Cocoa view controller subclass that includes responder chain patching when used in conjunction with XSWindowController.

This is a reboot of the original implementation ([zip][1]). The original functionality has been retained but the API has been updated.

Build Requirements
==================

OS X 64 bit ARC.

How to use it
=============

Read the legacy articles below for guidance then read the header file notes.

Usage is a three step process:

1. Instantiate an `XSWindowController` (or a subclass thereof).
2. Add `XSViewController` children to the `XSWindowController` instance.
3. Add `further XSViewController` children to `XSViewController`instances.

As the `XSViewController` children are manipulated they will be added and removed from the responder chain as long as at least the topmost `XSViewController` instance in any given tree has an assigned window controller.

Note that this reboot modifies the default behaviour of the original implementation. The previous implementation's behaviour, as described in the legacy documents, can be recovered like so:

	// Class configuration - disallow calling NSViewController's designated initialiser
	[XSViewController setRaiseExceptionForDesignatedInitialiser:YES] 

	XSWindowController *winController = [[MyXSWindowControllerSubclass alloc] init]; 

	// Patch the responder chain from the window controller as opposed to the window
	winController.responderChainPatchRoot = winController;

	// Add controllers in descending order - that is starting with the root rather than the children
	winController.addControllersToResponderChainInAscendingOrder = NO;

Legacy Articles
===============

The original articles that accompanied the code are no longer available. However, archived versions of the articles are still accessible. These explain in some detail the reasoning that lies behind the code:

- [Part 1](http://web.archive.org/web/20100323081441/http://katidev.com/blog/2008/04/09/nsviewcontroller-the-new-c-in-mvc-pt-1-of-3/)

- [Part 2](http://web.archive.org/web/20100501003602/http://katidev.com/blog/2008/04/17/nsviewcontroller-the-new-c-in-mvc-pt-2-of-3/)

- [part 3](http://web.archive.org/web/20100523011748/http://katidev.com/blog/2008/05/26/nsviewcontroller-the-new-c-in-mvc-pt-3-of-3/)

- [XCode demo project][1]

Authors
=======

Created by Jonathan Dann and Cathy Shive on 14/04/2008.

Updated by Jonathan Mitchell on 20/11/2013.

[1]: http://web.archive.org/web/20100501003602/http://katidev.com/blog/wp-content/uploads/2008/04/viewcontroller.zip
