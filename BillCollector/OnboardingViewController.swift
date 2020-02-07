//
//  OnboardingViewController.swift
//  Bill Collectorasdfasdasdasdasdfasdfasdfasdasdf
//
//  Created by Christopher Garcia on 5/19/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var onboardingImage: UIImageView!
    @IBOutlet weak var gettingStartedButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var imageName: String!, pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingImage.image = UIImage(named: imageName)
        
        if (imageName == "Onboarding-5") {
            onboardingImage.isHidden = true
            gettingStartedButton.isHidden = false
            skipButton.isHidden = true
        }
        
        gettingStartedButton.addTarget(self, action: #selector(OnboardingViewController.closeOnboarding(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(OnboardingViewController.closeOnboarding(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func closeOnboarding(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
}
