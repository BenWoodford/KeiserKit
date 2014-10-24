//
//  CycleUtility.m
//  KeiserKit
//
//  Created by Ben Woodford on 24/10/2014.
//  Copyright (c) 2014 Ben Woodford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CycleUtility.h"

@implementation CycleUtility

const float bikeRefresh = 2.0f;

+ (float)refresh {
    return bikeRefresh;
}

+ (void)cycleBike:(KKBike*)bike {
    int effort = [CycleUtility effortPredictor];
    
    if(effort == 1) {
        if(bike.gear < 24)
            bike.gear++;
        
        if(bike.RPM < 1100)
            bike.RPM += (arc4random() % 100) + 1;
        
        bike.heartRate += (arc4random() % 20) + 11;
    } else if(effort == -1) {
        if(bike.gear > 2)
            bike.gear--;
        if(bike.RPM > 400)
            bike.RPM -= (arc4random() % 100) + 1;
        
        bike.heartRate -= (arc4random() % 20) + 11;
    }
    
    bike.power = (bike.gear / 64.0f) * bike.RPM;
    
    // I don't even know what these numbers are, I just stole them from Keiser's simulator.
    bike.kCal += ((bike.power / 4.187f) * 4.0f * [CycleUtility refresh]) / 1000.0f;
    bike.elapsedSeconds += [CycleUtility refresh];
    if(bike.elapsedSeconds >= 60) {
        bike.elapsedMinutes++;
        bike.elapsedSeconds = bike.elapsedSeconds - 60;
    }
    bike.trip += bike.power / 1000.0f;
    
    if(arc4random() % 10 > 5) {
        if(bike.RSSI < -19) {
            bike.RSSI++;
        }
    } else {
        if(bike.RSSI > -60)
            bike.RSSI--;
    }
}

+ (int)effortPredictor {
    int effort = (arc4random() % 100) + 1;
    
    if(effort >= 60)
        return 1;
    else if(effort >= 40)
        return 0;
    else
        return -1;
}

@end