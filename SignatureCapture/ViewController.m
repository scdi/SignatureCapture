//
//  ViewController.m
//  SignatureCapture
//
//  Created by Jude Jonassaint on 10/31/15.
//  Copyright © 2015 Sicklesoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //set the view background to light gray
    self.view.backgroundColor = [UIColor lightGrayColor];
    

    
    //create a frame for our signature capture based on whats remaining
    self.imageFrame = CGRectMake(self.view.frame.origin.x+10,
                            self.view.frame.origin.y-5,
                            self.view.frame.size.width-20,
                            self.view.frame.size.height-30);
    
    //allocate an image view and add to the main view
    self.mySignatureImage = [[UIImageView alloc] initWithImage:nil];
    self.mySignatureImage.frame = self.imageFrame;
    self.mySignatureImage.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mySignatureImage];
}
//when one or more fingers touch down in a view or window
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //did our finger moved yet?
    self.fingerMoved = NO;
    UITouch *touch = [touches anyObject];
    
    //just clear the image if the user tapped twice on the screen
    if ([touch tapCount] == 2) {
        self.mySignatureImage.image = nil;
        return;
    }
    
    //we need 3 points of contact to make our signature smooth using quadratic bezier curve
    self.currentPoint = [touch locationInView:_mySignatureImage];
    self.lastContactPoint1 = [touch previousLocationInView:_mySignatureImage];
    self.lastContactPoint2 = [touch previousLocationInView:_mySignatureImage];
    
}


//when one or more fingers associated with an event move within a view or window
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //well its obvious that our finger moved on the screen
    _fingerMoved = YES;
    UITouch *touch = [touches anyObject];
    
    //save previous contact locations
    _lastContactPoint2 = _lastContactPoint1;
    _lastContactPoint1 = [touch previousLocationInView:_mySignatureImage];
    //save current location
    _currentPoint = [touch locationInView:_mySignatureImage];
    
    //find mid points to be used for quadratic bezier curve
    CGPoint midPoint1 = [self midPoint:_lastContactPoint1 withPoint:_lastContactPoint2];
    CGPoint midPoint2 = [self midPoint:_currentPoint withPoint:_lastContactPoint1];
    
    //create a bitmap-based graphics context and makes it the current context
    UIGraphicsBeginImageContext(_imageFrame.size);
    
    //draw the entire image in the specified rectangle frame
    [_mySignatureImage.image drawInRect:CGRectMake(0, 0, _imageFrame.size.width, _imageFrame.size.height)];
    
    //set line cap, width, stroke color and begin path
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0f);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    
    //begin a new new subpath at this point
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), midPoint1.x, midPoint1.y);
    //create quadratic Bézier curve from the current point using a control point and an end point
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(),
                                 _lastContactPoint1.x, _lastContactPoint1.y, midPoint2.x, midPoint2.y);
    
    //set the miter limit for the joins of connected lines in a graphics context
    CGContextSetMiterLimit(UIGraphicsGetCurrentContext(), 2.0);
    
    //paint a line along the current path
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    //set the image based on the contents of the current bitmap-based graphics context
    _mySignatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
    
    //remove the current bitmap-based graphics context from the top of the stack
    UIGraphicsEndImageContext();
    
    //lastContactPoint = currentPoint;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    //just clear the image if the user tapped twice on the screen
    if ([touch tapCount] == 2) {
        _mySignatureImage.image = nil;
        return;
    }
    
    
    //if the finger never moved draw a point
    if(!_fingerMoved) {
        UIGraphicsBeginImageContext(_imageFrame.size);
        [_mySignatureImage.image drawInRect:CGRectMake(0, 0, _imageFrame.size.width, _imageFrame.size.height)];
        
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0f);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _currentPoint.x, _currentPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _currentPoint.x, _currentPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        
        _mySignatureImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

//calculate midpoint between two points
- (CGPoint) midPoint:(CGPoint )p0 withPoint: (CGPoint) p1 {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}


//save button was clicked, its time to save the signature
- (void) saveSignature:(id)sender {
    
    //get reference to the button that requested the action
    UIBarButtonItem *myButton = (UIBarButtonItem *)sender;
    
    //check which button it is, if you have more than one button on the screen
    //you must check before taking necessary action
    if([myButton.title isEqualToString:@"Save"]){
        NSLog(@"Clicked on the bar button");
        
        //display an alert to capture the person's name
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving signature with name"
                                                            message:@"Please enter your name"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Ok", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
    }
    
}

