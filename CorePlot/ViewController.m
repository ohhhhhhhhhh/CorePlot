//
//  ViewController.m
//  CorePlot
//
//  Created by zy on 2017/6/22.
//  Copyright © 2017年 zy. All rights reserved.
//

#import "ViewController.h"
#import <CorePlot.h>

@interface ViewController ()<CPTPlotDataSource,CPTBarPlotDataSource,CPTBarPlotDelegate,CPTPlotSpaceDelegate>{
    
    // 柱状图
    NSMutableArray * dataSource1;
    NSMutableArray * dataSource2;
    
    CPTGraphHostingView * hostView;
}

@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) NSArray * coordinatesX;

@property (nonatomic,strong) NSArray * sliceFills;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     CorePlot提供了散点图（CPTScatterPlot）的绘制，包括：折线图、曲线图、直方图
     CorePlot框架自身提供了线条样式、文本样式及填充色的设置。
     CPTMutableLineStyle／CPTLineStyle用于设置线条样式；
     CPTMutableTextStyle／CPTTextStyle用于设置文本样式；
     CPTFill用于设置填充色。
     */
    
//    [self initData];
    [self initPieData];
    
    [self createHostView];
    
    [self createGraph];
    
    [self createPlotSpace];
    
//    [self createAxis];
    
    [self createPlots3];
    
//    [self createLegend];
}

#pragma mark -数据源及x轴的标签
- (void)initData{
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++) {
        [dataSource addObject:@(arc4random()%10)];
    }
    self.dataSource = dataSource;
    _coordinatesX = @[@"第一次",@"第二次",@"第三次",@"第四次",@"第五次",@"第六次",@"第七次",@"第八次",@"第九次",@"第十次"];
}

#pragma mark 创建宿主HostView
// CorePlot中的所有图表都是绘制在宿主View中的，其他普通View无法绘制图标。CPTGraphHostingView继承自UIView
- (void)createHostView
{
    CGRect frame = CGRectMake(10, 150, 350, 350);
    //  图形要放在CPTGraphHostingView宿主中，因为UIView无法加载CPTGraph
    hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    //  默认值：NO，设置为YES可以减少GPU的使用，但是渲染图形的时候会变慢
    hostView.collapsesLayers = NO;
    //  允许捏合缩放 默认值：YES
    hostView.allowPinchScaling = NO;
    //  背景色 默认值：clearColor
    hostView.backgroundColor = [UIColor whiteColor];
    
    // 添加到View中
    [self.view addSubview:hostView];
}


#pragma mark 创建图表，用于显示的画布
// CPTXYGraph继承自CPTGraph。CPTXYGraph是绘制带有x、y轴坐标的图标。CPTGraph管理绘图空间、绘图区域、坐标轴、标签、标题等的创建。
- (void)createGraph
{
    // 基于xy轴的图表创建
    CPTXYGraph *graph=[[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    // 使宿主视图的hostedGraph与CPTGraph关联
    hostView.hostedGraph = graph;
    
    // 设置主题，类似于皮肤
    {
        //CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
        //[graph applyTheme:theme];
    }
    
    // 标题设置
    {
        graph.title = @"标题：曲线图";
        // 标题对齐于图框的位置，可以用CPTRectAnchor枚举类型，指定标题向图框的4角、4边（中点）对齐标题位置 默认值：CPTRectAnchorTop（顶部居中）
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        // 标题对齐时的偏移距离（相对于titlePlotAreaFrameAnchor的偏移距离）默认值：CGPointZero
        graph.titleDisplacement = CGPointZero;
        // 标题文本样式 默认值：nil
        CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
        textStyle.fontSize = CPTFloat(25);
        textStyle.textAlignment = CPTTextAlignmentLeft;
        graph.titleTextStyle = textStyle;
    }
    
    // CPGGraph内边距，默认值：20.0f
    {
        graph.paddingLeft = CPTFloat(0);
        graph.paddingTop = CPTFloat(0);
        graph.paddingRight = CPTFloat(0);
        graph.paddingBottom = CPTFloat(0);
    }
    
    // CPTPlotAreaFrame绘图区域设置
    {
        // 内边距设置，默认值：0.0f
        graph.plotAreaFrame.paddingLeft = CPTFloat(0);
        graph.plotAreaFrame.paddingTop = CPTFloat(0);
        graph.plotAreaFrame.paddingRight = CPTFloat(0);
        graph.plotAreaFrame.paddingBottom = CPTFloat(0);
        // 边框样式设置 默认值：nil
        graph.plotAreaFrame.borderLineStyle=nil;
    }
    
    /**
     CorePlot为CPTGraph提供了几种主题可供使用，
     有：kCPTDarkGradientTheme、
        kCPTPlainBlackTheme、
        kCPTPlainWhiteTheme、
        kCPTSlateTheme、
        kCPTStocksTheme。
     每种可以切换主题试试有什么不同的效果。
     内边距（paddingLeft、paddingTop、paddingRight、paddingBottom）
     来自于父类CPTLayer。CPTLayer是CorePlot中所有层（Layer）的父类，继承于CALayer。
     绘图边框（plotAreaFrame）中关联了绘图区域（CPTPlotArea）、坐标系（CPTAxisSet）。
     */
}

#pragma mark 创建绘图空间
// CPTXYPlotSpace是CPTPlotSpace的子类。绘图空间定义了坐标空间和绘制空间的映射关系。CPTXYPlotSpace则定义了在二维（x、y轴）中的映射关系
- (void)createPlotSpace
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)hostView.hostedGraph.defaultPlotSpace;
    // 绘图空间是否允许与用户交互 默认值：NO
    plotSpace.allowsUserInteraction = YES;
    // 委托事件
    plotSpace.delegate = self;
    
    //设置移动时的停止动画
    {
        // 这些参数保持默认即可  变化不大
        plotSpace.allowsMomentum = YES;
        plotSpace.momentumAnimationCurve = CPTAnimationCurveCubicIn;
        plotSpace.bounceAnimationCurve = CPTAnimationCurveBackIn;
        plotSpace.momentumAcceleration = 20000.0;
    }
    
    // 可显示大小 一屏内横轴／纵轴的显示范围
    {
        // 横轴
        {
            // location表示坐标的显示起始值，length表示要显示的长度 类似于NSRange
            CPTMutablePlotRange *xRange = [CPTMutablePlotRange plotRangeWithLocation:@(-1) length:@(_coordinatesX.count + 1)];
            // 横轴显示的收缩／扩大范围 1：不改变  <1:收缩范围  >1:扩大范围
            [xRange expandRangeByFactor:@(1)];
            
            plotSpace.xRange = xRange;
        }
        
        // 纵轴
        {
            CPTMutablePlotRange *yRange = [CPTMutablePlotRange plotRangeWithLocation:@(-1) length:@(11)];
            [yRange expandRangeByFactor:@(1)];
            
            plotSpace.yRange = yRange;
        }
    }
    
    // 绘图空间的最大显示空间，滚动范围
    {
        CPTMutablePlotRange *xGlobalRange = [CPTMutablePlotRange plotRangeWithLocation:@(-2) length:@(_coordinatesX.count + 5)];
        
        CPTMutablePlotRange *yGlobalRange = [CPTMutablePlotRange plotRangeWithLocation:@(-2) length:@(16)];
        
        plotSpace.globalXRange = xGlobalRange;
        plotSpace.globalYRange = yGlobalRange;
    }
    
    /**
     需着重理解xRange／yRange于globalXRange／globalYRange之间的区别。
     xRange／yRange是指在视图中显示的范围，人们可以看到的范围。
     globalXRange／globalYRange是指绘图空间最大显示范围（滚动范围），可以通过手指拖动看到其他的范围。
     xRange／yRange类似于UIScorllView中frame的size，
     globalXRange／globalYRange类似于UIScrollView中的contentSize。
     */
}

