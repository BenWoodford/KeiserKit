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

/** A proxy method for the CBCentralManagerDelegate bluetoothStateDidChange
 
 @param CBCentralManagerState The CBCentralManager's state taking from the state property
 @param KKManager The instance of KKManager
*/
- (void)bluetoothStateDidChange:(CBCentralManagerState)state withManager:(KKManager*)manager;

/** Called when the array of bikes is updated during Scanning mode
 
 @param NSArray An array of KKBike pointers
*/
- (void)bikeListUpdated:(NSArray*)bikeList;

/** Called when the bike the library is following updates
 
 @param KKBike The followed bike, with updated data
*/
- (void)followedBikeDidUpdate:(KKBike*)bike;

@end
