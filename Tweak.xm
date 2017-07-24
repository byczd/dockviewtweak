

#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/DockViewBundle.bundle"]

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.adong.dockviewbundle.plist"

//typedef void (^CDUnknownBlockType)(void);

#import "tweakExternal.h"
#import <sqlite3.h>

static bool isLeftTouch=true;
static bool hasGetTouchFlag=false;
static bool hasLayOutFlag=false;

static UIView *tmpView=nil;
static UITextView *textView=nil;

static bool GetPrefBool(NSString *key) //static或inline都可以
{

return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];

}

static float GetPrefnumber(NSString *key) //static或inline都可以
{

return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] floatValue];

}

static NSString *GetRandomDBData(){
    //从数据库读取随机数据，显示在右侧上滑屏幕上
    NSString *retDvalue=@"";
    sqlite3 *database;

    NSString *dbPath=[BUNDLE pathForResource:@"adongDoc.db" ofType:nil];
    //NSLog(@"dbPath=%@",dbPath);

    /*-------------------------
    if (sqlite3_open([dbPath UTF8String], &database)==SQLITE_OK) { //#import <sqlite3.h>
    //BUNDLE中，只有已经存在db文件，才能打Open成功，否则失败不会自动创建(无权限)
    NSLog(@"sqlite3_open-Success--%@",dbPath);
    //创建诗词数据表(id及text)
    NSString *_sql = @"create table if not exists scData (scIndex INTEGER PRIMARY KEY, scContent TEXT)";
    char *errorMsg;
    if (sqlite3_exec(database, [_sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
    NSLog(@"----Create scData Success--in bundle.");
    }
    else {
    NSLog(@"----Create scData Fail--in bundle. msg=%s",errorMsg);
    //在bundle中的数据库中创建表会失败：attempt to write a readonly database,而在docments目录中可以创建数据库及表成功
    //故可以将原始数据库文件从资源库拷贝到Documents目录（由于在沙盒里只有Documents目录是可读写的），
    //[fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
    }
    sqlite3_close(database);
    }
    else
    {
    NSLog(@"sqlite3_open-Fail--%@",dbPath);
    }
    ------------------*/

    NSArray *docArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSLog(@"docArray=%@",docArray); //docArray=("/var/mobile/Documents")
    NSString *homeDoc = [docArray lastObject];
    //沙盒路径 or [docArray objectAtIndex:0]，都可以取到，推荐用[docArray lastObject]无数据时不需崩溃
    //tweak的document路径为：/var/mobile/Documents  如果是application则为：/var/mobile/Library/AppName/
    if ( not [homeDoc hasSuffix:@"/"]) //得到docments路径没末尾没有'/'
    homeDoc=[homeDoc stringByAppendingString:@"/"];
    NSString *docPath = [homeDoc stringByAppendingString:@"adongDoc.db"];//拼接数据库文件路径

    //将Bundle中的默认db拷贝到Documents目录中
    NSFileManager*fileManager =[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:docPath]){
        [fileManager copyItemAtPath:dbPath toPath:docPath error:nil];
        NSLog(@"----copy-db-from-bundle");
    }
    //else
    //    NSLog(@"----already-Exist-db:%@",docPath);



    if([fileManager fileExistsAtPath:docPath]){
        if (sqlite3_open([docPath UTF8String], &database)==SQLITE_OK) {
            //在Document路径下：如果db文件不存在时sqlite3_open会自动创建对应的db文件
            NSLog(@"sqlite3_open-Success--%@",docPath);
            NSUInteger rndIndex = arc4random_uniform(44);  //rand from 0 to 43
            NSString *query = [NSString stringWithFormat:@"select scContent from scData where scIndex=%d",(int)rndIndex];//需增加(int)或(long)，如果即支持armv7s又需支持arm64的话
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    //get data
                    char *dvalue = (char *)sqlite3_column_text(statement, 0);
                    retDvalue = [NSString stringWithCString:dvalue encoding:NSUTF8StringEncoding];
                    NSLog(@"-----Sqlite-Ccontent from %d",(int)rndIndex);
                }
                sqlite3_finalize(statement);
            }
            else
                NSLog(@"----sqlite3_prepare_v2---Fail");
        }
        else
            NSLog(@"sqlite3_open-Fail--%@",docPath);


            /*-------------------
            //创建诗词数据表(id及text)
            NSString *_sql = @"create table if not exists scData (scIndex INTEGER PRIMARY KEY, scContent TEXT)";
            char *errorMsg;
            if (sqlite3_exec(database, [_sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"----Create scData Success--in Document.");
            //在Docments中创建表格则会成功
            }
            else {
            NSLog(@"----Create scData Fail--in Document. msg=%s",errorMsg);
            }
            -----------------------*/

            sqlite3_close(database);
    }
    else
    {
            NSLog(@"----not-Exist-db:%@",docPath);
    }

return retDvalue;

}

@class _UIBackdropView;
@class SBControlCenterContentView;


//------------------设置Dock阴影背景----------------

%hook SBDockView

