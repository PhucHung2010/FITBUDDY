//
//  HomeView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI
import AudioToolbox

struct ArchiveBox: View {
    @EnvironmentObject var theme: AppThemeController
    @Environment(\.managedObjectContext) var viewContext
    @State var summaryParameter: [SummaryExerciseParameterStorage] = []
    @State var selectedParameter: SummaryExerciseParameterStorage?
    @State var selectedTimeUnit: String?
    @State var showFeedbackTextSheet: Bool = false
    
    @State var showHistoryList: Bool = true

    
    var formatter = DateFormatter()
    
    @State private var isPressingOnText = false
    @State private var beingPressedOn: Int? = nil
    @Namespace private var animation
    
    @State var groupedByTimeUnit: [String: [SummaryExerciseParameterStorage]] = [:]
    @AppStorage("DateFormatOption") var currentDateFormatOption: String = "MM/YYYY"
    func groupSummaryByTimeUnit(_ parameters: [SummaryExerciseParameterStorage], dateFormat: String) -> [String: [SummaryExerciseParameterStorage]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = dateFormat // hoặc "LLLL yyyy" nếu muốn theo tháng-năm

        let sorted = parameters.sorted {
            ($0.dateAdded ?? Date()) > ($1.dateAdded ?? Date())
        }

        let grouped = Dictionary(grouping: sorted) { item in
            formatter.string(from: item.dateAdded ?? Date())
        }

        return grouped
    }

    
    init() {
        formatter.dateFormat = "HH:mm, dd/MM/yyyy"
    }
    
    
    