#pragma mark -绘图空间<CPTPlotSpaceDelegate>
// 替换移动坐标
- (CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector
{
    //    NSLog(@"\n============willDisplaceBy==========\n");
    //    NSLog(@"原始的将要移动的坐标:%@", NSStringFromCGPoint(proposedDisplacementVector));
    //
    return proposedDisplacementVector;
}

// 是否允许缩放
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    //    NSLog(@"\n============shouldScaleBy==========\n");
    //    NSLog(@"缩放比例:%lf", interactionScale);
    //    NSLog(@"缩放的中心点:%@", NSStringFromCGPoint(interactionPoint));
    return YES;
}

// 缩放绘图空间时调用，设置当前显示的大小
- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    //    NSLog(@"\n============willChangePlotRangeTo==========\n");
    //    NSLog(@"坐标类型:%d", coordinate);
    //    // CPTPlotRange 有比较方法 containsRange:
    //    NSLog(@"原始的坐标空间:location:%@,length:%@", [NSDecimalNumber decimalNumberWithDecimal:newRange.location].stringValue, [NSDecimalNumber decimalNumberWithDecimal:newRange.length].stringValue);
    //
    return newRange;
}

// 结束缩放绘图空间时调用
- (void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate
{
    //    NSLog(@"\n============didChangePlotRangeForCoordinate==========\n");
    //    NSLog(@"坐标类型:%d", coordinate);
}

// 开始按下 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceDownEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

// 开始拖动 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceDraggedEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

// 松开 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceUpEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

// 取消，如：来电时产生的取消事件
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceCancelledEvent==========\n");
    
    return YES;  
}  


