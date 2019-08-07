//
//  ChoosePhotoViewController.m
//  Pitch
//
//  Created by mariobaxter on 8/7/19.
//  Copyright © 2019 PitchFBU. All rights reserved.
//

#import "ChoosePhotoViewController.h"
#import "AVFoundation/AVFoundation.h"

@interface ChoosePhotoViewController () <AVCapturePhotoCaptureDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
//@property (weak, nonatomic) IBOutlet UIView *cameraView;
//@property (weak, nonatomic) IBOutlet UIImageView *lastImageView;
//@property (weak, nonatomic) IBOutlet UIButton *selectImageButton;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ChoosePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.cameraButton.layer.cornerRadius = self.cameraButton.frame.size.width/2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.session = [AVCaptureSession new];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        NSLog(@"Unable to access back camera!");
        return;
    }
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!error) {
        self.stillImageOutput = [AVCapturePhotoOutput new];
        if ([self.session canAddInput:input] && [self.session canAddOutput:self.stillImageOutput]) {
            
            [self.session addInput:input];
            [self.session addOutput:self.stillImageOutput];
            [self setupLivePreview];
        }
    }
    else {
        NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
    }
    dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        [self.session startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoPreviewLayer.frame = self.cameraView.bounds;
        });
    });
}

- (void)setupLivePreview {
    
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    if (self.videoPreviewLayer) {
        
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.cameraView.layer addSublayer:self.videoPreviewLayer];
        
        //Step12
    }
}

- (IBAction)didTakePhoto:(id)sender {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (IBAction)selectPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    
    NSData *imageData = photo.fileDataRepresentation;
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        // Add the image to captureImageView here...
        self.lastImageView.image = image;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    [self.delegate sendImageBack:self.lastImageView.image];
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
