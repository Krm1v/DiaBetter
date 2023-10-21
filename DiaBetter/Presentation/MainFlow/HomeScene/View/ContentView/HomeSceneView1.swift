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
    
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<HomeSceneViewActions, Never>()
    @State var props: HomeSceneWidgetPropsModel
    @State var treshold: Double?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    createHeader(with: Localization.lastSevenDaysGlucose)
                    BarChart(model: props.glucoseChartModel, treshold: props.glucoseChartModel.treshold)
                        .padding(.bottom)
                    
                    createHeader(with: Localization.averageGlucose)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(props.averageGlucoseChartModel) { element in
                                AverageGlucoseHomeWidget(model: element)
                                    .frame(
                                        width: UIScreen.main.bounds.width / 2,
                                        height: UIScreen.main.bounds.width / 2)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    createHeader(with: Localization.glucoseTimeline)
                    LineChartHomeWidget(model: props.lineChartHomeWidgetModel)
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.home)
            .toolbar {
                Button(Localization.addNewRecord) {
                    actionSubject.send(.addNewRecordButtonDidTapped)
                }
                .foregroundStyle(Color(uiColor: Colors.customPink.color))
                .font(.custom(FontFamily.Montserrat.regular.name, size: 17))
            }
            .padding([.leading, .trailing])
        }
    }
}

struct HomeSceneView_Preview: PreviewProvider {
    static var previews: some View {
        HomeSceneView(
            props: .init(
                glucoseChartModel: .init(data: [], treshold: 11),
                averageGlucoseChartModel: [.init(averageValue: "10", glucoseUnit: .mmolL, dotColor: .red, period: .week)],
                lineChartHomeWidgetModel: .init(data: [])))
    }
}
