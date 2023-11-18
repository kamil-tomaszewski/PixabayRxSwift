//
//  DescriptionTableViewCell.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 18/11/2023.
//

import UIKit

final class DescriptionTableViewCell: UITableViewCell {
    @IBOutlet private var descriptionTitleLabel: UILabel!
    @IBOutlet private var descriptionValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, description: String) {
        descriptionTitleLabel.text = title
        descriptionValueLabel.text = description
    }
    
}
