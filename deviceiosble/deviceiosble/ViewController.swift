//
//  ViewController.swift
//  deviceiosble
//
//  Created by Motokazu Nishimura on 2016/10/22.
//  Copyright © 2016年 mtkz.info. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    // MotionManager
    let motionManager = CMMotionManager()
    // acceleration limit
    let accelerationLimit:CGFloat = 7.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if motionManager.isAccelerometerAvailable {
            // 加速度センサーの値取得間隔
            motionManager.accelerometerUpdateInterval = 0.1
            
            // motionの取得を開始
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                // 取得した値をコンソールに表示
                print("x: \(data?.acceleration.x) y: \(data?.acceleration.y) z: \(data?.acceleration.z)")
                
                var r = CGFloat((data?.acceleration.x)! * 100.0)
                var g = CGFloat((data?.acceleration.y)! * 100.0)
                var b = CGFloat((data?.acceleration.z)! * 100.0)
                
                // limitation
                if r > self.accelerationLimit {
                    r = self.accelerationLimit
                }
                if g > self.accelerationLimit {
                    g = self.accelerationLimit
                }
                if b > self.accelerationLimit {
                    b = self.accelerationLimit
                }
                r = r / self.accelerationLimit
                g = g / self.accelerationLimit
                b = b / self.accelerationLimit
                
                print("r : \(r) g : \(g) b : \(b)")
                
                let c:UIColor = UIColor(red:r,green:g,blue:b,alpha:1.0)
                self.view.backgroundColor = c
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