    @State private var batchSize = 5
    @State private var currentOffset = 0
    @State private var isLoadingMore = false

    
    var body: some View {
        archiveBox
        .onAppear {
            updateSummaryParameters()
                NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                       object: viewContext,
                                                       queue: .main) { _ in
                    updateSummaryParameters()
                }
        }
//        .onAppear {
//            loadInitialBatch()
//            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
//                                                   object: viewContext,
//                                                   queue: .main) { _ in
//                reloadAll()
//            }
//        }
    }
    
    func loadInitialBatch() {
        currentOffset = 0
        summaryParameter = SummaryExerciseParameterStorage.fetchBatch(in: viewContext,
                                                                      limit: batchSize,
                                                                      offset: currentOffset)
        groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter,
                                                   dateFormat: currentDateFormatOption)
    }

    func loadMore() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        currentOffset += batchSize
        let more = SummaryExerciseParameterStorage.fetchBatch(in: viewContext,
                                                              limit: batchSize,
                                                              offset: currentOffset)
        if !more.isEmpty {
            summaryParameter.append(contentsOf: more)
            groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter,
                                                       dateFormat: currentDateFormatOption)
        }
        isLoadingMore = false
    }

    func reloadAll() {
        loadInitialBatch()
    }

    
    
    func updateSummaryParameters() {
        let allSummary: [[SummaryExerciseParameterStorage]] = FitnessExerciseCategory().categories.map {
            SummaryExerciseParameterStorage.loadSummaryParameter(for: $0.name, in: viewContext)
        }
        summaryParameter = allSummary
            .flatMap { $0 }
            .sorted { ($0.dateAdded ?? Date.distantPast) > ($1.dateAdded ?? Date.distantPast) }
        groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
    }

    
    
    var archiveBox: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        showHistoryList.toggle()
                    }
                }) {
                    Image(systemName: "archivebox.circle.fill")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundColor(.Orange)
                        .frame(height: 40)
                        .background {
                            BlurView(style: theme.main.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                }
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                if showHistoryList {
                    dateFormatToggle
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 40)
            
            if showHistoryList { HistoryList() }
        }
        .frame(width: UIScreen.main.bounds.width - 50)
        .padding(5)
        .mask(RoundedRectangle(cornerRadius: 25))
        .background(BlurRoundedBackground(cornerRadius: 25,
                                          style: theme.main.ultraThinMaterial))
    }
    
    var dateFormatToggle: some View {
        HStack(spacing: 0) {
            ForEach(DateFormatOption.allCases, id: \.rawValue) { dateFormatOption in
                HStack(spacing: 5) {
                    Text("\(dateFormatOption)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(currentDateFormatOption == dateFormatOption.rawValue ? theme.main.mainColor : .Orange)
                .shadow(radius: 2)
                .scaleEffect(currentDateFormatOption == dateFormatOption.rawValue ? 1.2 : 1)
                .frame(width: 60, height: 30)
                .background {
                    if currentDateFormatOption == dateFormatOption.rawValue {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(Color.Orange)
                            .matchedGeometryEffect(id: "ActiveDate", in: animation)
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(Color.white.opacity(0.0001))
                    }
                }
                .onTapGesture {
                    currentDateFormatOption = dateFormatOption.rawValue
                    groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 1), value: currentDateFormatOption)
        .padding(4)
        .background(BlurRoundedBackground(style: theme.main.ultraThinMaterial))
        .transition(.scale)
    }
    
    @ViewBuilder
    func HistoryList() -> some View {
        if summaryParameter.isEmpty {
            Text("History is empty!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.main.text)
                .padding(5)
                .background(BlurRoundedBackground(cornerRadius: 20, style: theme.main.ultraThinMaterial))
        }
        else {
            TabView(selection: $selectedTimeUnit) {
                ForEach(groupedByTimeUnit.sorted(by: { $0.key > $1.key }), id: \.key) { timeUnit, items in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Text(timeUnit)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.Orange)
                                .padding(4)
                                .background {
                                    BlurView(style: theme.main.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 4)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                            
                            ForEach(items.indices, id: \.self) { index in
                                let parameter = items[index]
                                
                                VStack(spacing: 10) {
                                    HStack(spacing: 10) {
                                        Text(parameter.categoryName ?? "Unknown")
                                            .font(.system(size: 20, weight: .heavy))
                                            .foregroundColor(.Orange)
                                            .minimumScaleFactor(0.5)
                                            .padding(.leading, 5)
                                        Spacer()
                                        Text(parameter.dateAdded.map { formatter.string(from: $0) } ?? "No date")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(theme.main.text)
                                            .padding(.trailing, 5)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 70, height: 30)
                                    .background(
                                        BlurView(style: theme.main.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .shadow(radius: 2)
                                    )
                                    .scaleEffect(isPressingOnText && beingPressedOn == index ? 0.5 : 1.0)
                                    .animation(.spring(response: 0.5, dampingFraction: 1), value: isPressingOnText)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                            selectedParameter = (selectedParameter == parameter) ? nil : parameter
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 1.5, pressing: { isPressing in
                                        isPressingOnText = isPressing
                                        if isPressing {
                                            beingPressedOn = index
                                        }
                                    } ,perform: {
                                        if let index = beingPressedOn {
                                            viewContext.delete(summaryParameter[index])
                                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                                summaryParameter.removeAll { $0 == summaryParameter[index] }
                                                groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
                                                selectedParameter = nil
                                            }
                                            try? viewContext.save()
                                        }
                                    })
                                    
                                    if selectedParameter == parameter {
                                        VStack(spacing: 35) {
                                            AccuracyBarButton(parameter: parameter)
                                            
                                            VStack(spacing: 20) {
                                                RepSummaryView(minimizeBarChart: true,
                                                               screenWidth: CGFloat(UIScreen.main.bounds.width - 100),
                                                               totalCorrect: CGFloat(parameter.totalCorrect),
                                                               totalIncorrect: CGFloat(parameter.totalIncorrect),
                                                               targetCount: Int(parameter.targetCount))
                                                TimeSummaryView(minimizeBarChart: true,
                                                                screenWidth: CGFloat(UIScreen.main.bounds.width - 100),
                                                                totalTime: CGFloat(parameter.totalTime),
                                                                targetTime: Int(parameter.targetTime))
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        .transition(.scale)
                                    }
                                }
                                .mask(RoundedRectangle(cornerRadius: 15))
                                .background(BlurRoundedBackground(cornerRadius: 15, style: theme.main.ultraThinMaterial))
                                .frame(width: UIScreen.main.bounds.width - 30)
                            }
                            
                            Spacer().frame(height: 50)
                        }
                    }
                    .tag(timeUnit)
                }
            }
            .tabViewStyle(.page)
            .frame(width: UIScreen.main.bounds.width - 30)
            .frame(height: 300)
            .onChange(of: selectedTimeUnit) {newValue in
                selectedParameter = nil
//                if let unit = newValue {
//                    groupedByTimeUnit = SummaryExerciseParameterStorage.loadSummaryParameterForTimeUnit(for: "YourCategoryName", timeUnit: unit, in: viewContext)
//                }
            }
            .transition(.scale)
        }
    }
    
    @ViewBuilder
    func AccuracyBarButton(parameter: SummaryExerciseParameterStorage) -> some View {
        if selectedParameter == parameter {
            let total = Int(parameter.totalCorrect + parameter.totalIncorrect)
            Button(action: {
                showFeedbackTextSheet.toggle()
            }) {
                accuracyBar(parameter: parameter)
            }
            .customHeightSheet(showSheet: $showFeedbackTextSheet,
                               sheetHeight: 500) {
                    FeedbackSummaryView(screenWidth: CGFloat(UIScreen.main.bounds.width - 60),
                                        feedbackText: [""],
                                        totalCorrect: Int(parameter.totalCorrect),
                                        totalCount: Int(total),
                                        convertByJSONString: parameter.feedbackText)
                    .environmentObject(AppThemeController())
            } onEnd: {}
        }
        else {
            accuracyBar(parameter: parameter)
        }
    }
    
    @ViewBuilder
    func accuracyBar(parameter: SummaryExerciseParameterStorage) -> some View {
        let total = Int(parameter.totalCorrect + parameter.totalIncorrect)
        HStack(spacing: 5) {
            Image(systemName: "scope")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
            Text("Accuracy: \(total != 0 ? Int(Double(parameter.totalCorrect) / Double(total) * 100.0) : 0)%")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.trailing, 3)
        .frame(height: 30)
        .minimumScaleFactor(0.5)
        .background(
            BlurView(style: .systemUltraThinMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 4)
        )
    }
}

struct ArchiveBox_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
