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
    
    var userData = UserData.init()
    var maps: [Map] = [] {
        didSet {
            userData.maps = maps
            tableView.reloadData()
        }
    }
    
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

        loadData()
        layoutSubviews()
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: mapListItemCellId)

        // If map list is empty, go to new map automatically
        // autoOpenNewMapIfListIsEmpty()
    }
    

    // =========================================
    // TABLE VIEW DATA SOURCE
    
    func loadData() {
        maps = userData.maps
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mapListItemCellId, for: indexPath)
        cell.textLabel?.text = maps[indexPath.row].name
        cell.accessoryType = .detailButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let editMapController = EditMapViewController()
        editMapController.map = maps[indexPath.row]
        navigationController?.pushViewController(editMapController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("open map \(maps[indexPath.row].name)")
    }
    

    // =========================================
    // ACTION FUNCTIONS

    @objc func newMapButtonTapped(_ sender: AnyObject?) {
        
        let newMap = Map.init(name: "New Map", locations: [])
        maps.append(newMap)
        print("Updated maps array: ", maps)
        print("UserDefaults is: ", userData)
        
//        DispatchQueue.main.async {
//            self.navigationController?.pushViewController(EditMapViewController(), animated: true)
//        }
    }
    
    func autoOpenNewMapIfListIsEmpty() {
        if maps.count == 0 { // list is empty
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(EditMapViewController(), animated: true)
            }
        }
    }
}
