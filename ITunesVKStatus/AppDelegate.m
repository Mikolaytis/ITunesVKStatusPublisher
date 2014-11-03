//
//  AppDelegate.m
//  ITunesVKStatus
//
//  Created by Mikolaytis Sergey on 04/11/14.
//  Copyright (c) 2014 Mikolaytis Sergey. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;
@property (nonatomic,strong) NSString * Token;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSURL *url = [NSURL URLWithString:@"http://oauth.vk.com/authorize?client_id=4618709&scope=status&display=touch&response_type=token"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[[self webView] mainFrame] loadRequest:urlRequest];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)LogIn:(id)sender
{
    NSURL *url = [[[[[self webView] mainFrame] dataSource] request] URL];
    NSLog(@"%@",[url absoluteString]);
    NSUInteger from = [[url absoluteString] rangeOfString:@"="].location;
    NSUInteger to = [[url absoluteString] rangeOfString:@"&"].location;
    self.Token = [[url absoluteString] substringWithRange:NSMakeRange(from + 1, to - from - 1)];
    NSLog(@"%@",self.Token);
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(updateTrackInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];
    [self.window setIsVisible:NO];
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
}

- (void) updateTrackInfo:(NSNotification *)notification {
    NSDictionary *information = [notification userInfo];
    NSLog(@"track information: %@", information);
    NSString * text = [NSString stringWithFormat:@"ITunes: %@ - %@. Album: %@; Play Count: %@;",[information objectForKey:@"Artist"],[information objectForKey:@"Name"],[information objectForKey:@"Album"], [information objectForKey:@"Play Count"]];
    NSLog(@"track information: %@", text);
    text = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)text, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
    NSLog(@"track information: %@", text);
    NSString *req = [NSString stringWithFormat:@"https://api.vkontakte.ru/method/status.set.xml?text=%@&access_token=%@",text,self.Token];
    NSLog(@"track information: %@", req);
    NSURL *url = [NSURL URLWithString:req];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[[self webView] mainFrame] loadRequest:urlRequest];
}

@end
