//
//  DownloadOperation.h
//  SoftServe Discount
//
//  Created by agavrish on 26.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPJsonParser.h"
#import "CDCoreDataManager.h"


@interface DownloadOperation : NSOperation <JPJsonParserDelegate>

@property (nonatomic, strong) JPJsonParser *downloader;
@property (nonatomic, strong) CDCoreDataManager *coreDataManager;

-(void) performOperationWithURL:(NSString *)url withName:(NSString *)name completion:(void (^)())completion;

@end
