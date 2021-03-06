//
//  LSURLDispatcherThread.m
//  Lightstreamer Thread Pool Library
//
//  Created by Gianluca Bertani on 10/09/12.
//  Copyright 2013-2015 Weswit Srl
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "LSURLDispatcherThread.h"
#import "LSURLDispatcher.h"
#import "LSLog.h"
#import "LSLog+Internals.h"


#pragma mark -
#pragma mark LSURLDispatcherThread extension

@interface LSURLDispatcherThread () {
	NSTimeInterval _loopInterval;
	
	NSTimeInterval _lastActivity;
	
	BOOL _running;
}


@end


#pragma mark -
#pragma mark LSURLDispatcherThread implementation

@implementation LSURLDispatcherThread


#pragma mark -
#pragma mark Initialization

- (id) init {
    if ((self = [super init])) {
        
        // Initialization
        _running= YES;
		
		// Use a random loop time to avoid periodic delays
		int random= 0;
		SecRandomCopyBytes(kSecRandomDefault, sizeof(random), (uint8_t *) &random);
		_loopInterval= 1.0 + ((double) (ABS(random) % 2000)) / 1000.0;
    }
    
    return self;
}


#pragma mark -
#pragma mark Thread run loop

- (void) main {
    @autoreleasepool {
        NSRunLoop *runLoop= [NSRunLoop currentRunLoop];
        
		[LSLog sourceType:LOG_SRC_URL_DISPATCHER source:[LSURLDispatcher sharedDispatcher] log:@"thread %p started", self];
		
        do {
            @autoreleasepool {
                @try {
                    [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:_loopInterval]];
                    
                } @catch (NSException *e) {
					[LSLog sourceType:LOG_SRC_URL_DISPATCHER source:[LSURLDispatcher sharedDispatcher] log:@"exception caught while running thread %p run loop: %@", self, e];
                }
            }
            
        } while (_running);
        
		[LSLog sourceType:LOG_SRC_URL_DISPATCHER source:[LSURLDispatcher sharedDispatcher] log:@"thread %p stopped", self];
    }
}


#pragma mark -
#pragma mark Execution control

- (void) stopThread {
    _running= NO;
}


#pragma mark -
#pragma mark Properties

@synthesize lastActivity= _lastActivity;



@end
