//
//  SCRLog.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 2/8/10.
//	aleks@screencustoms.com
//

#define SCR_LEVEL_TRACE		0 /* All level messages will go through. */
#define SCR_LEVEL_DEBUG		1
#define SCR_LEVEL_INFO		2
#define SCR_LEVEL_WARNING	3
#define SCR_LEVEL_ERROR		4 /* Only error-level messages will go through. */
#define SCR_LEVEL_OFF		5 /* No log messages will be produced. */

#ifndef SCR_LOG_LEVEL

#if TARGET_IPHONE_SIMULATOR != 0
#define SCR_LOG_LEVEL SCR_LEVEL_TRACE
#else
#define SCR_LOG_LEVEL SCR_LEVEL_OFF
#endif

#endif

#if SCR_LOG_LEVEL == SCR_LEVEL_TRACE
#define SCR_LOG_TRACE(CAT, MSG, ...)	\
NSLog(@"[T] [%@] %s:%d:%@", CAT, \
	__PRETTY_FUNCTION__, __LINE__, \
	[NSString stringWithFormat:MSG, ## __VA_ARGS__] \
);
#else
#define SCR_LOG_TRACE(CAT, MSG, ...)
#endif

#if (SCR_LOG_LEVEL <= SCR_LEVEL_DEBUG)
#define SCR_LOG_DEBUG(CAT, MSG, ...)	\
NSLog(@"[D] [%@] %s:%d:%@", CAT, \
	__PRETTY_FUNCTION__, __LINE__, \
	[NSString stringWithFormat:MSG, ## __VA_ARGS__] \
);
#else
#define SCR_LOG_DEBUG(CAT, MSG, ...)
#endif

#if (SCR_LOG_LEVEL <= SCR_LEVEL_INFO)
#define SCR_LOG_INFO(CAT, MSG, ...) \
NSLog(@"[I] [%@] %s:%d:%@", CAT, \
	__PRETTY_FUNCTION__, __LINE__, \
	[NSString stringWithFormat:MSG, ## __VA_ARGS__] \
);
#else
#define SCR_LOG_INFO(CAT, MSG, ...)
#endif

#if (SCR_LOG_LEVEL <= SCR_LEVEL_WARNING)
#define SCR_LOG_WARNING(CAT, MSG, ...) \
NSLog(@"[W] [%@] %s:%d:%@", CAT, \
	__PRETTY_FUNCTION__, __LINE__, \
	[NSString stringWithFormat:MSG, ## __VA_ARGS__] \
);
#else
#define SCR_LOG_WARNING(CAT, MSG, ...)
#endif

#if (SCR_LOG_LEVEL <= SCR_LEVEL_ERROR)
#define SCR_LOG_ERROR(CAT, MSG, ...)	\
NSLog(@"[E] [%@] %s:%d:%@", CAT, \
	__PRETTY_FUNCTION__, __LINE__, \
	[NSString stringWithFormat:MSG, ## __VA_ARGS__] \
);
#else
#define SCR_LOG_ERROR(CAT, MSG, ...)
#endif
