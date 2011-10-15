//
//  E2editCellNote.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"

@interface E2editCellNote : UITableViewCell <UITextFieldDelegate>
{
	id						delegate;
	E2record			*Re2record;
	//NSString			*RzKey;
	
@private
}

@property (nonatomic, retain) IBOutlet UITextField		*ibTfNote1;
@property (nonatomic, retain) IBOutlet UITextField		*ibTfNote2;

@property (nonatomic, assign) id						delegate;
@property (nonatomic, retain) E2record			*Re2record;		// 結果を戻すため
//@property (nonatomic, retain) NSString			*RzKey;			// 結果を戻すため

@end
