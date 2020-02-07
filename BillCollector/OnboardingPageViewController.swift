//
//  OnboardingPageViewController.swift
//  Bill Collector
//
//  Created by Christopher Garcia on 5/19/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var imageNames: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageNames = ["Onboarding-1", "Onboarding-2", "Onboarding-3", "Onboarding-4", "Onboarding-5"]
        
        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let onboardingView: OnboardingViewController = viewController as! OnboardingViewController
        
        var index = onboardingView.pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        
        index -= 1
        
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let onboardingView: OnboardingViewController = viewController as! OnboardingViewController
        
        var index = onboardingView.pageIndex
        
        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == imageNames.count) {
            return nil
        }
        
        return getViewControllerAtIndex(index)
    }
    
    func getViewControllerAtIndex(_ index: NSInteger) -> OnboardingViewController {
        let onboardingViewController = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController

        onboardingViewController.imageName = imageNames[index] as! String
        onboardingViewController.pageIndex = index
        
        return onboardingViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imageNames.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
//    func gettingStartedButtonPressed(_ sender: UIButton) {
//        _ = self.navigationController?.popToRootViewController(animated: true)
//    }
//    
//    func skipButtonPressed(_ sender: UIButton) {
//        _ = self.navigationController?.popToRootViewController(animated: true)
//    }
    
}
