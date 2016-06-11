//
//  ViewController.swift
//  GameofSingle15
//
//  Created by Greg Simons 3rd on 5/13/16. Modified by Jun Li on 5/28/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ViewController: UIViewController, NSFetchedResultsControllerDelegate{
   
    @IBOutlet weak var timerLabel: UILabel! // diaplay current timer
    @IBOutlet weak var movesLabel: UILabel! // display current moves
    @IBOutlet weak var showBestTimeLabel: UILabel! //display best time record
    @IBOutlet weak var showBestMoveLabel: UILabel! // display best move record
    
    let backgroundView = UIImageView() // set background view
    let playgroundView = UIImageView() // an image view for playground to add on
    let pausedView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) // display a blurry view when paused
    
    let startTime = "00:00"
    let startMove = "0"
    let totalTime = 3600 // in seconds
    
    var gameTimer = NSTimer() //Declare a timer
    var timerCounter = 0
    var movesCounter = 0
    var isPaused = false // flag for determing if the playground is paused
    var randomizeIsFinished = false // flag for determing if ramdomizeLayout is finished
    var isMoved = false // flag for determing if a number is moved successfully
    
    let moc = DataController().managedObjectContext // instance of our managedObjectContext
    var frcMove : NSFetchedResultsController!
    var frcTime : NSFetchedResultsController!
    var moveArr = [MoveRecords]() // Declare an array to store move records
    var timeArr = [TimeRecords]() // Declare an array to store time records
    var newMoveRecord : MoveRecords!
    var newTimeRecord : TimeRecords!
    
    let screensize : CGRect = UIScreen.mainScreen().bounds
    
    let viewFrameMargin = 10 //margin around entire edge
    let cellFrameMargin = 2  //margin around each cell
    let rows  = 4; //4x4 game initially
    let cols  = 4;
    
    var emptyCellX = 0
    var emptyCellY = 0
    
    //  Declare Globals
    var cellWidth : Int = 0
    var cellHeight : Int = 0
    var offsetX0 : Int = 0
    var offsetY0 : Int = 0
    
    // Sounds
    var buttonBeep : AVAudioPlayer?
    var secondBeep : AVAudioPlayer?
    var backgroundMusic : AVAudioPlayer?
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    
    func cellEmpty(y: Int, x: Int)->Bool {
        //accepts any x & y.  Returns true if the cell is in valid range, and if the cell is not occupied with a button
        var retCode = false
        if ((0..<rows ~= y) && (0..<cols ~= x)) { //are cell coordinates in bounds?
            if (myBoard[x][y] == nil) { //is cell empty?
                retCode = true
            }
        }
        return retCode
    }
    
    
    func RandomizeLayout()->Void {
        randomizeIsFinished = false
        
        //var lastButtonMoved : UIButton? = nil //track last button moved, so we don't move it twice in a row
        for i in 1...50 {
            
            //find the empty cell
            // (this could be optimzed if needed)
            var emptyX = -1
            var emptyY = -1
            for x in 0..<cols {
                for y in 0..<rows {
                    if myBoard[x] [y] == nil {
                        emptyX = x
                        emptyY = y
                    }
                }
            }
            
            //debug error ck
            if emptyY == -1 || emptyX == -1 {
                print("ERROR -- NO EMPTY CELL FOUND iteration \(i) \n")
            }
            
            //now that we know the xy of empty cell, we choose a button in that row or col at random, as follows:
            // 1. we alternate on row or column
            // 2. within that row or column, we choose a cell at random, avoiding the empty cell
            
            var button : UIButton?
            if i % 2 == 0 { //alternate row/col
                //let this be row
                var randomCol = Int(arc4random()) % (cols-1) //NB:  this yields a random number 1 less than # of cols
                if randomCol == emptyX {
                    randomCol = randomCol + 1
                }
                button = myBoard[randomCol] [emptyY]
            } else {
                //let this be column
                var randomRow = Int(arc4random()) % (rows-1) //NB:  this yields a random number 1 less than # of rows
                if randomRow == emptyY {
                    randomRow = randomRow + 1
                }
                button = myBoard[emptyX] [randomRow]
            }
            
            buttonTouched(button)
            
            //let button = myBoard[Int(arc4random()) % cols] [Int(arc4random()) % rows]
//            if button != nil && button != lastButtonMoved { //avoid moving last button back
//                buttonTouched(button)
//                if isMoved {  //ck this flag that tells us if a piece was actually moved
//                    lastButtonMoved = button
//                }
//            } else if button != nil {
//                print("avoided redundant move on iteration \(i) \n")
//            } else  {
//                print("avoided nil button on iteration \(i) \n")
//            }
        
        }

        /*
        //go thru every board position, and swap it's tile with another randomly chosen tile
        var timeOfThisAnimation = 0.0
        var timeOfLastAnimation = 0.0
        let animationSpeed = 0.3    //animation speed coefficient
        for row in (0..<Int(rows)) {
            for col in (0..<cols) {
                
                let cga = CGPoint(x:col, y:row) //cell a is col/row
                let cgb = CGPoint(x:random() % cols, y:random() % rows) //cell b is random
                let buttonA = myBoard[col][row]
                let buttonB = myBoard[Int(cgb.x)][Int(cgb.y)]
                let distance = Double(hypot(cga.x - cgb.x, cga.y - cgb.y))
                
                //animate cga to cgb postion
                if (buttonA != nil) {
                    let destCenter = CGPointFromArray(cgb)
                    timeOfLastAnimation += timeOfThisAnimation
                    timeOfThisAnimation = animationSpeed * distance
                    
                    //self.view.bringSubviewToFront(buttonA!) //BUG:  THIS DOESN'T WORK -- NOT SURE WHY GS 5/25/16
                    UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveLinear, animations: {
                        self.view.bringSubviewToFront(buttonA!);
                        buttonA!.center.x = destCenter.x ; buttonA!.center.y = destCenter.y },
                                               completion:
                        {finished in self.view.sendSubviewToBack(buttonA!) }  )
                }
                
                //...and animate cgb to cga
                if (buttonB != nil) {
                    let destCenter = CGPointFromArray(cga)

                    timeOfLastAnimation += timeOfThisAnimation
                    timeOfThisAnimation = animationSpeed * distance
                    //self.view.bringSubviewToFront(myBoard[Int(cgb.x)][Int(cgb.y)]!)
                    
                    if(row == rows-1 && col == cols-1)
                    {
                        UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveEaseIn, animations: {
                            self.view.bringSubviewToFront(buttonB!) ;
                            buttonB!.center.x = destCenter.x ;
                            buttonB!.center.y = destCenter.y
                            }, completion: {finished in self.startTimer()})
                    }
                    else
                    {
                        UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveEaseIn, animations: {
                            self.view.bringSubviewToFront(buttonB!) ;
                            buttonB!.center.x = destCenter.x ;
                            buttonB!.center.y = destCenter.y },
                            completion: {finished in self.view.sendSubviewToBack(buttonB!) } )
                    }
                }

                BoardSwap(cga, b: cgb) //swap them in array
            }
        }
 */
        
        startTimerAsLastAnimation() //starts timer after all queued up "randomize" animations finish
    }
    

    
    
    func youWon()->Bool {
        for row in (0..<Int(rows)) {
            for col in (0..<cols) {
                if !((row == rows-1) && (col == cols-1)) { //leave last cell empty
                    
                    let boardTitle = myBoard[col][row]?.currentTitle
                    let shouldBe = (col + 1 + (row * cols)).description
                    if (boardTitle != shouldBe) {
                    //if (myBoard[col][row]?.currentTitle != ((col + 1 + (row * cols)).description)) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func ckIfYouWon()->Void {
        if (youWon()) {
            //let msgAlert = UIAlertView(title: "VICTORY", message: "You Won!!!!", delegate: nil, cancelButtonTitle: "Play Again")
            //let msgAlert = UIAlertController(title: "VICTORY", message: "You Won!!!!", preferredStyle: .Alert)
            //msgAlert.show()
            
            saveRecords()
            
            self.gameStop()
            
            let alert = UIAlertController(title: "VICTORY!", message:"Play Again?", preferredStyle: .Alert)
            
            backgroundMusic?.volume = 0.3 //temporary hack to play music -- will be changed so it is "victory" music and stops when dialog is dismissed
            backgroundMusic?.play()
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default){ _ in})
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in self.restartGame()})
            //attempt to present uialertcontroller which is already presenting!!
            self.presentViewController(alert, animated: true){}
        }
    }
    
    // This function display an alert when time is out
    func timeOut(){
        self.gameStop()
        
        let alert = UIAlertController(title: "Sorry, time is up!", message:"Play Again?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default){ _ in})
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in self.restartGame()})
        //attempt to present uialertcontroller which is already presenting!!
        self.presentViewController(alert, animated: true){}
    }
    
    func BoardIntegrityCheck()->Bool {
        /* verify that the location of every board tile button is where it should be 
         this is a utility function that should only be needed for debugging  */
        for row in (0..<Int(rows)) {
            for col in (0..<cols) {
                if let location = myBoard[col][row]?.center {
                 let shouldBe = CGPointFromArray(CGPointMake(CGFloat(col), CGFloat(row)))
                    if (location != shouldBe) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    
    var timeLastAnimationFinishes = 0.0
    

    func moveToEmptyCell(cgFrom: CGPoint, cgTo: CGPoint) {
        // moves board piece at cgFrom to cgTo, updating board data structure and initiating button animcation on screen
        // assumes board[cgTo] is nil
        
        /* Timing computations:
         We want animations to happen serially, regardless of whether this is initial "randomization" or normal moves.
         To make that happen, we track time last animation was supposed to finish, and we make sure this animation doesn't start before that.
         if timeOfLastAnimation >
        */
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var delay : Double
        if (currentTime > timeLastAnimationFinishes) { //if timeLastAnimationFinishes is in the past, and is irrelevant -- no delay
            timeLastAnimationFinishes = currentTime
        }
        delay = timeLastAnimationFinishes - currentTime //set up to wait until last animation finishes
        let duration = 0.1
        timeLastAnimationFinishes = timeLastAnimationFinishes + duration //set it up for next time
        
        let destCenter = CGPointFromArray(cgTo)
        let button = myBoard[Int(cgFrom.x)][Int(cgFrom.y)]!
        
       //UIView.animateWithDuration(0.5, animations: {sender.center.x = destCenter.x ; sender.center.y = destCenter.y })
        UIView.animateWithDuration(duration, delay: delay, options: .CurveLinear, animations: {button.center.x = destCenter.x ; button.center.y = destCenter.y ; self.isMoved = true}, completion: {finished in
            if (finished) {
                self.ckIfYouWon()
            }
        }) //completion
        BoardSwap(cgFrom, b: cgTo) //swap data in the board array (swaps nil for button in this case)
    }

    func   startTimerAsLastAnimation() {
        //starts timer after any pending animations are done.  This is typically used at the end of the "Randomize" routine which scrambles the tiles at beginning of game.
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var delay : Double
        if (currentTime > timeLastAnimationFinishes) { //if timeLastAnimationFinishes is in the past, and is irrelevant -- no delay
            timeLastAnimationFinishes = currentTime
        }
        delay = timeLastAnimationFinishes - currentTime //set up to wait until last animation finishes
//        UIView.animateWithDuration(0.01, delay: delay, options: .CurveLinear, animations: {self.backgroundView.backgroundColor
//            = CGColor.init(red: 140.0/255.0, green: 0/255.0, blue: 26.0/255.0, alpha: 1).CGColor}, completion: {finished in self.startTimer()})
//        print("will start timer in \(delay) seconds \n")
        
        
        // This starts timer after "delay"
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.startTimer()
        }
        movesCounter = 0 //reset moves counter (after it got incremented as side effect of randomize)
    }

    func traverseAndMoveAllPossible(cgFrom: CGPoint, cgTo: CGPoint) {
        //given two cgs on same axis, determines if a single or multi tile move is possible along that vector, and makes that(those) move(s)
        //cgFrom is typically the coordinates of point clicked on
        //cgTo is typically at extreme end of that row/col
        //  moves all cells that can be moved away from From towards To 1 unit
        //  this routine is normally called 4 times, for xmin, xmax, ymin and ymax
        //how:
        //traverses from From to To, moving all pieces possible, iteratively
        //   has the effect of moving everything in a row or column
        //assumes cgFrom and cgTo are on same x or y axis
        //

        //set up to use integers
        let fromX = Int(cgFrom.x)
        let fromY = Int(cgFrom.y)
        let toX = Int(cgTo.x)
        let toY = Int(cgTo.y)
        
        var closerNeighbor = 0

        if ((fromX == toX) && (fromY == toY))  { //don't process case where points are equal
            return
        } else if (fromX == toX) {//look along y axis
            if (toY < fromY ) { //prepare to look upwards
                closerNeighbor = 1
            } else if (toY > fromY ) {//prepare to look downwards
                closerNeighbor = -1
            } else {
                print("x's and y's equal -- should never get here \n")
            }
        
            var y = toY
            repeat {
                if myBoard[toX][y] == nil {
                    moveToEmptyCell(CGPoint(x: CGFloat(toX), y: CGFloat(y + closerNeighbor)), cgTo: CGPoint(x: CGFloat(toX), y: CGFloat(y)))
                }
                y += closerNeighbor
            } while (y != fromY)
            
        } else if (fromY == toY) { //look along x axis
            if (toX < fromX ) { //to the right
                closerNeighbor = 1
            } else if (toX > fromX ) { //to the left
                closerNeighbor = -1
            } else {
                print("x's and y's equal -- can never get here \n")
            }

            var x = toX
            repeat {
                if myBoard[x][toY] == nil {
                    moveToEmptyCell(CGPoint(x: CGFloat(x + closerNeighbor), y: CGFloat(toY)), cgTo: CGPoint(x: CGFloat(x), y: CGFloat(toY)))
                }
                x += closerNeighbor
            } while (x != fromX)
            
        } else {
            print("traverseAndMoveAllPossible -- cgs not aligned on axis /n")
        }
    }
    
    func buttonTouched(sender:UIButton!)
        /* first verify you've clicked on a button
            if you can verify you have a neighbor that is free, swap these two cells and update button location
         */
    {
        isMoved = false // Set flag back to false: click on a button may not cause a move
        
        let cga = CGArrayFromPoint(sender.center)
        let x = Int(cga.x)
        let y = Int(cga.y)
        if (myBoard[x][y] != nil) { //verifies you're clicking on a button -- this should always be true
            
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: cga.x, y: CGFloat(0))) //look from this cell all the way up
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: cga.x, y: CGFloat(rows-1))) //look from this cell all the way down
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: CGFloat(0), y: cga.y)) ////look from this cell all the way left
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: CGFloat(cols-1), y: cga.y)) //look from this cell all the way right
        }
        if(isMoved == true){
            buttonBeep?.play() //play move sound
            
            if randomizeIsFinished {
                movesCounter+=1 // Move counter + 1 after each move!
                movesLabel.text = String(movesCounter)
            }
        }
    }
    
    var myBoard = [[UIButton?]]() //board is initially empty    //var myBoard : [[UIButton?]] = nil
    func CGPointFromArray(cgArray : CGPoint)->CGPoint //given array subscripts, return screen coords
    {
        return CGPointMake(CGFloat(CGFloat(offsetX0) + (cgArray.x * CGFloat(cellWidth))), CGFloat(CGFloat(offsetY0) + (cgArray.y * CGFloat(cellHeight))))
    }
    
    func CGArrayFromPoint(cgScrnPoint : CGPoint)->CGPoint //given screen coords, return array subscripts in cgPoint
    {
        return CGPointMake((cgScrnPoint.x - CGFloat(offsetX0)) / CGFloat(cellWidth), (cgScrnPoint.y - CGFloat(offsetY0)) / CGFloat(cellHeight))
    }
    
    func BoardSwap(a : CGPoint, b : CGPoint) {  //given coords of two board positions, swap them
        let temp = myBoard[Int(a.x)][Int(a.y)]
        myBoard[Int(a.x)][Int(a.y)] = myBoard[Int(b.x)][Int(b.y)]
        myBoard[Int(b.x)][Int(b.y)] = temp
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateRecordsOnLabel()
        
        //Initialize Sounds
        if let buttonBeep = self.setupAudioPlayerWithFile("ButtonTap", type:"wav") {
            self.buttonBeep = buttonBeep
        }
        if let secondBeep = self.setupAudioPlayerWithFile("SecondBeep", type:"wav") {
            self.secondBeep = secondBeep
        }
        if let backgroundMusic = self.setupAudioPlayerWithFile("HallOfTheMountainKing", type:"mp3") {
            self.backgroundMusic = backgroundMusic
        }
        
        // Init background view
        backgroundView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        backgroundView.image = UIImage(named: "background")
        self.view.addSubview(backgroundView)
        
        // Init playground view
        playgroundView.frame = CGRectMake(7, 300, view.frame.width-7, 400)
        self.backgroundView.addSubview(playgroundView)
        
        // Enable User interactions 
        backgroundView.userInteractionEnabled = true
        playgroundView.userInteractionEnabled = true
        
        timerLabel.layer.borderWidth  = 2
        timerLabel.layer.borderColor  = UIColor.init(red: 140.0/255.0, green: 0/255.0, blue: 26.0/255.0, alpha: 1).CGColor
        
        movesLabel.layer.borderWidth  = 2
        movesLabel.layer.borderColor  = UIColor.init(red: 140.0/255.0, green: 0/255.0, blue: 26.0/255.0, alpha: 1).CGColor
        
        //Init Globals
        cellWidth = ((Int(screensize.width) - (2 * viewFrameMargin)) / cols) - (2 * cellFrameMargin)
        cellHeight = cellWidth //was (((screensize.height) - (2 * viewFrameMargin)) / rows) - (2 * cellFrameMargin)
        
        offsetX0 = viewFrameMargin + cellFrameMargin + (cellWidth / 2)
        offsetY0 = viewFrameMargin + cellFrameMargin + (cellHeight / 2)
        
        myBoard.removeAll() //start clean
        for col in (0..<cols) {
            var colOfBoard = [UIButton?]()
            for row in (0..<Int(rows)) {
                if !((row == rows-1) && (col == cols-1)) { //leave last cell empty
                    let button = UIButton(frame: CGRectMake(0,0, CGFloat(cellWidth - (2 * cellFrameMargin)), CGFloat(cellHeight - (2 * cellFrameMargin))))
                    button.center = CGPointFromArray(CGPointMake(CGFloat(col), CGFloat(row)))
                    button.backgroundColor = UIColor.init(red: 140.0/255.0, green: 0/255.0, blue: 26.0/255.0, alpha: 1)
                    //button.backgroundColor = UIColor.redColor()//setting backgroundColor
                    button.setTitle((col + 1 + (row * cols)).description, forState: UIControlState.Normal)
                    button.layer.cornerRadius = 5
                    button.layer.borderWidth = 1
                    button.layer.borderColor = UIColor.whiteColor().CGColor
                    button.addTarget(self, action: #selector(ViewController.buttonTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    self.playgroundView.addSubview(button)
                    
                    colOfBoard.append(button)
                    //myBoard[col][row] = button
                } else {
                    emptyCellX = col  // should be 3 3 in game of 15
                    emptyCellY = row
                    colOfBoard.append(nil)
                    //myBoard[col][row] = nil
                }
            } //for row
            //now that we're done creating all buttons in this row, append it
            myBoard.append(colOfBoard)
        } //for col
        
        RandomizeLayout()
        BoardIntegrityCheck()
        
        timerLabel.text = startTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateRecordsOnLabel()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // This function counts seconds
    func updateCounter() {
        secondBeep?.play() //play second ticking sound
        
        timerCounter+=1
        
        let strSeconds = String(format: "%02d", timerCounter % 60)
        let strMinutes = String(format: "%02d", timerCounter / 60)
        
        timerLabel.text = strMinutes + ":" + strSeconds
        
        if(timerCounter == totalTime){
            timeOut()
        }
    }
    
    func startTimer() {
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(ViewController.updateCounter), userInfo: nil, repeats: true)
        
        randomizeIsFinished = true
    }
    
    func gameStop(){
        gameTimer.invalidate()
    }
    
    func restartGame(){
        gameStop()
        
        timerCounter = 0
        movesCounter = 0
        timerLabel.text = startTime
        movesLabel.text = startMove
        
        RandomizeLayout()
    }
    
    func didClickCancelPauseBtn(sender: UIButton!){
        pausedView.removeFromSuperview()
        startTimer()
        
        isPaused = false
    }
    
    // When pause button is clicked, it displays a blurry image view to cover the playground
    @IBAction func pauseGame(sender: AnyObject) {
        
        let cancelPauseBtn = UIButton(type: .Custom) // a cancel button displaying on pausedView
        
        if(randomizeIsFinished == true && isPaused == false){
            gameStop()
            
            // Create blur view 
            pausedView.frame = CGRectMake(0, 0, playgroundView.frame.width, playgroundView.frame.height)
            playgroundView.addSubview(pausedView)
            
            // Create the cancel button
            cancelPauseBtn.frame = CGRectMake(pausedView.frame.width - 60, 0, 60, 60)
            let cancelImage = UIImage(named: "cancel")
            cancelPauseBtn.setImage(cancelImage, forState: UIControlState.Normal)
            pausedView.addSubview(cancelPauseBtn)
            
            cancelPauseBtn.addTarget(self, action: #selector(ViewController.didClickCancelPauseBtn(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            isPaused = true
        }
    }
    
    @IBAction func refreshTimer(sender: AnyObject) {
        if (randomizeIsFinished == true && isPaused == false){
            restartGame()
        }
    }
    
    // Func to fetch the records in CoreData
    func fetch()->Bool{
        
        let frMove = NSFetchRequest(entityName: "MoveRecords")
        let sdMove = NSSortDescriptor(key: "iMove", ascending: true)
        frMove.sortDescriptors = [sdMove]
        frcMove = NSFetchedResultsController(fetchRequest: frMove, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frcMove.delegate = self
        
        let frTime = NSFetchRequest(entityName: "TimeRecords")
        let sdTime = NSSortDescriptor(key: "iTime", ascending: true)
        frTime.sortDescriptors = [sdTime]
        frcTime = NSFetchedResultsController(fetchRequest: frTime, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frcTime.delegate = self
        
        var error: NSError? = nil
        let count = moc.countForFetchRequest(frMove, error: &error)
        
        do {
            try frcMove.performFetch()
            try frcTime.performFetch()
        } catch {
            fatalError("Warning warning fatal error happened: \(error)")
        }
        
        moveArr = frcMove.fetchedObjects as! [MoveRecords]
        timeArr = frcTime.fetchedObjects as! [TimeRecords]
        
        if (count == 0){
            return false
        }
        else{
            return true
        }
    }
    
    // Func to save new records
    // This function is only called when the game is won
    func saveRecords(){
        
        //let myMOC = DataController().managedObjectContext
        
        newMoveRecord = NSEntityDescription.insertNewObjectForEntityForName("MoveRecords", inManagedObjectContext: moc) as! MoveRecords
        newTimeRecord = NSEntityDescription.insertNewObjectForEntityForName("TimeRecords", inManagedObjectContext: moc) as! TimeRecords
        
        newMoveRecord.iMove = movesCounter
        newTimeRecord.iTime = timerCounter
        
        do
        {
            try moc.save()
        }
        catch
        {
            print(error)
            return
        }
    }
    
    func updateRecordsOnLabel(){
        
        if(!fetch()){
            showBestMoveLabel.text = "No Record Yet"
            showBestTimeLabel.text = "No Record Yet"
        }
        else{
            let convertedInt = timeArr[0].iTime.integerValue
            
            let strSeconds = String(format: "%02d", convertedInt % 60)
            let strMinutes = String(format: "%02d", convertedInt / 60)
            
            showBestMoveLabel.text = "Move Rec: " + String(moveArr[0].iMove)
            showBestTimeLabel.text = "Time Rec: " + strMinutes + ":" + strSeconds
        }
    }
    
    //Updating funcs
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        updateRecordsOnLabel()
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController){
    }

}