#pragma mark -创建坐标系
// CPTXYAxisSet继承自CPTAxisSet，是一个二维坐标（x轴、y轴）。
- (void)createAxis
{
    // 轴线样式
    CPTMutableLineStyle *axisLineStyle = [[CPTMutableLineStyle alloc] init];
    axisLineStyle.lineWidth = CPTFloat(1);
    axisLineStyle.lineColor = [CPTColor blackColor];
    
    // 标题样式
    CPTMutableTextStyle *titelStyle = [CPTMutableTextStyle textStyle];
    titelStyle.color = [CPTColor redColor];
    titelStyle.fontSize = CPTFloat(20);
    
    // 主刻度线样式
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    majorLineStyle.lineColor = [CPTColor purpleColor];
    
    // 细分刻度线样式
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor blueColor];
    
    // 轴标签样式
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blueColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = CPTFloat(11);
    
    // 轴标签样式
    CPTMutableTextStyle *axisLabelTextStyle = [[CPTMutableTextStyle alloc] init];
    axisLabelTextStyle.color=[CPTColor greenColor];
    axisLabelTextStyle.fontSize = CPTFloat(17);
    
    // 坐标系
    CPTXYAxisSet *axis = (CPTXYAxisSet *)hostView.hostedGraph.axisSet;
    
    //X轴设置
    {
        // 获取X轴线
        CPTXYAxis *xAxis = axis.xAxis;
        
        // 轴线设置
        xAxis.axisLineStyle = axisLineStyle;
        
        // 显示的刻度范围 默认值：nil
        xAxis.visibleRange=[CPTPlotRange plotRangeWithLocation:@(0) length:@(_coordinatesX.count - 1)];
        
        // 标题设置
        {
            xAxis.title =@ "X轴";
            // 文本样式
            xAxis.titleTextStyle = titelStyle;
            // 位置 与刻度有关,
            xAxis.titleLocation = @(2);
            // 方向设置
            xAxis.titleDirection = CPTSignNegative;
            // 偏移量,在方向上的偏移量
            xAxis.titleOffset = CPTFloat(25);
        }
        
        // 位置设置
        {
            // 固定坐标 默认值：nil
            //xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:50.0];
            // 坐标原点所在位置，默认值：CPTDecimalFromInteger(0)（在Y轴的0点位置）
//            xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
        }
        
        // 主刻度线设置
        {
            // X轴大刻度线，线型设置
            xAxis.majorTickLineStyle = majorLineStyle;
            // 刻度线的长度
            xAxis.majorTickLength = CPTFloat(5);
            // 刻度线位置
            NSMutableSet *majorTickLocations =[NSMutableSet setWithCapacity:_coordinatesX.count];
            for (int i= 0 ;i< _coordinatesX.count ;i++) {
                [majorTickLocations addObject:[NSNumber numberWithInt:(i)]];
            }
            xAxis.majorTickLocations = majorTickLocations;
        }
        
        // 细分刻度线设置
        {
            // 刻度线的长度
            xAxis.minorTickLength = CPTFloat(3);
            // 刻度线样式
            xAxis.minorTickLineStyle = minorLineStyle;
            // 刻度线位置
            NSInteger minorTicksPerInterval = 3;
            CGFloat minorIntervalLength = CPTFloat(1) / CPTFloat(minorTicksPerInterval + 1);
            NSMutableSet *minorTickLocations =[NSMutableSet setWithCapacity:(_coordinatesX.count - 1) * minorTicksPerInterval];
            for (int i= 0 ;i< _coordinatesX.count - 1;i++) {
                for (int j = 0; j < minorTicksPerInterval; j++) {
                    [minorTickLocations addObject:[NSNumber numberWithFloat:(i + minorIntervalLength * (j + 1))]];
                }
            }
            xAxis.minorTickLocations = minorTickLocations;
        }
        
        // 网格线设置
        {
            //xAxis.majorGridLineStyle = majorLineStyle;
            //xAxis.minorGridLineStyle = minorLineStyle;
//            xAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(9)];
        }
        
        // 轴标签设置
        {
            //清除默认的方案，使用自定义的轴标签、刻度线；
            xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
            // 轴标签偏移量
            xAxis.labelOffset = 0.f;
            // 轴标签样式
            xAxis.labelTextStyle = axisTextStyle;
            
            // 存放自定义的轴标签
            NSMutableSet *xAxisLabels = [NSMutableSet setWithCapacity:_coordinatesX.count];
            for ( int i= 0 ;i< _coordinatesX.count ;i++) {
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:_coordinatesX[i] textStyle:axisLabelTextStyle];
                // 刻度线的位置
                newLabel.tickLocation = @(i);
                newLabel.offset = xAxis.labelOffset + xAxis.majorTickLength;
                newLabel.rotation = M_PI_4;
                [xAxisLabels addObject :newLabel];
            }
            xAxis.axisLabels = xAxisLabels;
        }
    }
    
    //Y轴设置
    {
        // 获取Y轴坐标
        CPTXYAxis *yAxis = axis.yAxis;
        
        // 委托事件
        yAxis.delegate = self;
        
        //轴线样式
        yAxis.axisLineStyle = axisLineStyle;
        
        //显示的刻度
        yAxis.visibleRange = [CPTPlotRange plotRangeWithLocation:@(0.0f) length:@(9)];
        
        // 标题设置
        {
            yAxis.title = @"Y轴";
            // 文本样式
            yAxis.titleTextStyle = titelStyle;
            // 位置 与刻度有关,
            yAxis.titleLocation = @(2.4);
            // 方向设置
            yAxis.titleDirection = CPTSignNegative;
            // 偏移量,在方向上的偏移量
            yAxis.titleOffset = CPTFloat(18);
            // 旋转方向
            yAxis.titleRotation = CPTFloat(M_PI_2);
        }
        
        // 位置设置
        {
            // 获取X轴原点即0点的坐标
            CPTXYAxis *xAxis = axis.xAxis;
            CGPoint zeroPoint = [xAxis viewPointForCoordinateValue:@(0)];
            
            // 固定坐标 默认值：nil
            yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:CPTFloat(zeroPoint.x)];
            
            // 坐标原点所在位置，默认值：CPTDecimalFromInteger(0)（在X轴的0点位置）
            //yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
        }
        
        // 主刻度线设置
        {
            // 显示数字标签的量度间隔
            yAxis.majorIntervalLength = @(1);
            // 刻度线，线型设置
            yAxis.majorTickLineStyle = majorLineStyle;
            // 刻度线的长度
            yAxis.majorTickLength = 6;
        }
        
        // 细分刻度线设置
        {
            // 每一个主刻度范围内显示细分刻度的个数
            yAxis.minorTicksPerInterval = 5;
            // 刻度线的长度
            yAxis.minorTickLength = CPTFloat(3);
            // 刻度线，线型设置
            yAxis.minorTickLineStyle = minorLineStyle;
        }
        
        // 网格线设置 默认不显示
        {
            //yAxis.majorGridLineStyle = majorLineStyle;
            //yAxis.minorGridLineStyle = minorLineStyle;
            //yAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_coordinatesY.count)];
        }
        
        // 轴标签设置
        {
            // 轴标签偏移量
            yAxis.labelOffset = CPTFloat(5);
            // 轴标签样式
            yAxis.labelTextStyle = axisTextStyle;
            
            // 排除不显示的标签
            NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                        [CPTPlotRange plotRangeWithLocation:@(0.99) length:@(0.02)],
                                        [CPTPlotRange plotRangeWithLocation:@(2.99) length:@(0.02)],
                                        nil];
            yAxis.labelExclusionRanges = exclusionRanges;
            
            // 因为没有清除默认的轴标签（CPTAxisLabelingPolicyNone）,如果想要自定义轴标签，需实现委托方法
        }
    }
    
    
    // 如果想自定义标签及刻度，则需要清除默认的方案，设置属性labelingPolicy为CPTAxisLabelingPolicyNone，预设的轴标签有4种：CPTAxisLabelingPolicyLocationsProvided、CPTAxisLabelingPolicyFixedInterval、CPTAxisLabelingPolicyAutomatic、CPTAxisLabelingPolicyEqualDivisions。如果采用预设的方案，只是采用它的刻度线设置，想使用自定义的轴标签，则需要实现轴标签的委托事件。
    /*
     #pragma mark 是否使用系统的轴标签样式 并可改变标签样式 可用于任何标签方案(labelingPolicy)
     - (BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
     {
     // 返回NO，使用自定义，返回YES，使用系统的标签
     return NO;
     }
     */
}


