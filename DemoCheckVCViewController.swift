//
//  DemoCheckVCViewController.swift
//  DemoNearbyGooglePlaces
//
//  Created by VSL057 on 14/03/19.
//  Copyright © 2019 Disha. All rights reserved.
//

import UIKit

class DemoCheckVCViewController: UIViewController{
    @IBOutlet weak var collViewDemo: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension DemoCheckVCViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
}
