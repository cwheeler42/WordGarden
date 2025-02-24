//
//  ContentView.swift
//  WordGarden
//
//  Created by Chris Wheeler on 2/19/25.
//

import SwiftUI

struct ContentView: View {
    private static let maximumGuesses = 8
    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]

    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var guessedLetter = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 100)
                .minimumScaleFactor(0.5)
                .padding()
            
            Text(revealedWord())
                .font(.title)
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else { return }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .onSubmit {
                            guard guessedLetter != "" else { return }
                            guessALetter()
                            updateGamePlay()
                        }
                        .focused($textFieldIsFocused)
                    
                    Button("Guess a Letter") {
                        guessALetter()
                        updateGamePlay()
                    }
                    .disabled(guessedLetter.isEmpty)
                    .buttonStyle(.bordered)
                    .tint(.mint)
                }
                .padding(.bottom)
            }
            else {
                Button(playAgainButtonLabel) {
                    // If all the words have been guessed
                    if currentWordIndex >= wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    
                    // Reset after word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    lettersGuessed = ""
                    let _ = revealedWord()
                    guessesRemaining = Self.maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
                .padding(.bottom)
            }

            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            lettersGuessed = ""
        }
    }
    
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
    }
    
    func revealedWord() -> String
    {
        return wordToGuess.map { letter in
            lettersGuessed.contains(letter) ? "\(letter)" : "_"
        }.joined(separator: " ")
    }
    
    func updateGamePlay() {
        // TODO: Redo this with LocalizedStringKey & Inflect
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "flower\(guessesRemaining)"
        }
        
        // When do we play another word?
        if !revealedWord().contains("_") {
            gameStatusMessage = "You Guessed It! It Took You \(lettersGuessed.count) Guesses to Guess the Word!"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
        }
        else if guessesRemaining == 0 {
            gameStatusMessage = "Game Over! You Are All Out of Guesses!"
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
        }
        else {
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        guessedLetter = ""
        
        if currentWordIndex >= wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\n\nRestart From the Beginning?"
        }
    }
}

#Preview {
    ContentView()
}
