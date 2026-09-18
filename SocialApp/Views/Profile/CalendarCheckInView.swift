import SwiftUI

struct CalendarCheckInView: View {
    let userId: Int
    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentYear: Int
    @State private var currentMonth: Int

    private let calendar = Calendar.current
    private let months = ["1月", "2月", "3月", "4月", "5月", "6月",
                          "7月", "8月", "9月", "10月", "11月", "12月"]

    init(userId: Int, vm: ProfileViewModel) {
        self.userId = userId
        self.vm = vm
        let now = Date()
        _currentYear = State(initialValue: calendar.component(.year, from: now))
        _currentMonth = State(initialValue: calendar.component(.month, from: now))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 年/月 切换
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Text("\(String(currentYear))年 \(months[currentMonth - 1])")
                        .font(.headline)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                if vm.checkedInToday {
                    Text("今日已打卡 ✅")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.green)
                }

                // 星期标题
                HStack {
                    ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                        Text(day)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // 日历格子
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    let days = generateDays()
                    let checkinDatesSet = Set(vm.checkinDates)

                    ForEach(days, id: \.self) { day in
                        if day == 0 {
                            Text("")
                                .frame(height: 36)
                        } else {
                            let dateStr = String(format: "%04d-%02d-%02d", currentYear, currentMonth, day)
                            let isChecked = checkinDatesSet.contains(dateStr)
                            let isToday = isDateToday(day: day)

                            Text("\(day)")
                                .font(.callout)
                                .frame(width: 36, height: 36)
                                .background(isChecked ? Color.green : Color.clear)
                                .foregroundColor(isChecked ? .white : (isToday ? .blue : .primary))
                                .clipShape(Circle())
                                .overlay(
                                    isToday ?
                                    Circle().stroke(Color.blue, lineWidth: 2) : nil
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)

                // 统计信息
                VStack(spacing: 8) {
                    HStack {
                        Text("本月打卡")
                        Spacer()
                        Text("\(vm.totalThisMonth) 天")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("连续打卡")
                        Spacer()
                        Text("\(vm.checkinStreak) 天")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("累计打卡")
                        Spacer()
                        Text("\(vm.totalAll) 天")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("打卡记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .task { await vm.loadCheckinRecords(userId: userId, year: currentYear, month: currentMonth) }
        .onChange(of: currentYear) { _ in
            Task { await vm.loadCheckinRecords(userId: userId, year: currentYear, month: currentMonth) }
        }
        .onChange(of: currentMonth) { _ in
            Task { await vm.loadCheckinRecords(userId: userId, year: currentYear, month: currentMonth) }
        }
    }

    // MARK: - 生成日历网格
    private func generateDays() -> [Int] {
        let comps = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let firstDay = calendar.date(from: comps) else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay) // 1=Sun
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 30

        var days: [Int] = Array(repeating: 0, count: weekday - 1)
        days.append(contentsOf: 1...daysInMonth)
        return days
    }

    private func isDateToday(day: Int) -> Bool {
        let now = Date()
        let y = calendar.component(.year, from: now)
        let m = calendar.component(.month, from: now)
        let d = calendar.component(.day, from: now)
        return y == currentYear && m == currentMonth && d == day
    }

    private func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }

    private func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
}