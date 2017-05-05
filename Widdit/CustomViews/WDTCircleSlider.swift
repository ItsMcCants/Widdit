//
//  WDTCircleSlider.swift
//  Widdit
//
//  Created by JH Lee on 17/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import CircleSlider

@IBDesignable class WDTCircleSlider: CircleSlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    enum WDTCircle {
        case Hours
        case Days
    }
    var circle: WDTCircle = .Hours
    
    class var sliderOptionsHours: [CircleSliderOption] {
        return [
            CircleSliderOption.barColor(UIColor.clear),
            CircleSliderOption.thumbImage(UIImage(named: "post_image_slider_thumb")!),
            CircleSliderOption.thumbWidth(16),
            CircleSliderOption.trackingColor(UIColor.WDTGreenColor()),
            CircleSliderOption.barWidth(12),
            CircleSliderOption.startAngle(270),
            CircleSliderOption.maxValue(24),
            CircleSliderOption.minValue(1)
        ]
    }
    
    class var sliderOptionsDays: [CircleSliderOption] {
        return [
            CircleSliderOption.barColor(UIColor.WDTGreenColor()),
            CircleSliderOption.thumbImage(UIImage(named: "post_image_slider_thumb")!),
            CircleSliderOption.thumbWidth(16),
            CircleSliderOption.trackingColor(UIColor.WDTTealColor()),
            CircleSliderOption.barWidth(12),
            CircleSliderOption.startAngle(270),
            CircleSliderOption.maxValue(31),
            CircleSliderOption.minValue(1)
        ]
    }
    
    var timer: Timer!
    
    init() {
        super.init(frame: .zero, options: WDTCircleSlider.sliderOptionsHours)        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(setDefaultValue), userInfo: nil, repeats: true)
    }
    
    func setDefaultValue() {        
        value += 0.1
        
        if value >= 12 {
            timer.invalidate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func changeOptionsFromHoursToDays() {
        if circle == .Hours {
            circle = .Days
            self.changeOptions(WDTCircleSlider.sliderOptionsDays)
        }
    }
    
    func changeOptionsFromDaysToHours() {
        if circle == .Days {
            circle = .Hours
            self.changeOptions(WDTCircleSlider.sliderOptionsHours)
        }
    }
    
    
    var lastValue: Int = 0
    var stack = [Int]()
    
    func roundControll() {
        let value = Int(self.value)
        if value != lastValue {
            stack.append(value)
            
            if (value >= 1 && value <= 4) && (lastValue >= 22 && lastValue <= 24) && circle == .Hours {
                changeOptionsFromHoursToDays()
            } else if (value >= 27 && value <= 31) && (lastValue >= 1 && lastValue <= 3) && circle == .Days {
                changeOptionsFromDaysToHours()
            }
            lastValue = value
        }
    }
   
}
