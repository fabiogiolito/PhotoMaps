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
            tableView.reloadData()
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

    lazy var newMapPrompt: UIAlertController = {
        let alert = UIAlertController(title: "New Map", message: "Choose a name for your map", preferredStyle: .alert)
        let create = UIAlertAction(title: "Create", style: .default, handler: { (_) in
            guard let mapNameField = alert.textFields?[0] else { return }
            self.createNewMap(name: mapNameField.text)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "your map name…"
        })
        alert.addAction(create)
        alert.addAction(cancel)
        return alert
    }()

    lazy var emptyStateView: EmptyStateView = {
        let empty = EmptyStateView()
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
        self.navigationItem.title = "Your Maps" // Set screen title
        userData = UserData.init() // Get fresh user data
        tableView.reloadData() // Refresh tableview with new data
        showEmptyStateIfNoMaps() // Check if should display empty state
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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 88, height: 44))
        label.text = "photo".pluralize(count: userData.maps[indexPath.row].locations.count)
        label.textColor = UIColor.grayLight()
        label.textAlignment = .right
        label.font = UIFont.caption()
        cell.accessoryView = label
        return cell
    }

    // Selected a map
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMap(userData.maps[indexPath.row])
    }
    
    // Provide a footer view to remove placeholder lines on tableview
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // Make cells deletable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Edit cell: delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            userData.maps.remove(at: indexPath.row)
        }
    }
    

    // =========================================
    // ACTION FUNCTIONS

    // Tapped new map button on navbar
    @objc func newMapButtonTapped(_ sender: AnyObject?) {
        print("Prompt new map name")
        present(newMapPrompt, animated: true)
    }

    // Typed map name, create map and go to map screen
    func createNewMap(name: String?) {
        guard let name = name else { return } // Make sure we have a name
        let nextId = userData.maps.count // Get a new ID for this map
        let newMap = Map.init(id: nextId, name: name, locations: []) // Build map model
        userData.maps.append(newMap) // Add to user data (saves it)
        tableView.reloadData() // Reload tableview to show new map
        openMap(newMap) // Go to map screen
    }
    
    // Open map screen
    func openMap(_ map: Map) {
        self.navigationItem.title = "" // prevent title from appearing on next screen's back button
        
        // Build map view and open it
        let mapController = MapViewController()
        mapController.map = map
        self.navigationController?.pushViewController(mapController, animated: true)
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
