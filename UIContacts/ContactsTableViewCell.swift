//
//  ContactsTableViewCell.swift
//  UIContacts
//
//  Created by Praveen on 28/11/18.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet var contactImage: UIImageView!
    @IBOutlet var contactName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func assignValues(contactCell:Contact) {
        self.contactImage.layer.cornerRadius = (self.contactImage.frame.height)/2
        self.contactImage.clipsToBounds = true
        self.contactImage.layer.masksToBounds = true
        if let image = contactCell.contactImage {
            self.contactImage.image = UIImage(data: image)
        }
        let firstName = contactCell.firstName
        let lastName = contactCell.lastName
        let fullName = firstName! + " " + lastName!
        self.contactName.text = fullName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
