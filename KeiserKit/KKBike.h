//
//  KKBike.h
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface KKBike : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, assign) int RSSI;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int buildMinor;
@property (nonatomic, assign) int buildMajor;
@property (nonatomic, assign) enum {RealTime,Average} dataType;
@property (nonatomic, assign) int bikeId;
@property (nonatomic, assign) float RPM;
@property (nonatomic, assign) float heartRate;
@property (nonatomic, assign) int power;
@property (nonatomic, assign) int kCal;
@property (nonatomic, assign) int elapsedMinutes;
@property (nonatomic, assign) int elapsedSeconds;
@property (nonatomic, assign) float trip;
@property (nonatomic, assign) int gear;
@property (nonatomic, assign) float updateDelta;
@property (nonatomic, assign) float lastUpdate;

-(id)initWithData:(NSData*)data;
-(void)updateWithData:(NSData*)data;
-(NSString*)timeInMinutesAndSeconds;

@end