//
//  ViewController.swift
//  MusicSearch
//
//  Created by Suba shri Kulandai Samy on 1/11/17.
//  Copyright © 2017 Suba shri Kulandai Samy. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
   
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    @IBOutlet weak var txfSearch: UITextField!
    @IBOutlet weak var vwLoading: UIActivityIndicatorView!
    @IBOutlet weak var vwCollTracks: UICollectionView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var segVwType: UISegmentedControl!
    @IBOutlet weak var btnSortFilter: UIButton!
    
    var layout = UICollectionViewFlowLayout.init()
    var dataSource:NSMutableArray = []
    var isInListView:Bool = false
    var selectedTrack:MusicTrack?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make the keypad visible during the startup
        txfSearch.becomeFirstResponder()
        
        initializeCollectionView()
    }
    
    //MARK: Helper methods
    
    /*
    called out when the serach button is tapped
     */
    @IBAction func searchTapped(_ sender: Any) {
        
        txfSearch.resignFirstResponder()
        vwLoading.startAnimating()
        view.bringSubview(toFront: vwLoading)
        
        btnSortFilter.layer.cornerRadius = 3.0
        btnSortFilter.layer.borderWidth = 1.0
        btnSortFilter.layer.borderColor = UIColor.init(colorLiteralRed: 70/255, green: 114/255, blue: 197/255, alpha: 1).cgColor
        MusicHelper.getTracksForKeyword(strKeyword: txfSearch.text!) { (succeeded, result) in
            DispatchQueue.main.async {
                self.vwLoading.stopAnimating()
                if succeeded{
                    print("Suceeded")
                    //refresh teh view with new tracks
                    self.dataSource.removeAllObjects()
                    self.dataSource.addObjects(from: (result as! MusicResults).results)
                    self.vwCollTracks.isHidden = false
                    self.vwHeader.isHidden = false
                    self.vwCollTracks.reloadData()
                }
                else{
                    print("Failed")
                }
            }
        }
    }
    
    /*
     called out when the view type segment button is tapped
     */
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        isInListView = sender.selectedSegmentIndex == 1
        vwCollTracks.reloadData()
        vwCollTracks.performBatchUpdates({
            self.vwCollTracks.collectionViewLayout.invalidateLayout()
        }){ (completed) in
            self.vwCollTracks.setCollectionViewLayout(self.layout, animated:true)
        }
    }
    
    @IBAction func sortAndFilterTapped(_ sender: Any) {
        
       let alert = UIAlertController.init(title: "To be implemented", message: "This will allow the user to sort and refine the results from the search", preferredStyle: UIAlertControllerStyle.alert)
        let actionOk = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
    /*
     initialises the collection view
     */
    func initializeCollectionView(){
        
        //layout setup
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets.zero
        
        //collecrtion view
        vwCollTracks.backgroundColor = UIColor.init(colorLiteralRed: 224/255, green: 224/255, blue: 224/255, alpha: 1)
        vwCollTracks.collectionViewLayout = layout
        vwCollTracks.register(TracksGridCollectionViewCell.self, forCellWithReuseIdentifier:"trackGridCell")
        vwCollTracks.register(TracksListCollectionViewCell.self, forCellWithReuseIdentifier:"trackListCell")
        vwCollTracks.layer.cornerRadius = 3.0
        vwCollTracks.isHidden = true
    }
    
    //MARK: Collection view delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let track:MusicTrack = dataSource.object(at: (indexPath as NSIndexPath).row) as! MusicTrack
        let cell:UICollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: isInListView ? "trackListCell" : "trackGridCell", for: indexPath)
        (cell as! TracksGridCollectionViewCell).delegate = self
        (cell as! TracksGridCollectionViewCell).configureCellWithTrack(track, forListView: isInListView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTrack = dataSource.object(at: (indexPath as NSIndexPath).row) as? MusicTrack
        performSegue(withIdentifier: "ResultsToTrack", sender: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //can be enahaced to hold different sizes based on teh string length
        if isInListView {
            return CGSize(width: screenWidth, height: 110)
        }
        else{
            
            let isDeviceiPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
            let width = isDeviceiPad ?(screenWidth - 10)/4 : (screenWidth - 2)/2
            return CGSize(width: width, height: 200)
        }
    }
    
    
    //MARK: Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Seque Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let trackVc:TrackViewController = segue.destination as! TrackViewController
        trackVc.track = selectedTrack
    }
}
