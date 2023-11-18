//
//  HomeViewController.swift
//  PixabayRxSwift
//
//  Created by Kamil Tomaszewski on 16/11/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Nuke
import NukeExtensions
import RxNuke
import pixabay_repositories

final class HomeViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    typealias Section = HomeViewModel.Section
    
    var viewModel: HomeViewModel!
    private let pipeline = ImagePipeline.shared
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section> { [weak self] _, tableView, indexPath, item in
        guard let self else { return .init() }
        
        let cell: ImageDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.authorLabel.text = item.author
        
        var options = ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
        options.pipeline = self.pipeline
        cell.display(self.pipeline.rx.loadImage(with: item.imageUrl))
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        title = "Images"
        setupTableView()
        
        bindOutput()
        bindInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.input.viewDidAppear.accept(())
    }

    private func bindOutput() {
        viewModel.output.images
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.navigateToDetails
            .asObservable()
            .subscribe(onNext: { [weak self] in
                let imageDetailsViewController = ImageDetailsViewController(nibName: "ImageDetailsViewController", bundle: nil)
                imageDetailsViewController.viewModel = ImageDetailsViewModel(imageDetails: $0)
                self?.navigationController?.pushViewController(imageDetailsViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindInput() {
        tableView.rx
            .modelSelected(Section.Item.self)
            .bind(to: viewModel.input.detailsSelected)
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ImageDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageDetailsTableViewCell")
    }
}
