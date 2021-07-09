//
//  Item.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/11/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "ItemModel.h"
#import "AppManager.h"
#import "UserManager.h"
#import "DownloadManager.h"
#import "Categories.h"
#import "ImageItemModel.h"

@interface ItemModel() <DownloadProtocol>
@property (nonatomic, strong) NSMutableArray    *downloadingUrls;
@end

@implementation ItemModel

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        self.downloadingUrls = [[NSMutableArray alloc] init];
        dict = [Utils checkNull:dict];
        self.sellerModel = [[SellerModel alloc] initWithDictionary:[dict objectForKey:@"seller"]];
        [self loadFirstImage];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    [super updateWithDictionary:dict];
    dict = [Utils checkNull:dict];
    [self.sellerModel updateWithDictionary:[dict objectForKey:@"seller"]];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    [super setSpecialValue:dict];
    self.liked = [[Utils checkNil:[dict objectForKey:@"liked"] defaultValue:@"0"] boolValue];
    self.commented = [[Utils checkNil:[dict objectForKey:@"reviewed"] defaultValue:@"0"] boolValue];
    self.total_likes = [[Utils checkNil:[dict objectForKey:@"total_likes"] defaultValue:@"0"] integerValue];
    self.total_comments = [[Utils checkNil:[dict objectForKey:@"total_reviews"] defaultValue:@"0"] integerValue];
    self.total_followers = [[Utils checkNil:[dict objectForKey:@"total_followers"] defaultValue:@"0"] integerValue];
    self.in_wish_list = [[Utils checkNil:[dict objectForKey:@"in_wish_list"] defaultValue:@"0"] boolValue];
    self.created_at = [[Utils checkNil:[dict objectForKey:@"created_at"] defaultValue:@"0"] doubleValue];
    self.flagged = [[Utils checkNil:[dict objectForKey:@"flagged"] defaultValue:@"0"] boolValue];
    
    self.imageItems = [[NSMutableArray alloc] init];
    NSArray *imageArr = [dict objectForKey:@"images"];
    for (NSDictionary *imgDict in imageArr) {
        ImageItemModel *imageItem = [[ImageItemModel alloc] initWithDictionary:imgDict];
        [self.imageItems addObject:imageItem];
    }
    
    self.latest_likers = [[NSMutableArray alloc] init];
    NSArray *likers = [dict objectForKey:@"latest_likers"];
    for (NSDictionary *likerDict in likers) {
        SellerModel *liker = [[SellerModel alloc] initWithDictionary:likerDict];
        if (liker) {
            [self.latest_likers addObject:liker];
        }
    }
    
    self.latest_comments = [[NSMutableArray alloc] init];
    NSArray *comments = [dict objectForKey:@"latest_comments"];
    for (NSDictionary *commentDict in comments) {
        CommentModel *comment = [[CommentModel alloc] initWithDictionary:commentDict];
        if (comment) {
            [self.latest_comments addObject:comment];
        }
    }
}

- (NSString *)name {
    return [Utils convertUnicodeToEmoji:[super name]];
}

- (NSString *)getPriceWithCurencyText {
    if (self.price >= 1000) {
        return [NSString stringWithFormat:@"%@%0.0f", self.currency, self.price];
    }
    if (self.price >= 100) {
        return [NSString stringWithFormat:@"%@%0.1f", self.currency, self.price];
    }
    return [NSString stringWithFormat:@"%@%0.2f", self.currency, self.price];
}

- (NSString *)getTotalCommentsText {
    return [NSString stringWithFormat:@"%ld %@", (long)_total_comments, NSLocalizedString(@"comments", @"")];
}

- (NSString *)getNumberOfLikesText {
    NSString *str = [NSString stringWithFormat:@"%ld", (long)self.total_likes];
    if (self.total_likes >= 1000 && self.total_likes < 1000) {
        str = [NSString stringWithFormat:@"%0.1fK", (float)self.total_likes / 1000];
    }
    else if (self.total_likes >= 10000 && self.total_likes < 1000000) {
        str = [NSString stringWithFormat:@"%0.0fK", (float)self.total_likes / 1000];
    }
    else if (self.total_likes >= 1000000) {
        str = [NSString stringWithFormat:@"%0.0fM", (float)self.total_likes / 1000000];
    }
    return [NSString stringWithFormat:@"%@ %@", str, (self.total_likes <= 1) ? NSLocalizedString(@"like", @"") : NSLocalizedString(@"likes", @"")];
}

- (NSString *)getNumberOfCommentsText {
    NSString *str = [NSString stringWithFormat:@"%ld", (long)self.total_comments];
    if (self.total_comments >= 1000 && self.total_comments < 1000) {
        str = [NSString stringWithFormat:@"%0.1fK", (float)self.total_comments / 1000];
    }
    else if (self.total_comments >= 10000 && self.total_comments < 1000000) {
        str = [NSString stringWithFormat:@"%0.0fK", (float)self.total_comments / 1000];
    }
    else if (self.total_comments >= 1000000) {
        str = [NSString stringWithFormat:@"%0.0fM", (float)self.total_comments / 1000000];
    }
    return [NSString stringWithFormat:@"%@ %@", str, (self.total_comments <= 1) ? NSLocalizedString(@"comment", @"") : NSLocalizedString(@"comments", @"")];
}