#pragma mark 创建图例
- (void)createLegend
{
    // 图例样式设置
    NSMutableArray *plots = [NSMutableArray array];
    for (int i = 0; i < hostView.hostedGraph.allPlots.count; i++) {
        CPTScatterPlot *scatterPlot = hostView.hostedGraph.allPlots[i];
        
        CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
        plot.dataLineStyle = scatterPlot.dataLineStyle;
        plot.plotSymbol = scatterPlot.plotSymbol;
        plot.identifier = @"折线图";
        [plots addObject:plot];
    }
    // 图例初始化
    CPTLegend *legend = [CPTLegend legendWithPlots:plots];
    // 图例的列数。有时图例太多，单列显示太长，可分为多列显示
    legend.numberOfColumns = 1;
    // 图例外框的线条样式
    legend.borderLineStyle = nil;
    // 图例的填充属性，CPTFill 类型
    legend.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    // 图例中每个样本的大小
    legend.swatchSize = CGSizeMake(40, 10);
    // 图例中每个样本的文本样式
    CPTMutableTextStyle *titleTextStyle = [CPTMutableTextStyle textStyle];
    titleTextStyle.color = [CPTColor blackColor];
    titleTextStyle.fontName = @"Helvetica-Bold";
    titleTextStyle.fontSize = 13;
    legend.textStyle = titleTextStyle;
    
    // 把图例于图表关联起来
    hostView.hostedGraph.legend = legend;
    // 图例对齐于图框的位置，可以用 CPTRectAnchor 枚举类型，指定图例向图框的4角、4边（中点）对齐，默认值：CPTRectAnchorBottom（底部居中）
    hostView.hostedGraph.legendAnchor = CPTRectAnchorTopRight;
    // 图例对齐时的偏移距离（相对于legendAnchor的偏移距离），默认值：CGPointZeor
    hostView.hostedGraph.legendDisplacement = CGPointMake(-10, 0);
    
    /**
     创建图例时，如果图例的名称和CPTPlot属性identifier的名称一致，则不需要在单独创建plots集合了，直接使用_hostView.hostedGraph.allPlots即可，因为土里的图标和名称取得就是CPTScatterPlot的dataLineStyle、plotSymbol及identifier属性。
     */
    
    
    /**
     
     如果想使用数据源方法设置图例方法，必须要用如下方法创建图例，这会使每一个柱子都在图例中
     
     CPTLegend *legend = [CPTLegend legendWithPlots:_hostView.hostedGraph.allPlots];
     CPTLegend *legend = [CPTLegend legendWithGraph:_hostView.hostedGraph];
     
     
     如果不需要每个柱子都显示图例（不会调用数据legendTitleForBarPlot），只需要设置不同类别的图例，可以使用如下方法。
     
     // 图例样式设置
     NSMutableArray *plots = [NSMutableArray array];
     for (int i = 0; i < _hostView.hostedGraph.allPlots.count; i++) {
     CPTBarPlot *barPlot = _hostView.hostedGraph.allPlots[i];
     
     CPTBarPlot *plot = [[CPTBarPlot alloc] init];
     plot.fill = barPlot.fill;
     plot.lineStyle = barPlot.lineStyle;
     plot.identifier = [NSString stringWithFormat:@"柱状图%d", (i + 1)];
     [plots addObject:plot];
     }
     // 图例初始化 只有把plots 替换为 _hostView.hostedGraph.allPlots 数据源方法的设置图例名称才会生效
     CPTLegend *legend = [CPTLegend legendWithPlots:plots];
     
     */
}


