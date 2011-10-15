//
//  main.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AzBodyNoteAppDelegate.h"

int main(int argc, char *argv[])
{
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//int retVal = UIApplicationMain(argc, argv, nil, nil);
	//[pool release];
	//return retVal;
	
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AzBodyNoteAppDelegate class]));
	}
}