- (void)setBackgroundAlpha:(float)arg1{
if (GetPrefBool(@"AlphaSwitch")){
float f_alpha=GetPrefnumber(@"alphavalue");
NSString *s_alpha=[NSString stringWithFormat:@"%.1f",f_alpha]; //设置alpha只能小数后1位
f_alpha=[s_alpha floatValue];
NSLog(@"--------SBDockView-setBackgroundAlpha--%f",f_alpha);
arg1=f_alpha;
    NSLog(@"--------SBDockView-setBackgroundAlpha-true:alpha=%f",arg1);
}
else
    NSLog(@"--------SBDockView-setBackgroundAlpha-false:alpha=%f",arg1);
%orig;
}

- (void)_backgroundContrastDidChange:(id)arg1{
%orig;
[self setBackgroundAlpha:0.0];

}

%end



//-----------------------设置右侧上滑显示每日诗词------------------
%hook SBControlCenterViewController

- (void)setRevealPercentage:(float )revealPercentage {
NSLog(@"-----------setRevealPercentage:%f---isLeftTouch=%d",revealPercentage,isLeftTouch);
%orig;
}

%end


%hook SBControlCenterController

- (float)_controlCenterHeightForTouchLocation:(struct CGPoint)arg1 {
if (arg1.x<160)
    isLeftTouch=true;
else
    isLeftTouch=false;

hasGetTouchFlag=true;

NSLog(@"-----------_controlCenterHeightForTouchLocation:(%f,%f)----isLeftTouch=%d",arg1.x,arg1.y,isLeftTouch);
float r = %orig;
return r;
}
- (void)_revealSlidingViewToHeight:(float)arg1 {
NSLog(@"----------_revealSlidingViewToHeight:%f",arg1);
%orig;
}

- (void)updateTransitionWithTouchLocation:(struct CGPoint)arg1 velocity:(struct CGPoint)arg2
{
//velocity速率

if (arg1.x<160)
    isLeftTouch=true;
else
    isLeftTouch=false;

hasGetTouchFlag=true;

NSLog(@"------------updateTransitionWithTouchLocation:%@ velocity:%@---isLeftTouch=%d",NSStringFromCGPoint(arg1),NSStringFromCGPoint(arg2),isLeftTouch);

%orig;
}

%end


%hook SBControlCenterContentContainerView

- (void)controlCenterDidFinishTransition {
%orig;
NSLog(@"----controlCenterDidFinishTransition-isLeftTouch=%d,bounds=%@",isLeftTouch,NSStringFromCGRect(self.contentView.bounds));
hasGetTouchFlag=false;
hasLayOutFlag=false;
}


- (void)controlCenterWillBeginTransition {
    NSLog(@"----controlCenterWillBeginTransition-isLeftTouch=%d--bounds=%@",isLeftTouch,NSStringFromCGRect(self.contentView.bounds));
    %orig;
//上滑显示和下滑隐藏时都会触发，但能获取到正确的isLeftTouch和bounds
//不会自动回收tmpview

}


- (void)layoutSubviews {
if (self.contentView && hasGetTouchFlag && (!hasLayOutFlag)){
    hasLayOutFlag=true;
    NSLog(@"----layoutSubviews-isLeftTouch=%d--bounds=%@",isLeftTouch,NSStringFromCGRect(self.contentView.bounds));
//上滑显示和下滑隐藏时都会触发，但能获取到正确的isLeftTouch和bounds，在工具栏显示完成时触发
if (!isLeftTouch){
    if (!tmpView){
        tmpView=[[UIView alloc]init];
        [self.contentView addSubview:tmpView];
        [tmpView setBackgroundColor:[UIColor colorWithRed:16/255.0f green:25/255.0f blue:54/255.0f alpha:0.1f]];//[UIColor redColor]
        tmpView.frame=self.contentView.bounds;
        //[tmpView setHidden:NO];
        tmpView.hidden=NO;

        textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 20,tmpView.bounds.size.width-10,tmpView.bounds.size.height-25)];
        [tmpView addSubview:textView];
        textView.text =GetRandomDBData();

        // 设置文本字体
        textView.font = [UIFont fontWithName:@"Arial" size:20.0f];
        // 设置文本颜色
        textView.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
        // 设置文本框背景颜色
        textView.backgroundColor =[UIColor cyanColor];
        //[UIColor colorWithRed:45/255.0f green:254/255.0f blue:254/255.0f alpha:0.9f]; //2dfefe;[UIColor cyanColor];
        // 设置文本对齐方式
        textView.textAlignment = NSTextAlignmentLeft;
        // 设置自动纠错方式
        textView.autocorrectionType = UITextAutocorrectionTypeNo;

        //外框
        textView.layer.borderColor = [UIColor redColor].CGColor;
        textView.layer.borderWidth = 1;
        textView.layer.cornerRadius =5;
        // 设置是否可以拖动
        textView.scrollEnabled = true;

        NSLog(@"----layoutSubviews-add-tmpView");
    }
    else
    {
        tmpView.hidden=NO;
        textView.text =GetRandomDBData();
        NSLog(@"----layoutSubviews-show-tmpView");
    }
}
else
{
    if (tmpView){
        tmpView.hidden=YES;
        tmpView=nil;
        NSLog(@"----layoutSubviews-hide-tmpView");
    }
    //else{
    //NSLog(@"----layoutSubviews-notExsit-tmpView");
    //}
}

}
else
    NSLog(@"----layoutSubviews-isLeftTouch=%d",isLeftTouch);
%orig;
}

%end





