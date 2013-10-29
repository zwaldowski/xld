//
//  XLDFlacOutput.m
//  XLDFlacOutput
//
//  Created by tmkk on 06/09/15.
//  Copyright 2006 tmkk. All rights reserved.
//

#import "XLDFlacOutput.h"
#import "XLDFlacOutputTask.h"

@interface XLDFlacOutput ()

@property (nonatomic, strong) IBOutlet NSView *prefPane;
@property (nonatomic, strong) IBOutlet NSSlider *compressionLevelSlider;
@property (nonatomic, strong) IBOutlet NSButton *oggFlacCheckbox;
@property (nonatomic, strong) IBOutlet NSTextField *paddingField;
@property (nonatomic, strong) IBOutlet NSButton *allowEmbeddedCuesheetCheckbox;
@property (nonatomic, strong) IBOutlet NSButton *setOggSCheckBox;
@property (nonatomic, strong) IBOutlet NSButton *useCustomApodizationCheckbox;
@property (nonatomic, strong) IBOutlet NSTextField *customApodizationField;
@property (nonatomic, strong) IBOutlet NSButton *writeReplayGainCheckbox;

@end

@implementation XLDFlacOutput

+ (NSString *)pluginName
{
	return @"FLAC";
}

+ (BOOL)canLoadThisBundle
{
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber10_1) {
		return NO;
	}
	else return YES;
}

- (id)init
{
	self = [super init];
	if (self) {
		[[NSBundle bundleForClass:[self class]] loadNibNamed:@"XLDFlacOutput" owner:self topLevelObjects:NULL];
		srand((unsigned)time(NULL));
	}
	return self;
}

- (void)savePrefs
{
	NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
	[pref setInteger:self.compressionLevelSlider.integerValue forKey:@"XLDFlacOutput_CompressionLevel"];
	[pref setInteger:self.oggFlacCheckbox.state forKey:@"XLDFlacOutput_OggFLAC"];
	[pref setInteger:self.paddingField.integerValue forKey:@"XLDFlacOutput_Padding"];
	[pref setInteger:self.allowEmbeddedCuesheetCheckbox.state forKey:@"XLDFlacOutput_AllowEmbeddedCueSheet"];
	[pref setInteger:self.setOggSCheckBox.state forKey:@"XLDFlacOutput_SetOggS"];
	[pref setInteger:self.useCustomApodizationCheckbox.state forKey:@"XLDFlacOutput_UseCustomApodization"];
	[pref setObject:self.customApodizationField.stringValue forKey:@"XLDFlacOutput_Apodization"];
	[pref setInteger:self.writeReplayGainCheckbox.state forKey:@"XLDFlacOutput_WriteRGTags"];
	[pref synchronize];
}

- (void)loadPrefs
{
	NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
	[self loadConfigurations:pref];
}

- (id)createTaskForOutput
{
	return [[XLDFlacOutputTask alloc] initWithConfigurations:[self configurations]];
}

- (id)createTaskForOutputWithConfigurations:(NSDictionary *)cfg
{
	return [[XLDFlacOutputTask alloc] initWithConfigurations:cfg];
}

- (int)compressionLevel
{
	return self.compressionLevelSlider.intValue;
}

- (BOOL)oggFlac
{
	return (self.oggFlacCheckbox.state == NSOnState);
}

- (int)padding
{
	return MAX(1, self.paddingField.intValue);
}

- (BOOL)allowEmbeddedCuesheet
{
	return (self.allowEmbeddedCuesheetCheckbox.state == NSOnState);
}

- (BOOL)setOggS
{
	return (self.setOggSCheckBox.state == NSOnState);
}

- (BOOL)writeRGTags
{
	return (self.writeReplayGainCheckbox.state == NSOnState);
}

- (BOOL)useCustomApodization
{
	return (self.useCustomApodizationCheckbox.state == NSOnState);
}

- (NSMutableDictionary *)configurations
{
	NSMutableDictionary *cfg = [[NSMutableDictionary alloc] init];
	/* for GUI */
	cfg[@"XLDFlacOutput_CompressionLevel"] = @(self.compressionLevelSlider.intValue);
	cfg[@"XLDFlacOutput_OggFLAC"] = @(self.oggFlacCheckbox.state);
	cfg[@"XLDFlacOutput_Padding"] = @(self.paddingField.integerValue);
	cfg[@"XLDFlacOutput_AllowEmbeddedCueSheet"] = @(self.allowEmbeddedCuesheetCheckbox.integerValue);
	cfg[@"XLDFlacOutput_SetOggS"] = @(self.setOggSCheckBox.integerValue);
	cfg[@"XLDFlacOutput_UseCustomApodization"] = @(self.useCustomApodizationCheckbox.state);
	cfg[@"XLDFlacOutput_Apodization"] = self.customApodizationField.stringValue;
	cfg[@"XLDFlacOutput_WriteRGTags"] = @(self.writeReplayGainCheckbox.state);
	/* for task */
	cfg[@"CompressionLevel"] = @([self compressionLevel]);
	cfg[@"OggFlac"] = @([self oggFlac]);
	cfg[@"Padding"] = @([self padding]);
	cfg[@"AllowEmbeddedCuesheet"] = @([self allowEmbeddedCuesheet]);
	cfg[@"SetOggS"] = @([self setOggS]);
	if (self.useCustomApodization == NSOnState) cfg[@"Apodization"] = self.customApodizationField.stringValue;
	cfg[@"WriteRGTags"] = @([self writeRGTags]);
	/* desc */
	if ([self oggFlac]) {
		if([self compressionLevel] >= 0) cfg[@"ShortDesc"] = [NSString stringWithFormat:@"level %d, ogg wrapped",[self compressionLevel]];
		else  cfg[@"ShortDesc"] = @"uncompressed, ogg wrapped";
	}
	else {
		if([self compressionLevel] >= 0) cfg[@"ShortDesc"] = [NSString stringWithFormat:@"level %d",[self compressionLevel]];
		else  cfg[@"ShortDesc"] = @"uncompressed";
	}
	return cfg;
}

- (void)loadConfigurations:(NSUserDefaults *)cfg
{
	id obj;
	if((obj=[cfg objectForKey:@"XLDFlacOutput_CompressionLevel"])) {
		self.compressionLevelSlider.integerValue = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_OggFLAC"])) {
		self.oggFlacCheckbox.state = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_Padding"])) {
		self.paddingField.integerValue = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_AllowEmbeddedCueSheet"])) {
		self.allowEmbeddedCuesheetCheckbox.state = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_SetOggS"])) {
		self.setOggSCheckBox.integerValue = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_UseCustomApodization"])) {
		self.useCustomApodizationCheckbox.state = [obj integerValue];
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_Apodization"])) {
		self.customApodizationField.stringValue = obj;
	}
	if((obj=[cfg objectForKey:@"XLDFlacOutput_WriteRGTags"])) {
		self.writeReplayGainCheckbox.integerValue = [obj integerValue];
	}
}

@end
