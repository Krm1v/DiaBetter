//
//  BackupSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit
import Combine

enum BackupSceneActions {
    case dateCellDidTapped(Date, BackupDateCellModel)
    case plainCellDidTapped(BackupShareCellModel)
}

final class BackupSceneView: BaseView {
    // MARK: - Typealiases
    typealias BackupSceneDatasource = UICollectionViewDiffableDataSource<BackupSceneSections, BackupSceneItems>
    typealias BackupSceneSnapshot = NSDiffableDataSourceSnapshot<BackupSceneSections, BackupSceneItems>
    
    // MARK: - UI Elements
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout())
    
    // MARK: - Properties
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<BackupSceneActions, Never>()
    private var datasource: BackupSceneDatasource?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bindActions()
    }
    
    // MARK: - Public methods
    func setupSnapshot(sections: [SectionModel<BackupSceneSections, BackupSceneItems>]) {
        var snapshot = BackupSceneSnapshot()
        for section in sections {
            snapshot.appendSections([section.section])
            snapshot.appendItems(section.items, toSection: section.section)
        }
        datasource?.apply(snapshot)
    }
}

// MARK: - Private extension
private extension BackupSceneView {
    func setupUI() {
        setupLayout()
        setupCollectionView()
    }
    
    func setupLayout() {
        addSubview(
            collectionView,
            withEdgeInsets: .all(.zero))
    }
    
    func setupCollectionView() {
        collectionView.register(
            BackupDateCell.self,
            forCellWithReuseIdentifier: BackupDateCell.reuseID)
        
        collectionView.register(
            BackupPlainCell.self,
            forCellWithReuseIdentifier: BackupPlainCell.reuseID)
        
        collectionView.register(
            BackupSectionFooter.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: BackupSectionFooter.reuseId)
        
        setupDatasource()
    }
    
    func setupDatasource() {
        datasource = BackupSceneDatasource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let self = self else {
                    return UICollectionViewCell()
                }
                
                switch item {
                case .datePickerItem(let model):
                    let cell = collectionView.configureCell(
                        cellType: BackupDateCell.self,
                        indexPath: indexPath)
                    
                    cell.configure(model)
                    cell.actionPublisher
                        .sink { [unowned self] actions in
                            switch actions {
                            case .datePickerValueDidChanged(let date):
                                guard let object: BackupDateCellModel = self.getObject(indexPath) else {
                                    return
                                }
                                self.actionSubject.send(.dateCellDidTapped(date, object))
                            }
                        }
                        .store(in: &cell.cancellables)
                    return cell
                    
                case .plainItem(let model):
                    let cell = collectionView.configureCell(
                        cellType: BackupPlainCell.self,
                        indexPath: indexPath)
                    
                    cell.configure(model)
                    return cell
                }
            })
        
        datasource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionFooter else {
                return nil
            }
            let sectionFooter = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: BackupSectionFooter.reuseId,
                for: indexPath) as? BackupSectionFooter
            
            let section = self?.datasource?.snapshot().sectionIdentifiers[indexPath.section]
            sectionFooter?.titleText = section?.title
            
            return sectionFooter
        }
    }
    
    // MARK: - Layout
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else {
                return nil
            }
            guard let sections = BackupSceneSections(rawValue: sectionIndex) else {
                return nil
            }
            switch sections {
            case .backupDateSection: return makeListSection(with: layoutEnvironment)
            case .shareSection: 	 return makeListSection(with: layoutEnvironment)
            case .eraseDataSection:  return makeListSection(with: layoutEnvironment)
            }
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.intersectionSpacing
        layout.configuration = configuration
        return layout
    }
    
    func makeListSection(
        with layoutEnvironment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .black
        configuration.showsSeparators = false
        
        let section = NSCollectionLayoutSection.list(
            using: configuration,
            layoutEnvironment: layoutEnvironment)
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.defaultEdgeInset,
            leading: Constants.defaultEdgeInset,
            bottom: .zero,
            trailing: Constants.defaultEdgeInset)
        
        let footer = makeSectionFooter()
        section.boundarySupplementaryItems = [footer]
        return section
    }
    
    func makeSectionFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Constants.footerWidth),
            heightDimension: .fractionalWidth(Constants.footerHeight))
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom,
            absoluteOffset: CGPoint(
                x: .zero,
                y: Constants.footerYOffset))
        
        return sectionFooter
    }
    
    func getObject<T: BackupCellModelProtocol>(_ indexPath: IndexPath) -> T? {
        guard let object = datasource?.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        switch object {
        case .datePickerItem(let model):
            return model as? T
            
        case .plainItem(let model):
            return model as? T
        }
    }
    
    func bindActions() {
        collectionView.didSelectItemPublisher
            .sink { [unowned self] indexPath in
                guard let object: BackupShareCellModel = self.getObject(indexPath) else {
                    return
                }
                self.actionSubject.send(.plainCellDidTapped(object))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let intersectionSpacing: CGFloat = 8
    static let defaultEdgeInset: CGFloat = 16
    static let footerYOffset: CGFloat = 10
    static let footerWidth: CGFloat = 1.0
    static let footerHeight: CGFloat = 0.1
}
