//
//  DataSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

final class DataSceneView: BaseView {
	typealias DataSceneDatasource = UICollectionViewDiffableDataSource<DataSceneSections, DataSceneItems>
	typealias Snapshot = NSDiffableDataSourceSnapshot<DataSceneSections, DataSceneItems>
	
	//MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
	private var datasource: DataSceneDatasource?
	
	//MARK: - Properties
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

//MARK: - Private extension
private extension DataSceneView {
	func setupUI() {
		setupColletionView()
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(collectionView, withEdgeInsets: .all(.zero))
	}
	
	func setupColletionView() {
		backgroundColor = .cyan
		collectionView.register(AppleHealthActivationCell.self,
								forCellWithReuseIdentifier: AppleHealthActivationCell.reuseID)
	}
	
	func setupDatasource() {
		datasource = .init(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else { return UICollectionViewCell() }
			switch item {
			case .appleHealthItem:
				let cell = collectionView.configureCell(cellType: AppleHealthActivationCell.self,
														indexPath: indexPath)
				return cell
			case .backupItem:
				return nil
				
			}
		})
	}
}
