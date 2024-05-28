//
//  ContentView.swift
//  Word Scramble
//
//  Created by Mehmet Alp Sönmez on 28/05/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var wordScore = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Section {
                    Text("Your Score: \(wordScore)")
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("New Word", action: startGame)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .scrollContentBackground(.hidden)
            .background(RadialGradient(colors: [.yellow, .indigo, .white], center: .center, startRadius: 50, endRadius: 500))
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK") {
                }
            } message: {
                Text(errorMessage)
            }
        }

    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        
        guard wordLength(word: answer) else {
            wordError(title: "Insufficient Character", message: "Word must have at least three character!")
            return
        }
        guard wordItself(word: answer) else {
            wordError(title: "Repetition", message: "You can't enter the word itself! Cheating is not good!!")
            return
        }
            
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up you know!!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)' !")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        wordScore += answer.utf16.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                wordScore = 0
                usedWords.removeAll()
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var  tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func wordLength(word: String) -> Bool {
        let charCount = word.utf16.count
        if charCount > 2 {
            return true
        } else {
            return false
        }
    }
    
    func wordItself(word: String) -> Bool {
        if word != rootWord {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    ContentView()
}
