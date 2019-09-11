//
//  AppUtility.swift
//  HolidayPlan
//
//  Created by datt on 4/4/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import AudioToolbox

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            //delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}
// MARK:- Navigation

func viewController(withID ID : String) -> UIViewController {
    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ID)
    return controller
}

func setVibrate()  {
    if #available(iOS 10.0, *) , UIDevice.current.hasHapticFeedback == true {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    } else {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)// AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        if let topController = UIApplication.topViewController() {
            topController.showToast(message: "No Internet Connection")
        }
        return false
    }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        if let topController = UIApplication.topViewController() {
            topController.showToast(message: "No Internet Connection")
        }
        return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    if !(isReachable && !needsConnection)
    {
        if let topController = UIApplication.topViewController() {
            topController.showToast(message: "No Internet Connection")
        }
    }
    return (isReachable && !needsConnection)
}
public extension UIDevice{
    public func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }}
public extension UIDevice {
    public var hasHapticFeedback: Bool {
        return ["iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4"].contains(platform())
    }
}
extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
extension UIViewController   {
    
    func showToast(message : String) {
        self.view.endEditing(true)
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2, delay: 2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UITableViewCell
{
    func cellAnimate(){
        //1. Setup the CATransform3D structure
        var rotation = CATransform3D()
        rotation = CATransform3DMakeRotation((90.0 * .pi) / 180, 0.0, 0.7, 0.4)
        rotation.m34 = 1.0 / -600
        //2. Define the initial state (Before the animation)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: CGFloat(10), height: CGFloat(10))
        self.alpha = 0
        self.layer.transform = rotation
        self.layer.anchorPoint = CGPoint(x: CGFloat(0), y: CGFloat(0.5))
        //3. Define the final state (After the animation) and commit the animation
        UIView.beginAnimations("rotation", context: nil)
        UIView.setAnimationDuration(0.8)
        self.layer.transform = CATransform3DIdentity
        self.alpha = 1
        self.layer.shadowOffset = CGSize(width: CGFloat(0), height: CGFloat(0))
        UIView.commitAnimations()
    }
}
extension UINavigationController
{
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
}

extension UITextField
{
    func shake () {
        setVibrate()
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        
        self.layer.add(animation, forKey: "position")
        
    }
}
//extension GADBannerView
//{
//
//    func setBanner()   {
//        self.adUnitID = "ca-app-pub-4018971263267828/3696080595"
//         if let topController = UIApplication.topViewController() {
//         self.rootViewController = topController
//         }
//        //  bannerView.load(GADRequest())
//        let request: GADRequest = GADRequest()
//        //request.testDevices = [kDFPSimulatorID]
//        self.load(request)
//
//    }
//}
