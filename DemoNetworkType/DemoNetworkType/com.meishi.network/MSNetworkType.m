//
//  MSNetworkType.m
//  DemoNetworkType
//
//  Created by Meishi on 14-7-24.
//  Copyright (c) 2014年 Kangbo. All rights reserved.
//

#import "MSNetworkType.h"

@interface MSNetworkType ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation MSNetworkType

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

+ (instancetype)sharedinstance
{
    static MSNetworkType *_netinstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _netinstance = [[MSNetworkType alloc] init];
    });
    return _netinstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.baidu.com";
    
	self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability connectionRequired];
	[self.hostReachability startNotifier];
	[self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
	[self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
	[self.wifiReachability startNotifier];
	[self updateInterfaceWithReachability:self.wifiReachability];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    [self checkNetworktype:reachability];
}

- (NetworkType)checkNetworktype:(Reachability*)curReach;
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            self.networkStatus = NETWORK_TYPE_NONE;
            break;
        case ReachableViaWWAN:
            self.networkStatus = NETWORK_TYPE_WWAN;
            break;
        case ReachableViaWiFi:
            self.networkStatus = NETWORK_TYPE_WIFI;
            break;
        case ReachableVia2G:
            self.networkStatus = NETWORK_TYPE_2G;
            break;
        case ReachableVia3G:
            self.networkStatus = NETWORK_TYPE_3G;
            break;
            default:
            break;
    }
    return self.networkStatus;
}

- (BOOL)isConnected
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

@end




@implementation MSNetworkTypeUI

+ (NetworkType)getNetworkTypeFromStatusBar
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    NetworkType nettype = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    nettype = [num intValue];
    
    return nettype;
}

@end