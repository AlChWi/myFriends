//
//  ViewController.swift
//  My Friends
//
//  Created by Алексей Перов on 24.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import UIKit
import CoreData

class MyFriendsListViewController: UIViewController {

    //MARK: - OUTLETS -
    @IBOutlet weak private var friendsTableView: UITableView! {
        didSet {
            friendsTableView.dataSource = self
            friendsTableView.delegate = self
            let nib = UINib(nibName: Constants.NibNames.userTableViewCell, bundle: nil)
            friendsTableView.register(nib, forCellReuseIdentifier: Constants.CellIDs.userTableViewCell)
        }
    }
    
    //MARK: - PRIVATE VARIABLES -
    private var fetchedResultsController = NSFetchedResultsController<UserEntity>()
    private var friends: [User] = []
    
    //MARK: - LIFE CYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()
                
        DataService.shared.fetchFriendsWith(fetchedResultsController: &fetchedResultsController, for: self) { (users) in
            self.friends = users
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        friendsTableView.setEditing(true, animated: true)
        friendsTableView.reloadData()
    }

    //MARK: - PRIVATE METHODS -
    @IBAction private func addButtonTapped(_ sender: UIBarButtonItem) {
        let navVC = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllerIDs.addFriendsNavVC)
        present(navVC, animated: true)
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource -
extension MyFriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = friendsTableView.dequeueReusableCell(withIdentifier: "FriendCellID", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = friends[indexPath.row]
        cell.configure(forUser: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navVC = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewControllerIDs.editFriendNavVC) as? UINavigationController else { return }
        guard let vc = navVC.viewControllers[0] as? EditFriendInfoTableViewController else { return }
        let entity = try? DataService.shared.findUser(userID: friends[indexPath.row].id)
        
        if let entity = entity {
            vc.configure(forUser: entity)
            present(navVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let friend = friends[indexPath.row]
            DataService.shared.removeFromFriendlist(friend)
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate -
extension MyFriendsListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
        friendsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange anObject: Any, at indexPath: IndexPath?, for type:
    NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                friendsTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                friendsTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                friendsTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        default:
            friendsTableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects as? [UserEntity] {
            let viewUsers = fetchedObjects.map({ User(entity: $0)})
            friends = viewUsers
        }
    }
    
    func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
        friendsTableView.endUpdates()
    }
}
