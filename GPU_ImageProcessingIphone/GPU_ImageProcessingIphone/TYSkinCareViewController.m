//
//  TYSkinCareViewController.m
//  GPU_ImageProcessingIphone
//
//  Created by 汤义 on 2018/7/5.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "TYSkinCareViewController.h"
#import "GPUImage.h"

@interface TYSkinCareViewController ()<GPUImageMovieDelegate,GPUImageMovieWriterDelegate,GPUImageVideoCameraDelegate>
@property(nonatomic, strong) GPUImageVideoCamera *videocamera;//摄像
@property(nonatomic, strong) GPUImageStillCamera *stillCamera;//拍照
@property(nonatomic, strong) GPUImageMovie *movie;

@property(nonatomic, strong) GPUImageFilterGroup *_filterGroup;//滤镜组
@end

@implementation TYSkinCareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self liveVideo];
//    [self imageFilter];//手动操作滤镜，可以添加多个滤镜
//    [self SingleimageFilter];//给图片添加单个滤镜，自动添加滤镜
//    [self videoAndStore];//播放录像滤镜并存储
//    [self addManyFilter];//添加滤镜组
    [self GPUImageAmatorkaFilterTest];//以上三种特殊的滤镜-----左边Resources文件夹中是图片
    [self writeToFile];
}

