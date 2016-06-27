//
//  TagListView.m
//  TagObjc
//
//  Created by Javi Pulido on 16/7/15.
//  Copyright (c) 2015 Javi Pulido. All rights reserved.
//

#import "TagListView.h"
#import "TagView.h"

@interface TagListView ()
@property (nonatomic) NSMutableArray *rowContent;
@end

@implementation TagListView

// Required by Interface Builder
#if TARGET_INTERFACE_BUILDER
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];  
    return self;
}
#endif

- (NSMutableArray *)tagViews {
    if(!_tagViews) {
        [self setTagViews:[[NSMutableArray alloc] init]];
    }
    return _tagViews;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setTextColor:textColor];
    }
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor {
    _tagBackgroundColor = tagBackgroundColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBackgroundColor:tagBackgroundColor];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    for(TagView *tagView in [self tagViews]) {
        [tagView setCornerRadius:cornerRadius];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBorderWidth:borderWidth];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBorderColor:borderColor];
    }
}

- (void)setPaddingY:(CGFloat)paddingY {
    _paddingY = paddingY;
    for(TagView *tagView in [self tagViews]) {
        [tagView setPaddingY:paddingY];
    }
}

- (void)setPaddingX:(CGFloat)paddingX {
    _paddingX = paddingX;
    for(TagView *tagView in [self tagViews]) {
        [tagView setPaddingX:paddingX];
    }
}

- (void)setMarginY:(CGFloat)marginY {
    _marginY = marginY;
    [self rearrangeViews];
}

- (void)setMarginX:(CGFloat)marginX {
    _marginX = marginX;
    [self rearrangeViews];
}

- (void)setRows:(NSInteger)rows {
    _rows = rows;
    [self invalidateIntrinsicContentSize];
}

- (void)setAlignment:(TagListViewAlignment)alignment {
    _alignment = alignment;
    [self rearrangeViews];
}

# pragma mark - Interface builder

- (void)prepareForInterfaceBuilder {
    [self addTag:@"Thanks"];
    [self addTag:@"for"];
    [self addTag:@"using"];
    [self addTag:@"TagListView"];
}

# pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self rearrangeViews];
}

- (void)rearrangeViews {
    for(TagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }
    
    self.rowContent = [NSMutableArray new];
    NSInteger oldRow = 0;
    NSInteger currentRow = 0;
    NSInteger currentRowTagCount = 0;
    CGFloat currentRowWidth = 0;
    for(TagView *tagView in [self tagViews]) {
        CGRect tagViewFrame = [tagView frame];
        tagViewFrame.size = [tagView intrinsicContentSize];
        [tagView setFrame:tagViewFrame];
        self.tagViewHeight = tagViewFrame.size.height;
        
        if (currentRowTagCount == 0 || (currentRowWidth + tagView.frame.size.width + [self marginX]) > self.frame.size.width) {
            currentRow += 1;
            CGRect tempFrame = [tagView frame];
            tempFrame.origin.x = 0;
            tempFrame.origin.y = (currentRow - 1) * ([self tagViewHeight] + [self marginY]);
            [tagView setFrame:tempFrame];
            
            currentRowTagCount = 1;
            currentRowWidth = tagView.frame.size.width + [self marginX];
        } else {
            CGRect tempFrame = [tagView frame];
            tempFrame.origin.x = currentRowWidth;
            tempFrame.origin.y = (currentRow - 1) * ([self tagViewHeight] + [self marginY]);
            [tagView setFrame:tempFrame];
            
            currentRowTagCount += 1;
            currentRowWidth += tagView.frame.size.width + [self marginX];
        }
        
        if (oldRow != currentRow) {
            oldRow = currentRow;
            if (self.rowContent.count != currentRow) {
                [self.rowContent addObject:[NSMutableArray new]];
            }
        }
        [[self.rowContent objectAtIndex:currentRow-1] addObject:tagView];
        
        [self addSubview:tagView];
    }
    self.rows = currentRow;
    
    if (self.alignment == TagListViewAlignmentCenter) {
        [self centralize];
    }
}

- (void)centralize {
    for (NSArray *array in self.rowContent) {
        CGFloat middle = self.frame.size.width/2.0f;
        CGFloat totalWidth = 0.0f;
        for (TagView *tagView in array) {
            totalWidth += tagView.frame.size.width;
        }
        CGFloat startPoint = middle-(totalWidth/2.0f);
        for (TagView *tagView in array) {
            tagView.frame = CGRectMake(startPoint, tagView.frame.origin.y, tagView.frame.size.width, tagView.frame.size.height);
            startPoint += tagView.frame.size.width + [self marginX];
        }
    }
}

# pragma mark - Manage tags

- (CGSize) intrinsicContentSize {
    CGFloat height = [self rows] * ([self tagViewHeight] + [self marginY]);
    if([self rows] > 0) {
        height -= [self marginY];
    }
    return CGSizeMake(self.frame.size.width, height);
}

- (TagView *)addTag:(NSString *)title {
    TagView *tagView = [[TagView alloc] initWithTitle:title];
    
    [tagView setTextColor: [self textColor]];
    [tagView setBackgroundColor: [self tagBackgroundColor]];
    [tagView setCornerRadius: [self cornerRadius]];
    [tagView setBorderWidth: [self borderWidth]];
    [tagView setBorderColor: [self borderColor]];
    [tagView setPaddingY: [self paddingY]];
    [tagView setPaddingX: [self paddingX]];
    [tagView setTextFont: [self textFont]];
    
    [tagView addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addTagView: tagView];
    
    return tagView;
}

- (void) addTagView:(TagView *)tagView {
    [[self tagViews] insertObject:tagView atIndex:[self.tagViews count]];
    [self rearrangeViews];
}

- (void)removeTag:(NSString *)title {
    // Author's note: Loop the array in reversed order to remove items during loop
    for(NSInteger index = (NSInteger)[[self tagViews] count] - 1 ; index <= 0; index--) {
        TagView *tagView = [[self tagViews] objectAtIndex:index];
        if([[tagView currentTitle] isEqualToString:title]) {
            [tagView removeFromSuperview];
            [[self tagViews] removeObjectAtIndex:index];
        }
    }
}

- (void)removeAllTags {
    for(TagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }
    [self setTagViews:[[NSMutableArray alloc] init]];
    [self rearrangeViews];
}

- (void)tagPressed:(TagView *)sender {
    if (sender.onTap) {
        sender.onTap(sender);
    }
}

@end
