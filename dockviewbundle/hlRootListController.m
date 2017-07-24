#include "hlRootListController.h"

@implementation hlRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)myWeibo{
    NSString *myUrl=@"http://weibo.com/u/2303542754?source=blog&is_all=1";
    NSLog(@"------myWeibo-open:%@",myUrl);
    NSURL *url = [ [ NSURL alloc ] initWithString: myUrl];
    [[UIApplication sharedApplication] openURL:url];
}

@end
