
#import <Foundation/Foundation.h>
#import <XLDPlugins/XLDTypes.h>

@class NSView;

@protocol XLDOutput <NSObject>

+ (NSString *)pluginName;
+ (BOOL)canLoadThisBundle;
- (NSView *)prefPane;
- (void)savePrefs;
- (void)loadPrefs;
- (id)createTaskForOutput;
- (id)createTaskForOutputWithConfigurations:(NSDictionary *)cfg;
- (NSMutableDictionary *)configurations;
- (void)loadConfigurations:(id)configurations;

@end