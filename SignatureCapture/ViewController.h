//
//  ViewController.h
//  SignatureCapture
//
//  Created by Jude Jonassaint on 10/31/15.
//  Copyright © 2015 Sicklesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"

@interface ViewController : UIViewController
@property (nonatomic, strong) UIImageView *mySignatureImage;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSString *pdfPath;
@property (nonatomic, strong) NSString *icfPathOutput;
@property (nonatomic, assign) CGPoint lastContactPoint1, lastContactPoint2, currentPoint;
@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) BOOL fingerMoved;
@property (nonatomic, assign) float navbarHeight;
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

