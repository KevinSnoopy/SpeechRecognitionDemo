//
//  SpeechRecognition.h
//  SpeechRecognitionDemo
//
//  Created by kevin on 2019/3/18.
//  Copyright © 2019 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LANGUAGETYPE) {
    //    LANGUAGE_BR = 0,//葡萄牙 -巴西
    //    LANGUAGE_SK = 1,//斯洛伐克 -斯洛伐克
    //    LANGUAGE_CA = 2,//法国 -加拿大
    //    LANGUAGE_RO = 3,//罗马尼亚语 -罗马尼亚
    LANGUAGE_NO = 0,//挪威语(挪威)
    //    LANGUAGE_FI = 5,//芬兰语 -芬兰
    //    LANGUAGE_PL = 6,//波兰 -波兰
    LANGUAGE_DE = 1,//德国 -德国
    //    LANGUAGE_NL = 8,//荷兰 -荷兰
    //    LANGUAGE_ID = 9,//印尼 -印尼
    //    LANGUAGE_TR = 10,//土耳其语 -土耳其
    //    LANGUAGE_IT = 11,//意大利 -意大利
    //    LANGUAGE_PT = 12,//葡萄牙 -葡萄牙
    LANGUAGE_FR = 2,//法国 -法国
    //    LANGUAGE_RU = 14,//俄国 -俄国
    //    LANGUAGE_MX = 15,//西班牙 -墨西哥
    LANGUAGE_HK = 3,//繁体中文(香港)
    //    LANGUAGE_SE = 17,//瑞典 -瑞典
    //    LANGUAGE_HU = 18,//匈牙利语 -匈牙利
    LANGUAGE_TW = 4,//繁体中文(台湾)
    //    LANGUAGE_ES = 20,//西班牙 -西班牙
    LANGUAGE_CN = 5,//简体中文(大陆)
    //    LANGUAGE_BE = 22,//荷兰 -比利时
    LANGUAGE_GB = 6,//英国 -英国
    LANGUAGE_KR = 7,//韩国 -韩国
    //    LANGUAGE_CZ = 25,//捷克 -捷克
    //    LANGUAGE_ZA = 26,//英国 -南非
    //    LANGUAGE_AU = 27,//英国 -澳洲
    //    LANGUAGE_DK = 28,//丹麦文 -丹麦
    //    LANGUAGE_US = 29,//英国 -美国
    //    LANGUAGE_IE = 30,//英国 -爱尔兰
    //    LANGUAGE_IN = 31,//北印度语 -印度
    //    LANGUAGE_GR = 32,//希腊 -希腊
    LANGUAGE_JP = 8//日本 -日本
};

NS_ASSUME_NONNULL_BEGIN

@protocol SpeechRecognitionProtocol <NSObject>
@optional

/**
 翻译的结果
 */
- (void)speechRecognitionResult:(NSString *__nullable)result;

@end

@interface SpeechRecognition : NSObject

/**
 设置代理
 */
+ (void)setDelegate:(id <SpeechRecognitionProtocol> __nullable)delegate;
/**
 选择源语言和目标语言
 */
+ (void)setSource:(LANGUAGETYPE)source;
/**
 开始识别
 */
+ (void)startRecognition;
/**
 结束识别
 */
+ (void)stopRecognition;

@end

NS_ASSUME_NONNULL_END
