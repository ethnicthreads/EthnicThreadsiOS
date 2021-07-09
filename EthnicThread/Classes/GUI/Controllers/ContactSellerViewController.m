//
//  ContactSellerViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/25/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ContactSellerViewController.h"
#import "CustomImageView.h"
#import "MessageTableViewCell.h"
#import "MoreInfoViewController.h"
#import "InputMessageView.h"
#import "SellerProfileViewController.h"
#import "ImageCropperViewController.h"
#import "PhotoTweaksViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImagePopupViewController.h"

#define TEXTVIEW_MAX_LINE       3
#define PER_COUNT               15
#define SELECT_PHOTO           9999

@interface ContactSellerViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MessageTableViewCellDelegate, ImageCropperDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, PhotoTweaksViewControllerDelegate> {
    CGFloat         headerSectionHeight;
    BOOL            hasSentMessageAlready;
    BOOL            downloadingOldMessage;
}
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeight;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightInputView;

@property (nonatomic, assign) IBOutlet UITableView          *tableView;
@property (nonatomic, strong) UIView                        *sclContentView;
@property (strong, nonatomic) MessageTableViewCell          *offScreenCell;
@property (nonatomic, strong) NSMutableArray                *messages;
@property (nonatomic, assign) NSInteger                     downloadingPage;
@property (nonatomic, strong) UIRefreshControl              *refreshControl;
@property (nonatomic, strong) UIImage                       *imageToUse;

@property (nonatomic, assign) IBOutlet UIView               *vItem;
@property (nonatomic, assign) IBOutlet UILabel              *lblItemTitle;
@property (nonatomic, assign) IBOutlet UILabel              *lblItemtId;
@property (nonatomic, assign) IBOutlet CustomImageView      *imvItemImage;
@property (nonatomic, assign) IBOutlet InputMessageView     *inputMessageView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightInput;
@property (nonatomic, strong) NSString                      *defaultMessage;
@property (nonatomic, assign) id<OperationProtocol>         sendingThread;
@property (nonatomic, strong) NSMutableArray                *nofificationIds;
@property (nonatomic, strong) UITapGestureRecognizer        *tabGesture;
@property (nonatomic, strong) NSOperationQueue              *messageQueue;
@end

@implementation ContactSellerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.downloadingPage = 1;
    self.messages = [[NSMutableArray alloc] init];
    self.shouldMarkOpened = YES;
    self.nofificationIds = [[NSMutableArray alloc] init];
    self.messageQueue = [[NSOperationQueue alloc] init];
    self.messageQueue.maxConcurrentOperationCount = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:self.fullName andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    
    self.inputMessageView.lcHeight = self.lcHeightInput;
    [self.inputMessageView.btnSend addTarget:self action:@selector(handleSendButton:) forControlEvents:UIControlEventTouchUpInside];
    self.inputMessageView.textView.placeholder = NSLocalizedString(@"type_a_message", @"");
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    self.tabGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:self.tabGesture];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.vItem setHidden:self.itemModel == nil];
    if (self.itemModel) {
        self.lblItemTitle.text = self.itemModel.name;
        self.lblItemtId.text = [NSString stringWithFormat:@"#%@", [self.itemModel getIdString]];
        [self.imvItemImage setImage:[UIImage imageNamed:ITEM_THUMB]];
        [self.imvItemImage loadImageForUrl:[self.itemModel getFirstImageUrl]];
        self.inputMessageView.btnSend.highlighted = NO;
    }
    
    self.inputMessageView.textView.text = self.defaultMessage;
    self.defaultMessage = nil;
    
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadMessages:threadObj:) argument:@""];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    self.lcHeight.constant = [UIScreen mainScreen].bounds.size.height - self.lcTop.constant -64;
    if (self.itemModel != nil) {
        self.lcHeightInputView.constant = 100;
    }
    else {
        self.lcHeightInputView.constant = 47;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [self didEnterBackground:nil];
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(updateThread:)]) {
        [self.delegate updateThread:[self.messages firstObject]];
    }
}

