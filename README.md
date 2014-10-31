You can find a sample project [here](https://github.com/BenWoodford/KeiserKit.git)

To start tracking bikes, you need to make a delegate that implements KKManagerDelegate, and then init KKManager:

```
KKManager *manager = [[KKManager alloc] initWithDelegate:yourDelegateClass];
```

You can start scanning straight away, but I'd recommend ensuring the Bluetooth state is on in bluetoothStateDidChange (in your delegate) and calling it from there:

```
- (void)bluetoothStateDidChange:(CBCentralManagerState)state withManager:(KKManager *)manager {
    if(state == CBCentralManagerStatePoweredOn) {
	[manager startScanningForBikes];
    } else {
        // There's many more [states to check for](https://developer.apple.com/library/IOs//documentation/CoreBluetooth/Reference/CBCentralManager_Class/index.html#//apple_ref/c/tdef/CBCentralManagerState) but this is a simple example.
    }
}
```

You can start scanning with `[manager startScanningForBikes]` or simulate bikes with `[manager startSimulationWithBikes:aNumberOfBikes]`, the same methods will be called for updates either way.
 
`bikeListUpdated` is called when bikes are found, and provides their latest info. It's recommended that you identify them to the user by the Bike ID, but internally make sure you use the UUID for any unique-identifying as the Bike ID is something set by the bike owner.
 
You can then follow a bike with `[manager followBike:bikeObject]` and then `bikeListUpdated` will stop being called and `followedBikeDidUpdate` will be called only for that bike.
 
Easy! Three method implementations and you're tracking a single bike. You could of course track multiple bikes by never following a bike, but that's probably a bit more niche.
