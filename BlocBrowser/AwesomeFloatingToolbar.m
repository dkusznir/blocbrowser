//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Dorian Kusznir on 3/10/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles
{
    self = [super init];
    
    if (self)
    {
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles)
        {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.backgroundColor = colorForThisButton;
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(buttonReleased:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }

        self.buttons = buttonsArray;
        
        for (UILabel *thisButton in self.buttons)
        {
            [self addSubview:thisButton];
        }
        
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        //[self addGestureRecognizer:self.tapGesture];
    
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void) layoutSubviews
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
    for (UIButton *thisButton in self.buttons)
    {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonY = 0;
        CGFloat buttonX = 0;
        
        if (currentButtonIndex < 2)
        {
            buttonY = 0;
        }
        
        else
        {
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0)
        {
            buttonX = 0;
        }
        
        else
        {
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
        
    });
}

#pragma mark - Touch Handling

- (UILabel *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];

    return (UILabel *)subview;

}

- (void) buttonReleased:(UIButton *)sender
{
    if ([self.buttons containsObject:sender])
    {
        if ([self.delegate respondsToSelector:@selector(floatingToolBar:didSelectButtonWithTitle:)])
             {
                 [self.delegate floatingToolBar:self didSelectButtonWithTitle:sender.currentTitle];
             }
    }
    
    [sender setAlpha:1];
}

- (void) buttonPressed:(UIButton *)sender
{
    [sender setAlpha:0.5];
}

/*
- (void) tapFired:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:tappedView])
        {
            if ([self.delegate respondsToSelector:@selector(floatingToolBar:didSelectButtonWithTitle:)])
            {
                [self.delegate floatingToolBar:self didSelectButtonWithTitle:((UIButton *)tappedView).titleLabel.text];
            }
        }
    }
}
*/
- (void) panFired:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolBar:didTryToPanWithOffset:)])
        {
            [self.delegate floatingToolBar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat scale = recognizer.scale;
        
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
        recognizer.scale = 1;
        
        NSLog(@"New Scale: %f", scale);
        
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer;
{
    for (UIButton *thisButton in self.buttons)
    {

        NSInteger currentColorIndex = 0;

        for (UIColor *thisColor in self.colors)
        {
            if ([thisColor isEqual:thisButton.backgroundColor])
            {
               currentColorIndex = [self.colors indexOfObject:thisColor];
            }
        }
        
        currentColorIndex++;
        
        if (currentColorIndex > (self.colors.count - 1))
        {
            currentColorIndex = 0;
        }
        
        UIColor *buttonColor = [self.colors objectAtIndex:currentColorIndex];
        
        thisButton.backgroundColor = buttonColor;
        
   }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound)
    {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
