//
//  UserSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.02.2023.
//

import UIKit
import Combine

enum UserSceneViewActions {
	case logoutButtonTapped
	case editButtonTapped
}

enum UserSceneViewEvents {
	case userEmailLabelChanged(String)
}

final class UserSceneView: BaseView {
	//MARK: - Typealiases
	typealias UserDatasource = UICollectionViewDiffableDataSource<UserProfileSections, UserSettings>
	typealias UserSnapshot = NSDiffableDataSourceSnapshot<UserProfileSections, UserSettings>
	
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<UserSceneViewActions, Never>()
	private var diffableDatasource: UserDatasource?
	
	//MARK: - UI Elements
	private lazy var logoutButton = buildGradientButton(with: Localization.logout, fontSize: Constants.basicFontSize)
	private lazy var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: makeLayout())
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCollection()
		actionsBinding()
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupCollection()
		actionsBinding()
		setupUI()
	}
	
	//MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<UserProfileSections, UserSettings>]) {
		var snapshot = UserSnapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		diffableDatasource?.apply(snapshot)
	}
}

//MARK: - Private extension
private extension UserSceneView {
	//MARK: - SetupUI
	func setupUI() {
		backgroundColor = .white
		addSubs()
	}
	
	func addSubs() {
		addSubview(collectionView)
		addSubview(logoutButton)
		setupConstraintsForLogoutButton()
		setupConstraintsForCollectionView()
	}
	
	func setupConstraintsForCollectionView() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.topAnchor.constraint(equalTo: topAnchor)
			.isActive = true
		collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
			.isActive = true
		collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
			.isActive = true
		collectionView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor)
			.isActive = true
	}
	
	func setupConstraintsForLogoutButton() {
		logoutButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.basicBottomInset)
			.isActive = true
		logoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultEdgeInsets)
			.isActive = true
		logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultEdgeInsets)
			.isActive = true
		logoutButton.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
			.isActive = true
	}
	
	//MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = UserProfileSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .header:
				return self.makeHeaderSection()
			case .list:
				return self.makeListSection(with: layoutEnvironment)
			}
		}
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.interSectionSpacing = Constants.basicInterSectionSpacing
		layout.configuration = configuration
		return layout
	}
	
	func makeHeaderSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constants.basicLayoutFractionalWidth),
											  heightDimension: .fractionalHeight(Constants.basicLayoutFractionalHeight))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: .zero,
													 leading: Constants.defaultEdgeInsets,
													 bottom: .zero,
													 trailing: Constants.defaultEdgeInsets)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constants.basicLayoutFractionalWidth),
											   heightDimension: .absolute(Constants.headerHeightDimension))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	func makeListSection(with layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .white
		let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
		section.contentInsets = NSDirectionalEdgeInsets(top: .zero,
														leading: Constants.defaultEdgeInsets,
														bottom: .zero,
														trailing: Constants.defaultEdgeInsets)
		return section
	}
	
	//MARK: - Diffable Datasource
	func setupDiffableDatasource() {
		diffableDatasource = UICollectionViewDiffableDataSource<UserProfileSections, UserSettings>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else { return UICollectionViewCell() }
			switch item {
			case .header(let model):
				let cell = self.configureCell(cellType: HeaderCell.self, indexPath: indexPath)
				cell.configure(with: model)
				cell.editButton.tapPublisher
					.sink { [unowned self] in
						self.actionSubject.send(.editButtonTapped)
					}
					.store(in: &self.cancellables)
				return cell
			case .plain(let model):
				let cell = self.configureCell(cellType: UserDataCell.self, indexPath: indexPath)
				cell.configure(with: model)
				return cell
			}
		})
	}
	
	//MARK: - Setup Collection
	func setupCollection() {
		collectionView.backgroundColor = .white
		collectionView.register(UserDataCell.self, forCellWithReuseIdentifier: UserDataCell.reuseID)
		collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.reuseID)
		setupDiffableDatasource()
	}
	
	//MARK: - Cell configuring
	func configureCell<T: SelfConfiguringCollectionViewCell>(cellType: T.Type,
															 indexPath: IndexPath) -> T {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID,
															for: indexPath) as? T else {
			fatalError("Error \(cellType)")
		}
		return cell
	}
	
	//MARK: - Actions
	func actionsBinding() {
		logoutButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.logoutButtonTapped)
			}
			.store(in: &cancellables)
	}
}

//MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct UserScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(UserSceneView())
	}
}
#endif

//MARK: - Constants
fileprivate enum Constants {
	static let buttonsStackViewSpacing: CGFloat = 8
	static let basicInterSectionSpacing: CGFloat = 8
	static let defaultInsetFromTop: CGFloat = 50
	static let defaultEdgeInsets: CGFloat = 16
	static let minimumFontScaleFactor: CGFloat = 0.5
	static let defaultLabelFontSize: CGFloat = 20
	static let basicFontSize: CGFloat = 13
	static let basicBottomInset: CGFloat = 20
	static let basicHeight: CGFloat = 50
	static let basicLayoutFractionalHeight: CGFloat = 1
	static let basicLayoutFractionalWidth: CGFloat = 1
	static let headerHeightDimension: CGFloat = 165
}
