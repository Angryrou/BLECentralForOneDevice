//
//  ViewController.swift
//  BluetoothCentral
//
//  Created by Kawhi Lu on 15/9/15.
//  Copyright (c) 2015年 Kawhi Lu. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var mycentralManager: CBCentralManager!
    var myperipheral: CBPeripheral!
    var myService: CBService!
    var readCharacteristic: CBCharacteristic!
    var writeCharacteristic: CBCharacteristic!
    let HiphoneServiceUUID = CBUUID(string: "64E0C29C-FFC0-4811-97EF-0B9D4E1174F5")
    let HiphoneCharacteristicUUID = CBUUID(string: "33F1C2B0-AB2A-490B-B661-21A62E592A16")
    
    @IBOutlet weak var deviceName: NSTextField!
    @IBOutlet weak var connectionState: NSTextField!
    @IBOutlet weak var serviceState: NSTextField!
    @IBOutlet weak var characteristicState: NSTextField!
    
    @IBAction func discoverAction(sender: AnyObject) {
        mycentralManager.scanForPeripheralsWithServices(nil, options: nil)
    }

    @IBAction func connectionAction(sender: AnyObject) {
        mycentralManager.connectPeripheral(myperipheral, options: nil)
    }
    
    @IBAction func findServiceAction(sender: AnyObject) {
        myperipheral.discoverServices(nil)
    }

    @IBAction func findCharacteristicAction(sender: AnyObject) {
        myperipheral.discoverCharacteristics(nil, forService: myService)
    }
    
    
    //  Start central
    func startCentralManager(){
        mycentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func
        centralManagerDidUpdateState(central: CBCentralManager){
        print("CentralManager is initialized", terminator: "")
        
        switch central.state{
        case CBCentralManagerState.Unauthorized:
            print("The app is not authorized to use Bluetooth low energy.", terminator: "")
        case CBCentralManagerState.PoweredOff:
            print("Bluetooth is currently powered off.", terminator: "")
        case CBCentralManagerState.PoweredOn:
            print("Bluetooth is currently powered on and available to use.", terminator: "")
        default:break
        }
    }

    //  Discover peripheral
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
        print("peripheral: \(peripheral)", terminator: "")
        print("CenCentalManagerDelegate didDiscoverPeripheral", terminator: "")
        print("Discovered \(peripheral.name)", terminator: "")
        print("Rssi: \(RSSI)", terminator: "")
        print("Stop scan the Ble Devices", terminator: "")
        
        let str = peripheral.name
        self.deviceName.stringValue = str!
        self.mycentralManager.stopScan()
        self.myperipheral = peripheral
    }
    
    //  Connect peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("CenCentalManagerDelegate didConnectPeripheral", terminator: "")
        print("Connected with \(peripheral.name)", terminator: "")
        connectionState.stringValue = "connected!"
        self.myperipheral.delegate = self
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("CenCentalManagerDelegate didFailToConnectPeripheral", terminator: "")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        connectionState.stringValue = "disconnect"
        print("CenCentalManagerDelegate didDisconnectPeripheral")
    }
    
    
    // Discover services
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("CBPeripheralDelegate didDiscoverServices")
        for  service in peripheral.services! {
            let thisService = service 
            print("Discover service \(service)")
//            print("UUID \(service.UUIDString)")
            
            if service.UUID == HiphoneServiceUUID {
                // Discover characteristics of IR Temperature Service
                print("Find HiphoneServe")
                
                self.myService = thisService
                serviceState.stringValue = "Found"
            }
        }
    }
    
    // Discover characteristic
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?){
        if (error != nil) {
            print("error: \(error)", terminator: "")
            return
        }
        for characteristic in service.characteristics!{
         
            print("Discover characteristic \(characteristic)", terminator: "\n")
            print("UUID \(characteristic.UUID)", terminator: "\n")
            
            if characteristic.UUID == HiphoneCharacteristicUUID {
                readCharacteristic = characteristic
                peripheral.setNotifyValue(true, forCharacteristic: readCharacteristic)
                print("Found Hiphone Characteristic", terminator: "\n")
                characteristicState.stringValue = "Found"
            }

        }
        
//        let characteristics: NSArray = service.characteristics
//        println("Found \(characteristics.count) characteristics! : \(characteristics)")
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        if error != nil {
            print("Notify状態更新失敗...error: \(error)", terminator: "\n")
        }
        else {
            print("Notify状態更新成功！ isNotifying: \(characteristic.isNotifying)", terminator: "\n")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        if (error != nil) {
            print("Failed... error: \(error)", terminator: "")
            return
        }
        let data = characteristic.value!
        let str = ConvertNSDataToString(data)
        let darray = str.componentsSeparatedByString("&")
        let d1 = darray[0]
        let d2 = darray[1]
        let d3 = darray[2]
        let d4 = darray[3]
        let d5 = darray[4]
        let d6 = darray[5]
        let d7 = darray[6]
        let d8 = darray[7]
        let d9 = darray[8]
        print("Succeeded! device name: \(peripheral.name)")
        print("userAcceleration: x \(d1), y \(d2), z \(d3)")
        print("rotationRate: x \(d4), y \(d5), z \(d6)")
        print("attitude: roll \(d7), pitch \(d8), yaw \(d9)")
    }
    
    
    func ConvertNSDataToString(data: NSData) -> String
    {
        let str : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        return str as String
    }
    
    func ConvertNSDataToDouble(data: NSData) -> Double
    {
        let str : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let d = str.doubleValue
        return d
    }
    
    func ConvertDoubleToNSData(d: Double) -> NSData{
        let str = NSString(format: "%f", d)
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
        return data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startCentralManager()

//        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