#pragma mark 创建平面图，折线图
// CPTScatterPlot用于创建散点图，继承自CPTPlot。
- (void)createPlots
{
    // 创建折线图
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    
    // 添加图形到绘图空间
    [hostView.hostedGraph addPlot:scatterPlot];
    
    // 标识,根据此@ref identifier来区分不同的plot,也是图例显示名称,
    scatterPlot.identifier = @"scatter";
    
    // 设定数据源，需应用CPTScatterPlotDataSource协议
    scatterPlot.dataSource = self;
    
    // 委托事件
    scatterPlot.delegate = self;
    
    // 线性显示方式设置 默认值：CPTScatterPlotInterpolationLinear（折线图）
    // CPTScatterPlotInterpolationCurved（曲线图）
    // CPTScatterPlotInterpolationStepped／CPTScatterPlotInterpolationHistogram（直方图）
    scatterPlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    // 数据标签设置，如果想用自定义的标签，则需要数据源方法：dataLabelForPlot:recordIndex:
    {
        // 偏移量设置
        scatterPlot.labelOffset = 15;
        // 数据标签样式
        CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
        labelTextStyle.color = [CPTColor magentaColor];
        scatterPlot.labelTextStyle = labelTextStyle;
    }
    
    // 线条样式设置
    {
        CPTMutableLineStyle * scatterLineStyle = [[ CPTMutableLineStyle alloc ] init];
        scatterLineStyle.lineColor = [CPTColor blackColor];
        scatterLineStyle.lineWidth = 3;
        // 破折线
        scatterLineStyle.dashPattern = @[@(10.0),@(5.0)];
        
        // 如果设置为nil则为散点图
        scatterPlot.dataLineStyle = scatterLineStyle;
    }
    
    // 添加拐点
    {
        // 符号类型：椭圆
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        // 符号大小
        plotSymbol.size = CPTSizeMake(8.0f, 8.f);
        // 符号填充色
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
        // 边框设置
        CPTMutableLineStyle *symboLineStyle = [[ CPTMutableLineStyle alloc ] init];
        symboLineStyle.lineColor = [CPTColor blackColor];
        symboLineStyle.lineWidth = 3;
        plotSymbol.lineStyle = symboLineStyle;
        
        // 向图形上加入符号
        scatterPlot.plotSymbol = plotSymbol;
        
        // 设置拐点的外沿范围，以用来扩大检测手指的触摸范围
        scatterPlot.plotSymbolMarginForHitDetection = CPTFloat(5);
    }
    
    // 创建渐变区
    {
        // 创建一个颜色渐变：从渐变色BeginningColor渐变到色endingColor
        CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
        // 渐变角度：-90 度（顺时针旋转）
        areaGradient.angle = -90.0f ;
        // 创建一个颜色填充：以颜色渐变进行填充
        CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        // 为图形设置渐变区
        scatterPlot.areaFill = areaGradientFill;
        // 渐变区起始值，小于这个值的图形区域不再填充渐变色
        scatterPlot.areaBaseValue = @0.0;
    }
    
    // 显示动画
    {
        scatterPlot.opacity = 0.0f;
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration            = 3.0f;
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fillMode            = kCAFillModeForwards;
        fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
        [scatterPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    }
    
    /**
     在CPTXYScatterPlot中属性interpolation用于设置线性显示方式，它是一个枚举类型，有
     CPTScatterPlotInterpolationLinear（折线图）、
     CPTScatterPlotInterpolationCurved（曲线图）、
     CPTScatterPlotInterpolationStepped／
     CPTScatterPlotInterpolationHistogram（直方图）
     4 种，
     其中CPTScatterPlotInterpolationLinear是默认值。
     只要把线条样式（dataLineStyle）的值设为nil，则是散点图。
     */
}

/*
#pragma mark -CPTScatterPlot的dataSource方法
// 询问有多少个数据
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.dataSource.count;
}

// 询问一个个数据值 fieldEnum:一个轴类型，是一个枚举  idx：坐标轴索引
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *num = nil;
    if(fieldEnum == CPTScatterPlotFieldY){            //询问在Y轴上的值
        num = self.dataSource[idx];
    }else if (fieldEnum == CPTScatterPlotFieldX){     //询问在X轴上的值
        num = @(idx);
    }
    return num;
}

// 添加数据标签，在拐点上显示的文本
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    // 数据标签样式
    CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
    labelTextStyle.color = [CPTColor magentaColor];
    
    // 定义一个 TextLayer
    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%d",[self.dataSource[idx] intValue]] style:labelTextStyle];
    
    return newLayer;
}

#pragma mark -CPTScatterPlot的delegate方法
// 选择拐点时
- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(UIEvent *)event
{
    // 移除注释
    CPTPlotArea *plotArea = hostView.hostedGraph.plotAreaFrame.plotArea;
    [plotArea removeAllAnnotations];
    
    // 创建拐点注释，plotSpace：绘图空间 anchorPlotPoint：坐标点
    CPTPlotSpaceAnnotation *symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:hostView.hostedGraph.defaultPlotSpace anchorPlotPoint:@[@(idx),self.dataSource[idx]]];
    
    // 文本样式
    CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
    annotationTextStyle.color = [CPTColor greenColor];
    annotationTextStyle.fontSize = 17.0f;
    annotationTextStyle.fontName = @"Helvetica-Bold";
    // 显示的字符串
    NSString *randomValue = [NSString stringWithFormat:@"折线图\n随即值：%@ \n", [self.dataSource[idx] stringValue]];
    // 注释内容
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:randomValue style:annotationTextStyle];
    // 添加注释内容
    symbolTextAnnotation.contentLayer = textLayer;
    
    // 注释位置
    symbolTextAnnotation.displacement = CGPointMake(CPTFloat(0), CPTFloat(20));
    
    // 把拐点注释添加到绘图区域中
    [plotArea addAnnotation:symbolTextAnnotation];
}
*/


#pragma mark 创建平面图，柱状图
- (void)createPlots2
{
    dataSource1 = [[NSMutableArray alloc]init];
    dataSource2 = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 10; i++) {
        [dataSource1 addObject:[NSNumber numberWithInt:rand()%20]];
        [dataSource2 addObject:[NSNumber numberWithInt:rand()%20]];
    }
    
    
    // 动画
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    
    // 第一个柱状图
    {
        // 第一个参数指定渐变色的开始颜色，默认结束颜色为黑色，第二个参数指定是否绘制水平柱子。
        CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
        
        // 添加图形到绘图空间
        [hostView.hostedGraph addPlot:barPlot];
        
        // 设置数据源 实现CPTBarPlotDataSource委托
        barPlot.dataSource = self;
        
        // 委托事件
        barPlot.delegate = self;
        
        // 标识,根据此@ref identifier来区分不同的plot,也是图例显示名称,
        barPlot.identifier = @"BarPlot1" ;
        
        // 基线值设置
        {
            // NO：@ref baseValue的设置对所有的柱子生效，YES：需要通过数据源设置每一个柱子的@ref baseValue  默认值：NO
            barPlot.barBasesVary = YES;
            // 柱子的基线值 @ref barBasesVary为NO时才会生效，否则需要在数据源中设置枚举为CPTBarPlotFieldBarBase的一个适当的值
            // 柱子都是从此基线值处开始绘制，相当于原点
            barPlot.baseValue = @(1);
        }
        
        // 柱子设置，柱子的实际宽度为@ref barWidth * barWidthScale
        {
            // 宽度计算方式 NO：1主刻度长度＝1宽度  YES：1像素＝1宽度  默认值：NO
            barPlot.barWidthsAreInViewCoordinates = YES;
            // 宽度
            barPlot.barWidth = @(20);
            // 柱宽的缩放系数
//            barPlot.barWidthScale = CPTFloat(1);
            // 开始绘制的偏移位置，默认为0，表示柱子的中间位置在刻度线上
            barPlot.barOffset = @(-10) ;
            // 尖端的圆角值 用的是像素单位
            barPlot.barCornerRadius = CPTFloat(0);
            // 底部的圆角值，基线值的圆角 用的是像素单位
            barPlot.barBaseCornerRadius = CPTFloat(0);
            // 外框的线型 默认：黑色 宽度1
            barPlot.lineStyle = nil;
            // 填充色
            CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor greenColor] endingColor:[CPTColor clearColor]];
            CPTFill *fill = [CPTFill fillWithGradient:gradient];
            barPlot.fill = fill;
        }
        
        // 数据标签设置，如果想用自定义的标签，则需要数据源方法：dataLabelForPlot:recordIndex:
        {
            // 偏移量设置
            barPlot.labelOffset = 15;
            // 数据标签样式
            CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
            labelTextStyle.color = [CPTColor magentaColor];
            barPlot.labelTextStyle = labelTextStyle;
        }
        
        // 添加动画
        barPlot.opacity = 0.f;
        [barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
        
    }
    
    // 第2个柱状图
    {
        // 第一个参数指定渐变色的开始颜色，默认结束颜色为黑色，第二个参数指定是否绘制水平柱子。
        CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
        
        // 添加图形到绘图空间
        [hostView.hostedGraph addPlot:barPlot];
        
        // 设置数据源 实现CPTBarPlotDataSource委托
        barPlot.dataSource = self;
        
        // 标识,根据此@ref identifier来区分不同的plot,也是图例显示名称,
        barPlot.identifier = @"BarPlot2" ;
        
        // 基线值设置
        {
            // NO：@ref baseValue的设置对所有的柱子生效，YES：需要通过数据源设置每一个柱子的@ref baseValue  默认值：NO
            barPlot.barBasesVary = NO;
            // 柱子的基线值 @ref barBasesVary为NO时才会生效，否则需要在数据源中设置枚举为CPTBarPlotFieldBarBase的一个适当的值
            // 大于这个值以上的点，柱子只从这个点开始画。小于此值的点，则是反向绘制的，即从基线值向下画，一直画到到数据点。
            barPlot.baseValue = @(0);
        }
        
        // 柱子设置
        {
            // 宽度计算方式 NO：1主刻度长度＝1宽度  YES：1像素＝1宽度  默认值：NO
            barPlot.barWidthsAreInViewCoordinates = NO;
            // 宽度
            barPlot.barWidth = @(0.4);
            // 柱宽的缩放系数
//            barPlot.barWidthScale = CPTFloat(1);
            // 开始绘制的偏移位置
            barPlot.barOffset = @(0.2) ;
            // 尖端的圆角值 用的是像素单位
            barPlot.barCornerRadius = CPTFloat(0);
            // 底部的圆角值，基线值的圆角 用的是像素单位
            barPlot.barBaseCornerRadius = CPTFloat(0);
            // 外框的线型 默认：黑色 宽度1
            barPlot.lineStyle = nil;
            // 填充色
            CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
            CPTFill *fill = [CPTFill fillWithGradient:gradient];
            barPlot.fill = fill;
        }
        
        // 数据标签设置，如果想用自定义的标签，则需要数据源方法：dataLabelForPlot:recordIndex:
        {
            // 偏移量设置
            barPlot.labelOffset = 15;
            // 数据标签样式
            CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
            labelTextStyle.color = [CPTColor magentaColor];
            barPlot.labelTextStyle = labelTextStyle;
        }
        
        // 添加动画
        barPlot.opacity = 0.f;
        [barPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    }
}

