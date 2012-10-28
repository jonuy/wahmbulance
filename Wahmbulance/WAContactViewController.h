//
//  WAContactViewController.h
//  Wahmbulance
//
//  Created by Jonathan Uy on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WAContactViewController : UIViewController
{
    IBOutlet UITextField *emailFieldView;
    IBOutlet UITextView *messageBodyView;
    IBOutlet UIButton *submitBtn;
}

@end
