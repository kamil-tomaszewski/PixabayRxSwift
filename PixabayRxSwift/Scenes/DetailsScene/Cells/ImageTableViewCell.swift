//
//  ImageTableViewCell.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 18/11/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxNuke
import Nuke

final class ImageTableViewCell: UITableViewCell {
    @IBOutlet private var largeImageView: UIImageView!

    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        largeImageView.image = nil
    }
    
    func display(_ image: Single<ImageResponse>) {
        disposeBag = DisposeBag()
        largeImageView.image = nil

        image
            .subscribe(onSuccess: { [weak self] response in
                self?.largeImageView.image = response.image
            })
            .disposed(by: disposeBag)
    }
}
