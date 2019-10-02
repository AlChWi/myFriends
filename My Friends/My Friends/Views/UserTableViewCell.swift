//
//  UserTableViewCell.swift
//  My Friends
//
//  Created by Алексей Перов on 25.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableViewCell: UITableViewCell {

    //MARK: - OUTLETS -
    @IBOutlet weak var friendPhotoImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    //MARK: - LIFE CYCLE -
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendPhotoImageView.layer.borderWidth = 2
        friendPhotoImageView.layer.masksToBounds = false
        friendPhotoImageView.layer.borderColor = UIColor.black.cgColor
        friendPhotoImageView.layer.cornerRadius = friendPhotoImageView.frame.height/2
        friendPhotoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - CONFIGURE -
    func configure(forUser user: User) {
        friendNameLabel.text = "\(user.firstName) \(user.lastName)"
        if let customImage = user.image {
            friendPhotoImageView.image = UIImage(data: customImage)
        } else {
            friendPhotoImageView.kf.setImage(with: user.imageOnServer)
        }
    }
}
