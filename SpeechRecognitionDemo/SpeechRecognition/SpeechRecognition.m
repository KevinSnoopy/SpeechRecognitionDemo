//
//  SpeechRecognition.m
//  SpeechRecognitionDemo
//
//  Created by kevin on 2019/3/18.
//  Copyright © 2019 kevin. All rights reserved.
//

#import "SpeechRecognition.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

NSString *Language(LANGUAGETYPE status) {
    switch (status) {
            //        case LANGUAGE_BR:
            //            return @"pt-BR";
            //            break;
            //        case LANGUAGE_SK:
            //            return @"sk-SK";
            //            break;
            //        case LANGUAGE_CA:
            //            return @"fr-CA";
            //            break;
            //        case LANGUAGE_RO:
            //            return @"ro-RO";
            //            break;
        case LANGUAGE_NO:
            return @"no-NO";
            break;
            //        case LANGUAGE_FI:
            //            return @"fi-FI";
            //            break;
            //        case LANGUAGE_PL:
            //            return @"pl-PL";
            //            break;
        case LANGUAGE_DE:
            return @"de-DE";
            break;
            //        case LANGUAGE_NL:
            //            return @"nl-NL";
            //            break;
            //        case LANGUAGE_ID:
            //            return @"id-ID";
            //            break;
            //        case LANGUAGE_TR:
            //            return @"tr-TR";
            //            break;
            //        case LANGUAGE_IT:
            //            return @"it-IT";
            //            break;
            //        case LANGUAGE_PT:
            //            return @"pt-PT";
            //            break;
        case LANGUAGE_FR:
            return @"fr-FR";
            break;
            //        case LANGUAGE_RU:
            //            return @"ru-RU";
            //            break;
            //        case LANGUAGE_MX:
            //            return @"es-MX";
            //            break;
        case LANGUAGE_HK:
            return @"zh-HK";
            break;
            //        case LANGUAGE_SE:
            //            return @"sv-SE";
            //            break;
            //        case LANGUAGE_HU:
            //            return @"hu-HU";
            //            break;
        case LANGUAGE_TW:
            return @"zh-TW";
            break;
            //        case LANGUAGE_ES:
            //            return @"es-ES";
            //            break;
        case LANGUAGE_CN:
            return @"zh-CN";
            break;
            //        case LANGUAGE_BE:
            //            return @"nl-BE";
            //            break;
        case LANGUAGE_GB:
            return @"en-GB";
            break;
        case LANGUAGE_KR:
            return @"ko-KR";
            break;
            //        case LANGUAGE_CZ:
            //            return @"cs-CZ";
            //            break;
            //        case LANGUAGE_ZA:
            //            return @"en-ZA";
            //            break;
            //        case LANGUAGE_AU:
            //            return @"en-AU";
            //            break;
            //        case LANGUAGE_DK:
            //            return @"da-DK";
            //            break;
            //        case LANGUAGE_US:
            //            return @"en-US";
            //            break;
            //        case LANGUAGE_IE:
            //            return @"en-IE";
            //            break;
            //        case LANGUAGE_IN:
            //            return @"hi-IN";
            //            break;
            //        case LANGUAGE_GR:
            //            return @"el-GR";
            //            break;
        case LANGUAGE_JP:
            return @"ja-JP";
            break;
        default:
            return @"";
            break;
    }
}

@interface SpeechRecognition () <SFSpeechRecognizerDelegate>

@property (nonatomic, assign) BOOL stopTalk;//停止说话
@property (nonatomic, assign) BOOL canRecognizer;//能否识别

@property (nonatomic, assign) LANGUAGETYPE source;//源语言

@property (nonatomic, weak) id <SpeechRecognitionProtocol> delegate;//代理

@property (nonatomic, retain) NSTimer *volumeTimer;//鉴别音量定时器
@property (nonatomic, retain) NSTimer *recorderTimer;//是否开始识别定时器

@property (nonatomic, strong) AVAudioRecorder *recorder;//录音机
@property (nonatomic, strong) AVAudioEngine *audioEngine;//录音机管理器

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;//语音识别工具
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;//语音识别任务
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;//语音识别请求

@end

static SpeechRecognition *_instance;
@implementation SpeechRecognition

/**
 初始化
 */
+ (SpeechRecognition *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        BOOL OK = [self judgeRecording];
        if (OK) {
            [[NSRunLoop mainRunLoop] addTimer:self.volumeTimer forMode:NSDefaultRunLoopMode];
        }
        self.stopTalk = NO;
    }
    return self;
}

