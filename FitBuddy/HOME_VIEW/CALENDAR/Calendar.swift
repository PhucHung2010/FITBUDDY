//
//  Calendar.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 23/7/25.
//

import SwiftUI
import AudioToolbox

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonthIndex = 0
    @State private var monthDates: [Date] = []
    
    @Environment(\.managedObjectContext) var viewContext
    @State var routineParameter: [RoutineExerciseStorage] = []
    @State var routineDayCopied: [RoutineExerciseStorage]?

    private let initialMonthsToDisplay = 1
    private let preloadThreshold = 1 // khi còn 2 tháng nữa thì load thêm
    
    var plannedDates: [Date?] {
        routineParameter.map { $0.plannedDate }
    }

    var body: some View {
        TabView(selection: $currentMonthIndex) {
            ForEach(monthDates.indices, id: \.self) { index in
                MonthlyCalendarView(monthDate: monthDates[index],
                                    selectedDate: $selectedDate,
                                    routineDayCopied: $routineDayCopied,
                                    plannedDates: plannedDates)
                    .tag(index)
                    .onAppear {
                        if index >= monthDates.count - preloadThreshold {
                            addMoreMonths()
                        }
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 350, alignment: .top)
        .onAppear {
            initializeMonths()
        }
        .onAppear {
            updatePlannedDate()
//            requestNotificationPermission()
//            scheduleNotifications(for: plannedDates)
            
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                   object: viewContext,
                                                   queue: .main) { _ in
                updatePlannedDate()
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self,
                                                      name: .NSManagedObjectContextObjectsDidChange,
                                                      object: viewContext)
        }
        .onChange(of: currentMonthIndex) {_ in
            updatePlannedDate()
        }
    }
    
    func updatePlannedDate() {
        routineParameter = RoutineExerciseStorage.loadRoutineParameter(forMonth: monthDates[currentMonthIndex], in: viewContext)
    }

    private func initializeMonths() {
        let startDate = Date.now.startOfMonth
        monthDates = (0..<initialMonthsToDisplay).compactMap {
            Calendar.current.date(byAdding: .month, value: $0, to: startDate)
        }
    }

    private func addMoreMonths() {
        guard let lastMonth = monthDates.last else { return }
        let newMonths = (1...12).compactMap {
            Calendar.current.date(byAdding: .month, value: $0, to: lastMonth)
        }
        monthDates.append(contentsOf: newMonths)
    }
}

struct MonthlyCalendarView: View {
    @EnvironmentObject var theme: AppThemeController
    @Environment(\.managedObjectContext) var viewContext
    
    let monthDate: Date
    @Binding var selectedDate: Date
    @Binding var routineDayCopied: [RoutineExerciseStorage]?
    var plannedDates: [Date?]

    private let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State var showCalendar = true
    @State var pastingRoutineDay = false

    var body: some View {
        VStack(spacing: 12) {
            // Header Bar
            HStack {
                Text("\(monthDate.formatted(.dateTime.year().month(.wide)))")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                if plannedDates.contains(selectedDate) || routineDayCopied != nil {
                    Button(action: {
                        if routineDayCopied == nil && plannedDates.contains(selectedDate) {
                            routineDayCopied = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                        } else if routineDayCopied != nil {
                            routineDayCopied = nil
                        }
                    }) {
                        Image(systemName: (routineDayCopied != nil) ? "checkmark.circle.fill" : "bookmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(theme.accentGradient)
                                    .shadow(color: theme.accentColor.opacity(0.3), radius: 4, y: 2)
                            )
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.88))
                    .transition(.scale)
                } else {
                    NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)

            VStack(spacing: 10) {
                // Weekday Row
                HStack {
                    ForEach(daysOfWeek.indices, id: \.self) { index in
                        Text(daysOfWeek[index])
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.45))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 6)

                // Days Grid
                LazyVGrid(columns: columns, spacing: 8) {
                    let today = Date.now.startOfDay
                    let calendarDays = monthDate.calendarDisplayDays

                    ForEach(calendarDays, id: \.self) { day in
                        if day.startOfDay < today && day.monthInt == monthDate.monthInt {
                            Text("\(Calendar.current.component(.day, from: day))")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.3))
                                .frame(width: 36, height: 36)
                        } else if day.monthInt != monthDate.monthInt {
                            Color.clear
                                .frame(width: 36, height: 36)
                        } else {
                            let isSelected = selectedDate.startOfDay == day.startOfDay
                            let isToday = day.startOfDay == today
                            let isPlanned = plannedDates.contains(day)
                            
                            Button(action: {
                                guard selectedDate != day.startOfDay else { return }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selectedDate = day.startOfDay
                                }
                                if let routineDay = routineDayCopied {
                                    RoutineExerciseStorage.deleteRoutineParameter(for: selectedDate, in: viewContext)
                                    for exercise in routineDay {
                                        let obj = RoutineExerciseStorage(context: viewContext)
                                        obj.id = exercise.id
                                        obj.categoryName = exercise.categoryName
                                        obj.plannedDate = selectedDate.startOfDay
                                        if exercise.targetTime == 0 { exercise.targetTime = -1 }
                                        if exercise.targetCount == 0 { exercise.targetCount = -1 }
                                        obj.targetCount = Int32(exercise.targetCount)
                                        obj.targetTime = Int32(exercise.targetTime)

                                        try? viewContext.save()
                                    }
                                }
                            }) {
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                                    .foregroundColor(
                                        isSelected ? .white :
                                        isToday ? NeumorphicColors.dotGreen :
                                        isPlanned ? theme.accentColor :
                                        theme.main.text
                                    )
                                    .frame(width: 36, height: 36)
                                    .background {
                                        if isSelected {
                                            Circle()
                                                .fill(theme.accentGradient)
                                                .shadow(color: theme.accentColor.opacity(0.4), radius: 5, y: 2)
                                        } else if isToday {
                                            Circle()
                                                .fill(NeumorphicColors.dotGreen.opacity(0.18))
                                                .overlay(Circle().stroke(NeumorphicColors.dotGreen, lineWidth: 1.5))
                                        } else if isPlanned {
                                            Circle()
                                                .fill(theme.accentColor.opacity(0.15))
                                        }
                                    }
                            }
                            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.88))
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 12)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .padding(10)
        .neumorphicCard(cornerRadius: 28)
    }
}




// MARK: COMPACT CALENDAR VIEW

struct CompactCalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentWeekStart: Date = Date().startOfWeek

    private let calendar = Calendar.current
    private let daysOfWeek = Calendar.current.shortWeekdaySymbols // ["Sun", "Mon", ..., "Sat"]

    var body: some View {
        HStack(spacing: 8) {
            // Previous week
            Button(action: {
                withAnimation {
                    currentWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart)!
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.purple)
            }

            ForEach(0..<7, id: \.self) { offset in
                let day = calendar.date(byAdding: .day, value: offset, to: currentWeekStart)!
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(day)

                VStack(spacing: 5) {
                    Text(day.formatted(.dateTime.weekday(.abbreviated)).uppercased()) // MON
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Text("\(calendar.component(.day, from: day))")
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .black)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.purple : Color.clear)
                        )

                    Circle()
                        .fill(isToday ? .red : .clear)
                        .frame(width: 6, height: 6)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation {
                        selectedDate = day
                    }
                }
            }

            // Next week
            Button(action: {
                withAnimation {
                    currentWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
    }
}

extension Date {
    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
