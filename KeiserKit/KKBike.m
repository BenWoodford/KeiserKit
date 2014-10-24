//
//  KKBike.m
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBike.h"

@implementation KKBike
const NSRange BUILDMAJOR_R = {2, 1};
const NSRange BUILDMINOR_R = {3, 1};
const NSRange DATATYPE_R = {4, 1};
const NSRange BIKEID_R = {5, 1};
const NSRange RPM_R = {6, 2};
const NSRange HR_R = {8, 2};
const NSRange POWER_R = {10, 2};
const NSRange KCAL_R = {12, 2};
const NSRange MINUTES_R = {14, 1};
const NSRange SECONDS_R = {15, 1};
const NSRange TRIP_R = {16, 2};
const NSRange GEAR_R = {18, 1};

@synthesize peripheral, identifier, name, gear, elapsedSeconds, elapsedMinutes, bikeId, buildMajor, buildMinor, trip, heartRate, kCal, RPM, RSSI, power, dataType;

- (id)initWithData:(NSData *)data {
    if(self = [super init]) {
        [self updateWithData:data];
    }
    
    return self;
}

- (void)updateWithData:(NSData *)data {
    [data getBytes:&buildMajor range:BUILDMAJOR_R];
    [data getBytes:&buildMinor range:BUILDMINOR_R];
    
    [data getBytes:&bikeId range:BIKEID_R];
    [data getBytes:&RPM range:RPM_R];
    [data getBytes:&heartRate range:HR_R];
    [data getBytes:&power range:POWER_R];
    [data getBytes:&kCal range:KCAL_R];
    [data getBytes:&elapsedMinutes range:MINUTES_R];
    [data getBytes:&elapsedSeconds range:SECONDS_R];
    [data getBytes:&gear range:GEAR_R];
    
    uint8_t dt_tmp;
    [data getBytes:&dt_tmp range:DATATYPE_R];
    if(dt_tmp == 0)
        dataType = RealTime;
    else
        dataType = Average;

    uint16_t trip_tmp;
    [data getBytes:&trip_tmp range:TRIP_R];
    trip = (float)trip_tmp / 10.0f;
    
    uint16_t rpm_tmp;
    [data getBytes:&rpm_tmp range:RPM_R];
    RPM = (float)rpm_tmp / 10.0f;
}

- (NSString *)timeInMinutesAndSeconds {
    return [NSString stringWithFormat:@"%d:%d", self.elapsedMinutes, self.elapsedSeconds];
}

@end
