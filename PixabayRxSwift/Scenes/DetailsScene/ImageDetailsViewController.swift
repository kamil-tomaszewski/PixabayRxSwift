//
//  ImageDetailsViewController.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 18/11/2023.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import Differentiator
import Nuke
import NukeExtensions

final class ImageDetailsViewController: UIViewController {
    typealias Sections = ImageDetailsViewModel.Sections
    @IBOutlet private weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    private let pipeline = ImagePipeline.shared
    
    var viewModel: ImageDetailsViewModel!
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Sections> { _, tableView, indexPath, item in
        switch item {
        case let .ImageUrlSectionItem(url):
            let cell: ImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            var options = ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
            options.pipeline = self.pipeline
            cell.display(self.pipeline.rx.loadImage(with: url))
            return cell
        case let .TitleDescriptionSectionItem(field, description):
            let cell: DescriptionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(title: field.rawValue, description: description)
            return cell
        }
    } titleForHeaderInSection: { dataSource, index in
        dataSource[index].title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(.init(nibName: "DescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "DescriptionTableViewCell")
        tableView.register(.init(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
        
        bindOutput()
    }
    
    private func bindOutput() {
        viewModel.output.detailsSections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
