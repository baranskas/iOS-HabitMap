//  HabitsView.swift
//  HabitMap
//
//  Created by Martynas Baranskas on 08/05/2024.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    var habitName: String
}

struct HabitsView: View {
    @State private var isAddAlertPresented = false
    @State private var habits: [Habit] = []
    @State private var newHabitName = ""
    
    @State private var isEditAlertPresented = false
    @State private var editedHabitIndex = 0
    @State private var editedHabitName = ""
    
    @State private var deletedHabitIndex = 0
    @State private var isDeleteAlertPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(habits) { habit in
                        Text(habit.habitName)
                            .swipeActions(edge: .leading) {
                                Button(action: {
                                    editedHabitIndex = habits.firstIndex(where: { $0.id == habit.id })!
                                    editedHabitName = habits[editedHabitIndex].habitName
                                    isEditAlertPresented.toggle()
                                }) {
                                    Text("Edit")
                                }
                                .tint(.green)
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
                    }
                }
                .listStyle(PlainListStyle())
                .foregroundColor(.blue)
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddAlertPresented.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .alert("Add Habit", isPresented: $isAddAlertPresented) {
                    TextField("Habit Name", text: $newHabitName)
                    Button("Add", action: addHabit)
                    Button("Cancel", role: .cancel) { }
                }
                .alert("Edit Habit", isPresented: $isEditAlertPresented) {
                    TextField("Habit Name", text: $editedHabitName)
                    Button("Save", action: saveEditedHabit)
                    Button("Cancel", role: .cancel) { }
                }
                .alert("Are you sure you want to delete this habit?", isPresented: $isDeleteAlertPresented) {
                    Button("Yes") {
                        deleteHabit(index: deletedHabitIndex)
                    }
                    Button("Cancel", role: .cancel) { }
                }
                .navigationTitle("Your Habits")
            }
            .onAppear {
                if let savedHabits = UserDefaults.standard.data(forKey: "habits") {
                    if let decodedHabits = try? JSONDecoder().decode([Habit].self, from: savedHabits) {
                        self.habits = decodedHabits
                    }
                }
            }
        }
    }
    
    private func addHabit() {
        let habit = Habit(habitName: newHabitName)
        habits.append(habit)
        saveHabits()
        newHabitName = ""
    }
    
    private func deleteHabit(index: Int) {
        habits.remove(at: index)
        saveHabits()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits")
        }
    }
    
    private func saveEditedHabit() {
        habits[editedHabitIndex].habitName = editedHabitName
        saveHabits()
        isEditAlertPresented.toggle()
    }
}

#if DEBUG
struct HabitsView_Previews: PreviewProvider {
    static var previews: some View {
        HabitsView()
    }
}
#endif
