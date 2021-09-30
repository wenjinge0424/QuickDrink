//
//  CustomerRegistPhotoController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerRegistPhotoController.h"
#import "Util.h"
#import "DBCong.h"

@interface CustomerRegistPhotoController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage * m_selectedImage;
}
@property (strong, nonatomic) IBOutlet UIImageView *img_photo;
@property (nonatomic, retain) UIImagePickerController * picker;


@end

@implementation CustomerRegistPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.img_photo.layer.cornerRadius = self.img_photo.frame.size.width/2;
    
    DBUsers * defaultuser = [[StackMemory createInstance] stack_signInItem];
    if(defaultuser.isSocialUser == YES && defaultuser.profile_image){
        m_selectedImage = defaultuser.profile_image;
        [self.img_photo setImage:m_selectedImage];
    }
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNext:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if(!m_selectedImage){
        [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){}];
    }else{
        UIImage *profileImage = [Util getUploadingImageFromImage:m_selectedImage];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers addPhotoInfoTo:[[StackMemory createInstance] stack_signInItem] :imageData sucessBlock:^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:@"gotoCustomPayment" sender:self];
        } failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error." finish:^(void){}];
        }];
    }
}
- (IBAction)onChoosePhoto:(id)sender {
    [Util checkGalleryPermission:^(BOOL res){
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:nil];
    }failBlock:^(BOOL res){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertTitle:self title:@"" message:@"Gallery setting is Turned off." finish:^(void){}];
        });
        
    }];
}
- (IBAction)onTakePhoto:(id)sender {
    
    [Util checkCameraPermission:^(BOOL res){
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.picker animated:YES completion:nil];
        }else{
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.picker animated:YES completion:nil];
        }
    } failBlock:^(BOOL res){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertTitle:self title:@"" message:@"Camera setting is Turned off." finish:^(void){}];
        });
        
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    m_selectedImage = chosenImage;
    [self.img_photo setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