- (void)setThreadModel:(ThreadModel *)threadModel {
    _threadModel = threadModel;
    if ([self.threadModel isMine]) {
        self.userId = [self.threadModel.receiver getIdString];
        self.fullName = [self.threadModel.receiver getDisplayName];
    }
    else {
        self.userId = [self.threadModel.sender getIdString];
        self.fullName = [self.threadModel.sender getDisplayName];
    }
}

- (void)setDefaultMessage:(NSString *)message {
    _defaultMessage = message;
}

- (void)didReceiveDerectMessage:(NSNumber *)messId notifId:(NSNumber *)notifId userId:(NSNumber *)userId {
    [self.nofificationIds addObject:[notifId description]];
    
    if (![userId isEqualToNumber:[[UserManager sharedInstance] getAccount].id]) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeGetDirectReceivedMessage:threadObj:) argument:[messId description]];
    }
}

- (void)didEnterBackground:(NSNotification *)noti {
    if (self.nofificationIds.count > 0) {
        NSString *notifIds = [self.nofificationIds componentsJoinedByString:@","];
        [self.nofificationIds removeAllObjects];
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDismissNotificaion:threadObj:) argument:notifIds];
    }
}

#pragma mark - Private Method
- (NSInteger)downloadMessages:(NSInteger)page andPer:(NSInteger)per threadObj:(id<OperationProtocol>)threadObj {
    NSInteger rowCount = 0;
    Response *response = [CloudManager getMessagesWithUser:self.userId
                                                          andFromPage:page
                                                               andPer:per];
    
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            MessageModel *message = [[MessageModel alloc] initWithDictionary:dict];
            if (message) {
                [results addObject:message];
            }
        }
        
        if (results.count > 0) {
            // increasing page for next request
            rowCount = results.count;
            self.downloadingPage++;
            [self.messages addObjectsFromArray:results];
        }
    }
    if (self.downloadingPage == 1) {
        self.downloadingPage++;
    }
    return rowCount;
}

- (void)executeDownloadMessages:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    [self downloadMessages:self.downloadingPage andPer:PER_COUNT threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self reloadTableViewAndGotoRow:(self.messages.count - 1) atScrollPosition:UITableViewScrollPositionBottom withAnimation:NO];
        
        if (self.shouldMarkOpened) {
            ThreadModel *thread = [[ThreadModel alloc] initWithMessage:[self.messages firstObject]];
            [thread justOpened];
        }
    });
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeDownloadOldMessagesAndInsertTopPosition:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    if (downloadingOldMessage) {
        [threadObj releaseOperation];
        return;
    }
    downloadingOldMessage = YES;
    NSInteger _newRows = [self downloadMessages:self.downloadingPage andPer:PER_COUNT threadObj:threadObj];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self reloadTableViewAndGotoRow:_newRows atScrollPosition:UITableViewScrollPositionTop withAnimation:NO];
        [self.refreshControl endRefreshing];
    });
    downloadingOldMessage = NO;
    [threadObj releaseOperation];
}

- (void)executeSendMessage:(NSDictionary *)param threadObj:(id<OperationProtocol>)threadObj {
//    [self startSpinnerWithWaitingText];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
//    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Response *response = [CloudManager sendMessageToUser:self.userId andBody:param];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSDictionary *dict = response.getJsonObject;
        MessageModel *message = [[MessageModel alloc] initWithDictionary:dict];
        if (message) {
            [self.messages insertObject:message atIndex:0];
            self.threadModel.itemModel = nil;
            hasSentMessageAlready = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.inputMessageView resetTextView];
            [self.vItem setHidden:YES];
            self.lcHeightInputView.constant = 47;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [self reloadTableViewAndGotoRow:(self.messages.count - 1) atScrollPosition:UITableViewScrollPositionBottom withAnimation:YES];
        });
    }
//    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeGetDirectReceivedMessage:(NSString *)messId threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager getMessagesWithUser:self.userId byMessageId:messId];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSArray *array = response.getJsonObject;
        NSDictionary *dict = [array firstObject];
        MessageModel *messModel = [[MessageModel alloc] initWithDictionary:dict];
        if (messModel) {
            [self.messages insertObject:messModel atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self reloadTableViewAndGotoRow:(self.messages.count - 1) atScrollPosition:UITableViewScrollPositionBottom withAnimation:YES];
            });
        }
    }
    [threadObj releaseOperation];
}

