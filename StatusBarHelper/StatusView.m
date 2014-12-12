//
//  StatusView.m
//  StatusBarHelper
//

#import "StatusView.h"

NSRect NSEdgeInsetRect(NSRect r, NSEdgeInsets i)
{
    NSRect ir = NSZeroRect;
    ir.origin.x = r.origin.x + i.left;
    ir.origin.y = r.origin.y + i.top;
    ir.size.width = r.size.width - (i.left + i.right);
    ir.size.height = r.size.height - (i.top + i.bottom);
    return ir;
}

@implementation StatusView

#pragma mark - Overrides -

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect coloredRect = NSEdgeInsetRect(self.bounds, self.margins);
    NSRect redrawRect = NSIntersectionRect(coloredRect, dirtyRect);
    
    if (!NSIsEmptyRect(redrawRect))
    {
        [self.backgroundColor set];
        NSRectFillUsingOperation(redrawRect, NSCompositeSourceOver);
    }
}

#pragma mark - Public -

- (NSButton *)button
{
    if (!_button)
    {
        _button = [[NSButton alloc] initWithFrame:self.bounds];
        _button.transparent = YES;
        [self addSubview:_button];
    }
    
    return _button;
}

- (void)setMargins:(NSEdgeInsets)margins
{
    if (!NSEdgeInsetsEqual(_margins, margins))
    {
        _margins = margins;
        self.needsDisplay = YES;
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    if (_backgroundColor != backgroundColor)
    {
        _backgroundColor = backgroundColor;
        self.needsDisplay = YES;
    }
}

@end
