//
//  CustomControl.swift
//  StarRating
//
//  Created by Karen Rodriguez on 3/19/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import UIKit

class CustomControl: UIControl {
    
    // MARK: - Properties
    
    var value: Int = 0 {
        didSet {
            print("didSet")
            sendActions(for: [.valueChanged])
        }
    }
    var labels: [UILabel] = []
    var rightToLeft: Bool = false {
        didSet {
            setup()
        }
    }
    
    // MARK: - Private Properties
    
    private let componentDimension: CGFloat = 40.0
    private let componentCount: Int = 5
    private let componentActiveColor: UIColor = .black
    private let componentInactiveColor: UIColor = .gray
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        value = 1
        
        for tag in 0..<componentCount {
            let newLabel = UILabel()
            
            if !rightToLeft {
                newLabel.tag = tag + 1
            } else {
                newLabel.tag = componentCount - tag
            }
            
            if tag + 1 == 1 {
                newLabel.frame = CGRect(x: (componentDimension / CGFloat(componentCount)), y: 0.0, width: componentDimension, height: componentDimension)
            } else {
                newLabel.frame = CGRect(x: labels.last!.frame.maxX + (componentDimension / CGFloat(componentCount)), y: 0.0, width: componentDimension, height: componentDimension)
            }
            if newLabel.tag == 1 {
                newLabel.textColor = componentActiveColor
            } else {
                newLabel.textColor = componentInactiveColor
            }
            
            newLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
            newLabel.text = "✭"
            newLabel.textAlignment = .center
            labels.append(newLabel)
            addSubview(newLabel)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let componentsWidth = CGFloat(componentCount) * componentDimension
        let componentsSpacing = CGFloat(componentCount + 1) * (componentDimension / CGFloat(componentCount))
        let width = componentsWidth + componentsSpacing
        return CGSize(width: width, height: componentDimension)
    }
    
    private func updateValue(at touch: UITouch) {
        var updateValue = value
        
        for tag in 0..<labels.count {
            let touchPoint = touch.location(in: labels[tag])
            
            if labels[tag].bounds.contains(touchPoint) {
                print("Touched at tag: \(labels[tag])")
                updateValue = labels[tag].tag
                
                for activeLabel in labels {
                    if activeLabel.tag <= labels[tag].tag {
                        activeLabel.textColor = componentActiveColor
                    } else {
                        activeLabel.textColor = componentInactiveColor
                    }
                }
                
                labels[tag].performFlare()
                
            }
        }
        
        if updateValue != value {
            value = updateValue
        }
    }
    
    // MARK: - Control Methods
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(at: touch)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        
        if self.bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: [.touchDragInside])
        } else {
            sendActions(for: [.touchDragOutside])
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else { return }
        
        let touchPoint = touch.location(in: self)
        
        if self.bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: [.touchUpInside])
        } else {
            sendActions(for: [.touchUpOutside])
        }
        
    }
    
    override func cancelTracking(with event: UIEvent?) {
        sendActions(for: [.touchCancel])
    }
    
}

extension UIView {
    func performFlare() {
        func flare() { transform = CGAffineTransform(scaleX: 1.6, y: 1.6) }
        func unflare() { transform = .identity }
        
        UIView.animate(withDuration: 0.3,
                       animations: { flare() },
                       completion: { _ in UIView.animate(withDuration: 0.1) { unflare() }})
    }
}
