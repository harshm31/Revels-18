//
//  ResultsPage.swift
//  Revels-18
//
//  Created by Shreyas Aiyar on 12/12/17.
//  Copyright © 2017 Shreyas Aiyar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CoreData

class ResultsPage: UIViewController,NVActivityIndicatorViewable,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UITabBarControllerDelegate {
    
    let segmentLabels:[String] = ["Results","Sports Results"]
    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var resultsCollectionView: UICollectionView!
    let resultsURL = "https://api.mitportals.in/results/"
    let resultNetworkingObject = ResultNetworking()
    var resultsDataSource:[Results] = []
    var filteredDataSource:[Results] = []
    let httpRequestObject = HTTPRequest()
    var searchBar = UISearchBar()
    var searchActive:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsMain()
        createBarButtonItems()
        configureNavigationBar()
        searchBar.delegate = self
        tabBarController?.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
    }

    override func searchButtonPressed() {
        super.searchButtonPressed()
        self.searchBar.becomeFirstResponder()
        searchBar.alpha = 1
        navigationItem.titleView = searchBar
    }
    
    //MARK: Search Functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    }
    
    override func reloadData(){
        resultsMain()
        self.resultsCollectionView.reloadData()
    }
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultsCell", for: indexPath) as! ResultsCell
        cell.eventName.text = resultsDataSource[indexPath.row].evename
        cell.roundNo.text = "Round " + resultsDataSource[indexPath.row].round
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsDataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = 85
        let yourHeight = 110
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }


    //MARK: Get JSON Data
    func resultsMain(){
        startAnimating()
        var results:[Results] = []
        httpRequestObject.makeHTTPRequestForEvents(eventsURL: resultsURL){ status in
            switch status{
            case .Success(let parsedJSON):
                for result in parsedJSON["data"] as! [Dictionary<String,String>]{
                    let resultObject = Results(dictionary: result)
                    results.append(resultObject)
                }
                self.resultsDataSource = results
                self.resultNetworkingObject.saveResultsToCoreData(resultData: results)
                self.stopAnimating()
                self.resultsCollectionView.reloadData()
                
            case .Error(let errorMessage):
                DispatchQueue.main.async {
                    print(errorMessage)
                    self.resultsDataSource = self.resultNetworkingObject.fetchResultsFromCoreData()
                }
                
            }
        }
        
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.resultsCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
}
    


