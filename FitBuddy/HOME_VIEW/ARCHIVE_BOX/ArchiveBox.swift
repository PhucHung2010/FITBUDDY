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
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        showHistoryList.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: showHistoryList ? "archivebox.fill" : "archivebox")
                            .font(.system(size: 16, weight: .bold))
                        Text("Archive")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(showHistoryList ? .white : theme.main.text)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                    .background {
                        if showHistoryList {
                            Capsule().fill(theme.accentGradient)
                        }
                    }
                    .neumorphicPill(gradient: showHistoryList ? theme.accentGradient : nil)
                }
                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.92))
                
                Spacer()
                
                if showHistoryList {
                    dateFormatToggle
                } else {
                    NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 6)
            
            if showHistoryList { HistoryList() }
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .neumorphicCard(cornerRadius: 28)
    }
    
    var dateFormatToggle: some View {
        HStack(spacing: 4) {
            ForEach(DateFormatOption.allCases, id: \.rawValue) { dateFormatOption in
                let isActive = currentDateFormatOption == dateFormatOption.rawValue
                Text("\(dateFormatOption)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(isActive ? .white : theme.main.text.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        if isActive {
                            Capsule()
                                .fill(theme.accentGradient)
                                .matchedGeometryEffect(id: "ActiveDate", in: animation)
                                .shadow(color: Color.black.opacity(0.18), radius: 3, y: 1)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            currentDateFormatOption = dateFormatOption.rawValue
                            groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
                        }
                    }
            }
        }
        .padding(3)
        .neumorphicInset(cornerRadius: 18)
        .transition(.scale)
    }
    
    @ViewBuilder
    func HistoryList() -> some View {
        if summaryParameter.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 32))
                    .foregroundColor(theme.main.text.opacity(0.35))
                Text("History is empty!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .neumorphicInset(cornerRadius: 20)
        }
        else {
            TabView(selection: $selectedTimeUnit) {
                ForEach(groupedByTimeUnit.sorted(by: { $0.key > $1.key }), id: \.key) { timeUnit, items in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            Text(timeUnit)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .neumorphicInset(cornerRadius: 12)
                                .padding(.top, 4)
                            
                            ForEach(items.indices, id: \.self) { index in
                                let parameter = items[index]
                                
                                VStack(spacing: 8) {
                                    HStack(spacing: 10) {
                                        Text(parameter.categoryName ?? "Unknown")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(theme.main.text)
                                            .minimumScaleFactor(0.6)
                                            .padding(.leading, 6)
                                        Spacer()
                                        Text(parameter.dateAdded.map { formatter.string(from: $0) } ?? "No date")
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(theme.main.text.opacity(0.5))
                                            .padding(.trailing, 6)
                                            .minimumScaleFactor(0.6)
                                    }
                                    .frame(height: 36)
                                    .scaleEffect(isPressingOnText && beingPressedOn == index ? 0.96 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressingOnText)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
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
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                summaryParameter.removeAll { $0 == summaryParameter[index] }
                                                groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
                                                selectedParameter = nil
                                            }
                                            try? viewContext.save()
                                        }
                                    })
                                    
                                    if selectedParameter == parameter {
                                        VStack(spacing: 16) {
                                            AccuracyBarButton(parameter: parameter)
                                            
                                            VStack(spacing: 14) {
                                                RepSummaryView(minimizeBarChart: true,
                                                               screenWidth: CGFloat(UIScreen.main.bounds.width - 90),
                                                               totalCorrect: CGFloat(parameter.totalCorrect),
                                                               totalIncorrect: CGFloat(parameter.totalIncorrect),
                                                               targetCount: Int(parameter.targetCount))
                                                TimeSummaryView(minimizeBarChart: true,
                                                                screenWidth: CGFloat(UIScreen.main.bounds.width - 90),
                                                                totalTime: CGFloat(parameter.totalTime),
                                                                targetTime: Int(parameter.targetTime))
                                            }
                                        }
                                        .padding(.vertical, 10)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .neumorphicCard(cornerRadius: 18)
                                .frame(width: UIScreen.main.bounds.width - 50)
                            }
                            
                            Spacer().frame(height: 50)
                        }
                    }
                    .tag(timeUnit)
                }
            }
            .tabViewStyle(.page)
            .frame(width: UIScreen.main.bounds.width - 32)
            .frame(height: 300)
            .onChange(of: selectedTimeUnit) { newValue in
                selectedParameter = nil
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
        let accuracyPercent = total != 0 ? Int(Double(parameter.totalCorrect) / Double(total) * 100.0) : 0
        HStack(spacing: 6) {
            Image(systemName: "scope")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            Text("Accuracy: \(accuracyPercent)%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(accuracyPercent >= 80 ? NeumorphicColors.greenGradient : NeumorphicColors.coralGradient)
                .shadow(color: Color.black.opacity(0.18), radius: 4, y: 2)
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