//some action was taken on the alert view
- (void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //which button was pressed in the alert view
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    //user wants to save the signature now
    if ([buttonTitle isEqualToString:@"Ok"]){
        NSLog(@"Ok button was pressed.");
        NSLog(@"Name of the person is: %@", [[alertView textFieldAtIndex:0] text]);
        NSString * personName = [[alertView textFieldAtIndex:0] text];
        
        //create path to where we want the image to be saved
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"MyFolder"];
        
        //if the folder doesn't exists then just create one
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&error];
        
        //convert image into .png format.
        NSData *imageData = UIImagePNGRepresentation(_mySignatureImage.image);
        NSString *fileName = [filePath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@.png", personName]];
        
        //creates an image file with the specified content and attributes at the given location
        [fileManager createFileAtPath:fileName contents:imageData attributes:nil];
        NSLog(@"image saved");
        
        //check if the display signature view controller doesn't exists then create it
//        if(self.displaySignatureViewController == nil){
//            DisplaySignatureViewController *displayView = [[DisplaySignatureViewController alloc] init];
//            self.displaySignatureViewController = displayView;
//        }
//        
//        //pass the person's name to the next view controller
//        self.displaySignatureViewController.personName = personName;
//        
//        //tell the navigation controller to push a new view into the stack
//        [self.navigationController pushViewController:self.displaySignatureViewController animated:YES];
        
        
    }
    
    //just forget it
    else if ([buttonTitle isEqualToString:@"Cancel"]){
        NSLog(@"Cancel button was pressed.");
    }
    
}
/*
-(void)makePDF {
    [self setupPDFDocumentNamed:@"NewPDF" Width:850 Height:1100];
    
    [self beginPDFPage];
    
    CGRect textRect = [self addText:@"This is some nice text here, don't you agree?"
                          withFrame:CGRectMake(kPadding, kPadding, 400, 200) fontSize:28.0f];
    
    CGRect blueLineRect = [self addLineWithFrame:CGRectMake(kPadding, textRect.origin.y + textRect.size.height + kPadding, _pageSize.width - kPadding*2, 4)
                                       withColor:[UIColor blueColor]];
    
    UIImage *anImage = [UIImage imageNamed:@"tree.jpg"];
    CGRect imageRect = [self addImage:anImage
                              atPoint:CGPointMake((_pageSize.width/2)-(anImage.size.width/2), blueLineRect.origin.y + blueLineRect.size.height + kPadding)];
    
    [self addLineWithFrame:CGRectMake(kPadding, imageRect.origin.y + imageRect.size.height + kPadding, _pageSize.width - kPadding*2, 4)
                 withColor:[UIColor redColor]];
    
    [self finishPDF];
}

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height {
    _pageSize = CGSizeMake(width, height);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
}

- (void)beginPDFPage {
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);
}

- (void)finishPDF {
    UIGraphicsEndPDFContext();
}

- (CGRect)addText:(NSString*)text withFrame:(CGRect)frame fontSize:(float)fontSize {
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(_pageSize.width - 2*20-2*20, _pageSize.height - 2*20 - 2*20) lineBreakMode:UILineBreakModeWordWrap];
    
    float textWidth = frame.size.width;
    
    if (textWidth < stringSize.width)
        textWidth = stringSize.width;
    if (textWidth > _pageSize.width)
        textWidth = _pageSize.width - frame.origin.x;
    
    CGRect renderingRect = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    
    [text drawInRect:renderingRect
            withFont:font
       lineBreakMode:UILineBreakModeWordWrap
           alignment:UITextAlignmentLeft];
    
    frame = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    
    return frame;
}

- (CGRect)addLineWithFrame:(CGRect)frame withColor:(UIColor*)color {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    
    // this is the thickness of the line
    CGContextSetLineWidth(currentContext, frame.size.height);
    
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    
    return frame;
}

- (CGRect)addImage:(UIImage*)image atPoint:(CGPoint)point {
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    
    return imageFrame;
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end