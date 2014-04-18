#import "CDRExceptionExample.h"
#import "CDRReportDispatcher.h"

@interface CDRExample (Private)
- (void)setState:(CDRExampleState)state;
@end

@implementation CDRExceptionExample

+ (CDRExample *)example {
    return [[CDRExceptionExample alloc] init];
}

- (instancetype)init {
    return [super initWithText:@"should raise exception"];
}

- (void)runWithDispatcher:(CDRReportDispatcher *)dispatcher {
    [startDate_ release];
    startDate_ = [[NSDate alloc] init];
    [dispatcher runWillStartExample:self];

    if (!self.shouldRun) {
        self.state = CDRExampleStateSkipped;
    } else {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            [parent_ setUp];
            if (parent_.subjectActionBlock) { parent_.subjectActionBlock(); }
            self.state = CDRExampleStateFailed;
        } @catch(...) {
            self.state = CDRExampleStatePassed;
        } @finally {
            @try {
                [parent_ tearDown];
            } @catch (NSObject *x) {
                if (self.state != CDRExampleStateFailed) {
                    self.failure = [CDRSpecFailure specFailureWithRaisedObject:x];
                    self.state = CDRExampleStateError;
                }
            }
        }
        [pool drain];
    }
    [endDate_ release];
    endDate_ = [[NSDate alloc] init];

    [dispatcher runDidFinishExample:self];
}

@end
