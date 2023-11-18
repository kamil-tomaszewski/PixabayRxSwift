//
//  ImageDetailsTableViewCell.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 17/11/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxNuke
import Nuke

final class ImageDetailsTableViewCell: UITableViewCell {
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var previewImageView: UIImageView!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorLabel.text = nil
        previewImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func display(_ image: Single<ImageResponse>) {
        disposeBag = DisposeBag()
        previewImageView.image = nil

        image
            .subscribe(onSuccess: { [weak self] response in
                self?.previewImageView.image = response.image
            })
            .disposed(by: disposeBag)
    }
}
