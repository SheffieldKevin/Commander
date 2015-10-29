//
//  main.m
//  rotatetext
//
//  Created by Kevin Meaney on 02/02/2015.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

void SaveCGImageToAPNGFile(CGImageRef theImage, NSString *fileName)
{
    NSString *df = @"~/Desktop/";
    NSString *destination = [NSString stringWithFormat:@"%@/%@",
                             [df stringByExpandingTildeInPath], fileName];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:destination];
    CGImageDestinationRef exporter = CGImageDestinationCreateWithURL(
                                                                     (__bridge CFURLRef)fileURL,
                                                                     kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(exporter, theImage, nil);
    CGImageDestinationFinalize(exporter);
    CFRelease(exporter);
}

void SaveCGBitmapContextToAPNGFile(CGContextRef context, NSString *fileName)
{
    CGImageRef image = CGBitmapContextCreateImage(context);
    SaveCGImageToAPNGFile(image, fileName);
    CGImageRelease(image);
}

void DrawText()
{
    CGPathRef thePath = NULL;
    if (arrayOfPathElements)
    {
        CGContextBeginPath(self.context);
        result = [self
                  _generatePathUsingPathElementsInArray:arrayOfPathElements
                  startPoint:thePoint];
        CGContextClosePath(self.context);
        if (result)
            thePath = CGContextCopyPath(self.context);
    }
    NSMutableDictionary *attributesDict = [[NSMutableDictionary alloc]
                                           initWithCapacity:0];
    [attributesDict setObject:(__bridge id)(font)
                       forKey:(__bridge NSString *)(kCTFontAttributeName)];
    if (foreColor)
        [attributesDict setObject:(__bridge id)(foreColor)
                           forKey:(__bridge NSString *)(kCTForegroundColorAttributeName)];
    else
    {
        [attributesDict setObject:(__bridge id)(kCFBooleanTrue)
                           forKey:(__bridge NSString *)
         kCTForegroundColorFromContextAttributeName];
    }
    
    if (alignmentString)
    {
        CTTextAlignment alignment;
        alignment = GetTextAlignmentFromString(alignmentString);
        CTParagraphStyleSetting settings[] = {
            {   kCTParagraphStyleSpecifierAlignment,
                sizeof(alignment),
                &alignment} };
        CTParagraphStyleRef paragraphStyle = NULL;
        paragraphStyle = CTParagraphStyleCreate(settings,
                                                sizeof(settings) / sizeof(settings[0]));
        [attributesDict setObject:(__bridge id)paragraphStyle
                           forKey:(__bridge id)kCTParagraphStyleAttributeName];
        CFRelease(paragraphStyle);
    }
    
    if (strokeColor)
        [attributesDict setObject:(__bridge id)(strokeColor)
                           forKey:(__bridge NSString *)kCTStrokeColorAttributeName];
    
    if (strokeWidth)
        [attributesDict setObject:strokeWidth
                           forKey:(__bridge id)kCTStrokeWidthAttributeName];
    
    NSAttributedString *theAttrString = NULL;
    theAttrString = [[NSAttributedString alloc] initWithString:theString
                                                    attributes:attributesDict];
    
    
    
    CTFramesetterRef frameSetter;
    frameSetter = CTFramesetterCreateWithAttributedString(
                                                          (__bridge CFAttributedStringRef)theAttrString);
    if (frameSetter)
    {
        CTFrameRef theFrame = CTFramesetterCreateFrame(frameSetter,
                                                       CFRangeMake(0, [theAttrString length]),
                                                       thePath, NULL);
        CFRelease(frameSetter);
        CTFrameDraw(theFrame, self.context);
        CFRelease(theFrame);
    }
    else
    {
        MILogObjectOBJCMacro(@"Failed to create frame setter.",
                             stringDict);
        result = NO;
    }

}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
