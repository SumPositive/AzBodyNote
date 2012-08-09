//
//  PatternImageView.h
//  AzPackList
//
//  Created by Sum Positive on 12/01/07.
//  Copyright (c) 2012 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatternImageView : UIView
{
@private
    UIImage		*mImage;
}

- (id)initWithFrame:(CGRect)frame  patternImage:(UIImage*)image;

@end


