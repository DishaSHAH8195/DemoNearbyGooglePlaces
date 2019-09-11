//
//  ViewController.swift
//  DemoNearbyGooglePlaces
//
//  Created by Disha on 3/8/19.
//  Copyright © 2019 Disha. All rights reserved.
//

import UIKit
import CoreLocation

class CategoryListVC: UIViewController,UISearchBarDelegate{
    
    // MARK: - IBOutlets
    // MARK: -
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tblViewSearch: UITableView!
    
    // MARK: - Variables
    // MARK: -
    var filterAry = [String]()
    var isSearch = false
    var CurrentLocation = CLLocation()
    var aryCategory = ["Accounting","Airport","Amusement park","Aquarium","Art gallery","Atm","Bakery","Bank","Bar","Beauty salon","Bicycle store","Book store","Bowling alley","Bus station","Cafe","Campground","Car dealer","Car rental","Car repair","Car wash","Casino","Cemetery","Church","City hall","Clothing store","Convenience store","Courthouse","Dentist","Department store","Doctor","Electrician","Electronics store","Embassy","Establishment","Finance","Fire station","Florist","Food","Funeral home","Furniture store","Gas station","General contractor","Grocery or supermarket","Gym","Hair care","Hardware store","Health","Hindu temple","Home goods store","Hospital","Insurance agency","Jewelry store","Laundry","Lawyer","Library","Liquor store","Local government office","Locksmith","Lodging","Meal delivery","Meal takeaway","Mosque","Movie rental","Movie theater","Moving company","Museum","Night club","Painter","Park","Parking","Pet store","Pharmacy","Physiotherapist","Place of worship","Plumber","Police","Post office","Real estate agency","Restaurant","Roofing contractor","Rv park","School","Shoe store","Shopping mall","Spa","Stadium","Storage","Store","Subway station","Synagogue","Taxi stand","Train station","Transit station","Travel agency","University","Veterinary care","Zoo"]

    override func viewDidLoad() {
        super.viewDidLoad()
            self.title = "Select Category"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Notification oberserver methods
    // MARK: -
    @objc func didBecomeActive() {
        setCurrentLocation()
    }
    
    @objc func willEnterForeground() {
        self.CurrentLocation = CLLocation()
    }

    // MARK: - Searchbar related methods and delegates
    // MARK: -

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.count)! > 0{
            isSearch = true
            search(searchText: searchBar.text!)
        }else{
            isSearch = false
        }
        searchBar.showsCancelButton = true
        tblViewSearch.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false;
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false;
        self.view.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText: searchText)
    }
    
    func search(searchText: String)  {
        let predicate = NSPredicate(format: "self CONTAINS[cd] %@", searchText)
        filterAry = (aryCategory as NSArray).filtered(using: predicate) as! [String]
        //print("\(autoCompleteFilterArray)")
        if searchText.count > 0
        {
            isSearch = true
        }
        else
        {
            isSearch = false
        }
        tblViewSearch.reloadData()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        var isIN = false
        if isSearch
        {
            if filterAry.contains((searchBar.text?.lowercased().capitalizingFirstLetter())!)
            {
                isIN = true
            }
        }
        else
        {
            if aryCategory.contains((searchBar.text?.lowercased().capitalizingFirstLetter())!)
            {
                isIN = true
            }
        }
        if isIN {
            let replace = searchBar.text?.lowercased().replacingOccurrences(of: " ", with: "_")
            print(replace ?? "")
            if !(CurrentLocation.coordinate.latitude.isZero){
                let nearByPlacesVC = viewController(withID: String(describing:NearByPlacesVC.self)) as! NearByPlacesVC
                nearByPlacesVC.strReplace = replace!
                nearByPlacesVC.lat = CurrentLocation.coordinate.latitude
                nearByPlacesVC.long = CurrentLocation.coordinate.longitude
                self.navigationController?.pushViewController(nearByPlacesVC, animated: true)
            }
        }
        else
        {
            self.showToast(message: "Please select category")
        }
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Get User's Current Location on Map
    // MARK: -
    func setCurrentLocation()
    {
        LocationManager.sharedInstance.getLocation { (location:CLLocation?, error:NSError?) in
            
            if error != nil {
                self.alertMessage(message: (error?.localizedDescription)!, buttonText: "OK", completionHandler: nil)
                return
            }
            guard let _ = location else {
                self.alertMessage(message:"Unable To Fetch Current Location", buttonText: "OK", completionHandler: nil)
                return
            }
            self.CurrentLocation = location!
        }
    }
    
    // MARK: - Set AlertView for Settings and Location
    // MARK: -
    func alertMessage(message:String,buttonText:String,completionHandler:(()->())?) {
        
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }
        alert.addAction(okAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoryListVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "\(searchBar.text!)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSearch{
           return filterAry.count
        }else{
           return aryCategory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = (tblViewSearch?.dequeueReusableCell(withIdentifier: "SearchCell"))!
            if isSearch{
                cell.textLabel?.text = filterAry[indexPath.row]
            }else{
                cell.textLabel?.text = aryCategory[indexPath.row]
            }
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if isSearch
            {
                searchBar.text = filterAry[indexPath.row]
            }
            else
            {
                searchBar.text = aryCategory[indexPath.row]
                
            }
            searchBarSearchButtonClicked(searchBar)
        }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
