//
//  ContentView.swift
//  FinalProject
//
//  Created by Byron Lutz on 8/05/24.
//

import SwiftUI

struct ContentView: View {
    @State private var numberOfPlayers = 2 // default value for number of players able to change
    @State private var playerNames: [String] = ["", ""]
    @State private var selectedPlayers: [String] = [] // able to select playerNames for game
    @State private var allPlayers: [String] = []
    @State private var isDeleteMode = false
    @State private var startingLife: Int = 20  // default starting life
    @State private var editingPlayer: String? = nil // Track the current player being edited
    @State private var editingPlayerIndex: Int? = nil // Track the index of the player being edited

    var body: some View {
        NavigationView {
            VStack {
                Text("Magic: The Gathering Score Tracker")
                    .font(.largeTitle)
                    .padding()
                    .multilineTextAlignment(.center)// makes text centered

                //shows picker for number of players 2-4 and sets it to numberOfPlayers
                Picker("Number of Players", selection: $numberOfPlayers) {
                    ForEach(2..<5) { i in
                        Text("\(i) Players").tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                //picker for starting life 20 or 40 and sets it to startingLife
                Picker("Starting Life", selection: $startingLife) {
                    Text("20 Life").tag(20)
                    Text("40 Life").tag(40)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                
                //diplays all of the players added
                List {
                    ForEach(allPlayers.indices, id: \.self) { index in
                        let player = allPlayers[index]
                        HStack {
                            if editingPlayerIndex == index {
                                TextField("Edit name", text: Binding(
                                    get: { editingPlayer ?? player },
                                    set: { newValue in
                                        editingPlayer = newValue
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    if let newName = editingPlayer, newName != player {
                                        updatePlayerName(oldName: player, newName: newName)
                                    }
                                    endEditing()
                                    resetPickers()
                                }
                            } else {
                                Text(player)
                                    .opacity(isDeleteMode ? 0.5 : 1.0)
                            }

                            if !isDeleteMode && editingPlayerIndex == nil {
                                Spacer()
                                if let position = selectedPlayers.firstIndex(of: player) {
                                    Text("\(position + 1)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .contentShape(Rectangle()) // To make the entire row tappable
                        .onTapGesture {
                            if !isDeleteMode {
                                if selectedPlayers.contains(player) {
                                    selectedPlayers.removeAll { $0 == player }
                                } else if selectedPlayers.count < numberOfPlayers {
                                    selectedPlayers.append(player)
                                }
                            }
                        }
                        .onLongPressGesture {
                            if !isDeleteMode {
                                startEditingPlayer(player: player, at: index)
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        deletePlayer(at: indexSet)
                        resetPickers()
                    })
                }





                //
                HStack {
                    TextField("Add new player", text: $playerNames[0])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        //adds playername to database when button action
                        if !playerNames[0].isEmpty {
                            DatabaseManager.shared.insertPlayer(name: playerNames[0])
                            loadPlayers()
                            playerNames[0] = ""
                        }
                    }) {
                        Text("Add")
                    }
                    .padding()
                }
                .padding()

                Spacer()
                
                // launches GameView with variables when pressed
                NavigationLink(destination: GameView(playerNames: selectedPlayers, startingLife: startingLife)) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedPlayers.count != numberOfPlayers)
                .padding()
            }
            .onAppear(perform: loadPlayers)// loads players from database when launched
            .onChange(of: numberOfPlayers) { _, _ in
                selectedPlayers = []
            }
        }
    }

    // Load players from the database
    private func loadPlayers() {
        allPlayers = DatabaseManager.shared.fetchPlayers()
    }
    
    // Delete player from the list
    private func deletePlayer(at offsets: IndexSet) {
        offsets.forEach { index in
            let player = allPlayers[index]
            DatabaseManager.shared.deletePlayer(name: player)
        }
        loadPlayers() // Refresh the list after deletion
    }
    // Reset pickers and selected players
    private func resetPickers() {
        numberOfPlayers = 2
        selectedPlayers = []
    }

    // Start editing a player's name at a specific index
    private func startEditingPlayer(player: String, at index: Int) {
        editingPlayer = player
        editingPlayerIndex = index
    }

    // End editing and reset states
    private func endEditing() {
        editingPlayer = nil
        editingPlayerIndex = nil
    }

    // Update player name in the database
    private func updatePlayerName(oldName: String, newName: String) {
        guard !newName.isEmpty else { return }
        DatabaseManager.shared.updatePlayer(oldName: oldName, newName: newName)
        loadPlayers() // Refresh the list after update
        endEditing()
    }


}

#Preview {
    ContentView()
}
