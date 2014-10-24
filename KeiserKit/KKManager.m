//
//  KKManager.m
//  KeiserKit
//
//  Created by Ben Woodford on 23/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import "KKManager.h"

@implementation KKManager

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
    return self;
}

- (bool)startScanningForBikes {
    if(self.centralManager.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth is not ready!");
        return false;
    }
    
    self.scannedBikes = [[NSMutableArray alloc] init]; // Clear the scan array
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
    
    return true;
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

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.delegate bluetoothStateDidChange:central.state withManager:self];
}

- (void)followBike:(KKBike *)bike {
    self.followedBike = bike;
    self.scanMode = Following;
    
    [self.delegate followedBikeDidUpdate:bike];
}

- (void)followBikeWithUUID:(NSUUID *)uuid {
    self.followedBike = [self getBikeWithUUID:uuid];
    self.scanMode = Following;
}

- (void)stopListening {
    [self.centralManager stopScan];
}

- (void)stopFollowing {
    self.followedBike = nil;
    self.scanMode = Scanning;
}

@end
