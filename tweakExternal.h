//
//  tweakExternal.h
//  
//
//  Created by 陈志东 on 17/7/19.
//
//

//#ifndef tweakExternal_h
//#define tweakExternal_h

//typedef void (^CDUnknownBlockType)(void); // return type and parameters are unknown

@interface SBDockView
{
}
- (void)setBackgroundAlpha:(float)arg1;
@end

@interface SBControlCenterContentView:UIView
    
@end

@interface SBControlCenterContentContainerView
    {
        
    }
    @property(retain, nonatomic) SBControlCenterContentView *contentView;
@end

//#endif /* tweakExternal_h */


