//
//  HomeSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.10.2023.
//

import SwiftUI
import Combine

enum HomeSceneViewActions {
    case addNewRecordButtonDidTapped
}

struct HomeSceneView: View {
    // MARK: - Properties
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<HomeSceneViewActions, Never>()
    @State var props: HomeSceneWidgetPropsModel
    @State var treshold: Double?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    createHeader(with: Localization.lastSevenDaysGlucose)
                    if props.glucoseChartModel.data.isEmpty {
                        EmptyWidgetStateView()
                            .frame(height: UIScreen.main.bounds.width / 2)
                    } else {
                        BarChart(model: props.glucoseChartModel, treshold: props.glucoseChartModel.treshold)
                            .padding(.bottom)
                    }
                    
                    createHeader(with: Localization.averageGlucose)
                    if !props.averageGlucoseChartModel.isData {
                        EmptyWidgetStateView()
                            .frame(height: UIScreen.main.bounds.width / 2)
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                
                                ForEach(props.averageGlucoseChartModel.data) { element in
                                    AverageGlucoseHomeWidget(model: element)
                                        .frame(
                                            width: Constants.averageGlucoseWidgetWidth,
                                            height: Constants.averageGlucoseWidgetHeight
                                        )
                                        .padding(8)
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    createHeader(with: Localization.glucoseTimeline)
                    if props.lineChartHomeWidgetModel.data.isEmpty {
                        
                        EmptyWidgetStateView()
                            .frame(height: UIScreen.main.bounds.width / 2)
                    } else if props.lineChartHomeWidgetModel.data.count == 1 {
                        
                        EmptyWidgetStateView(textMessage: Localization.notEnoughData)
                            .frame(height: UIScreen.main.bounds.width / 2)
                    } else {
                        LineChartHomeWidget(model: props.lineChartHomeWidgetModel)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.home)
            .toolbar {
                Button(Localization.addNewRecord) {
                    actionSubject.send(.addNewRecordButtonDidTapped)
                }
                .foregroundStyle(
                    Color(
                        uiColor: Colors.customPink.color
                    )
                )
                .font(
                    .custom(
                        FontFamily.Montserrat.regular.name,
                        size: Constants.defaultFontSize)
                )
            }
            .padding([.leading, .trailing])
        }
    }
}

// MARK: - Preview
struct HomeSceneView_Preview: PreviewProvider {
    static var previews: some View {
        HomeSceneView(
            props: .init(
                glucoseChartModel: .init(data: [], treshold: 11),
                averageGlucoseChartModel: .init(
                    data: [
                        .init(
                            averageValue: "12",
                            glucoseUnit: .mmolL,
                            period: .overall
                        )],
                    isData: true),
                lineChartHomeWidgetModel: .init(data: [])))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 17
    static let averageGlucoseWidgetHeight: CGFloat = 100
    static let averageGlucoseWidgetWidth: CGFloat = 140
}
