//
//  Untitled.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/14/25.
//
import SwiftUI
import CoreData

enum DateFormatOption: String, CaseIterable {
//    case Hour = "HH:mm, dd/MM/yyyy"
    case Day = "dd/MM/YYYY"
    case Month = "MM/YYYY"
    case Year = "YYYY"
}

struct HistorySummary: View {
    @EnvironmentObject var theme: AppThemeController
    
    let category: Category?
    @Environment(\.managedObjectContext) var viewContext
    @State var summaryParameter: [SummaryExerciseParameterStorage] = []
    @State var selectedIndex: Int?
    @State var selectedParameter: SummaryExerciseParameterStorage?
    @State var selectedTimeUnit: String?
    @State var showFeedbackTextSheet: Bool = false

    
    var formatter = DateFormatter()
    @State var groupedByTimeUnit: [String: [SummaryExerciseParameterStorage]] = [:]
    @AppStorage("DateFormatOption") var currentDateFormatOption: String = "MM/YYYY"
    
    @State private var isPressingOnText = false
    @State private var beingPressedOn: Int? = nil
    @Namespace private var animation

    
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

    
    init(category: Category?,
         formatter: DateFormatter = DateFormatter()) {
        self.category = category
        self.formatter = formatter
        formatter.dateFormat = "HH:mm, dd/MM/yyyy"
    }
    
    var body: some View {
        Group {
            if summaryParameter.isEmpty {
                Text("History is empty!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.main.text)
                    .padding(10)
                    .background(BlurRoundedBackground(cornerRadius: 15))
            } else {
                VStack {
                    dateFormatToggle
                    
                    TabView(selection: $selectedTimeUnit) {
                        ForEach(groupedByTimeUnit.sorted(by: { $0.key > $1.key }), id: \.key) { timeUnit, items in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 15) {
                                    Text(timeUnit)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(theme.main.accent)
                                        .padding(4)
                                        .mask(RoundedRectangle(cornerRadius: 20))
                                        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
                                        .padding(.horizontal)
                                        .padding(.top, 5)
                                    
                                    ForEach(items.indices, id: \.self) { index in
                                        let parameter = items[index]
                                        
                                        VStack(spacing: 30) {
                                            HStack(spacing: 10) {
                                                AccuracyBarButton(parameter: parameter)
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
                                                    viewContext.delete(items[index])
                                                    summaryParameter.removeAll { $0 == items[index] }
                                                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                                        groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
                                                        selectedParameter = nil
                                                    }
                                                    try? viewContext.save()
                                                }
                                            })
                                            
                                            if selectedParameter == parameter {
                                                Group {
                                                    VStack(spacing: 35) {
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
                                                }
                                                .transition(.scale)
                                            }
                                        }
                                        .mask(RoundedRectangle(cornerRadius: 15))
                                        .background {
                                            BlurRoundedBackground(cornerRadius: 15)
                                        }
                                        
                                        
                                        .frame(width: UIScreen.main.bounds.width - 30)
                                    }
                                    
                                    Spacer().frame(height: 30)
                                }
                            }
                            .tag(timeUnit)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 300)
                    .onChange(of: selectedTimeUnit) {newValue in
                        selectedParameter = nil
                    }
                }
            }
        }
        .transition(.scale)
        .onAppear {
            summaryParameter = SummaryExerciseParameterStorage.loadSummaryParameter(for: category?.name ?? "", in: viewContext)
            groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: currentDateFormatOption)
        }
    }
    
    
    
    var dateFormatToggle: some View {
        HStack(spacing: 0) {
            ForEach(DateFormatOption.allCases, id: \.rawValue) { dateFormatOption in
                HStack(spacing: 5) {
                    Text("\(dateFormatOption)")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(currentDateFormatOption == dateFormatOption.rawValue ? theme.main.mainColor : theme.main.accent)
                .shadow(radius: 2)
                .scaleEffect(currentDateFormatOption == dateFormatOption.rawValue ? 1.3 : 1)
                .frame(width: 80, height: 30)
                .background {
                    if currentDateFormatOption == dateFormatOption.rawValue {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(theme.main.accent)
                            .matchedGeometryEffect(id: "ActiveDateFormatOption", in: animation)
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(Color.white.opacity(0.0001))
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        currentDateFormatOption = dateFormatOption.rawValue
                        groupedByTimeUnit = groupSummaryByTimeUnit(summaryParameter, dateFormat: dateFormatOption.rawValue)
                    }
                }
            }
        }
        .padding(3)
        .background(
            BlurRoundedBackground(style: .systemMaterialLight)
        )
        .transition(.scale)
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
                .foregroundColor(theme.main.text)
            Text("Accuracy: \(total != 0 ? Int(Double(parameter.totalCorrect) / Double(total) * 100.0) : 0)%")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.main.text)
        }
        .padding(.trailing, 3)
        .frame(height: 30)
        .minimumScaleFactor(0.5)
        .background(
            Color.cyan.opacity(0.95)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 0)
        )
    }
}




struct HistorySummary_Previews: PreviewProvider {
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        ExerciseParameterSettingView(category: $category,
                                     exercisePerformance: FitnessExercisePerformance())
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