- (NSString *)getCommentTextAndNumber {
    NSString *str = [NSString stringWithFormat:@" (%ld)", (long)self.total_comments];
    if (self.total_comments >= 1000 && self.total_comments < 1000) {
        str = [NSString stringWithFormat:@" (%0.1fK)", (float)self.total_comments / 1000];
    }
    else if (self.total_comments >= 10000 && self.total_comments < 1000000) {
        str = [NSString stringWithFormat:@"(%0.0fK)", (float)self.total_comments / 1000];
    }
    else if (self.total_comments >= 1000000) {
        str = [NSString stringWithFormat:@" (%0.0fM)", (float)self.total_comments / 1000000];
    }
    return [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"comment", @""), str];
}

- (NSString *)getGenderString {
    return [NSString stringWithFormat:@"For %@", self.gender];
}

- (NSString *)getSizeString {
    return (self.sizes.length > 0) ? [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"size", @""), self.sizes] : NSLocalizedString(@"size", @"");
}

- (UIImage *)getGenderImage {
    if ([self.gender isEqualToString:GENDER_MEN]) {
        return [UIImage imageNamed:@"man"];
    }
    if ([self.gender isEqualToString:GENDER_WOMEN]) {
        return [UIImage imageNamed:@"woman"];
    }
    if ([self.gender isEqualToString:GENDER_BOYS]) {
        return [UIImage imageNamed:@"boy"];
    }
    if ([self.gender isEqualToString:GENDER_GIRLS]) {
        return [UIImage imageNamed:@"girl"];
    }
    if ([self.gender isEqualToString:GENDER_HOME]) {
        return [UIImage imageNamed:@"home"];
    }
    if ([self.gender isEqualToString:GENDER_OTHER] || [self.gender isEqualToString:GENDER_FUN]) {
        return [UIImage imageNamed:@"other"];
    }
    return nil;
}

- (NSString *)getStatusString {
    NSString * result = @"";
    if ([self isUnavallable]) {
        result = NSLocalizedString(@"text_unvailable", @"");
    }
    else if (self.condition.length > 0 && ![self isService]) {
        NSString *condition = [self.condition isEqualToString:CONDITION_NEW] ? NSLocalizedString(@"text_new", @"") : NSLocalizedString(@"text_likenew", @"");
        result = condition;
    }
    return [result capitalizedString];
}

- (NSString *)getFirstImageUrl {
    ImageItemModel *imageItem = [self.imageItems firstObject];
    return imageItem.getImageURL;
}

- (NSMutableArray *)getAllImageUrls {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ImageItemModel *imageItem in self.imageItems) {
        [array addObject:imageItem.getImageURL];
    }
    return array;
}

- (NSString *)getDisplayedTags {
    NSArray *array = [self.tags componentsSeparatedByString:@","];
    NSString *tags = [array componentsJoinedByString:@", "];
    return tags;
}

- (NSString *)getPurchasesText {
    NSArray *array = [self.purchases componentsSeparatedByString:@","];
    NSString *purchases = [array componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"For %@", [purchases capitalizedString]];
}

- (BOOL)isUnavallable {
    NSRange range = [self.status rangeOfString:STATUS_UNAVAILABLE];
    return range.length != 0;
}

- (BOOL)isEqualToDictionaryOfItem:(NSDictionary *)dict {
    NSNumber *itemId = [dict objectForKey:@"id"];
    if ([itemId isEqualToNumber:self.id]) {
        return YES;
    }
    return NO;
}

- (void)resetStatus {
    self.liked = NO;
    self.in_wish_list = NO;
    self.commented = NO;
    self.sellerModel.followed = NO;
    self.sellerModel.rated = NO;
}

- (BOOL)isMine {
    return [self.sellerModel isMe];
}

- (void)dealloc {
    [self cancel];
}

- (NSString *)getSellerFollowStatus {
    NSString *title = nil;
    if (self.sellerModel.followed) {
        title = [NSString stringWithFormat:@"Followed (%ld)", self.sellerModel.total_followers];
    } else {
        title = [NSString stringWithFormat:@"+ Follow (%ld)", self.sellerModel.total_followers];
    }
    return title;
}

- (NSString *)getItemShareLink {
    NSString *type = self.isService ? @"talent" : @"style";
    NSString *link = [NSString stringWithFormat:@"%@/%@/?id=%@", [[AppManager sharedInstance] getCloudHostBaseUrl], type, self.getIdString];
    return link;
}

