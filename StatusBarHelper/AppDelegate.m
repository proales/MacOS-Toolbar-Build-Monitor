//
//  AppDelegate.m
//  StatusBarHelper
//

#import "AppDelegate.h"
#import "StatusView.h"
#import "AFNetworking.h"

const CGFloat kCheckInterval = 10.0; // Period in seconds

NSString * const kDomainURL = @"http://jenkins.url.com";
NSString * const kQueryURL = @"buildStatus.json";
NSString * const kOpenURL = @"https://jenkins.url.com/jenkins/job/www/";

@interface AppDelegate ()

@property (nonatomic) NSStatusItem *statusItem;

@property (nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (nonatomic) AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation AppDelegate

#pragma mark - Overrides -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ((StatusView *)self.statusItem.view).backgroundColor = [NSColor grayColor];

    [self checkAPI:nil];

    [self.reachabilityManager startMonitoring];

    [NSTimer scheduledTimerWithTimeInterval:kCheckInterval target:self selector:@selector(checkAPI:) userInfo:nil repeats:YES];
}

#pragma mark - Private
#pragma mark - Accessors

- (NSStatusItem *)statusItem
{
    if (!_statusItem)
    {
        StatusView *statusView = [[StatusView alloc] initWithFrame:NSMakeRect(0.0, 0.0, [NSStatusBar systemStatusBar].thickness, [NSStatusBar systemStatusBar].thickness)];
        statusView.backgroundColor = [NSColor redColor];
        statusView.margins = NSEdgeInsetsMake(3, 3, 3, 3);
        statusView.button.target = self;
        statusView.button.action = @selector(handleClick:);

        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:[NSStatusBar systemStatusBar].thickness]; // NSSquareStatusItemLength actually doesn't make item square
        _statusItem.view = statusView;
    }

    return _statusItem;
}

- (AFHTTPRequestOperationManager *)requestManager
{
    if (!_requestManager)
    {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kDomainURL]];
        _requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }

    return _requestManager;
}

- (AFNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager)
    {
        _reachabilityManager = [AFNetworkReachabilityManager managerForDomain:kDomainURL];

        typeof(self) __weak weakSelf = self;
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
            {
                if (!weakSelf.reachabilityManager.isReachable)
                {
                    ((StatusView *)weakSelf.statusItem.view).backgroundColor = [NSColor grayColor];
                }
            }];
    }

    return _reachabilityManager;
}

#pragma mark - Misc

- (void)checkAPI:(NSTimer *)timer
{
    typeof(self) __weak weakSelf = self;

    [self.requestManager GET:kQueryURL parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSColor *statusColor = [NSColor redColor];

            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                NSString *data = [responseObject objectForKey:@"buildStatusAllGreen"];
                statusColor = [data isKindOfClass:[NSString class]] && [data  isEqual: @"true"] ? [NSColor greenColor] : statusColor;
            }

            ((StatusView *)weakSelf.statusItem.view).backgroundColor = statusColor;
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (weakSelf.reachabilityManager.isReachable)
            {
                ((StatusView *)weakSelf.statusItem.view).backgroundColor = [NSColor redColor];
            }
            else
            {
                ((StatusView *)weakSelf.statusItem.view).backgroundColor = [NSColor grayColor];
            }
        }];
}

- (void)handleClick:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kOpenURL]];
}

@end
