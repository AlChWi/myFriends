//
//  AddFriendsViewController.swift
//  My Friends
//
//  Created by Алексей Перов on 25.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController {

    //MARK: - OUTLETS -
    @IBOutlet weak private var friendsTableView: UITableView! {
        didSet {
            friendsTableView.delegate = self
            friendsTableView.dataSource = self
            friendsTableView.prefetchDataSource = self
            let nib = UINib(nibName: Constants.NibNames.userTableViewCell, bundle: nil)
            friendsTableView.register(nib, forCellReuseIdentifier: Constants.CellIDs.userTableViewCell)
        }
    }
    
    //MARK: - PRIVATE VARIABLES -
    private let activityIndicator = UIActivityIndicatorView()
    private let background = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))

    private var people: [User] = [] {
        didSet {
            friendsTableView.reloadData()
        }
    }
    
    //MARK: - LIFE CYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Friends"

        setSpinnerFor(tableView: friendsTableView)
        loadInfo()
    }
    
    //MARK: - PRIVATE METHODS -
    private func setSpinnerFor(tableView: UITableView) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: friendsTableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = true
    }
    
    private func loadInfo() {
        activityIndicator.center = view.center
        activityIndicator.contentMode = .scaleAspectFit
        background.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        background.layer.cornerRadius = 10
        background.layer.masksToBounds = true
        background.center = view.center
        
        view.addSubview(background)
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        NetworkService().getUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.people.insert(contentsOf: users, at: self.people.count)
                    self.activityIndicator.stopAnimating()
                    self.background.isHidden = true
                    self.friendsTableView.tableFooterView?.isHidden = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        }
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDataSource, UITableViewDelegate -
extension AddFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = friendsTableView.dequeueReusableCell(withIdentifier: Constants.CellIDs.userTableViewCell, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(forUser: people[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        addingLabel.center = view.center
        addingLabel.textAlignment = .center
        addingLabel.text = "Saving Friend"
        addingLabel.backgroundColor = .clear
        let labelBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        labelBackground.frame = addingLabel.frame
        labelBackground.layer.cornerRadius = 10
        labelBackground.layer.masksToBounds = true
        view.addSubview(labelBackground)
        view.addSubview(addingLabel)
        let user = people[indexPath.row]
        if let result = try? DataService.shared.createFriend(user) {
            switch result.creationStatus {
            case .created:
                self.dismiss(animated: true) {
                    result.resultEntity.isMyFriend = true
                    addingLabel.removeFromSuperview()
                    labelBackground.removeFromSuperview()
                }
            case .alreadyExisted:
                addingLabel.text = "Friend is already added"
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    addingLabel.removeFromSuperview()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == people.count - 15 {
            NetworkService().getUsers { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let users):
                        self.people.insert(contentsOf: users, at: self.people.count)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
    }
    
}

//MARK: - UITableViewDataSourcePrefetching -
extension AddFriendsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetching")
    }


}
