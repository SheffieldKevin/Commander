//
//  arcexamples.m
//  arcexamples
//
//  Created by Kevin Meaney on 14/05/2013.
//  Copyright (c) 2013 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YVSARCExamples : NSObject
@property (strong) NSString *strongString;
@property (weak) NSString *weakString;
-(NSString *)newYVSString;
@end

@implementation YVSARCExamples
@synthesize strongString;
@synthesize weakString;

-(NSString *)newYVSString
{
	return [[NSString alloc] initWithFormat:@"newYVSString %d", 5];
}
@end

static void YVSARCExamplesTest1()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 101]];
	@autoreleasepool
	{
		[yvsObject setWeakString:[yvsObject strongString]];
	}
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest1 weakString:%@", [yvsObject weakString]); // null
}

static void YVSARCExamplesTest2()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 102]];
	[yvsObject setWeakString:[yvsObject strongString]];
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest2 weakString: %@", [yvsObject weakString]); // Strong string 102
}

// The following examples are for thinking about the strong string property
static void YVSARCExamplesTest3()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 103]];
	NSString * __weak weakStringVar;
	@autoreleasepool
	{
		weakStringVar = [yvsObject strongString];
	}
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest3 weakStringVar:%@", weakStringVar); // null
}

static void YVSARCExamplesTest4pt0()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 104]];
	NSLog(@"YVSARCExamplesTest4 01 strongString:%p = %@", [yvsObject strongString], [yvsObject strongString]); // Strong string 104
	NSString * __weak weakStringVar = [yvsObject strongString];
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest4pt0 02 weakStringVar:%@", weakStringVar); // null
}

static void YVSARCExamplesTest4pt1()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 104]];
	NSString *strongStringVar = [yvsObject strongString];
	@autoreleasepool
	{
		NSLog(@"YVSARCExamplesTest4pt1 01 strongString:%p = %@", strongStringVar, strongStringVar); // Strong string 104
	}
	NSString * __weak weakStringVar = [yvsObject strongString];
	[yvsObject setStrongString:nil];
	strongStringVar = nil;
	NSLog(@"YVSARCExamplesTest4pt1 02 weakStringVar:%@", weakStringVar); // null
}

static void YVSARCExamplesTest4pt2()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 104]];
	NSString * __strong strongStringVar;
	@autoreleasepool
	{
		strongStringVar = [yvsObject strongString];
	}
	NSLog(@"YVSARCExamplesTest4pt2 01 strongString:%p = %@", strongStringVar, strongStringVar); // Strong string 104
	NSString * __weak weakStringVar = strongStringVar;
	strongStringVar = nil;
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest4pt2 02 weakStringVar:%@", weakStringVar); // null
}

static void YVSARCExamplesTest5()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 110]];
	[yvsObject setWeakString:[yvsObject strongString]];
	NSString * __weak weakString;
	@autoreleasepool
	{
		weakString = [yvsObject strongString];
	}
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest5 weakString:%@", weakString); // Strong string 110
}

static void YVSARCExamplesTest6()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	[yvsObject setStrongString:[[NSString alloc] initWithFormat:@"Strong string %d", 111]];
	@autoreleasepool
	{
		[yvsObject setWeakString:[yvsObject strongString]];		
	}
	NSString * __weak weakString;
	@autoreleasepool
	{
		weakString = [yvsObject strongString];
	}
	[yvsObject setStrongString:nil];
	NSLog(@"YVSARCExamplesTest6 weakString:%@", weakString); // null
}

static void YVSARCExamplesTest7()
{
	YVSARCExamples *yvsObject = [[YVSARCExamples alloc] init];
	NSString * __strong strongString = [yvsObject newYVSString];
	NSString * __weak weakString = strongString;
	strongString = nil;
	NSLog(@"YVSARCExamplesTest7 weakString:%@", weakString);
}

static void TestArc1()
{
	NSString *__weak weakString;
	{
		NSString *strongString = [[NSString alloc] initWithFormat:@"String %d", 1];
		weakString = strongString;
	}
	NSLog(@"TestArc1 weakString:%@", weakString); // null
}

static void TestArc2()
{
	NSString *__weak weakString;
	{
		NSString *strongString = [NSString stringWithFormat:@"String %d", 2];
		weakString = strongString;
	}
	NSLog(@"TestArc2 weakString:%@", weakString); // String 2
}

static void TestArc3()
{
	NSString *__weak weakString = [[NSString alloc] initWithFormat:@"String %d", 3];
	NSLog(@"TestArc3 weakString:%@", weakString); // null
}

static void TestArc4()
{
	NSString *__weak weakString = [NSString stringWithFormat:@"String %d", 4];
	NSLog(@"TestArc4 weakString:%@", weakString); // String 4.
}

static void TestArc5()
{
	NSString *__weak weakString;
	@autoreleasepool
	{
		weakString = [NSString stringWithFormat:@"String %d", 5];
	}
	NSLog(@"TestArc5 weakString:%@", weakString); // null
}

static void TestArc6()
{
	NSString *__weak weakString;
	@autoreleasepool
	{
		weakString = [[NSString alloc] initWithFormat:@"String %d", 6];
	}
	NSLog(@"TestArc6 weakString:%@", weakString); // null
}

static void TestArc7()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"String %d", 7];
	NSString *__weak weakString = strongString;
	strongString = nil;
	NSLog(@"TestArc7 weakString:%@", weakString); // null
}

static void TestArc8()
{
	NSString *strongString = [NSString stringWithFormat:@"String %d", 8];
	NSString *__weak weakString = strongString;
	strongString = nil;
	NSLog(@"TestArc8 weakString:%@", weakString); // String 8
}

