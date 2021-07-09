//
//  NotificationModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 3/9/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

typedef enum _PUSH_NOTIF_TYPE {
    PNT_NOTHING,
    PNT_REVIEW,
    PNT_FOLLOW,
    PNT_COMMENT,
    PNT_LIKE,
    PNT_MESSAGE,
    PNT_SELLINGITEM
} PUSH_NOTIF_TYPE;

@interface NotificationModel : AssetModel
@property (strong, nonatomic) NSString      *alert;
@property (strong, nonatomic) NSString      *alert_body;
@property (strong, nonatomic) NSString      *pictureUrl;
@property (assign, nonatomic) BOOL          dismissed;
@property (assign, nonatomic) PUSH_NOTIF_TYPE type;

- (NSString *)getSenderId;
- (NSString *)getSenderFirstName;
- (NSString *)getSenderLastName;
- (NSString *)getItemId;
- (NSString *)getMessage;
- (NSDate *)getCreatedDate;
- (NSString *)getTargetId;// if of Review, Comment, Message, SellingItem
- (NSString *)getSenderFullName;
@end

/**
 *
 [
 {
 "id": 21,
 "alert_body": "Duy Phuoc listed a new item called TItle 1 .",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "SellingItem",
 "id": 133,
 "message": "",
 "item_id": 133,
 "created_at": 1425909756,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 19,
 "alert_body": "Duy Phuoc listed a new item called TItle 1 .",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "SellingItem",
 "id": 133,
 "message": "",
 "item_id": 133,
 "created_at": 1425909747,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 17,
 "alert_body": "Duy Phuoc listed a new item called TItle 1 .",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "SellingItem",
 "id": 133,
 "message": "",
 "item_id": 133,
 "created_at": 1425909731,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 15,
 "alert_body": "Duy Phuoc listed a new item called TItle 1 .",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "SellingItem",
 "id": 133,
 "message": "",
 "item_id": 133,
 "created_at": 1425909705,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 13,
 "alert_body": "Duy Phuoc listed a new item called TItle 1 .",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "SellingItem",
 "id": 132,
 "message": "",
 "item_id": 132,
 "created_at": 1425909474,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 10,
 "alert_body": "Duy Phuoc commented on your item - BERMUDA SHORTS.",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "Comment",
 "id": 463,
 "message": "You might be skeptical. I was too, 10 years ago when my boss insisted I learn Vim to work on the company's Web site. The first week was painful. The month after that was okay. Within two months, I'd have sooner typed with my feet than to switch away from Vim.",
 "item_id": 5,
 "created_at": 1425909257,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 9,
 "alert_body": "Duy Phuoc commented on your item - BERMUDA SHORTS.",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "Comment",
 "id": 462,
 "message": "You might be skeptical. I was too, 10 years ago when my boss insisted I learn Vim to work on the company's Web site. The first week was painful. The month after that was okay. Within two months, I'd have sooner typed with my feet than to switch away from Vim.",
 "item_id": 5,
 "created_at": 1425909075,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 8,
 "alert_body": "Duy Phuoc commented on your item - BERMUDA SHORTS.",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "Comment",
 "id": 461,
 "message": "You might be skeptical. I was too, 10 years ago when my boss insisted I learn Vim to work on the company's Web site. The first week was painful. The month after that was okay. Within two months, I'd have sooner typed with my feet than to switch away from Vim.",
 "item_id": 5,
 "created_at": 1425909008,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 7,
 "alert_body": "Duy Phuoc commented on your item - BERMUDA SHORTS.",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "Comment",
 "id": 460,
 "message": "You might be skeptical. I was too, 10 years ago when my boss insisted I learn Vim to work on the company's Web site. The first week was painful. The month after that was okay. Within two months, I'd have sooner typed with my feet than to switch away from Vim.",
 "item_id": 5,
 "created_at": 1425873935,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 },
 {
 "id": 5,
 "alert_body": "Duy Phuoc left you a review.",
 "sender": {
 "id": 30,
 "first_name": "Duy",
 "last_name": "Phuoc"
 },
 "target": {
 "type": "Review",
 "id": 458,
 "message": "asd d sad as",
 "item_id": null,
 "created_at": 1425794782,
 "picture_url": "/uploads/image_file/image/14/187a2aac32ed913d08a8_IMG.JPEG"
 },
 "dismissed": true
 }
 ]

 */