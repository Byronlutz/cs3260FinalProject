//
//  DatabaseManager.swift
//  FinalProject
//
//  Created by Byron Lutz on 8/05/24.
//

import SQLite3
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        // Set up the database when the app starts
        openDatabase()
        createTable()
    }

    // Open the database connection
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("PlayersDatabase.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    // Create the Players table
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        );
        """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Players table created.")
            } else {
                print("Players table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    // Insert a player into the database
    func insertPlayer(name: String) {
        let insertQuery = "INSERT INTO Players (name) VALUES (?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted player.")
            } else {
                print("Could not insert player.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    // Fetch all players from the database
    func fetchPlayers() -> [String] {
        let query = "SELECT name FROM Players;"
        var queryStatement: OpaquePointer?
        var players: [String] = []

        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                if let nameCString = sqlite3_column_text(queryStatement, 0) {
                    let name = String(cString: nameCString)
                    players.append(name)
                }
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        return players
    }

    // Delete a player from the database
    func deletePlayer(name: String) {
        let deleteQuery = "DELETE FROM Players WHERE name = ?;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (name as NSString).utf8String, -1, nil)

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted player.")
            } else {
                print("Could not delete player.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    // Editing a player in the database
    func updatePlayer(oldName: String, newName: String) {
            let updateQuery = "UPDATE Players SET name = ? WHERE name = ?;"
            var updateStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(updateStatement, 1, (newName as NSString).utf8String, -1, nil)
                sqlite3_bind_text(updateStatement, 2, (oldName as NSString).utf8String, -1, nil)

                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated player name.")
                } else {
                    print("Could not update player name.")
                }
            } else {
                print("UPDATE statement could not be prepared.")
            }
            sqlite3_finalize(updateStatement)
        }
}
