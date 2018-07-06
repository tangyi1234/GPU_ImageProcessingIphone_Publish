//
//  TYTestPerformanceViewController.m
//  GPU_ImageProcessingIphone
//
//  Created by 汤义 on 2018/7/6.
//  Copyright © 2018年 汤义. All rights reserved.
// https://blog.csdn.net/xoxo_x/article/details/52695032

#import "TYTestPerformanceViewController.h"

@interface TYTestPerformanceViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CIContext *coreImageContext;
@property (nonatomic, assign) int processingTimeForCPURoutine;
@property (nonatomic, assign) int processingTimeForCoreImageRoutine;
@property (nonatomic, assign) int processingTimeForGPUImageRoutine;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation TYTestPerformanceViewController
//- (UILabel *){
//    if (!_nameLbl) {
//        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(w - 160, 0, 160, 44)];
//        _nameLbl.textAlignment = NSTextAlignmentRight;
//        _nameLbl.textColor = [UIColor greenColor];
//        _nameLbl.backgroundColor = [UIColor redColor];
//    }
//    return _nameLbl;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, h - 300, w, 300)];
    imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_imageView = imageView];
    
    _array = [NSArray arrayWithObjects:@"CPU",@"CoreImage",@"GPUImage", nil];
    [self initTableView];
    [self addTestPerformance];
    
}

- (void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, w, 200) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(w - 160, 0, 160, 44)];
        _nameLbl.textAlignment = NSTextAlignmentRight;
        _nameLbl.textColor = [UIColor greenColor];
        _nameLbl.backgroundColor = [UIColor redColor];
        [cell addSubview:self.nameLbl];
    }
    cell.textLabel.text = _array[indexPath.row];
    int data = 0;
    switch (indexPath.row) {
        case 0:
            data = _processingTimeForCPURoutine;
            break;
        case 1:
            data = _processingTimeForCoreImageRoutine;
            break;
        case 2:
            data = _processingTimeForGPUImageRoutine;
            break;
            
        default:
            break;
    }
    _nameLbl.text = [NSString stringWithFormat:@"%d",data];
    return cell;
}

- (void)addTestPerformance {
    UIImage *inputImage = [UIImage imageNamed:@"11"];
    
    UIImage *imageFilteredUsingCPURoutine = [self imageProcessedOnCPU:inputImage];
    _imageView.image = imageFilteredUsingCPURoutine;
    [self writeImage:imageFilteredUsingCPURoutine toFile:@"29.png"];


    // Pulling creating the Core Image context out of the benchmarking area, because it can only be created once and reused
    //创建 Core Image 上下文 ,
    if (_coreImageContext == nil)
    {
        _coreImageContext = [CIContext contextWithOptions:nil];
    }

    UIImage *imageFilteredUsingCoreImageRoutine = [self imageProcessedUsingCoreImage:inputImage];
    _imageView.image = imageFilteredUsingCoreImageRoutine;
    [self writeImage:imageFilteredUsingCoreImageRoutine toFile:@"29.png"];

    UIImage *imageFilteredUsingGPUImageRoutine = [self imageProcessedUsingGPUImage:inputImage];
    _imageView.image = imageFilteredUsingGPUImageRoutine;
    [self writeImage:imageFilteredUsingGPUImageRoutine toFile:@"29.png"];

    [self.tableView reloadData];
}

- (void)writeImage:(UIImage *)imageToWrite toFile:(NSString *)fileName;
{
    if (imageToWrite == nil)
    {
        return;
    }
    
    NSData *dataForPNGFile = UIImagePNGRepresentation(imageToWrite);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"documentsDirectory ,%@",documentsDirectory);
    NSError *error = nil;
    if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:fileName] options:NSAtomicWrite error:&error])
    {
        return;
    }
}

//- (UIImage *)imageProcessedOnCPU:(UIImage *)imageToProcess;
//{
//    // Drawn from Rahul Vyas' answer on Stack Overflow at http://stackoverflow.com/a/4211729/19679
//
//    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
//
//    CGImageRef cgImage = [imageToProcess CGImage];
//    CGImageRetain(cgImage);
//    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
//    CFDataRef bitmapData = CGDataProviderCopyData(provider);
//    UInt8* data = (UInt8*)CFDataGetBytePtr(bitmapData);
//    CGImageRelease(cgImage);
//
//    int width = imageToProcess.size.width;
//    int height = imageToProcess.size.height;
//    NSInteger myDataLength = width * height * 4;
//
//
//    for (int i = 0; i < myDataLength; i+=4)
//    {
//        UInt8 r_pixel = data[i];
//        UInt8 g_pixel = data[i+1];
//        UInt8 b_pixel = data[i+2];
//
//        int outputRed = (r_pixel * .393) + (g_pixel *.769) + (b_pixel * .189);
//        int outputGreen = (r_pixel * .349) + (g_pixel *.686) + (b_pixel * .168);
//        int outputBlue = (r_pixel * .272) + (g_pixel *.534) + (b_pixel * .131);
//
//        if(outputRed>255)outputRed=255;
//        if(outputGreen>255)outputGreen=255;
//        if(outputBlue>255)outputBlue=255;
//
//
//        data[i] = outputRed;
//        data[i+1] = outputGreen;
//        data[i+2] = outputBlue;
//    }
//
//    CGDataProviderRef provider2 = CGDataProviderCreateWithData(NULL, data, myDataLength, NULL);
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    int bytesPerRow = 4 * width;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
//    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider2, NULL, NO, renderingIntent);
//
//    CGColorSpaceRelease(colorSpaceRef);
//    CGDataProviderRelease(provider2);
//    CFRelease(bitmapData);
//
//    UIImage *sepiaImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//
//    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
//    _processingTimeForCPURoutine = elapsedTime * 1000.0;
//    return sepiaImage;
//}

