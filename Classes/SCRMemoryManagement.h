//
//  SCRMemoryManagement.h
//
//  Created by Aleks Nesterow-Rutkowski on 11/19/09.
//  aleks@screencustoms.com
//  
//  Purpose
//	Contains macros to make memory management easier.
//

#define SCR_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define SCR_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define SCR_RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
