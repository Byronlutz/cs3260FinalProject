import SwiftUI

struct GameView: View {
    @State var playerNames: [String] // imports playerNames
    @State private var playerScores: [Int] //keeps track of players life
    @State private var diceValues: [[Int]] = Array(repeating: [0, 0], count: 4) // Two dice for 4 players
    @State private var showDice = false // toggle dice visability
    @State private var winnerName: String? // captures winners name
    @State private var showWinnerAnimation = false // toggle winner animation
    let startingLife: Int // imports starting life

    init(playerNames: [String], startingLife: Int) {
        self.playerNames = playerNames
        self.startingLife = startingLife
        self._playerScores = State(initialValue: Array(repeating: startingLife, count: playerNames.count))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    VStack {
                        Text("MAGIC THE GATHERING LIFE COUNTER")
                            .font(.system(size: 30))
                            .frame(height: 100)
                            .frame(maxWidth: .infinity, maxHeight: 75)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: 200)// makes sure it aligns properly
                    .padding(0)

                    Button(action: {
                        rollDice()
                    }) {
                        Text("Roll Dice")
                            .font(.title)
                            .padding(20)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .offset(y: 415)//makes sure it aligns properly
                    .padding(0)

                    HStack(spacing: 0) {
                        if playerNames.count > 0 {
                            ZStack {
                                PlayerScoreView(name: playerNames[0], score: $playerScores[0])//calls PlayerScoreView with first selected player
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                    .rotationEffect(Angle(degrees: 90))
                                if showDice {
                                    DiceStackView(diceValues: diceValues[0])
                                        .offset(y: 100)// makes sure it alligns properly
                                }
                            }
                        }
                        if playerNames.count > 1 {
                            ZStack {
                                PlayerScoreView(name: playerNames[1], score: $playerScores[1])//calls PlayerScoreView with second selected player
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                    .rotationEffect(Angle(degrees: 270))
                                if showDice {
                                    DiceStackView(diceValues: diceValues[1])
                                        .offset(y: 100)
                                }
                            }
                        }
                    }

                    HStack(spacing: 0) {
                        if playerNames.count > 2 {
                            ZStack {
                                PlayerScoreView(name: playerNames[2], score: $playerScores[2])//calls PlayerScoreView with third selected player
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                    .rotationEffect(Angle(degrees: 90))
                                if showDice {
                                    DiceStackView(diceValues: diceValues[2])
                                        .offset(y: -100)
                                }
                            }
                        }
                        if playerNames.count > 3 {
                            ZStack {
                                PlayerScoreView(name: playerNames[3], score: $playerScores[3])//calls PlayerScoreView with fourth selected player
                                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                    .rotationEffect(Angle(degrees: 270))
                                if showDice {
                                    DiceStackView(diceValues: diceValues[3])
                                        .offset(y: -100)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                
                // if showWinnerAnimation it displays it and on touch it exits
                if showWinnerAnimation, let winnerName = winnerName {
                    WinnerAnimationView(winnerName: winnerName, showAnimation: $showWinnerAnimation)
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)// makes sure it is correct size
                        
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 1.5)) {
                                showWinnerAnimation = false // disables animation on click
                            }
                        }
                }
            }
            .navigationBarTitle("Score Tracker", displayMode: .inline)
            .padding(0)
            .onChange(of: playerScores) {
                checkForWinner() // Add your logic here
            }

            .offset(y: -200)
        }
        // sets background to image uploaded in project
        .background(
            Image("backgroundimage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
    }

    // Function to roll the dice
    private func rollDice() {
        // Randomly generate dice values for each player
        diceValues = diceValues.indices.map { _ in
            [Int.random(in: 1...6), Int.random(in: 1...6)]
        }
        showDice = true // Show the dice after randomizing
    }

    // Function to check for a winner
    private func checkForWinner() {
        let playersWithLife = playerScores.filter { $0 > 0 } // sets players with life = any playerScore over 0
        // if playerWithLife is 1 it sets winner to winnerName
        if playersWithLife.count == 1, let winnerIndex = playerScores.firstIndex(of: playersWithLife.first!) {
            let winnerName = playerNames[winnerIndex]
            showWinner(winnerName: winnerName)
        }
    }

    // Function to show the winner animation sets showWinnerAnimation to true
    private func showWinner(winnerName: String) {
        self.winnerName = winnerName
        withAnimation(.easeInOut(duration: 2.0)) {
            showWinnerAnimation = true
        }
    }
}

//Creates the winner animation view
struct WinnerAnimationView: View {
    let winnerName: String
    @Binding var showAnimation: Bool

    var body: some View {
        //makes sure it is the correct size
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width, height: (geometry.size.height + 1000)) // makes sure it takes up the entire background
                    

                VStack {
                    //sets and alligns the winner text correctly
                    Text("\(winnerName) \nis the Winner!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(20)
                        .scaleEffect(1.5)
                        .transition(.scale)
                        .opacity(1.0)
                        .multilineTextAlignment(.center)

                    ConfettiStartView()// calls ConfettiStartView
                        .opacity(1.0)
                    
                    ConfettiStartView() // calls another one for more variety in animation
                        .opacity(1.0)
                }
                .offset(y:300)// correctly aligns it to fit screen where i want
            }
            
        }
    }
}


struct ConfettiStartView: View {
    @State private var confettiOffset: CGFloat = -UIScreen.main.bounds.height // sets start point to screen bounds
    @State private var showConfetti = true // variable to turn off and on confetti

    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView()// calls confeti view with offset of screen length and animation that will repeat view until turned off
                    .offset(y: confettiOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                            confettiOffset = UIScreen.main.bounds.height
                        }
                    }
                
            }
        }
        .offset(y:-100)
        .onTapGesture {
            withAnimation(.easeOut(duration: 1.5)) {
                showConfetti = false // turns it off after touched and will ease out for better look
            }
        }
    }
}
// creates 20 random squares to immulate confetti, fills them with random color and positions them in a random degree and position on screen
struct ConfettiView: View {
    var body: some View {
        ForEach(0..<20, id: \.self) { i in
            Rectangle()
                .fill(randomColor())
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: Double.random(in: 0...360)))
                .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
        }
    }
    // generates randomm color
    func randomColor() -> Color {
        let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .orange]
        return colors.randomElement()!
    }
}
// creates view for multiple dice
struct DiceStackView: View {
    let diceValues: [Int]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(diceValues, id: \.self) { value in
                DiceView(value: value)
            }
        }
    }
}
 // creates view for dice
struct DiceView: View {
    let value: Int

    var body: some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(5)
    }
}

// view for player scores
struct PlayerScoreView: View {
    let name: String
    @Binding var score: Int

    var body: some View {
        VStack {
            Text(name)
                .font(.title2)
                .padding()
            Text("\(score)")
                .fontWeight(.heavy)
                .font(.system(size: 31))
            // allows stepper to increase score up to 1000 or down to 0 from starting value
            Stepper(value: $score, in: 0...1000) {
            }
            .labelsHidden()// hiding label because we are using text to display value of score instead
            .padding()
        }
        //visual prefrences
        .background(Color.white.opacity(0.7))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    GameView(playerNames: ["Player 1", "Player 2", "Player 3", "Player 4"], startingLife: 2)
}