- (NSString *)createAtString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.created_at];
    NSString *dateString = [date convertToStringWithFormat:DATETIME_FORMAT_STRING];
    return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"added_on", @""), dateString];
}

#pragma mark - ItemSellerProtocol
- (void)updateLatestComment:(NSDictionary *)dict {
    CommentModel *comment = [[CommentModel alloc] initWithDictionary:dict];
    if (comment) {
        [self.latest_comments insertObject:comment atIndex:0];
        for (NSInteger i = self.latest_comments.count - 1; i >= 2; i--) {
            [self.latest_comments removeObjectAtIndex:i];
        }
        self.total_comments++;
    }
}

#pragma mark - Photo downloader
- (void)loadAvatar {
    NSString *url = self.sellerModel.avatar;
    if (url.length == 0) {
        [self didFinishDownloadingImage:nil url:url processImageType:IMAGE_CROPCENTER];
        return;
    }
    else if ([self.downloadingUrls containsObject:url]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *cachedImage = [[DownloadManager shareInstance] getCachedImageForUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (cachedImage) {
                [self didFinishDownloadingImage:cachedImage url:url processImageType:IMAGE_CROPCENTER];
            }
            else {
                [self.downloadingUrls addObject:url];
                [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:IMAGE_CROPCENTER delegate:self];
            }
        });
    });
}

- (void)loadFirstImage {
    NSString *url = [self getFirstImageUrl];
    if (url.length == 0 || [self.downloadingUrls containsObject:url])
        return;
    UIImage *cachedImage = [[DownloadManager shareInstance] getCachedImageForUrl:url];
    if (cachedImage) {
        self.cachedFirstImage = cachedImage;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *cachedImage = [[DownloadManager shareInstance] getCachedImageForUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (cachedImage) {
                [self didFinishDownloadingImage:cachedImage url:url processImageType:IMAGE_SCALE];
            }
            else {
                [self.downloadingUrls addObject:url];
                [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:IMAGE_SCALE delegate:self];
            }
        });
    });
}

- (void)downloadReparatoryImages {
    NSString *url = self.sellerModel.avatar;
    if (url.length > 0 && ![self.downloadingUrls containsObject:url]) {
        BOOL existed = [[DownloadManager shareInstance] checkExistCacheImageForUrl:url];
        if (!existed) {
            [self.downloadingUrls addObject:url];
            [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:IMAGE_CROPCENTER delegate:self];
        }
    }
    
    url = [self getFirstImageUrl];
    if (url.length > 0 && ![self.downloadingUrls containsObject:url]) {
        BOOL existed = [[DownloadManager shareInstance] checkExistCacheImageForUrl:url];
        if (!existed) {
            [self.downloadingUrls addObject:url];
            [[DownloadManager shareInstance] downloadPhotoUrl:url processImage:IMAGE_DONOTHING delegate:self];
        }
    }
}

- (void)cancel {
    [[DownloadManager shareInstance] removeListener:self];
    self.aDelegate = nil;
    [self.downloadingUrls removeAllObjects];
}

#pragma mark - Download protocol
- (void)didFinishDownloadingImage:(UIImage *)downloadedImage url:(NSString *)downloadedUrl processImageType:(PROCESSIMAGE)processType {
    CGSize scaledSize = CGSizeMake(GALLERY_SCROLLVIEW_SIZE.width * 2, GALLERY_SCROLLVIEW_SIZE.height * 2);
    if (downloadedUrl == self.sellerModel.avatar) {
        scaledSize = AVATAR_SIZE;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = downloadedImage;
        switch (processType) {
            case IMAGE_CROPCENTER:
                image = [downloadedImage cropCenterToSize:scaledSize];
                break;
            case IMAGE_SCALE:
                image = [downloadedImage scaleToSize:scaledSize];
                break;
            default:
                image = downloadedImage;
                break;
        }
        self.cachedFirstImage = image;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (downloadedUrl == self.sellerModel.avatar) {
                if ([self.aDelegate respondsToSelector:@selector(didFinishLoadingAvatar:sender:)]) {
                    [self.aDelegate didFinishLoadingAvatar:image sender:self];
                }
            }
            else if (downloadedUrl == [self getFirstImageUrl]) {
                if ([self.aDelegate respondsToSelector:@selector(didFinishLoadingFirstImage:sender:)]) {
                    [self.aDelegate didFinishLoadingFirstImage:image sender:self];
                }
            }
        });
    });
    
    [self.downloadingUrls removeObject:downloadedUrl];
}

- (void)didHaveErrorWhileDownloadPhotoAtUrl:(NSString *)downloadedUrl {
    if ([self.aDelegate respondsToSelector:@selector(didHaveErrorWhileLoadingImaeUrl:sender:)]) {
        [self.aDelegate didHaveErrorWhileLoadingImaeUrl:downloadedUrl sender:self];
    }
    [self.downloadingUrls removeObject:downloadedUrl];
}
@end