/*
#pragma mark -CPTBarPlot的数据源方法CPTBarPlotDataSource
// 询问有多少个数据
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger count = 0;
    if ([plot.identifier isEqual:@"BarPlot1"]) {
        count = dataSource1.count;
    }else {
        count = dataSource2.count;
    }
    
    return count;
}

#pragma mark 询问一个个数据值 fieldEnum:一个轴类型，是一个枚举  idx：坐标轴索引
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *num = nil;
    
    if ([plot.identifier isEqual:@"BarPlot1"]) {
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:    // 柱子所处位置 如果是垂直柱子，即为x轴的位置
            {
                num = @(idx + 1);
            }
                break;
            case CPTBarPlotFieldBarTip:         // 柱子尖端位置（柱子的长度） 如果是垂直柱子，即为y轴的位置
            {
                num = dataSource1[idx];
            }
                break;
            case CPTBarPlotFieldBarBase:        // 柱子的基线值 只有@ref barBasesVary = YES 时才会用到该枚举
            {
                num = @(0);
            }
                break;
            default:
                break;
        }
    }else if ([plot.identifier isEqual:@"BarPlot2"]){
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:    // 柱子所处位置 如果是垂直柱子，即为x轴的位置
            {
                num = @(idx + 1);
            }
                break;
            case CPTBarPlotFieldBarTip:         // 柱子末端位置（柱子的长度） 如果是垂直柱子，即为y轴的位置
            {
                num = dataSource2[idx];
            }
                break;
            case CPTBarPlotFieldBarBase:        // 柱子的基线值 只有@ref barBasesVary = YES 时才会用到该枚举
            {
                
            }
                break;
            default:
                break;
        }
    }
    return num;
}

#pragma mark 添加数据标签
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    if ([plot.identifier isEqual:@"BarPlot1"]) {
        // 数据标签样式
        CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
        labelTextStyle.color = [CPTColor magentaColor];
        
        // 定义一个 TextLayer
        CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%d",[dataSource1[idx] intValue]] style:labelTextStyle];
        
        return newLayer;
    }else {
        // 数据标签样式
        CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
        labelTextStyle.color = [CPTColor magentaColor];
        
        // 定义一个 TextLayer
        CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%d",[dataSource2[idx] intValue]] style:labelTextStyle];
        
        return newLayer;
    }
}

#pragma mark 设置图例名称 返回每一个柱子的图例名称 返回nil则不显示该索引下的图例
- (NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    NSString *legendTitle = nil;
    if ([barPlot.identifier isEqual:@"BarPlot1"]) {
        legendTitle = [NSString stringWithFormat:@"柱状图1-%ld",idx];
    }else {
        legendTitle = [NSString stringWithFormat:@"柱状图2-%ld",idx];
    }
    return legendTitle;
}

#pragma mark -CPTBarPlot的delegate方法
// 选中某个柱子的操作 添加注释
- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(UIEvent *)event
{
    // 移除注释
    CPTPlotArea *plotArea = hostView.hostedGraph.plotAreaFrame.plotArea;
    [plotArea removeAllAnnotations];
    
    // 创建注释，plotSpace：绘图空间 anchorPlotPoint：坐标点
    CPTPlotSpaceAnnotation *barTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:hostView.hostedGraph.defaultPlotSpace anchorPlotPoint:@[@(idx + 1),dataSource1[idx]]];
    
    // 文本样式
    CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
    annotationTextStyle.color = [CPTColor redColor];
    annotationTextStyle.fontSize = 17.0f;
    annotationTextStyle.fontName = @"Helvetica-Bold";
    // 显示的字符串
    NSString *randomValue = [NSString stringWithFormat:@"柱状图\n随即值：%@ \n", [dataSource1[idx] stringValue]];
    // 注释内容
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:randomValue style:annotationTextStyle];
    // 添加注释内容
    barTextAnnotation.contentLayer = textLayer;
    
    // 注释位置
    barTextAnnotation.displacement = CGPointMake(CPTFloat(0), CPTFloat(20));
    
    // 把拐点注释添加到绘图区域中
    [plotArea addAnnotation:barTextAnnotation];
}
*/


