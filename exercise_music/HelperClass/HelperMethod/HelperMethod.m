//
//  HelerMethod.m
//  NetworkRequestProject
//
//  Created by Adite Technologies on 09/09/14.
//  Copyright (c) 2014 Adite Technologiesnology. All rights reserved.
//

#import "HelperMethod.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <AddressBookUI/AddressBookUI.h>
#import "exercise_music-Swift.h"

@interface UIImage (fixorientation)
- (UIImage *) fixOrientation;
@end

@implementation IMGDATA
@synthesize fileName;
@synthesize paraName;
@synthesize imgProfile;
@end

@implementation UIImage (fixorientation)
- (UIImage *) fixOrientation {

    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end

@interface HelerMethod()
@property (nonatomic, strong) void(^completionHandler)(id);
@end

@implementation HelerMethod

+ (HelerMethod *) HelerMethodObject
{
    return [HelerMethod new];
}
- (void) Toast:(NSString *) msg {
    
    [ALToastView toastInView:KAppDelegate.window withText:msg isKeyBoardUp:KAppDelegate.keyBoardIsUP];
}
- (void) Toast:(NSString *) msg isKeyBoardUp:(BOOL)up {
    [ALToastView toastInView:KAppDelegate.window withText:msg isKeyBoardUp:up];
}
- (BOOL) check:(NSString *) url
{
    NSURL *candidateURL = [NSURL URLWithString:url];

    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - PopUP

- (void) PopUP
{
    if (POPUP) {
        [self performSelectorOnMainThread:@selector(PopUpNetworkMessage) withObject:nil waitUntilDone:NO];
    }
}


#pragma mark - isObject

- (BOOL) isObjectNotNil:(id) ob
{
    if (ob == nil)
        return NO;

    if ([ob isKindOfClass:[NSNull class]])
        return NO;

    return YES;
}

- (BOOL) isObject:(id) ob TypeOf:(int) which
{
    @try {
        if (ob) {
            if (![ob isKindOfClass:[NSNull class]]) {
                if (which == Type_Str) {
                    if ([ob isKindOfClass:[NSString class]]) {
                        return YES;
                    } else {
                        if ([ob isKindOfClass:[NSMutableString class]])
                            return YES;
                        else
                            return NO;
                    }
                } else if (which == Type_Arr) {
                    if ([ob isKindOfClass:[NSArray class]]) {
                        return YES;
                    } else {
                        if ([ob isKindOfClass:[NSMutableArray class]])
                            return YES;
                        else
                            return NO;
                    }
                } else if (which == Type_Dct) {
                    if ([ob isKindOfClass:[NSDictionary class]]) {
                        return YES;
                    } else {
                        if ([ob isKindOfClass:[NSMutableDictionary class]])
                            return YES;
                        else
                            return NO;
                    }
                } else if (which == Type_Int) {
                    if ([ob isKindOfClass:[NSNumber class]]) {
                        return YES;
                    } else {
                        return NO;
                    }
                } else if (which == Type_Img) {
                    if ([ob isKindOfClass:[UIImage class]])
                        return YES;
                    else
                        return NO;
                } else if (which == Type_Lbl) {
                    if ([ob isKindOfClass:[UILabel class]])
                        return YES;
                    else
                        return NO;
                } else if (which == Type_ImV) {
                    if ([ob isKindOfClass:[UIImageView class]])
                        return YES;
                    else
                        return NO;
                } else if (which == Type_Btn) {
                    if ([ob isKindOfClass:[UIButton class]])
                        return YES;
                    else
                        return NO;
                } else if (which == Type_Viw) {
                    if ([ob isKindOfClass:[UIView class]])
                        return YES;
                    else
                        return NO;
                }
            } else {
                return NO;
            }
        } else {
            return NO;
        }

        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

#pragma mark - jsonString

-(NSString*) jsonString:(id) ob {
    NSError *error;
    BOOL prettyPrint = NO;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ob
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];

    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        if ([obNet isObject:ob TypeOf:Type_Dct]) {
            return @"{}";
        } else if ([obNet isObject:ob TypeOf:Type_Arr]) {
            return @"[]";
        } else {
            return nil;
        }
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

#pragma mark - DistanceBetweenTwoPoints

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}

#pragma mark - ConvertDate

- (NSString *) ConvertDate:(NSString *) toDate FromFormate:(NSString *) fromFormate ToFormate:(NSString *) toFormate
{
    @try {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:fromFormate];

        NSDate *date = [formatter dateFromString:toDate];

        [formatter setDateFormat:toFormate];

        NSString * output = [formatter stringFromDate:date];

        if (!output)
            output = toDate;

        return output;
    } @catch (NSException *exception) {
        return @"";
    }
}

#pragma mark - maskImage

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {

    CGImageRef maskRef = maskImage.CGImage;

    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}



- (void) setBorder:(UIView *) view Color:(UIColor *) color CornerRadious:(float) cr BorderWidth:(float) bw
{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = cr;
    view.layer.borderWidth = bw;
    view.layer.borderColor = color.CGColor;
}

- (void) setBorder:(UIView *) view ColorArray:(NSArray *) colorArray CornerRadious:(float) cr BorderWidth:(float) bw
{
    NSString * red   = colorArray[0]; //red
    NSString * green = colorArray[1]; //green
    NSString * blue  = colorArray[2]; //blue

    NSString * alpha = @"1.0";

    if (colorArray.count == 4)
        alpha = colorArray[3];        //alpha

    UIColor * color = [UIColor colorWithRed:red.doubleValue/255.0 green:green.doubleValue/255.0 blue:blue.doubleValue/255.0 alpha:alpha.doubleValue];

    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = cr;
    view.layer.borderWidth = bw;
    view.layer.borderColor = color.CGColor;
}

- (NSString *) getPNToken:(NSData*) deviceToken
{
    NSString * token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    return [token copy];
}

- (NSString *) base64forData:(NSData *) theData {

    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void) setUserInfoObject:(id) object
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:USERLOGINDATA];
    [defaults synchronize];
}

