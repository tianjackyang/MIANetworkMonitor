//
//  MIANetworkMonitor.m
//  MIACorpUMSApp
//
//  Created by 杨鹏 on 16/3/19.
//  Copyright © 2016年 上海名扬科技股份有限公司. All rights reserved.
//

#import "MIANetworkMonitor.h"
#import "Reachability.h"

static MIANetworkMonitor *shareMonitor = nil;

@interface MIANetworkMonitor ()
@property (nonatomic, strong) Reachability *internetConnectionReach;

@property (nonatomic, readwrite, getter=isNetworkAvailable) BOOL networkAvailable;
@property (nonatomic, readwrite, getter=isWifiAvailable) BOOL wifiAvailable;
@end

@implementation MIANetworkMonitor
+ (MIANetworkMonitor *)shareMonitor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareMonitor = [[self alloc] init];
    });
    return shareMonitor;
}

- (void)startMonitor
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.internetConnectionReach = [Reachability reachabilityForInternetConnection];
    [self.internetConnectionReach startNotifier];
    [self updateInternetWithReachability:self.internetConnectionReach];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *curReach = [notification object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInternetWithReachability:curReach];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FINetworkStatusDidChangeNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)updateInternetWithReachability:(Reachability*)reach
{

    NetworkStatus netStatus = [reach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            self.networkAvailable = NO;
            self.wifiAvailable = NO;
        }
            break;
            
        case ReachableViaWiFi:
        {
            self.networkAvailable = YES;
            self.wifiAvailable = YES;
        }
            break;
            
        case ReachableViaWWAN:
        {
            self.networkAvailable = YES;
            self.wifiAvailable = NO;
        }
            break;
    }
}


-(void)dealloc {
    [self.internetConnectionReach stopNotifier];
    self.internetConnectionReach = nil;
}

@end
