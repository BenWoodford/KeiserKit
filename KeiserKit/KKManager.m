//
//  KKManager.m
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

/** This class has all the methods you'll ever need in it.
 
 To start tracking bikes, you need to make a delegate that implements KKManagerDelegate, and then init KKManager:

    KKManager *manager = [[KKManager alloc] initWithDelegate:yourDelegateClass];
 
 You can start scanning straight away, but I'd recommend doing the scanning via user input and ensuring the Bluetooth state is on in bluetoothStateDidChange (in your delegate):
 
    - (void)bluetoothStateDidChange:(CBCentralManagerState)state withManager:(KKManager *)manager {
        if(state == CBCentralManagerStatePoweredOn) {
            // It's safe to scan
        } else {
            // There's many more [states to check for](https://developer.apple.com/library/IOs//documentation/CoreBluetooth/Reference/CBCentralManager_Class/index.html#//apple_ref/c/tdef/CBCentralManagerState) but this is a simple example.
        }
    }
 
 Then you can start scanning with [manager startScanningForBikes] or simulate bikes with [manager startSimulationWithBikes:aNumberOfBikes], whichever you do, the below will apply and the same methods in your delegate will be called.
 
 bikeListUpdated is called when bikes are found, and provides their latest info. It's recommended that you identify them to the user by the Bike ID, but internally make sure you use the UUID for any unique-identifying as the Bike ID is something set by the bike owner.
 
 You can then follow a bike with [manager followBike:bikeObject] and then bikeListUpdated will stop being called and followedBikeDidUpdate will be called only for that bike.
 
 Easy! Three method implementations and you're tracking a single bike. You could of course track multiple bikes by never following a bike, but that's probably a bit more niche.
 */

#import "KKManager.h"
#import "CycleUtility.h"

@implementation KKManager {
    NSTimer *simTimer;
}

@synthesize centralManager, scanMode, scannedBikes, followedBike, delegate;

- (id)initWithDelegate:(id<KKManagerDelegate>)del {
    self = [self init];
    self.delegate = delegate;
    
    return self;
}

- (id) init {
    if(self == [super self]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    self.isSimulating = false;
    return self;
}


- (bool)startScanningForBikes {
    [self stopListening];
    self.isSimulating = false;
    if(self.centralManager.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth is not ready!");
        return false;
    }
    
    self.scannedBikes = [[NSMutableArray alloc] init]; // Clear the scan array
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
    
    return true;
}

- (void)startSimulationWithBikes:(int)number {
    [self.centralManager stopScan];
    self.scannedBikes = [[NSMutableArray alloc] init]; // Clear the scan array
    
    for(int i = 0; i < number; i++) {
        KKBike *newBike = [[KKBike alloc] init];
        newBike.identifier = [NSUUID UUID];
        newBike.bikeId = number+1;
        [CycleUtility cycleBike:newBike];
        [scannedBikes addObject:newBike];
    }
    
    self.isSimulating = true;
    
    [self.delegate bikeListUpdated:scannedBikes];
    
    simTimer = [NSTimer scheduledTimerWithTimeInterval:[CycleUtility refresh] target:self selector:@selector(simulateRiding) userInfo:nil repeats:TRUE];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // We only care about the M3
    if(![peripheral.name isEqualToString:@"M3"])
        return;
    
    if(![[advertisementData allKeys] containsObject:CBAdvertisementDataManufacturerDataKey]) {
        NSLog(@"Advertisement Data does not contain Manufacturer Data.");
        return;
    }
    
    NSData *data = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    
    if(self.scanMode == Scanning) {
        KKBike *bike = [self getBikeWithUUID:peripheral.identifier];
        
        if(!bike || bike == nil) {
            bike = [[KKBike alloc] initWithData:data];
            bike.RSSI = [RSSI intValue];
            bike.name = peripheral.name;
            bike.peripheral = peripheral;
            bike.identifier = peripheral.identifier;
            [self.scannedBikes addObject:bike];
        } else {
            [bike updateWithData:data];
            bike.name = peripheral.name;
            bike.RSSI = [RSSI intValue];
        }
        
        if(bike.lastUpdate > 0)
            bike.updateDelta = [[NSDate date] timeIntervalSince1970] - bike.lastUpdate;
        
        bike.lastUpdate = [[NSDate date] timeIntervalSince1970];
        
        [self.delegate bikeListUpdated:self.scannedBikes];
    } else {
        if(!self.followedBike || self.followedBike == nil) {
            NSLog(@"Followed bike is nil!");
            return;
        }

        if(peripheral.identifier == self.followedBike.identifier) {
            [self.followedBike updateWithData:data];
            self.followedBike.name = peripheral.name;
            self.followedBike.peripheral = peripheral;
            self.followedBike.RSSI = [RSSI intValue];
            
            if(self.followedBike.lastUpdate > 0)
                self.followedBike.updateDelta = [[NSDate date] timeIntervalSince1970] - self.followedBike.lastUpdate;
            
            self.followedBike.lastUpdate = [[NSDate date] timeIntervalSince1970];
            
            [self.delegate followedBikeDidUpdate:self.followedBike];
        }
    }
}

- (KKBike *)getBikeWithUUID:(NSUUID *)uuid {
    for (KKBike *bike in self.scannedBikes) {
        if(bike.identifier == uuid) {
            return bike;
        }
    }

    return nil;
}

- (void)simulateRiding {
    if(scanMode == Following) {
        [CycleUtility cycleBike:followedBike];
        [self.delegate followedBikeDidUpdate:followedBike];
    } else {
        for (KKBike *bike in scannedBikes) {
            [CycleUtility cycleBike:bike];
        }
        [self.delegate bikeListUpdated:scannedBikes];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.delegate bluetoothStateDidChange:central.state withManager:self];
}

- (void)followBike:(KKBike *)bike {
    self.followedBike = bike;
    self.scanMode = Following;
    
    [self.delegate followedBikeDidUpdate:bike];
}

- (void)followBikeWithUUID:(NSUUID *)uuid {
    [self followBike:[self getBikeWithUUID:uuid]];
}

- (void)stopListening {
    if(self.isSimulating) {
        [simTimer invalidate];
        simTimer = nil;
    } else {
        [self.centralManager stopScan];
    }
}

- (void)stopFollowing {
    self.followedBike = nil;
    self.scanMode = Scanning;
}

@end
