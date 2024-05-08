//
//  ContentView.swift
//  HabitMap
//
//  Created by Martynas Baranskas on 08/05/2024.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    var habitName: String
    var creationDate: Date

    init(habitName: String, creationDate: Date) {
        self.habitName = habitName
        self.creationDate = creationDate
    }
}

struct ContentView: View {
    @State private var habits: [Habit] = []
    @State private var newHabitName: String = ""
    @State private var currentDate: Date = Date()
    
    @State private var isEditAlertPresented = false
    @State private var editedHabitIndex = 0
    @State private var editedHabitName = ""
    
    @State private var deletedHabitIndex = 0
    @State private var isDeleteAlertPresented = false
    
    @State private var isAddAlertPresented = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("To-Do")
                        .font(.largeTitle)
                    DatePicker("", selection: $currentDate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                    Button(action: {
                        isAddAlertPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
                .padding()

                List(filteredHabits(), id: \.id) { habit in
                    Text(habit.habitName)
                        .swipeActions(edge: .leading) {
                           Button(action: {
                               editedHabitIndex = habits.firstIndex(where: { $0.id == habit.id })!
                               editedHabitName = habits[editedHabitIndex].habitName
                               isEditAlertPresented.toggle()
                           }) {
                               Text("Edit")
                           }
                           .tint(.orange)
                       }
                       .swipeActions(edge: .trailing) {
                           Button(action: {
                               deletedHabitIndex = habits.firstIndex(where: { $0.id == habit.id })!
                               isDeleteAlertPresented.toggle()
                           }) {
                               Text("Delete")
                           }
                           .tint(.red)
                       }
                       .padding(.vertical, 8)
                   }
                   .alert("Add Task", isPresented: $isAddAlertPresented) {
                       TextField("Task Name", text: $newHabitName)
                       Button("Add", action: addHabit)
                       Button("Cancel", role: .cancel) { }
                   }
                   .alert("Edit Task", isPresented: $isEditAlertPresented) {
                       TextField("Task Name", text: $editedHabitName)
                       Button("Save", action: saveEditedHabit)
                       Button("Cancel", role: .cancel) { }
                   }
                   .alert("Are you sure you want to delete this Task?", isPresented: $isDeleteAlertPresented) {
                       Button("Yes") {
                           deleteHabit(index: deletedHabitIndex)
                       }
                       Button("Cancel", role: .cancel) { }
                   }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {

                    }

                }
                .listStyle(PlainListStyle())
                .padding()
            }
            .onAppear {
                loadHabits()
            }
        }
    
    private func addHabit() {
        let habit = Habit(habitName: newHabitName, creationDate: currentDate)
        habits.append(habit)
        saveHabits()
        newHabitName = ""
    }

    private func deleteHabit(index: Int) {
        habits.remove(at: index)
        saveHabits()
    }

    private func saveEditedHabit() {
        habits[editedHabitIndex].habitName = editedHabitName
        saveHabits()
        isEditAlertPresented.toggle()
    }

    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func loadHabits() {
        if let savedHabits = UserDefaults.standard.data(forKey: "tasks") {
            if let decodedHabits = try? JSONDecoder().decode([Habit].self, from: savedHabits) {
                self.habits = decodedHabits
            }
        }
    }

    private func filteredHabits() -> [Habit] {
        return habits.filter { Calendar.current.isDate($0.creationDate, inSameDayAs: currentDate) }
    }

    private func days(in month: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: month)!
        let days = range.compactMap { calendar.date(bySetting: .day, value: $0, of: month) }
        return days
    }

    private func hasHabits(for date: Date) -> Bool {
        return habits.contains { Calendar.current.isDate($0.creationDate, inSameDayAs: date) }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
