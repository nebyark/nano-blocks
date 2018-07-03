//
//  SwitchTableViewCell.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import Lottie

class SwitchTableViewCell: UITableViewCell {
    
    private(set) var animatedSwitch: LOTAnimatedSwitch?
    @IBOutlet weak var switchContainer: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animatedSwitch = LOTAnimatedSwitch(named: "toggle")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let animatedSwitch = animatedSwitch, let switchBounds = switchContainer?.bounds else { return }
        animatedSwitch.removeFromSuperview()
        animatedSwitch.frame = CGRect(x: 0, y: 0, width: switchBounds.width, height: switchBounds.height)
        animatedSwitch.setProgressRangeForOnState(fromProgress: 0.0, toProgress: 0.5)
        animatedSwitch.setProgressRangeForOffState(fromProgress: 0.5, toProgress: 1.0)
        animatedSwitch.contentMode = .scaleAspectFill
        switchContainer?.addSubview(animatedSwitch)
    }
}
