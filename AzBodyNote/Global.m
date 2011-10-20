//
//  Global.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "Global.h"


void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton )
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:zTitle
													message:zMsg
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:zButton, nil];
	[alert show];
	//[alert release];
}


