//
//  JobUploaderController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 03/07/12.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "JobUploaderController.h"

@interface JobUploaderController (){
    BOOL running;
}
- (void) executeJob;

@end

@implementation JobUploaderController

+ (JobUploaderController*) getController
{
    static dispatch_once_t pred;
    static JobUploaderController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[JobUploaderController alloc] init];
    });
    
    return shared; 
}

- (void) start
{
    running = YES;
    
    dispatch_queue_t jobQueue = dispatch_queue_create("job_queue", NULL);
    dispatch_async(jobQueue, ^{
        @try {
            // start the thread
            while (running) {
                // sleep for 5 seconds
                [NSThread sleepForTimeInterval:5];
                // execute the method
                [self executeJob];
            }       
        }@catch (NSException *exception) {
            NSLog(@"Error in the job %@", [exception description]);
        }
    });
    dispatch_release(jobQueue);
}

- (void) stop
{
    // this will stop the thread
    running = NO;
}

- (BOOL) isRunning
{
    return running;
}


- (void) executeJob
{
    NSLog(@"Executing the job");
}


@end