- (void)liveVideo {
    //第一个参数：相机捕获视屏或图片的质量.有一次啊选项
    /*AVCaptureSessionPresetPhoto
     AVCaptureSessionPresetHigh
     AVCaptureSessionPresetMedium
     AVCaptureSessionPresetLow
     AVCaptureSessionPreset320x240
     AVCaptureSessionPreset352x288
     AVCaptureSessionPreset640x480
     AVCaptureSessionPreset960x540
     AVCaptureSessionPreset1280x720
     AVCaptureSessionPreset1920x1080
     AVCaptureSessionPreset3840x2160
     AVCaptureSessionPresetiFrame960x540
     AVCaptureSessionPresetiFrame1280x720
     */
    //第二个参数相机的位置
    /*typedef NS_ENUM(NSInteger, AVCaptureDevicePosition) {
     AVCaptureDevicePositionUnspecified         = 0,
     AVCaptureDevicePositionBack                = 1,
     AVCaptureDevicePositionFront               = 2
     } NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
     */
    
    GPUImageVideoCamera *videocamera=[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videocamera.delegate = self;
    self.videocamera=videocamera;//这个相机一定要用一个强引用，防止销毁
    //设置下面这个后，倒转手机后，画面也会跟着倒过来
    videocamera.horizontallyMirrorFrontFacingCamera =NO;
    videocamera.horizontallyMirrorRearFacingCamera =NO;
    /*捕获画面的方向设置，
     typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
     UIInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,
     UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
     UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
     UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
     UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
     } __TVOS_PROHIBITED;
     */
    videocamera.outputImageOrientation =UIInterfaceOrientationPortrait;
    
    //创建滤镜
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    
    
    //相机添加滤镜对象
    
    [videocamera addTarget:filter];
    //创建滤镜显示的view
    GPUImageView *filterView=[[GPUImageView alloc] initWithFrame:CGRectMake(10,10, 300,300)];
    [self.view addSubview:filterView];//添加滤镜view到view上
    
    //如果要用控制器本身的view作滤镜显示view要把控制器的view强转成GPUIMageView，如果用的是storyBoard，storyboard中的相应地view类型名要改成GPUIMageview
    //    GPUImageView *filterView = (GPUImageView *)self.view;
    
    //滤镜对象添加要显示的view;
    [filter addTarget:filterView];
    //相机开始捕获图像画面
    [videocamera startCameraCapture];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    NSLog(@"摄像头获取的数据");
}

//手动操作滤镜，可以添加多个滤镜
- (void)imageFilter{
    UIImage *inputImage = [UIImage imageNamed:@"11"];
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];//告诉滤镜以后用它，节省内存
    [stillImageSource processImage];//滤镜渲染
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];//从当前滤镜缓冲区获取滤镜图片
    
    UIImageView *imagev=[[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
    imagev.frame=self.view.frame;
    [self.view addSubview:imagev];
}

//给图片添加单个滤镜，自动添加滤镜
-(void)SingleimageFilter{
    UIImage *inputImage = [UIImage imageNamed:@"11"];
    GPUImageSepiaFilter *stillImageFilter2 = [[GPUImageSepiaFilter alloc] init];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter2 imageByFilteringImage:inputImage];
    
    
    UIImageView *imagev=[[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
    imagev.frame=self.view.frame;
    [self.view addSubview:imagev];
    
}


//播放录像滤镜并存储(我这里使用的是自定义的GPUImageView后视频出现马赛克)
-(void)videoAndStore{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video"ofType:@"mp4"];
    
    NSURL *url=[NSURL fileURLWithPath:path];
    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:url];
    //    self.movie=movie;
    movie.shouldRepeat =YES;//控制视频是否循环播放。
    movie.playAtActualSpeed = YES;//控制GPUImageView预览视频时的速度是否要保持真实的速度。如果设为NO，则会将视频的所有帧无间隔渲染，导致速度非常快。设为YES，则会根据视频本身时长计算出每帧的时间间隔，然后每渲染一帧，就sleep一个时间间隔，从而达到正常的播放速度。
    //    movie.playSound = YES;
    movie.delegate =self;
    
    GPUImagePixellateFilter *filter = [[GPUImagePixellateFilter alloc] init];//胶片效果
    [movie addTarget:filter];
    
    //创建滤镜显示的view
    GPUImageView *filterView=[[GPUImageView alloc] initWithFrame:CGRectMake(10,10, 300,300)];
    [self.view addSubview:filterView];//添加滤镜view到view上
    
    [filter addTarget:filterView];
    
    [movie startProcessing];
    
    
}



//添加滤镜组
-(void)addManyFilter{
    
    // 图片输入源
    UIImage* _inputImage = [UIImage imageNamed:@"11"];
    
    // 初始化 picture
    GPUImagePicture* _picture    = [[GPUImagePicture alloc] initWithImage:_inputImage smoothlyScaleOutput:YES];
    
    //    // 初始化 imageView用于显示滤镜
    //   GPUImageView* _imageView  = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    //    [self.view addSubview:_imageView];
    
    // 初始化 filterGroup
    GPUImageFilterGroup* _filterGroup = [[GPUImageFilterGroup alloc] init];
    self._filterGroup=_filterGroup;
    [_picture addTarget:_filterGroup];
    
    
    // 添加 filter
    /**
     原理：步骤--
     1. filterGroup(addFilter) 滤镜组添加每个滤镜。
     2. 按添加顺序（可自行调整）前一个filter(addTarget)添加后一个filter
     3. filterGroup.initialFilters = @[第一个filter]];---这一步是在组里面从第一个开始处理滤镜。
     4. filterGroup.terminalFilter = 最后一个filter;//设置最后一个滤镜，即最上面的滤镜。
     
     
     */
    GPUImageRGBFilter *filter1         = [[GPUImageRGBFilter alloc] init];
    GPUImageToonFilter *filter2        = [[GPUImageToonFilter alloc] init];
    GPUImageColorInvertFilter *filter3 = [[GPUImageColorInvertFilter alloc] init];
    GPUImageSepiaFilter       *filter4 = [[GPUImageSepiaFilter alloc] init];
    [self addGPUImageFilter:filter1];
    [self addGPUImageFilter:filter2];
    [self addGPUImageFilter:filter3];
    [self addGPUImageFilter:filter4];
    
    // 处理图片
    [_picture processImage];
    [_filterGroup useNextFrameForImageCapture];
    
    UIImage *imag= [_filterGroup imageFromCurrentFramebuffer];
    UIImageView *imageV=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageV.image = imag;
    [self.view addSubview:imageV];
}

//添加到滤镜组
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [self._filterGroup addFilter:filter];//滤镜组添加滤镜
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;//新的结尾滤镜
    
    NSInteger count =self._filterGroup.filterCount;//滤镜组里面的滤镜数量
    
    if (count ==1)
    {
        self._filterGroup.initialFilters =@[newTerminalFilter];//在组里面处理滤镜
        self._filterGroup.terminalFilter = newTerminalFilter;//最后一个滤镜，即最上面的滤镜
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    =self._filterGroup.terminalFilter;
        NSArray *initialFilters                          =self._filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];//逐层吧新的滤镜加到组里最上面
        self._filterGroup.initialFilters =@[initialFilters[0]];
        
        self._filterGroup.terminalFilter = newTerminalFilter;
    }
}


