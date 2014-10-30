//
//  KKManager.h
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KKManagerDelegate.h"

@interface KKManager : NSObject<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) id<KKManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *scannedBikes;
@property (nonatomic, assign) enum {Scanning,Following} scanMode;
@property (nonatomic, assign) bool isSimulating;

@property (nonatomic, assign) KKBike *followedBike;

- (id)initWithDelegate:(id<KKManagerDelegate>)del;
- (void)followBikeWithUUID:(NSUUID*)uuid;
- (void)followBike:(KKBike*)bike;
- (bool)startScanningForBikes;
- (void)startSimulationWithBikes:(int)number;
- (void)stopListening;
- (void)stopFollowing;
- (KKBike*)getBikeWithUUID:(NSUUID*)uuid;

@end
