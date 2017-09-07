//
//  NSString+Path.m
//  YLShare
//
//  Created by wyl on 2017/9/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)
+(NSString *)getDocumentPath
{
    static NSString *documentsDirectory = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
    });
    return documentsDirectory;
}
-(NSString *)getPathForDocuments
{
    
    NSString* path = [[NSString getDocumentPath] stringByAppendingPathComponent:self];
    return path;
}

-(NSString *)getPathForDocumentsinDir:(NSString *)dir
{
    return [[dir getPathForDocuments]stringByAppendingPathComponent:self];
}
-(BOOL)isFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self];
}
-(BOOL)deleteWithFilepath
{
    return [[NSFileManager defaultManager] removeItemAtPath:self error:nil];
}
-(NSArray*)getFilenamesWithDir
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:self error:nil];
    return fileList;
}

@end
