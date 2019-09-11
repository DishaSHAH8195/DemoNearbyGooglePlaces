//
//  NearByPlacesVC.swift
//  DemoNearbyGooglePlaces
//
//  Created by Disha on 3/8/19.
//  Copyright © 2019 Disha. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Kingfisher

class NearByPlacesVC: UIViewController{
    
    @IBOutlet var tblSearchNearbyView: UITableView!
    @IBOutlet var mapView: GMSMapView!
    
    var strReplace = String()
    open var lat : CLLocationDegrees?
    open var long : CLLocationDegrees?
    var resultAry = [AnyObject]()
    var bounds = GMSCoordinateBounds()

    override func viewDidLoad() {
        super.viewDidLoad()
        googleMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlacesByLatLong()
    }
    
    func getPlacesByLatLong(){
        ApiCall.sharedInstance.requestGetMethod(apiUrl: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat!),\(long!)&types=\(strReplace)&radius=50000&sensor=false&key=AIzaSyBG2lM5lHV6a0N2_Gk3fUV3Vz8DnI8z_OU") { (success, responseData) in
            //   print(responseData ?? AnyObject.self)
            self.resultAry = responseData?["results"] as! [AnyObject]
            print(self.resultAry)
            DispatchQueue.main.async{
                self.tblSearchNearbyView.reloadData()
                self.pinPlaces()
            }
        }
    }
    
    func googleMap()
    {
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    func pinPlaces(selectedIndex : Int = -1)
    {
        if !isInternetAvailable(){return}
        //mapView.clear()
        for i in 0 ..< resultAry.count
        {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees((resultAry[i]["geometry"] as! [String:[String:AnyObject]])["location"]?["lat"] as! Double), longitude: CLLocationDegrees((resultAry[i]["geometry"] as! [String:[String:AnyObject]])["location"]?["lng"] as! Double))
            marker.title = resultAry[i]["name"] as? String
            //marker.icon = UIImage(named:"id_location")
            bounds = bounds.includingCoordinate(marker.position)
            marker.appearAnimation = .pop
            marker.map = mapView
            if selectedIndex != -1
            {
                if selectedIndex == i
                {
                    mapView.selectedMarker = marker
                }
            }
            else
            {
                marker.appearAnimation = .pop
            }
        }
        //
        delay(seconds: 0.1) { () -> () in
            let zoomIn = GMSCameraUpdate.zoom(to: 10)
            self.mapView.animate(with: zoomIn)

            self.delay(seconds: 0.5, closure: { () -> () in
                
                CATransaction.begin()
                CATransaction.setValue(0.8, forKey: kCATransactionAnimationDuration)
                let update = GMSCameraUpdate.fit(self.bounds, withPadding: 15.0)
                self.mapView.moveCamera(update)
                self.mapView.animate(with: update)
                CATransaction.commit()

                self.delay(seconds: 0.1, closure: { () -> () in
                    let zoomOut = GMSCameraUpdate.zoom(to: 10)
                    self.mapView.animate(with: zoomOut)
                })
            })
        }
    }
    //
    func delay(seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
}

extension NearByPlacesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PlaceListTblViewCell = tblSearchNearbyView?.dequeueReusableCell(withIdentifier: "cell") as! PlaceListTblViewCell
        cell.cellAnimate()
        cell.lblPlaceName.text = resultAry[indexPath.row]["name"] as? String
        if resultAry[indexPath.row]["rating"]! != nil
        {
            //let strRating = String(resultAry[indexPath.row]["rating"] as! Float)
            cell.viewPlaceRating.rating = resultAry[indexPath.row]["rating"] as! Double
        }
        else
        {
            cell.viewPlaceRating.rating = 0
        }
        
        if resultAry[indexPath.row]["photos"]! != nil
        {
            // print("https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=\(((resultAry[indexPath.row]["photos"] as! NSArray)[0] as! [String:AnyObject])["photo_reference"] as! String)&key=AIzaSyBG2lM5lHV6a0N2_Gk3fUV3Vz8DnI8z_OU")
            cell.imgPlace?.kf.setImage(with:URL(string :"https://maps.googleapis.com/maps/api/place/photo?maxwidth=120&photoreference=\(((resultAry[indexPath.row]["photos"] as! NSArray)[0] as! [String:AnyObject])["photo_reference"] as! String)&key=AIzaSyAnoVZHMvytaZcSL0uIliU5fH8ZsAQMGOE"), placeholder:UIImage(named:"placeholder"),                                           options: [.transition(ImageTransition.fade(1))],                                           progressBlock: { receivedSize, totalSize in
            },completionHandler: { image, error, cacheType, imageURL in
            })
        }
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}
