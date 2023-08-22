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
	case userDataTextfieldDidChanged(String)
	case popoverListDidTapped(UserDataMenuSettingsModel)
}

final class UserSceneView: BaseView {
	// MARK: - Typealiases
	private typealias UserDatasource = UICollectionViewDiffableDataSource<UserProfileSections, UserSettings>
	private typealias UserSnapshot = NSDiffableDataSourceSnapshot<UserProfileSections, UserSettings>

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<UserSceneViewActions, Never>()
	private var diffableDatasource: UserDatasource?

	// MARK: - UI Elements
	private lazy var logoutButton = buildGradientButton(with: Localization.logout,
														fontSize: Constants.basicFontSize)
	private lazy var collectionView = UICollectionView(frame: .zero,
													   collectionViewLayout: makeLayout())

	// MARK: - Init
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

	// MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<UserProfileSections, UserSettings>]) {
		var snapshot = UserSnapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		diffableDatasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension UserSceneView {
	// MARK: - SetupUI
	func setupUI() {
		backgroundColor = .black
		addSubs()
	}

	func addSubs() {
		addSubview(logoutButton, constraints: [
			logoutButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -Constants.basicBottomInset),

			logoutButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: Constants.defaultEdgeInsets),

			logoutButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -Constants.defaultEdgeInsets),

			logoutButton.heightAnchor.constraint(
				equalToConstant: Constants.basicHeight)])

		addSubview(collectionView, constraints: [
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor)])
	}

	// MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
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
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.basicLayoutFractionalWidth),
			heightDimension: .fractionalHeight(Constants.basicLayoutFractionalHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: .zero,
			leading: Constants.defaultEdgeInsets,
			bottom: .zero,
			trailing: Constants.defaultEdgeInsets)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.basicLayoutFractionalWidth),
			heightDimension: .fractionalWidth(Constants.headerHeightDimension))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitem: item,
			count: 1)

		let section = NSCollectionLayoutSection(group: group)
		return section
	}

	func makeListSection(with layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .black
		configuration.showsSeparators = false
		let section = NSCollectionLayoutSection.list(
			using: configuration,
			layoutEnvironment: layoutEnvironment)

		section.contentInsets = NSDirectionalEdgeInsets(
			top: .zero,
			leading: Constants.defaultEdgeInsets,
			bottom: .zero,
			trailing: Constants.defaultEdgeInsets)
		return section
	}

	// MARK: - Diffable Datasource
	func setupDiffableDatasource() {
		diffableDatasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView,
			cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else {
				return UICollectionViewCell()
			}

			switch item {
			case .header(let model):
				let cell = collectionView.configureCell(
					cellType: HeaderCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				cell.actionPublisher
					.map { _ in UserSceneViewActions.editButtonTapped }
					.subscribe(actionSubject)
					.store(in: &self.cancellables)
				return cell

			case .plainWithTextfield(let model):
				let cell = collectionView.configureCell(
					cellType: UserDataCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				cell.userDataCellEventsPublisher
					.sink { [weak self] event in
						guard let self = self else {
							return
						}

						switch event {
						case .textFieldDidChanged(let text):
							self.actionSubject.send(.userDataTextfieldDidChanged(text))
						}
					}
					.store(in: &self.cancellables)
				return cell

			case .plainWithLabel(let model):
				let cell = collectionView.configureCell(cellType: UserDataMenuCell.self, indexPath: indexPath)
				cell.configure(with: model)
				cell.userDataMenuPublisher
					.sink { [weak self] action in
						guard let self = self else {
							return
						}
						guard var object = self.getObject(with: indexPath) else {
							return
						}
						switch action {
						case .menuDidTapped(let item):
							object.labelValue = item.title
							self.actionSubject.send(.popoverListDidTapped(object))
						}
					}
					.store(in: &cell.cancellables)
				return cell
			}
		})
	}

	func getObject(with indexPath: IndexPath) -> UserDataMenuSettingsModel? {
		guard let object = diffableDatasource?.itemIdentifier(for: indexPath) else {
			return nil
		}
		var model: UserDataMenuSettingsModel?
		switch object {
		case .plainWithLabel(let userDataMenuSettingsModel):
			model = userDataMenuSettingsModel
		default: break
		}
		return model
	}

	// MARK: - Setup Collection
	func setupCollection() {
		collectionView.backgroundColor = .clear
		collectionView.register(
			UserDataCell.self,
			forCellWithReuseIdentifier: UserDataCell.reuseID)

		collectionView.register(
			HeaderCell.self,
			forCellWithReuseIdentifier: HeaderCell.reuseID)

		collectionView.register(
			UserDataMenuCell.self,
			forCellWithReuseIdentifier: UserDataMenuCell.reuseID)

		setupDiffableDatasource()
	}

	// MARK: - Actions
	func actionsBinding() {
		logoutButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.logoutButtonTapped)
			}
			.store(in: &cancellables)
	}
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct UserScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(UserSceneView())
	}
}
#endif

// MARK: - Constants
private enum Constants {
	static let buttonsStackViewSpacing: 	CGFloat = 8
	static let basicInterSectionSpacing: 	CGFloat = 8
	static let defaultInsetFromTop: 	 	CGFloat = 50
	static let defaultEdgeInsets: 		 	CGFloat = 16
	static let minimumFontScaleFactor: 		CGFloat = 0.5
	static let defaultLabelFontSize: 	 	CGFloat = 20
	static let basicFontSize: 		     	CGFloat = 13
	static let basicBottomInset: 		 	CGFloat = 20
	static let basicHeight: 			    CGFloat = 50
	static let basicLayoutFractionalHeight: CGFloat = 1
	static let basicLayoutFractionalWidth:  CGFloat = 1
	static let headerHeightDimension: 		CGFloat = 0.42
}
