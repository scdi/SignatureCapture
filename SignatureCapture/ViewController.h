//
//  ViewController.h
//  SignatureCapture
//
//  Created by Jude Jonassaint on 10/31/15.
//  Copyright © 2015 Sicklesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, strong) UIImageView *mySignatureImage;
@property (nonatomic, assign) CGPoint lastContactPoint1, lastContactPoint2, currentPoint;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) BOOL fingerMoved;
@property (nonatomic, assign) float navbarHeight;

@end

