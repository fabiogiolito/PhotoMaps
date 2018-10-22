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
    
    var userData: UserData! {
        didSet {
            showEmptyStateIfNoMaps()
        }
    }
    
    enum CellIdentifier: String {
        case mapListItem
    }
    
    // =========================================
    // SUBVIEWS
    
    lazy var newMapButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newMapButtonTapped(_:)))
        return btn
    }()
    
    lazy var emptyStateView: EmptyStateView = {
        let empty = EmptyStateView(frame: self.view.frame)
        empty.titleLabel.text = "No maps"
        empty.bodyLabel.text = "Tap the + button to create your first map"
        return empty
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [newMapButton]
        navigationItem.leftBarButtonItems = []
        title = "Your maps"
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutSubviews()
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.mapListItem.rawValue)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data whenever view appears
        userData = UserData.init()
        showEmptyStateIfNoMaps()
    }


    // =========================================
    // TABLE VIEW DATA SOURCE
    
    // Number of maps
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.maps.count
    }
    
    // Build cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.mapListItem.rawValue, for: indexPath)
        cell.textLabel?.text = userData.maps[indexPath.row].name
        
        // Accessory button
        let editButton = UIButton(type: .system)
        editButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        editButton.setTitle("Edit", for: .normal)
        editButton.contentHorizontalAlignment = .right
        editButton.tag = indexPath.row
        editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        cell.accessoryView = editButton

        return cell
    }

    // Selected a map
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapView = MapViewController()
        mapView.map = userData.maps[indexPath.row]
        self.navigationController?.pushViewController(mapView, animated: true)
    }
    
    // Provide a footer view to remove placeholder lines on tableview
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    

    // =========================================
    // ACTION FUNCTIONS

    // Tapped new map button on navbar
    @objc func newMapButtonTapped(_ sender: AnyObject?) {
        let nextId = userData.maps.count
        let newMap = Map.init(id: nextId, name: "New map \(nextId)", locations: [])
        userData.maps.append(newMap)
        tableView.reloadData()

        let editMapController = EditMapViewController()
        editMapController.map = newMap
        self.navigationController?.pushViewController(editMapController, animated: true)
    }
    
    // Tapped edit button on map
    @objc func editButtonTapped(_ sender: AnyObject?) {
        if let index = sender?.tag {
            let editMapController = EditMapViewController()
            editMapController.map = userData.maps[index]
            navigationController?.pushViewController(editMapController, animated: true)
        }
    }
    
    // Show empty state
    func showEmptyStateIfNoMaps() -> Void {
        if userData.maps.count > 0 {
            self.tableView.backgroundView = nil
        } else {
            self.tableView.backgroundView = emptyStateView
        }
    }
}
