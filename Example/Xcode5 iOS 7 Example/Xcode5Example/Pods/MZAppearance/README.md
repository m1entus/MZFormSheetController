MZAppearance
============

UIAppearance proxy for custom objects

## How To Use

All you need is mark a method that participates in the appearance proxy API using MZ_APPEARANCE_SELECTOR.
Implement <MZAppearance> protocol method + (id)appearance, and call applyInvocationTo inside your init or viewDidLoad object method.

``` objective-c
@interface MZViewController : UIViewController <MZApperance>

@property (nonatomic,strong) UIColor *customColor MZ_APPEARANCE_SELECTOR;
@property (nonatomic,assign) CGFloat customFloat MZ_APPEARANCE_SELECTOR;

+ (id)appearance;

@end
```

``` objective-c
+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[[self class] appearance] applyInvocationTo:self];
    
    NSLog(@"custom color: %@",self.customColor);
    NSLog(@"custom float: %f",self.customFloat);
}
```

## How to setup appearance variable

``` objective-c
[[MZViewController appearance] setCustomColor:[UIColor blackColor]];
[[MZViewController appearance] setCustomFloat:6.0];
```

Console result will be

``` objective-c
2013-08-17 19:59:38.546 MZAppearance[3374:c07] custom color: UIDeviceWhiteColorSpace 0 1
2013-08-17 19:59:38.547 MZAppearance[3374:c07] custom float: 6.000000
```




[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/m1entus/mzappearance/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

