//
//  CameraOverlayView.m
//  VKPhotoEditor
//
//  Created by asya on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView {
    IBOutlet UILabel *flashLabel;
}

@synthesize picker;


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    [picker takePicture];
}

- (IBAction)cancel:(id)sender
{
    [picker.delegate imagePickerControllerDidCancel:picker];
}

- (IBAction)filters:(id)sender
{
    
}

- (IBAction)flash:(id)sender
{
    
}

- (IBAction)blur:(id)sender
{
    
}

- (IBAction)rotateCamera:(id)sender
{
    picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
}

@end
