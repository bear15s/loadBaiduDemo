//
//  ViewController.m
//  loadBaiduDemo
//
//  Created by 梁家伟 on 17/3/6.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/ip.h>
#import <arpa/inet.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController{
    int socketId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadBaidu];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)connectWithIpAddress:(NSString*)address andPort:(NSUInteger)port{
    
    
    socketId = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    struct sockaddr_in sockadress;
    
    sockadress.sin_family = AF_INET;
    
    sockadress.sin_port = htons(port);
    
    sockadress.sin_addr.s_addr =  inet_addr(address.UTF8String);
    
    int connectResult = connect(socketId, &sockadress, sizeof(sockadress));
    return connectResult == 0;
 
}

-(void)loadBaidu{
    
    BOOL connectResult = [self connectWithIpAddress:@"14.215.177.37" andPort:80];
    
    if(!connectResult){
        NSLog(@"链接失败");
    }
    
    NSString* htmlString = [self sendAndReceive];
    
    NSLog(@"%@",htmlString);
    
    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.baidu.com"]];
}


-(NSString*)sendAndReceive{
    
    
    //请求
//    NSString *request = @"GET / HTTP/1.1\r\n"
//    @"Host: www.baidu.com\r\n"
//    @"User-Agent: iPhone\r\n"
//    @"Connection: Close\r\n\r\n";

    NSString *request = @"GET / HTTP/1.1\r\n"
    @"Host: www.baidu.com\r\n"
    @"User-Agent: iPhone\r\n"
    @"Connection: close\r\n\r\n";
    
    ssize_t sendLenth = send(socketId,request.UTF8String, strlen(request.UTF8String), 0);
    NSString * resultStr = sendLenth  < 0 ? @"发送失败" : @"发送成功";
    NSLog(@"%@",resultStr);
    
    
    ssize_t length;
    uint8_t buffer[1024];
    NSMutableData* data = [NSMutableData data];
    
    
    do {
        length = recv(socketId, buffer, sizeof(buffer), 0);
        [data appendBytes:buffer length:length];
        
    } while (length>0);
    
    NSString* htmlString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange  headerRange = [htmlString rangeOfString:@"\r\n\r\n"];
    NSUInteger maxIndex = NSMaxRange(headerRange);
    
    
    htmlString = [htmlString substringFromIndex:maxIndex];
    
    return htmlString;
}

@end
