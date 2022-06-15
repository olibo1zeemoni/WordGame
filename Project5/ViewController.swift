//
//  ViewController.swift
//  Project5
//
//  Created by Olibo moni on 07/02/2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
      
        if let wordsUrl =  Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: wordsUrl) {
                allWords = startWords.components(separatedBy: "\n")
                print(allWords.first!)
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = usedWords[indexPath.row]
        
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
            
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String){
        let lowerAnswer = answer.lowercased()
        
        if isOriginal(answer: lowerAnswer){
            if isPossible(answer: lowerAnswer){
                if isReal(answer: lowerAnswer){
                    usedWords.insert(lowerAnswer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else{
                    showErrorMessage(title: "Word not recognized", message: "You cant just make them up, you know!")
                    return
                }
            } else {
                showErrorMessage(title: "Word not possible", message: "You can't spell \(answer) from \(title!.lowercased())")
                return
            }
        } else {
            showErrorMessage(title: "Word already used", message: "Be more original")
            return
        }
        
    }
    
    func showErrorMessage(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac,animated: true)
    }
    
    func isOriginal(answer: String)-> Bool{
        switch answer{
        case  title?.lowercased():
            return false
        default:
            return !usedWords.contains(answer)
        }
        
    }
    func isPossible(answer: String)->Bool{
        guard var tempWord = title?.lowercased() else{ return false}
        
        for letter in answer {
            guard let position = tempWord.firstIndex(of: letter)
                 
            else { return false}
            tempWord.remove(at: position)
        }
       
        
        return true
    }
    func isReal(answer: String)->Bool{
//         let answer = answer
//            guard  answer.count >= 3 else { return false }
        switch answer.count {
        case 0...2:
            return false
        default:
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: answer.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: answer, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        }
        
    }
    
    @objc func restartGame(){
        title = allWords.randomElement()
        usedWords.removeAll()
        tableView.reloadData()
    }


}

