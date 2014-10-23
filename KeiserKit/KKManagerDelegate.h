//
//  KKManagerDelegate.h
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KKBike.h"

@class KKManager;

@protocol KKManagerDelegate <NSObject>

- (void)bluetoothStateDidChange:(CBCentralManagerState)state withManager:(KKManager*)manager;
- (void)bikeListUpdated:(NSArray*)bikeList;
- (void)followedBikeDidUpdate:(KKBike*)bike;

@end