- (void)executeDismissNotificaion:(NSString *)notifIds threadObj:(id<OperationProtocol>)threadObj {
    Response *response = [CloudManager dismissNotification:notifIds];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        
    }
    [threadObj releaseOperation];
}

- (void)executeDownloadItem:(NSString *)itemId threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getItemsByIds:itemId];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        NSArray *array = response.getJsonObject;
        ItemModel *item = [[ItemModel alloc] initWithDictionary:[array firstObject]];
        if (item) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
                vc.itemModel = item;
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)executeUserProfile:(NSString *)userId threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager getUserProfile:userId];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        SellerModel *seller = [[SellerModel alloc] initWithDictionary:response.getJsonObject];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
            vc.sellerModel = seller;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

- (void)handleSendButton:(id)sender {
//    if ([self.sendingThread isReady])
//        return;
    if (self.inputMessageView.textView.text.length == 0) {
        [self handleSelectImage];
        return;
    }
    NSString *message = [self.inputMessageView.textView.text trimText];
    message = [Utils convertEmojiToUnicode:message];
    if (message.length > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:message forKey:@"message"];
        if (self.itemModel && hasSentMessageAlready == NO) {
            [dict setObject:[self.itemModel getIdString] forKey:@"item"];
        }
        [dict setObject:self.userId forKey:@"user_id"];
        [self resetSendButton];
        self.sendingThread = [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeSendMessage:threadObj:) argument:dict queue:self.messageQueue];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_sorry", @"") message:NSLocalizedString(@"alert_please_enter_your_message", @"")];
    }
}

- (void)handleSelectImage {
    DLog(@"Oke man");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"take_photo", @""), NSLocalizedString(@"choose_from_photo_library", @""), nil];
    [sheet showInView:self.view];
}

- (void)reloadTableViewAndGotoRow:(NSInteger)row atScrollPosition:(UITableViewScrollPosition)scrollPosition withAnimation:(BOOL)animate {
    // first reload to update cell to calculate header height
    headerSectionHeight = 0;
    [self.tableView reloadData];
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        headerSectionHeight = self.tableView.frame.size.height - self.tableView.contentSize.height;
    }
    else {
        headerSectionHeight = 0;
    }
    if (headerSectionHeight > 0) {
    // second reload to calculate content size of table
        [self.tableView reloadData];
    }
    NSInteger rowCount = [self.tableView numberOfRowsInSection:0];
    if (row < rowCount && row >= 0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:scrollPosition animated:animate];
    }
}

- (void)handleRefresh:(id)sender {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadOldMessagesAndInsertTopPosition:threadObj:) argument:@""];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self.tableView setHidden:(self.messages.count == 0)];
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *receivedMessageCellIdentifier = @"MessageCell";
    NSInteger index = 0;
    if (self.messages.count > 0) {
        index = self.messages.count - indexPath.row - 1;
    }
    
    MessageModel *message = [self.messages objectAtIndex:index];
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:receivedMessageCellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([MessageTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [cell setMessage:message];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, headerSectionHeight)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = 0;
    if (self.messages.count > 0) {
        index = self.messages.count - indexPath.row - 1;
    }
    
    MessageModel *message = [self.messages objectAtIndex:index];
    if (!self.offScreenCell) {
        self.offScreenCell = [[[UINib nibWithNibName:NSStringFromClass([MessageTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    
    [self.offScreenCell caculateHeightByMessage:message];
    
    [self.offScreenCell setNeedsUpdateConstraints];
    [self.offScreenCell updateConstraintsIfNeeded];
    self.offScreenCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.offScreenCell.bounds));
    [self.offScreenCell setNeedsLayout];
    [self.offScreenCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [self.offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    if ([message isImageType]) {
        height += tableView.bounds.size.width * 7 / 10;
    }
    return height += 1;
}

- (void)didTapOnTableView:(UIGestureRecognizer *)recognizer {
    [self.inputMessageView.textView resignFirstResponder];
}

- (void)didTapOnGalleryScrollView:(UIGestureRecognizer *)recognizer {
    MoreInfoViewController *vc = [[MoreInfoViewController alloc] init];
    vc.itemModel = self.itemModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlerViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:NSLocalizedString(@"alert_button_yes", @"")]) {
        PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:_imageToUse];
        photoTweaksViewController.delegate = self;
        photoTweaksViewController.autoSaveToLibray = YES;
        [self presentViewController:photoTweaksViewController animated:YES completion:nil];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"alert_button_no", @"")]) {
//        [self.itemView addImage:_imageToUse animate:YES];
        [self handleSendImageMessage:self.imageToUse];
    }
}
#pragma mark - MessageTableViewCellDelegate
- (void)openFullImage:(UIImage *)image {
    if (image) {
        [self showFullScreenImage:image];
    }
}
- (void)openMoreInfoPage:(ItemModel *)itemModel {
    // must download because item in message is not enough fields
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeDownloadItem:threadObj:) argument:[itemModel getIdString]];
}

