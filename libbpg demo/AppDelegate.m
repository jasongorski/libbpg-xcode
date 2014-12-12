//
//  AppDelegate.m
//  libbpg demo
//
//  Created by Jason Gorski on 2014-12-11.
//  Copyright (c) 2014 jgorski. All rights reserved.
//

#import "AppDelegate.h"
#import "libbpg.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)bpgViewInit
{
    BPGDecoderContext *img;
    
    NSString *bpgPath = [[NSBundle mainBundle] pathForResource:@"test.bpg" ofType:@""];
    NSData *bpgData = [NSData dataWithContentsOfFile:bpgPath];
    
    img = bpg_decoder_open();
    
    if (bpg_decoder_decode(img, [bpgData bytes], [bpgData length]) < 0)
    {
        NSLog(@"Could not decode image");
        return;
    }
    
    BPGImageInfo img_info_s, *img_info = &img_info_s;
    bpg_decoder_get_info(img, img_info);
    
    bpg_decoder_start(img, BPG_OUTPUT_FORMAT_RGBA32);
    
    unsigned int rowWidth = img_info->width * 4;
    NSMutableData *pixData = [[NSMutableData alloc] initWithCapacity:rowWidth * img_info->height];
    
    unsigned char *pixbuf = [pixData mutableBytes];
    unsigned char *row = pixbuf;
    for (int y = 0; y < img_info->height; y++)
    {
        bpg_decoder_get_line(img, row);
        row += rowWidth;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(pixbuf, img_info->width, img_info->height, 8, rowWidth, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    if (!ctx)
    {
        NSLog(@"error creating UIImage");
        return;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    
    bpg_decoder_close(img);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rawImage];
    [self.window.rootViewController.view addSubview:imageView];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self bpgViewInit];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
