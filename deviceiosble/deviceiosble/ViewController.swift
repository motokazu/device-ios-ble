//
//  ViewController.swift
//  deviceiosble
//
//  Created by Motokazu Nishimura on 2016/10/22.
//  Copyright © 2016年 mtkz.info. All rights reserved.
//

import UIKit
import CoreMotion
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MotionManager
    let motionManager = CMMotionManager()
    // acceleration limit
    let accelerationLimit:CGFloat = 7.0
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    let bleServiceUUID = CBUUID(string:"5B9631B5-5876-40AA-9C39-A6A07FCC1537")
    let bleCharacteristicUUID = CBUUID(string:"3FA7ABD1-DEE5-4206-B4F5-F182187F7A1A")
    
    var foundEdison = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if motionManager.isAccelerometerAvailable {
            // 加速度センサーの値取得間隔
            motionManager.accelerometerUpdateInterval = 0.1
            
            // motionの取得を開始
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                // 取得した値をコンソールに表示
                //print("x: \(data?.acceleration.x) y: \(data?.acceleration.y) z: \(data?.acceleration.z)")
                
                var r = CGFloat((data?.acceleration.x)! * 10.0)
                var g = CGFloat((data?.acceleration.y)! * 10.0)
                var b = CGFloat((data?.acceleration.z)! * 10.0)
                
                // limitation
                r = r < 0.0 ? -r : r
                r = (r>self.accelerationLimit) ? self.accelerationLimit: r
                r = r / self.accelerationLimit
                
                g = g < 0.0 ? -g : g
                g = (g>self.accelerationLimit) ? self.accelerationLimit: g
                g = g / self.accelerationLimit
                
                b = b < 0.0 ? -b : b
                b = (b>self.accelerationLimit) ? self.accelerationLimit: b
                b = b / self.accelerationLimit
                
                let c:UIColor = UIColor(red:r,green:g,blue:b,alpha:1.0)
                self.view.backgroundColor = c
                
                if self.foundEdison == true {
                    // send data to edison
                    let epocht = NSDate().timeIntervalSince1970
                    let textdata = NSString(format:"%ld,%f,%f,%f", epocht,r,g,b)
                    let data = textdata.data(using: String.Encoding.utf8.rawValue, allowLossyConversion:true)
                    
                    self.peripheral.writeValue(data!, for: self.characteristic, type: CBCharacteristicWriteType.withoutResponse)
                    
                    print("writeValue : \(textdata)" )
                }
            })
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////
    ////
    @IBAction func scanButton(_ sender: AnyObject) {
        
        // central manager 起動
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)");
        
        switch (central.state) {
        case .poweredOff:
            print("Bluetooth Powered Off")
        case .poweredOn:
            print("Bluetooth Powered On")
            // peripheral探索
            central.scanForPeripherals(withServices: [bleServiceUUID] , options: nil)
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("BLE_Device:\(peripheral)")
        
        if (peripheral.name?.hasPrefix("edison"))! {
            self.peripheral = peripheral
            self.centralManager.connect(self.peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("Connected")
        peripheral.delegate = self
        peripheral.discoverServices([self.bleServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("error: \(error)")
            return
        }
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([bleCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("error: \(error)")
            return
        }
        for characteristic in service.characteristics! {
            if characteristic.uuid.isEqual(bleCharacteristicUUID) {
                print("Found Edison")
                self.foundEdison = true
                self.peripheral = peripheral
                self.characteristic = characteristic
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        print("Connect error...")
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("Disconnect!")
        if error != nil {
            print("error: \(error)")
        }
        self.centralManager.cancelPeripheralConnection(self.peripheral)
        self.peripheral = nil
        self.foundEdison = false
    }
    
}

