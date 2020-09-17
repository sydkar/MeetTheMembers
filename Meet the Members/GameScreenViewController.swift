//
//  GameScreenViewController.swift
//  Meet the Members
//
//  Created by Sydney Karimi on 9/13/20.
//  Copyright © 2020 Sydney Karimi. All rights reserved.
//

import UIKit

class GameScreenViewController: UIViewController {
    //Outlet variables from storyboard
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var optionButton3: UIButton!
    @IBOutlet weak var optionButton4: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    
    //Timer stuff
    var time = 5 //5 seconds
    var isPaused = false
    var timer: Timer!
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    
    func pauseGame() {
        isPaused = !isPaused
        if isPaused {
            timer.invalidate()
            pauseButton.setTitle("Play", for: .normal)
            
        } else {
            startTimer()
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
 
    
    //MARK: Game Variables
    let nameList = Constants.names //names in the original order
    var gameNameList: [String] = []//the name list we will use for the game
    var totalNames: Int!
    var score = 0 //current score for the game
    var currentlyDisplaying: String!
    var streak: Int = 0
    var results: [String] = []
    var questionNumber = 0
    var lastThreeNames: [String] = ["None", "None", "None"]
    var longestStreak = 0
    var currentlyPlaying = false
    var correctButton: UIButton!
    
    
    func shuffleNames() -> [String] {
        return nameList.shuffled()
    }

    func setScoreLabel(_ score: Int) {
        scoreLabel.text = ("Score: " + String(score))
    }
    
    func setLastThreeNames(newName:String) {
        lastThreeNames = [newName, lastThreeNames[0], lastThreeNames[1]]
    }
    
    func setButtonOptions(_ answer: String) {
        var shuffledOptions = shuffleNames()
        shuffledOptions.removeAll(where: { $0 == answer })
        var buttonTitles: [String] = [answer, shuffledOptions[0], shuffledOptions[1], shuffledOptions[2]]
        buttonTitles.shuffle()
        
        optionButton1.setTitle(buttonTitles[0], for: .normal)
        optionButton2.setTitle(buttonTitles[1], for: .normal)
        optionButton3.setTitle(buttonTitles[2], for: .normal)
        optionButton4.setTitle(buttonTitles[3], for: .normal)
        if optionButton1.title(for: .normal) == answer {correctButton=optionButton1}
        if optionButton2.title(for: .normal) == answer {correctButton=optionButton2}
        if optionButton3.title(for: .normal) == answer {correctButton=optionButton3}
        if optionButton4.title(for: .normal) == answer {correctButton=optionButton4}
        
    }
    
    func checkButtonAnswer(answerChoice: String) -> Bool{
        timer.invalidate()
        timerLabel.text = String(5)
        if answerChoice == currentlyDisplaying {
            score += 1
            streak += 1
            if streak > longestStreak {longestStreak = streak}
            setScoreLabel(score)
            setLastThreeNames(newName: currentlyDisplaying)
            return true
        } else {
            if streak > longestStreak {longestStreak = streak}
            streak = 0
            setLastThreeNames(newName: currentlyDisplaying)
            return false
        }
    }
    
    //MARK: - Next Question
    func nextQuestion(question: Int) {
        time = 5
        setButtonColors()
        questionNumber = question + 1
        //STILL NEED TO HANDLE THE GAME ENDING HERE!!!!!
        if question >= gameNameList.count {
            timer.invalidate()
            currentlyPlaying = false
            print("Game Ended")
            performSegue(withIdentifier: "toResultsScreen", sender: self)
        } else {
            startTimer()
            currentlyDisplaying = gameNameList[question]
            //print stuff for debugging
            print("Question: " + String(questionNumber))
            print(currentlyDisplaying)
            print("Longset streak: " + String(longestStreak))
            print("Current streak: " + String(streak))
            
            pictureView.image = Constants.getImageFor(name: currentlyDisplaying)
            setButtonOptions(currentlyDisplaying)
            setScoreLabel(score)
        }
        
    }

    func startGame() {
        print("New game started with startGame()")
        score = 0
        currentlyPlaying = true
        questionNumber = 0
        gameNameList = shuffleNames()
        lastThreeNames = ["None", "None", "None"]
        longestStreak = 0
        nextQuestion(question: questionNumber)
        //startTimer()
    }
    
    
    func setButtonColors() {
        optionButton1.backgroundColor = .orange
        optionButton2.backgroundColor = .purple
        optionButton3.backgroundColor = .yellow
        optionButton4.backgroundColor = .cyan
    }
    
    //MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Running viewDidLoad")
        startGame()
    }
    
    
    //MARK: - Overrides
    override func viewDidAppear(_ animated: Bool) {
        print("Running viewDidAppear")
        if currentlyPlaying == false {
            print("New game started")
            startGame()
        }
        if isPaused {
            print("Unpaused")
            pauseGame()
        }
    }
    
    @objc func updateTime(){
        if time >= 0 {
            timerLabel.text = String(time)
            time -= 1
        }
        if time == -1 {
            checkButtonAnswer(answerChoice: "No Answer Given")
            nextQuestion(question: questionNumber)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStatisticsScreen" {
            let controller = segue.destination as! StatisticsViewController
            controller.lastThreeNamesArray = lastThreeNames
            controller.longestStreak = longestStreak
        }
        
        if segue.identifier == "toResultsScreen" {
            let controller = segue.destination as! ResultsViewController
            controller.finalScore = score
            controller.longestStreak = longestStreak
            controller.totalQuestions = gameNameList.count
        }
    }
    
    
    //MARK: - Animations
    func animateCorrect(correctButton:UIButton) {
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                       correctButton.backgroundColor = .green
                        //self.optionButton1.frame.size.width = 200
        }, completion: { _ in
            self.nextQuestion(question: self.questionNumber)
        })
    }
    
    func animateIncorrect(incorrectButton: UIButton) {
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.correctButton.backgroundColor = .green
                        incorrectButton.backgroundColor = .red
        }, completion: { _ in
            self.nextQuestion(question: self.questionNumber)
        })
    }
    
    
    //MARK: - Button Actions
    var correct = false
    
    @IBAction func onStatButton(_ sender: Any) {
        pauseGame()
        performSegue(withIdentifier: "toStatisticsScreen", sender: self)
    }
    
    @IBAction func onPauseButton(_ sender: Any) {
        pauseGame()
    }
    
    @IBAction func onButton1(_ sender: Any) {
        correct = checkButtonAnswer(answerChoice: optionButton1.title(for: .normal) ?? "No Name")
        
        if correct {
            animateCorrect(correctButton: optionButton1)
        } else {
            animateIncorrect(incorrectButton: optionButton1)
        }
    }
    
    @IBAction func onButton2(_ sender: Any) {
        correct = checkButtonAnswer(answerChoice: optionButton2.title(for: .normal) ?? "No Name")
        
        if correct {
            animateCorrect(correctButton: optionButton2)
        } else {
            animateIncorrect(incorrectButton: optionButton2)
        }
    }
    
    @IBAction func onButton3(_ sender: Any) {
        correct = checkButtonAnswer(answerChoice: optionButton3.title(for: .normal) ?? "No Name")
        
        if correct {
            animateCorrect(correctButton: optionButton3)
        } else {
            animateIncorrect(incorrectButton: optionButton3)
        }
    }
    
    @IBAction func onButton4(_ sender: Any) {
        correct = checkButtonAnswer(answerChoice: optionButton4.title(for: .normal) ?? "No Name")
        
        if correct {
            animateCorrect(correctButton: optionButton4)
        } else {
            animateIncorrect(incorrectButton: optionButton4)
        }
    }
    
}