- (id) getUserInfoObject {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:USERLOGINDATA];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

    return object;
}
- (void)removeUserInfoObject
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USERLOGINDATA];
    [defaults synchronize];
}

- (void) setDefaultUserData:(NSMutableDictionary *) dict WithKey:(NSString *) key
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [defaults setObject:myData forKey:key];
    [defaults synchronize];
}

- (NSMutableDictionary *) getDefaultUserDataWithKey:(NSString *) key
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary * dict = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:key]];
    return dict;
}

- (NSDateComponents *) ageFrom:(NSDate   *) from
                        ToDate:(NSDate   *) to
                FromDateString:(NSString *) fromDateString
               FromDateFormate:(NSString *) fromDateFormate
                  toDateString:(NSString *) toDateString
                 toDateFormate:(NSString *) toDateFormate
{
    if (from == nil) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:fromDateFormate];
        from = [dateFormatter dateFromString:fromDateString];
    }

    if (to == nil) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:toDateFormate];
        to = [dateFormatter dateFromString:toDateString];
    }

    @try {
        if (from && to)
        {
            NSDateComponents * ageComponents = [[NSCalendar currentCalendar]
                                                components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                fromDate:from
                                                toDate:to
                                                options:0];

            return ageComponents;
        } else {
            return [NSDateComponents new];
        }
    } @catch (NSException *exception) { }
}

- (NSString *) UUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (CGRect) deviceFrame {
    return [UIScreen mainScreen].bounds;
}

- (NSString *) getIPAddress {

    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void) startSpaceTo:(UITextField *)textfield Space:(float) space
{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, space)];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    [textfield setLeftView:spacerView];
}

- (void) titleInMoreLines:(UIButton *) button
{
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[button setTitle: @"Line1\nLine2" forState: UIControlStateNormal];
}

- (void) setHtml: (NSString*) html Label:(UILabel *) lbl
{
    NSError *err = nil;
    lbl.attributedText = [[NSAttributedString alloc] initWithData: [html dataUsingEncoding:NSUTF8StringEncoding]
                                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                               documentAttributes: nil
                                                            error: &err];

    if(err)
        NSLog(@"Unable to parse label text: %@", err);
}

+ (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *) font {
    CGSize size = CGSizeZero;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }

    return size;
}

- (id) getJsonFromFile:(NSString *) filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSError * e;
    NSMutableDictionary *dictJSON = [NSJSONSerialization JSONObjectWithData: [content dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];

    return dictJSON;
}

- (BOOL) checkJson:(id) json PassPopUp:(BOOL) boolPass FailPopUp:(BOOL) boolFail {
    if (json) {
        NSString * status = json[@"status"];

        if ([obNet isObject:status TypeOf:Type_Int]) {
            if (status.intValue == 1) {
                if (boolPass) ToastMSG(json[@"message"]);
                return YES;
            } else {
                if (boolFail) ToastMSG(json[@"message"]);
                return NO;
            }
        }
    }

    return NO;
}

- (UIColor *) colorWithHexString:(NSString *) hex alpha:(float)alpha
{
    //[self colorWithHexString:@"FFFFFF"]

    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

- (NSDate *) dateFromString:(NSString *) str withFormat:(NSString *) format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    NSDate *dateGST = [dateFormat dateFromString:str];

    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:dateGST];
    return [NSDate dateWithTimeInterval:seconds sinceDate:dateGST];
}

