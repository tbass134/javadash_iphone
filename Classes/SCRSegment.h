//
//  SCRSegment.h
//  TouchCustoms
//
//  Created by Aleks Nesterow-Rutkowski on 1/26/10.
//	aleks@screencustoms.com
//	
//	Purpose
//	Represents a single segment in SCRSegmentedControl.
//

#import "SCRSegmentColorScheme.h"

typedef enum {
	SCRSegmentCenter,
	SCRSegmentLeft,
	SCRSegmentRight,
	SCRSegmentLeftRound,
	SCRSegmentRightRound,
	SCRSegmentLeftTopRound,
	SCRSegmentLeftBottomRound,
	SCRSegmentRightTopRound,
	SCRSegmentRightBottomRound,
	SCRSegmentRound
} SCRSegmentStyle;

@interface SCRSegment : UIView {

@private
	BOOL _selected;
	SCRSegmentStyle _style;
	SCRSegmentColorScheme _colorScheme;
	UILabel *_titleLabel;
	UIImageView *_imageView;
}

@property (nonatomic, assign) BOOL selected;
/** Determines the form of the segment. */
@property (nonatomic, assign) SCRSegmentStyle style;
/** Determines segment foreground style when it is selected. */
@property (nonatomic, assign) SCRSegmentColorScheme colorScheme;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIImageView *imageView;

+ (SCRSegment *)segmentWithStyle:(SCRSegmentStyle)style;
- (id)initWithStyle:(SCRSegmentStyle)style;
- (id)initWithStyle:(SCRSegmentStyle)style frame:(CGRect)frame;

@end