static void TestArc9()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"String %d", 9];
	NSString * __weak weakString = strongString;
	NSLog(@"TestArc9 01 weakString:%p %@", weakString, weakString);
	strongString = nil;
	NSLog(@"TestArc9 02 weakString:%@", weakString); // String 9
}

static void TestArc10()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"String %d", 10];
	NSString * __weak weakString = strongString;
	@autoreleasepool
	{
		NSLog(@"TestArc10 01 weakString:%p %@", weakString, weakString);
	}
	strongString = nil;
	NSLog(@"TestArc10 02 weakString:%@", weakString); // null
}

static void TestArc11()
{
	__block NSString * __weak weakString;
	void (^testArcBlock)(void);
	testArcBlock = ^
	{
		NSString *localString = [[NSString alloc] initWithFormat:@"String %d", 11];
		weakString = localString;
	};
	testArcBlock();
	NSLog(@"TestArc11 weakString:%@", weakString); // null
}

static void TestArc12()
{
	__block NSString * __weak weakString;
	void (^testArcBlock)(void);
	testArcBlock = ^
	{
		NSString *localString = [NSString stringWithFormat:@"String %d", 12];
		weakString = localString;
	};
	testArcBlock();
	NSLog(@"TestArc12 weakString:%@", weakString); // String 12
}

static void TestArc13()
{
	__block NSString * __weak weakString;
	void (^testArcBlock)(void);
	testArcBlock = ^
	{
		NSString *localString = [[NSString alloc] initWithFormat:@"String %d", 13];
		weakString = localString;
		NSLog(@"TestArc13 01 weakString:%p %@", weakString, weakString);
	};
	testArcBlock();
	NSLog(@"TestArc13 02 weakString:%@", weakString); // String 13
}

static void TestArc14()
{
	__block NSString * __weak weakString;
	void (^testArcBlock)(void);
	testArcBlock = ^
	{
		@autoreleasepool
		{
			NSString *localString = [NSString stringWithFormat:@"String %d", 14];
			weakString = localString;
		}
	};
	testArcBlock();
	NSLog(@"TestArc14 weakString:%@", weakString); // null
}

static void TestArc15()
{
	__block NSString * __weak weakString;
	void (^testArcBlock)(void);
	testArcBlock = ^
	{
		@autoreleasepool
		{
			NSString *localString = [[NSString alloc] initWithFormat:@"String %d", 15];
			weakString = localString;
			NSLog(@"TestArc15 01 weakString:%p %@", weakString, weakString);
		}
	};
	testArcBlock();
	NSLog(@"TestArc15 02 weakString:%@", weakString); // null
}

static void PrintToLog(NSString * __weak weakArg)
{
	NSLog(@"PrintToLog: weakArg = %@", weakArg);
}

static void TestArc16()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"TestArc16 String %d", 16];
	NSString * __weak weakString = strongString;
	PrintToLog(weakString);
	strongString = nil;
	NSLog(@"TestArc16 02 weakString:%@", weakString); // String 16
}

static void PrintToLogWithAutorelease(NSString *__weak weakArg)
{
	@autoreleasepool
	{
		NSLog(@"PrintToLogWithAutorelease: weakArg = %@", weakArg);
	}
}

static void TestArc17()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"TestArc17 String %d", 17];
	NSString * __weak weakString = strongString;
	PrintToLogWithAutorelease(weakString);
	strongString = nil;
	NSLog(@"TestArc17 02 weakString:%@", weakString); // String 17
}

static void TestArc18()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"TestArc18 String %d", 18];
	NSString * __weak weakString = strongString;
	@autoreleasepool
	{
		PrintToLogWithAutorelease(weakString);		
	}
	strongString = nil;
	NSLog(@"TestArc18 02 weakString:%@", weakString); // null
}

static void TestArc19()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"String %d", 19];
	NSString * __weak weakString = strongString;
	NSLog(@"TestArc19 01 strongString:%p %@", strongString, strongString);
	strongString = nil;
	NSLog(@"TestArc19 02 weakString:%@", weakString); // null
}

static void TestArc20()
{
	NSString *strongString = [NSString stringWithFormat:@"String %d", 20];
	NSString * __weak weakString = strongString;
	NSLog(@"TestArc20 strongString:%p %@", strongString, strongString);
	strongString = nil;
	NSLog(@"TestArc20 weakString:%@", weakString); // String 20
}

static void PrintStrongStringToLog(NSString *string)
{
	NSLog(@"PrintStrongStringToLog %@", string);
}

static void TestArc21()
{
	NSString *strongString = [[NSString alloc] initWithFormat:@"TestArc21 String %d", 21];
	PrintStrongStringToLog(strongString);
	NSString * __weak weakString = strongString;
	strongString = nil;
	NSLog(@"TestArc21 weakString:%@", weakString); // null
}

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		YVSARCExamplesTest1();
		YVSARCExamplesTest2();
		YVSARCExamplesTest3();
		YVSARCExamplesTest4pt0();
		YVSARCExamplesTest4pt1();
		YVSARCExamplesTest4pt2();
		YVSARCExamplesTest5();
		YVSARCExamplesTest6();
		YVSARCExamplesTest7();
		TestArc1();
		TestArc2();
		TestArc3();
		TestArc4();
		TestArc5();
		TestArc6();
		TestArc7();
		TestArc8();
		TestArc9();
		TestArc10();
		TestArc11();
		TestArc12();
		TestArc13();
		TestArc14();
		TestArc15();
		TestArc16();
		TestArc17();
		TestArc18();
		TestArc19();
		TestArc20();
		TestArc21();
	}
    return 0;
}