- (NSString *) currentDateNTimeString:(NSString *) formate {
    NSDateFormatter * df = [[NSDateFormatter alloc] init];

    if (formate == nil)
        formate = @"yyyy-MM-dd hh:mm:ss";

    [df setDateFormat:formate];

    NSString * currentDate = [df stringFromDate:[NSDate date]];
    return currentDate;
}

- (BOOL) canDevicePlaceAPhoneCall:(BOOL) popUP; {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Device supports phone calls, lets confirm it can place one right now
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mnc = [carrier mobileNetworkCode];
        if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
            // Device cannot place a call at this time.  SIM might be removed.

            if (popUP)
                PopUp(@"Device cannot place a call at this time. SIM might be removed.", @"");

            return NO;
        } else {
            // Device can place a phone call
            return YES;
        }
    } else {
        // Device does not support phone calls
        return  NO;
    }
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

# define Textfeild Border

///// Defult Textfeild Border
-(void)SetTextFieldBorder :(UITextField *)textField colorHexString:(NSString *)colorHexString opacity:(float)opacity
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, textField.frame.size.height - 3, textField.frame.size.width, 2.0);
    bottomBorder.backgroundColor = [obNet colorWithHexString:colorHexString alpha:1.0].CGColor;
    bottomBorder.opacity = opacity;
    textField.layer.opacity = opacity;
    [textField.layer addSublayer:bottomBorder];
}

///// Textfeild Border For Extra UI
-(void)SetTextFieldBorderWhite :(UITextField *)textField colorHexString:(NSString *)colorHexString opacity:(float)opacity
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 6, textField.frame.size.width, 2.0);
    bottomBorder.backgroundColor = [obNet colorWithHexString:@"FFFFFF" alpha:1.0].CGColor;
    bottomBorder.opacity = opacity;
    [textField.layer addSublayer:bottomBorder];
}
-(void)SetviewBorder:(UIScrollView *)view width:(int)width
{
    CALayer *bottomBorder = [CALayer layer];
    CGFloat borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, view.frame.size.height - borderWidth,width, 1);
    bottomBorder.backgroundColor = [obNet colorWithHexString:@"#E3E3E3" alpha:0.4].CGColor;
    bottomBorder.opacity = 0.4f;
    bottomBorder.masksToBounds = true;
  //  bottomBorder.cornerRadius = view.frame.size.height/2;
    [view.layer addSublayer:bottomBorder];
}
-(BOOL)onlyChar:(NSString *)string
{
    NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}
- (CALayer *)prefix_addUpperBorder:(UIRectEdge)edge color:(UIColor *)color thickness:(CGFloat)thickness frame:(CGRect)frame
{
    CALayer *border = [CALayer layer];

    switch (edge) {
        case UIRectEdgeTop:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(frame), thickness);
            break;
        case UIRectEdgeBottom:
            border.frame = CGRectMake(0, CGRectGetHeight(frame) - thickness, CGRectGetWidth(frame), thickness);
            break;
        case UIRectEdgeLeft:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(frame));
            break;
        case UIRectEdgeRight:
            border.frame = CGRectMake(CGRectGetWidth(frame) - thickness, 0, thickness, CGRectGetHeight(frame));
            break;
        default:
            break;
    }

    border.backgroundColor = color.CGColor;

    //  [layer addSublayer:border];

    return border;
}

-(BOOL)isValidPinCode:(NSString*)pincode
{
    NSString *pinRegex = @"(^[0-9]{5}(-[0-9]{4})?$)";
    NSPredicate *pinTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinRegex];

    BOOL pinValidates = [pinTest evaluateWithObject:pincode];
    return pinValidates;
}
-(UIImage *)cropImageWithImage:(UIImage*)actualImage andRect:(CGRect)rect
{
    NSLog(@"%@",NSStringFromCGSize(actualImage.size));
    UIImage  *newImage = [self imageWithImage:actualImage scaledToSize:CGSizeMake(rect.size.width, actualImage.size.height)];
    NSLog(@"%@",NSStringFromCGSize(newImage.size));
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], rect);
    UIImage *cropedImage = [UIImage imageWithCGImage:imageRef];
    NSLog(@"cropedImage === %@",NSStringFromCGSize(cropedImage.size));

    return cropedImage;
}
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = newSize.width/newSize.height;

    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = newSize.height / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = newSize.height;
        }
        else{
            imgRatio = newSize.width / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = newSize.width;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (NSString *) stringDate:(NSDate *) date
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    return [df stringFromDate:date];
}
@end
