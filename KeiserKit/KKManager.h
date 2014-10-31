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

/** Initialisation Method
 
 @param id<KKManagerDelegate> Your implemented delegate
 @return A new instance of KKManager
 */
- (id)initWithDelegate:(id<KKManagerDelegate>)del;

/** Follows a bike by its UUID
 @param NSUUID The UUID of the bike to follow
 */
- (void)followBikeWithUUID:(NSUUID*)uuid;

/** Follows a certain bike, switching the mode from Scanning to Following
 
 @param KKBike The bike pointer to follow
 */
- (void)followBike:(KKBike*)bike;

/** Starts scanning for bikes (providing Bluetooth is enabled)
 
 @return TRUE if nothing went wrong, but if the state of the CBCentralManager isn't CBCentralManagerStatePoweredOn then it'll return FALSE
 */
- (bool)startScanningForBikes;

/** Simulates a number of bikes using some watered down simulation code from [Keiser.M3i.ReceiverSim](https://github.com/KeiserCorp/Keiser.M3i.ReceiverSim)
 
 @param int The number of bikes to simulate
 */
- (void)startSimulationWithBikes:(int)number;

/** Stops scanning (or simulating) for bikes */

- (void)stopListening;

/** Stops following the current bike and returns to scanning mode */

- (void)stopFollowing;

/** Gets a bike from the bike list by its UUID
 
 @param NSUUID The UUID of the bike you're looking for
 @return nil if bike is not found, otherwise the KKBike pointer
 */
- (KKBike*)getBikeWithUUID:(NSUUID*)uuid;

@end