/**
 设置代理
 */
+ (void)setDelegate:(id<SpeechRecognitionProtocol>)delegate{
    [SpeechRecognition shareInstance].delegate = delegate;
}

/**
 选择语言
 */
+ (void)setSource:(LANGUAGETYPE)source{
    SpeechRecognition *instance = [SpeechRecognition shareInstance];
    instance.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[[NSLocale alloc]initWithLocaleIdentifier:Language(source)]];
}

/**
 开始识别
 */
+ (void)startRecognition{
    SpeechRecognition *instance = [SpeechRecognition shareInstance];
    if (!instance.canRecognizer) {
        return;
    }
    if (instance.recognitionTask) {
        [instance.recognitionTask cancel];
        instance.recognitionTask = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    bool  audioBool = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    bool  audioBool1= [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    bool  audioBool2= [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (audioBool || audioBool1||  audioBool2) {
        NSLog(@"可以使用");
    }else{
        NSLog(@"这里说明有的功能不支持");
    }
    AVAudioInputNode *inputNode = instance.audioEngine.inputNode;
    instance.recognitionRequest= [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    instance.recognitionRequest.shouldReportPartialResults = true;
    instance.recognitionTask = [instance.speechRecognizer recognitionTaskWithRequest:instance.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        bool isFinal = false;
        if (result) {
            NSString *string = [[result bestTranscription] formattedString];
            isFinal = [result isFinal];
            if (!isFinal && [instance.delegate respondsToSelector:@selector(speechRecognitionResult:)] && string.length > 0) {
                [instance.delegate speechRecognitionResult:string];
            }
        }
        if (error || isFinal) {
            [inputNode removeTapOnBus:0];
        }
    }];
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [instance.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [instance.audioEngine prepare];
    [instance.audioEngine startAndReturnError:nil];
}

/**
 停止识别
 */
+ (void)stopRecognition{
    SpeechRecognition *instance = [SpeechRecognition shareInstance];
    if (!instance.canRecognizer) {
        return;
    }
    [instance.audioEngine stop];
    [instance.recognitionTask cancel];
}

/**
 能否语音识别
 */
- (BOOL)judgeRecording{
    if (!_speechRecognizer) {
        NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-CN"];
        _canRecognizer = NO;
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:{//可以语音识别
                    self.canRecognizer = YES;
                    self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:locale];
                    self.speechRecognizer.delegate = self;
                }
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied://用户拒绝
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted://设备不行
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined://还没授权
                    break;
                default:
                    break;
            }
        }];
        return _canRecognizer;
    }
    return YES;
}

- (void)monitor:(NSTimer *)timer{
    [timer invalidate];
    timer = nil;
    self.stopTalk = NO;
    [SpeechRecognition stopRecognition];
}

- (void)volumeLevel{
    [self.recorder updateMeters];
    float level = pow(10, [_recorder averagePowerForChannel:0]/40);
    if (level > .1) {
        [_recorderTimer invalidate];
        _recorderTimer = nil;
        self.stopTalk = NO;
        if (!self.audioEngine.isRunning) {
            [SpeechRecognition startRecognition];
        }
    }else{
        if (!self.stopTalk) {
            self.stopTalk = YES;
            [[NSRunLoop mainRunLoop] addTimer:self.recorderTimer forMode:NSDefaultRunLoopMode];
        }
    }
}

/**
 初始化工具
 */
- (AVAudioRecorder*)recorder{
    if (!_recorder) {
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                                   AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                                   AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                                   AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
        NSError *error;
        _recorder=[[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            NSLog(@"^%@",error);
        }
        [_recorder prepareToRecord];
        [_recorder setMeteringEnabled:YES];
        [_recorder record];
    }
    return _recorder;
}

- (AVAudioEngine *)audioEngine{
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc]init];
    }
    return _audioEngine;
}

- (NSTimer *)recorderTimer{
    if (!_recorderTimer) {
        _recorderTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(monitor:) userInfo:nil repeats:NO];
    }
    return _recorderTimer;
}

- (NSTimer *)volumeTimer{
    if (!_volumeTimer) {
        _volumeTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(volumeLevel) userInfo:nil repeats:YES];
    }
    return _volumeTimer;
}

- (void)dealloc{
    _speechRecognizer.delegate = nil;
    [SpeechRecognition stopRecognition];
}

@end
