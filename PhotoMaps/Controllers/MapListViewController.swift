//
//  MapListViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class MapListViewController: UITableViewController {
    
    // =========================================
    // MODEL
    
    var userData: UserData!
    
    let mapListItemCellId = "MapListItem"
    
    // =========================================
    // SUBVIEWS
    
    lazy var addButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newMapButtonTapped(_:)))
        return btn
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [addButton]
        navigationItem.leftBarButtonItems = []
        title = "Map List"
    }
    
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutSubviews()
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: mapListItemCellId)

        // If map list is empty, go to new map automatically
        // autoOpenNewMapIfListIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load data
        userData = UserData.init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("data is: ", userData)
    }
    

    // =========================================
    // TABLE VIEW DATA SOURCE
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.maps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mapListItemCellId, for: indexPath)
        cell.textLabel?.text = userData.maps[indexPath.row].name
        cell.accessoryType = .detailButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let editMapController = EditMapViewController()
        editMapController.map = userData.maps[indexPath.row]
        navigationController?.pushViewController(editMapController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapView = MapViewController()
        mapView.map = userData.maps[indexPath.row]
        self.navigationController?.pushViewController(mapView, animated: true)
    }
    

    // =========================================
    // ACTION FUNCTIONS

    @objc func newMapButtonTapped(_ sender: AnyObject?) {
        
        let nextId = userData.maps.count
        let newMap = Map.init(id: nextId, name: "New map \(nextId)", locations: [])
        userData.maps.append(newMap)
        tableView.reloadData()
        
        let editController = EditMapViewController()
        editController.map = newMap
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(editController, animated: true)
        }
    }
    
    func autoOpenNewMapIfListIsEmpty() {
        if userData.maps.count == 0 { // list is empty
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(EditMapViewController(), animated: true)
            }
        }
    }
}