////自定义滤镜----左边的shad.fsh中就是自定义的滤镜
//自定义滤镜--------给图片添加单个滤镜，自动添加滤镜
-(void)AutoDefineSingleimageFilter{
    UIImage *inputImage = [UIImage imageNamed:@"11"];
    
    GPUImageFilter *stillImageFilter2=[[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"shad"];//shad是自定义的滤镜shad.fsh
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter2 imageByFilteringImage:inputImage];
    
    
    UIImageView *imagev=[[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
    imagev.frame=self.view.frame;
    [self.view addSubview:imagev];
    
}




/**滤镜的制作：加一层调制好的调色调光的模板,GUPImage里有一张标准图lookup.png;
 设计师用 Photoshop调出来的色彩效果输出在了这种「格子图」上，在 App里通过解析「格子图」得到了色彩的变化规则，然后把这个规则应用在了图片/视频上，这种规则就是一种滤镜的算法。注意，这里只能进行颜色上的调整（曲线，色彩平衡等），其他效果调整也只限于利用图层间混合模式的更改，例如可做暗角、漏光等效果。
 
 GPUImage中自带三种这样的滤镜GPUImageAmatorkaFilter、GPUImageMissEtikateFilter、GPUImageSoftEleganceFilter.
 使用这三种滤镜需要导入左边sources中相应的图片，lookup.png是基本图，其他的图都是在lookup.png的基础上设计出来的
 
 根据这样的方法，把标准图给设计师，设计师添加完产品需要的调色动作，把新图导入程序，调用GPUImage中的方法，就得到了想要的滤镜。
 */
//以上三种特殊的滤镜-----左边Resources文件夹中是图片

-(void)GPUImageAmatorkaFilterTest{
    
    UIImage *inputImage = [UIImage imageNamed:@"11"];
    
    //    GPUImageAmatorkaFilter *stillImageFilter2=[[GPUImageAmatorkaFilter alloc]init];//需要导入左侧sources中lookup_amatorka.png图片，才生效
    
    //    GPUImageMissEtikateFilter *stillImageFilter2=[[GPUImageMissEtikateFilter alloc]init];//需要导入左侧sources中lookup_miss_etikate.png图片，才生效
    
    GPUImageSoftEleganceFilter *stillImageFilter2=[[GPUImageSoftEleganceFilter alloc] init];//需要导入左侧sources中lookup_soft_elegance_1.png和lookup_soft_elegance_2.png图片，才生效
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter2 imageByFilteringImage:inputImage];
    
    
    UIImageView *imagev=[[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
    imagev.frame=CGRectMake(0, 64, 300, 300);
    [self.view addSubview:imagev];
    
    
}

//渲染后存储到本地
-(void)writeToFile{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    NSURL *sampleURL=[NSURL fileURLWithPath:path];
    GPUImageMovie* movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    GPUImagePixellateFilter* pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    
    [movieFile addTarget:pixellateFilter];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    GPUImageMovieWriter*  movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    [pixellateFilter addTarget:movieWriter];
    
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];//允许渲染后保存
    
    [movieWriter startRecording];
    [movieFile startProcessing];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
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