#pragma mark -init pie data
- (void)initPieData{
    
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 6; i++) {
        [dataSource addObject:@(arc4random()%10)];
    }
    for (int i = 0; i < 6; i++) {
        CGFloat scale = [dataSource[i] floatValue] / [[dataSource valueForKeyPath:@"@sum.self"] floatValue];
        [dataSource replaceObjectAtIndex:i withObject:@(scale)];
    }
    self.dataSource = dataSource;
    _sliceFills = @[[CPTColor greenColor],
                    [CPTColor lightGrayColor],
                    [CPTColor cyanColor],
                    [CPTColor yellowColor],
                    [CPTColor magentaColor],
                    [CPTColor purpleColor]];
}

#pragma mark 创建平面图，饼图
- (void)createPlots3
{
    
    // 由于在绘制饼状图的过程中是不需要坐标轴的，所以我们要去除坐标系，如果不去除坐标系，我们将会看到，坐标轴的黑色轴线。
    // 饼图不需要显示坐标轴
    hostView.hostedGraph.axisSet = nil;
    
    // 饼图初始化
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    
    // 添加图形到绘图空间
    [hostView.hostedGraph addPlot:piePlot];
    
    // 标识,根据此@ref identifier来区分不同的plot
    piePlot.identifier = @"PieChart";
    
    // 指定饼图的数据源。数据源必须实现 CPTPieDataSource 委托
    piePlot.dataSource = self;
    
    // 指定饼图的事件委托。委托必须实现 CPTPieChartDelegate 中定义的方法
    piePlot.delegate = self;
    
    // 饼图设置
    {
        // 饼图的半径
        piePlot.pieRadius = CPTFloat(200);
        // 内部圆
        piePlot.pieInnerRadius = CPTFloat(10);
        // 开始绘制的位置，第1片扇形的起始角度，默认是PI/2
        piePlot.startAngle = 0;
        // 绘制的方向：正时针、反时针
        piePlot.sliceDirection = CPTPieDirectionClockwise;
        // 边线的样式
        piePlot.borderLineStyle= nil;
        // 饼图的重心（旋转时以此为中心）坐标（x,y），以相对于饼图直径的比例表示（0－1）之间。默认和圆心重叠（0.5,0.5）
        piePlot.centerAnchor = CGPointMake(0.5, 0.5);
        
        // 覆盖色
        //CPTGradient *gradient = [[CPTGradient alloc]init];
        // 剃度效果
        //gradient.gradientType = CPTGradientTypeRadial;
        // 设置颜色变换的颜色和位置
        //gradient = [gradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.1] atPosition:0.9];
        //gradient = [gradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.5] atPosition:0.5];
        //gradient = [gradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
        //piePlot.overlayFill = [CPTFill fillWithGradient:gradient];
    }
    
    // 扇形上的标签文字设置
    {
        // 是否顺着扇形的方向
        piePlot.labelRotationRelativeToRadius = YES;
        // 偏移量
        piePlot.labelOffset = -(piePlot.pieRadius - piePlot.pieInnerRadius) * 0.6;
    }
    
    // 添加动画
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    piePlot.opacity = 0.f;
    [piePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    
    // 由于在饼状图中的图例就是每一个扇形，所以我们只可以用以下的方法创建索引。
    CPTLegend *legend = [CPTLegend legendWithPlots:hostView.hostedGraph.allPlots];
    CPTLegend *legend2 = [CPTLegend legendWithGraph:hostView.hostedGraph];
    
    
    // 获取某个索引下扇形的中间的弧度
    CGFloat medianAngle = [piePlot medianAngleForPieSliceIndex:0];
    // 计算某个弧度下的扇形索引
    NSInteger sliceIndex = [piePlot pieSliceIndexAtAngle:CPTFloat(0)];
    
    NSLog(@"========== 扇形的中间的弧度 medianAngle = %f",medianAngle);
    NSLog(@"========== 扇形索引  sliceIndex = %ld",sliceIndex);
    
}


#pragma mark -CPTPiePlotDataSource数据源方法
// 询问有多少个扇形
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.dataSource.count;
}

// 询问扇形的数据值
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *num = self.dataSource[idx];
    return num;
}

// 扇形颜色
- (CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    CPTFill *color = [CPTFill fillWithColor:_sliceFills[idx]];
    return color;
}

// 扇形名称
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"饼图-%d",(int)(idx + 1)]];
    
    CPTMutableTextStyle *textStyle =[label.textStyle mutableCopy];
    textStyle.color = [CPTColor blackColor];
    textStyle.fontSize = CPTFloat(17);
    
    label.textStyle = textStyle;
    
    return label;
}

// 剥离扇形
- (CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    return idx == 2 ? 10 : 0;
}

// 图例名称 返回nil则不显示该索引下的图例
- (NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    NSString *legendTitle = [NSString stringWithFormat:@"饼图-%d",(int)(idx + 1)];
    return legendTitle;
}

#pragma mark -CPTPiePlotDelegate委托方法
// 选中扇形的操作
- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(UIEvent *)event
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