- (UIImage *)imageProcessedOnCPU:(UIImage *)imageToProcess{
//    if (!data) {
//        return nil;
//    }
    
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
//    //获取source
//    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
//    //解码
//    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CGImageRef imageRef = imageToProcess.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(dataRef);
    
//    NSUInteger  x, y;
//    //遍历出每一个像素
//    for (y = 0; y < height; y++) {
//        for (x = 0; x < width; x++) {
//            UInt8 *tmp;
//            //将其转换为RGB格式
//            tmp = buffer + y * bytesPerRow + x * 4;
//
//            UInt8 red,green,blue;
//            red = *(tmp + 0);
//            green = *(tmp + 1);
//            blue = *(tmp + 2);
//
//        }
//    }
    
    NSInteger myDataLength = width * height * 4;
    
    
    for (int i = 0; i < myDataLength; i+=4)
    {
        UInt8 r_pixel = buffer[i];
        UInt8 g_pixel = buffer[i+1];
        UInt8 b_pixel = buffer[i+2];
        
        int outputRed = (r_pixel * .393) + (g_pixel *.769) + (b_pixel * .189);
        int outputGreen = (r_pixel * .349) + (g_pixel *.686) + (b_pixel * .168);
        int outputBlue = (r_pixel * .272) + (g_pixel *.534) + (b_pixel * .131);
        
        if(outputRed>255)outputRed=255;
        if(outputGreen>255)outputGreen=255;
        if(outputBlue>255)outputBlue=255;
        
        
        buffer[i] = outputRed;
        buffer[i+1] = outputGreen;
        buffer[i+2] = outputBlue;
    }
    
    
    CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(dataRef));
    
    CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    size_t width_w = width;
    
    size_t height_h = height;
    /*
     sizt_t是定义的一个可移植性的单位，在64位机器中为8字节，32位位4字节。
     width：图片宽度像素
     height：图片高度像素
     bitsPerComponent：每个颜色的比特数，例如在rgba-32模式下为8
     bitsPerPixel：每个像素的总比特数
     bytesPerRow：每一行占用的字节数，注意这里的单位是字节
     space：颜色空间模式，例如const CFStringRef kCGColorSpaceGenericRGB 这个函数可以返回一个颜色空间对象。
     bitmapInfo：位图像素布局，这是个枚举
     provider：数据源提供者
     decode[]：解码渲染数组
     shouldInterpolate：是否抗锯齿
     intent：图片相关参数
     */
    
    CGImageRef effectedCgImage = CGImageCreate(
                                               width_w, height_h,
                                               bitsPerComponent, bitsPerPixel, bytesPerRow,
                                               colorSpace, bitmapInfo, effectedDataProvider,
                                               NULL, shouldInterpolate, intent);
    UIImage *outImage = [UIImage imageWithCGImage:effectedCgImage];
    
    if (!effectedCgImage) {
        return nil;
    }
    
    CGImageRelease(effectedCgImage);
    
    CFRelease(effectedDataProvider);
    
    CFRelease(effectedData);
    
    CFRelease(dataRef);
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    _processingTimeForCPURoutine = elapsedTime * 1000.0;
    return outImage;
}

- (UIImage *)imageProcessedUsingCoreImage:(UIImage *)imageToProcess;
{
    /*
     NSArray *filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
     
     NSLog(@"Built in filters");
     for (NSString *currentFilterName in filterNames)
     {
     NSLog(@"%@", currentFilterName);
     }
     */
    
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    
    CIImage *inputImage = [[CIImage alloc] initWithCGImage:imageToProcess.CGImage];
    
    CIFilter *sepiaTone = [CIFilter filterWithName:@"CISepiaTone"
                                     keysAndValues: kCIInputImageKey, inputImage,
                           @"inputIntensity", [NSNumber numberWithFloat:1.0], nil];
    
    CIImage *result = [sepiaTone outputImage];
    
    //    UIImage *resultImage = [UIImage imageWithCIImage:result]; // This gives a nil image, because it doesn't render, unless I'm doing something wrong
    
    CGImageRef resultRef = [_coreImageContext createCGImage:result fromRect:CGRectMake(0, 0, imageToProcess.size.width, imageToProcess.size.height)];
    UIImage *resultImage = [UIImage imageWithCGImage:resultRef];
    CGImageRelease(resultRef);
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    _processingTimeForCoreImageRoutine = elapsedTime * 1000.0;
    
    return resultImage;
}

- (UIImage *)imageProcessedUsingGPUImage:(UIImage *)imageToProcess;
{
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:imageToProcess];
    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    _processingTimeForGPUImageRoutine = elapsedTime * 1000.0;
    
    return currentFilteredVideoFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
