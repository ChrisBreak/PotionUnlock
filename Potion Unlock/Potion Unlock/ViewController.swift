//
//  ViewController.swift
//  Potion Unlock
//
//  Created by Cristhian Sotelo on 2020-02-14.
//  Copyright © 2020 Cristhian Sotelo. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var ttubeImage: UIImageView!
    @IBOutlet weak var ttubeContent: UIView!
    @IBOutlet weak var xImage: UIImageView!
    @IBOutlet weak var brightTTube: UIImageView!
    @IBOutlet weak var explosionImage: UIImageView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var bgImageHeight: NSLayoutConstraint!
    var circularSlider: DoubleHandleCircularSlider!
    var partRightSlider: CircularSlider!
    var partLeftSlider: CircularSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ttubeContent.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        brightTTube.alpha = 0
        checkmarkImage.alpha = 0
        xImage.alpha = 0
        
        // Do any additional setup after loading the view.
        // init slider view
        let frame = CGRect(x: 0, y: 0, width: sliderView.frame.width, height: sliderView.frame.height)
        circularSlider = DoubleHandleCircularSlider(frame: frame)
        partRightSlider = CircularSlider(frame: frame)
        partLeftSlider = CircularSlider(frame: frame)
        
        // setup target to watch for value change
        circularSlider.addTarget(self, action: #selector(ViewController.valueChanged(_:)), for: UIControl.Event.valueChanged)
        
        // setup slider defaults
        // NOTE: sliderMaximumAngle must be set before currentValue and upperCurrentValue
        circularSlider.maximumAngle = 270.0
        circularSlider.unfilledArcLineCap = .round
        circularSlider.filledArcLineCap = .round
        circularSlider.currentValue = 10
        circularSlider.upperCurrentValue = 60
        circularSlider.lineWidth = 40
        circularSlider.unfilledColor = UIColor.red.withAlphaComponent(0)
        
        partRightSlider.maximumAngle = 270.0
        partRightSlider.unfilledArcLineCap = .round
        partRightSlider.currentValue = 60
        partRightSlider.lineWidth = 40
        partRightSlider.unfilledColor = UIColor.red
        partRightSlider.filledColor = UIColor.red.withAlphaComponent(0)
        
        partLeftSlider.maximumAngle = 270.0
        partLeftSlider.filledArcLineCap = .round
        partLeftSlider.currentValue = 10
        partLeftSlider.lineWidth = 40
        partLeftSlider.unfilledColor = UIColor.red.withAlphaComponent(0)
        partLeftSlider.filledColor = UIColor.green
        
        
        // add to view
        sliderView.addSubview(partRightSlider)
        sliderView.addSubview(partLeftSlider)
        sliderView.addSubview(circularSlider)
        sliderView.alpha = 0.9
        
        // create and set a transform to rotate the arc so the white space is centered at the bottom
        circularSlider.transform = circularSlider.getRotationalTransform()
        partRightSlider.transform = circularSlider.getRotationalTransform()
        partLeftSlider.transform = circularSlider.getRotationalTransform()
        
        if (self.view.frame.height > 672) {
            bgImageHeight.constant = 750
        }
        
    }


    @IBAction func unlockPressed(_ sender: Any) {
        //UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil) //this minimizes the app
        
        let greenAmount = circularSlider.currentValue
        let blueAmount = (circularSlider.upperCurrentValue - circularSlider.currentValue)
        let redAmount = (100 - circularSlider.upperCurrentValue)
        
        print(greenAmount)
        print(blueAmount)
        print(redAmount)
        
        if (greenAmount > 55) && (greenAmount < 65) && (redAmount > 25) && (redAmount < 35) && (blueAmount > 5) && (blueAmount < 15) {
                    
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations: {
                        self.brightTTube.alpha = 1
                        
                }, completion: nil)
                    
                UIView.animate(withDuration: 0.2, delay: 0.6, options: [.curveEaseOut], animations: {
                        self.checkmarkImage.alpha = 1
                        
                }, completion: self.unlockSuccess(success:))
        }
        else {
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations: {
                self.brightTTube.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 0.2, delay: 0.6, options: [.curveEaseOut], animations: {
                    self.xImage.alpha = 1
            }, completion: nil)
                        
            UIView.animate(withDuration: 0.1, delay: 0.7, options: [], animations: {
                self.explosionImage.alpha = 1
            }, completion: self.vibrate(success:))
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.explosionImage.frame.size.width = 800
                self.explosionImage.frame.size.height = 800
                let explosionX = self.explosionImage.frame.minX - 350
                let explosionY = self.explosionImage.frame.minY - 350
                self.explosionImage.frame.origin = CGPoint(x: explosionX, y: explosionY)
            }, completion: self.unlockFailed(success:))
        }
        
    }
    
    private func unlockSuccess(success: Bool) {
        blurView.isHidden = true
        bgImage.alpha = 1
    }
    
    private func vibrate(success: Bool) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func unlockFailed(success: Bool) {
        self.brightTTube.alpha = 0
        self.explosionImage.alpha = 0
        self.xImage.alpha = 0
        self.explosionImage.frame.size.width = 100
        self.explosionImage.frame.size.height = 100
        let explosionX = self.explosionImage.frame.minX + 350
        let explosionY = self.explosionImage.frame.minY + 350
        self.explosionImage.frame.origin = CGPoint(x: explosionX, y: explosionY)
    }
    
    @objc func valueChanged(_ slider: DoubleHandleCircularSlider) {
        partLeftSlider.currentValue = circularSlider.currentValue
        partRightSlider.currentValue = circularSlider.upperCurrentValue
        
        let greenAmount = circularSlider.currentValue / 100
        let blueAmount = (circularSlider.upperCurrentValue - circularSlider.currentValue) / 100
        let redAmount = (100 - circularSlider.upperCurrentValue) / 100
                
        ttubeContent.backgroundColor = UIColor(red: CGFloat(redAmount), green: CGFloat(greenAmount), blue: CGFloat(blueAmount), alpha: 1)
        
    }
    
}

