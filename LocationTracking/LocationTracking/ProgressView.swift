//
//  ProgressView.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 7/27/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ProgressView: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .extraLight)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let height: CGFloat = 50.0
        self.frame = CGRect(x: 0,y: 0,width: screen_width,height: screen_height)
        vibrancyView.frame = self.bounds
        
        let activityIndicatorSize: CGFloat = 50
        activityIndictor.frame = CGRect(x: 0,y: 0,width: activityIndicatorSize,height: activityIndicatorSize)
        activityIndictor.center = CGPoint(x: screen_width/2, y: screen_height/2)
        
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.frame = CGRect(x: 0,y: 0,width: screen_width,height: height)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}