- (void)openUserProfilePage:(SellerModel *)sellerModel {
    [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executeUserProfile:threadObj:) argument:[sellerModel getIdString]];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            cameraUI.allowsEditing = NO;
            cameraUI.delegate = self;
            [self presentViewController:cameraUI animated:YES completion:nil];
        }
    }
    else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            mediaUI.allowsEditing = NO;
            mediaUI.delegate = self;
            [self presentViewController:mediaUI animated:YES completion:nil];
        }
    } else {
        [self resetSendButton];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        //        UIImageWriteToSavedPhotosAlbum (imageToUse, nil, nil , nil);
    }
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{
        //        ImageSquareCropperViewController *imgCropperVC = [[ImageSquareCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        //        ImageSquareCropperViewController *imgCropperVC = [[ImageSquareCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, cropFrame.width, cropFrame.height) limitScaleRatio:3.0];
        //        imgCropperVC.isRoundCroped = NO;
        //        imgCropperVC.delegate = self;
        //        [self presentViewController:imgCropperVC animated:YES completion:nil];
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_crop_image", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_no", @"") otherButtonTitles:NSLocalizedString(@"alert_button_yes", @""), nil];
        [alertView setTag:SELECT_PHOTO];
        self.imageToUse = imageToUse;
        [alertView show];
//        ImageCropperViewController *imgCropperVC = [[ImageCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
//        imgCropperVC.delegate = self;
//        [self presentViewController:imgCropperVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImageCropperDelegate
- (void)imageCropper:(ImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    editedImage = [editedImage scaleByWidth:IMAGE_ITEM_WIDTH];
    [self handleSendImageMessage:editedImage];
//    self.creativeAccount.avatar = filePath;
//    [self setAvatarImage:[UIImage imageWithContentsOfFile:filePath]];
//    [self justChangeAvatar];
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(ImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSendImageMessage:(UIImage *)image {
    NSString *filePath = [[CachedManager sharedInstance] cacheTempJPEGImage:image withFileName:@"IMG.JPEG"];
    NSDictionary *dict = @{@"file": filePath};
    self.sendingThread = [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeSendMessage:threadObj:) argument:dict queue:self.messageQueue];
}

#pragma mark PhotoTweaksViewControllerDelegate
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
//    [self.itemView addImage:croppedImage animate:YES];
    [self handleSendImageMessage:croppedImage];
    //[cropperViewController dismissViewControllerAnimated:YES completion:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
    //    //croppedImage = [croppedImage scaleByWidth:IMAGE_ITEM_WIDTH];
    //    [self.itemView addImage:croppedImage animate:YES];
    //    //[cropperViewController dismissViewControllerAnimated:YES completion:nil];
    //    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self resetSendButton];
}

- (void)resetSendButton {
    self.inputMessageView.textView.text = nil;
    self.inputMessageView.btnSend.highlighted = YES;
}

- (void)showFullScreenImage:(UIImage *)image {
    ImagePopupViewController *vc = [[ImagePopupViewController alloc] init];
    vc.images = [NSArray arrayWithObject:image];
    vc.currentIndex = 0;
    [self presentViewController:vc animated:NO completion:nil];
}
@end
