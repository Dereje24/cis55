//
//  ViewController.swift
//  GameofSingle15
//
//  Created by Greg Simons 3rd on 5/13/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var playgroundView: UIImageView! //an image view for playground to add to
    
    @IBOutlet weak var timerLabel: UILabel! // diaplay timer
    
    @IBOutlet weak var movesLabel: UILabel! // display moves
    
    var gameTimer = NSTimer()
    var timerCounter = 0
    let startTime = "00:00"
    
    var movesCounter = 0
    let startMove = "0"
    
    let screensize : CGRect = UIScreen.mainScreen().bounds
    
    let viewFrameMargin = 10 //margin around entire edge
    let cellFrameMargin = 2  //margin around each cell
    let rows  = 3; //4x4 game initially
    let cols  = 3;
    
    var emptyCellX = 0
    var emptyCellY = 0
    
    
//  Declare Globals
    var cellWidth : Int = 0
    var cellHeight : Int = 0
    var offsetX0 : Int = 0
    var offsetY0 : Int = 0
    
    
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
        //go thru every board position, and swap it's tile with another randomly chosen tile
        var timeOfThisAnimation = 0.0
        var timeOfLastAnimation = 0.0
        for row in (0..<Int(rows)) {
            for col in (0..<cols) {
                
                let cga = CGPoint(x:col, y:row) //cell a is col/row
                let cgb = CGPoint(x:random() % cols, y:random() % rows) //cell b is random
                let distance = Double(hypot(cga.x - cgb.x, cga.y - cgb.y))
                
                //animate cga to cgb postion
                if (myBoard[col][row] != nil) {
                    let destCenter = CGPointFromArray(cgb)
                    timeOfLastAnimation += timeOfThisAnimation
                    timeOfThisAnimation = 0.1 * distance
                    
                    self.view.bringSubviewToFront(myBoard[col][row]!) //BUG:  THIS DOESN'T WORK -- NOT SURE WHY GS 5/25/16
                    UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveLinear, animations: {self.myBoard[col][row]!.center.x = destCenter.x ; self.myBoard[col][row]!.center.y = destCenter.y }, completion: nil)
                }
                
                //...and animate cgb to cga
                if (myBoard[Int(cgb.x)][Int(cgb.y)] != nil) {
                    let destCenter = CGPointFromArray(cga)

                    timeOfLastAnimation += timeOfThisAnimation
                    timeOfThisAnimation = 0.1 * distance
                    self.view.bringSubviewToFront(myBoard[Int(cgb.x)][Int(cgb.y)]!)
                    
                    if(row == rows-1 && col == cols-1)
                    {
                        UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveEaseIn, animations: {self.myBoard[Int(cgb.x)][Int(cgb.y)]!.center.x = destCenter.x ; self.myBoard[Int(cgb.x)][Int(cgb.y)]!.center.y = destCenter.y }, completion: {finished in self.startTimer()})
                    }
                    else
                    {
                        UIView.animateWithDuration(timeOfThisAnimation, delay: timeOfLastAnimation, options: .CurveEaseIn, animations: {self.myBoard[Int(cgb.x)][Int(cgb.y)]!.center.x = destCenter.x ; self.myBoard[Int(cgb.x)][Int(cgb.y)]!.center.y = destCenter.y }, completion: nil)
                    }
                }

                BoardSwap(cga, b: cgb) //swap them
            }
        }
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
            
            gameOver()
            let alert = UIAlertController(title: "VICTORY!", message:"REPLAY THE GAME?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default){ _ in})
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in self.restartGame()})
            self.presentViewController(alert, animated: true){}
        }
        
    }
    
    func BoardIntegrityCheck()->Bool {
        /* verify that the location of every board tile button is where it should be */
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

    func moveToEmptyCell(cgFrom: CGPoint, cgTo: CGPoint) {
        // moves board piece at cgFrom to cgTo, updating board data structure and initiating button animcation on screen
        // assumes board[cgTo] is nil
        
        
        let destCenter = CGPointFromArray(cgTo)
        let button = myBoard[Int(cgFrom.x)][Int(cgFrom.y)]!
        
       //UIView.animateWithDuration(0.5, animations: {sender.center.x = destCenter.x ; sender.center.y = destCenter.y })
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {button.center.x = destCenter.x ; button.center.y = destCenter.y }, completion: {finished in
            if (finished) {
                self.ckIfYouWon()
            }
        }) //completion
        BoardSwap(cgFrom, b: cgTo) //swap data in the board array (swaps nil for button in this case)
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
        let cga = CGArrayFromPoint(sender.center)
        let x = Int(cga.x)
        let y = Int(cga.y)
        if (myBoard[x][y] != nil) { //verifies you're clicking on a button -- this should always be true
            
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: cga.x, y: CGFloat(0))) //look from this cell all the way up
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: cga.x, y: CGFloat(rows-1))) //look from this cell all the way down
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: CGFloat(0), y: cga.y)) ////look from this cell all the way left
            traverseAndMoveAllPossible(cga, cgTo: CGPoint(x: CGFloat(cols-1), y: cga.y)) //look from this cell all the way right
        }
        movesCounter+=1 // Add one move after each click on any button!
        movesLabel.text = String(movesCounter)
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

        //Init Globals
        cellWidth = ((Int(screensize.width) - (2 * viewFrameMargin)) / cols) - (2 * cellFrameMargin)
        cellHeight = cellWidth //was (((screensize.height) - (2 * viewFrameMargin)) / rows) - (2 * cellFrameMargin)
        
        offsetX0 = viewFrameMargin + cellFrameMargin + (cellWidth / 2)
        offsetY0 = viewFrameMargin + cellFrameMargin + (cellHeight / 2)
        
        timerLabel.layer.borderWidth  = 2
        timerLabel.layer.borderColor  = UIColor.greenColor().CGColor
        
        movesLabel.layer.borderWidth  = 2
        movesLabel.layer.borderColor  = UIColor.greenColor().CGColor
        
        myBoard.removeAll() //start clean
        for col in (0..<cols) {
            var colOfBoard = [UIButton?]()
            for row in (0..<Int(rows)) {
                if !((row == rows-1) && (col == cols-1)) { //leave last cell empty
                    let button = UIButton(frame: CGRectMake(0,0, CGFloat(cellWidth - (2 * cellFrameMargin)), CGFloat(cellHeight - (2 * cellFrameMargin))))
                    button.center = CGPointFromArray(CGPointMake(CGFloat(col), CGFloat(row)))
                    button.backgroundColor = UIColor.redColor()//setting backgroundColor
                    button.setTitle((col + 1 + (row * cols)).description, forState: UIControlState.Normal)
                    button.layer.cornerRadius = 5
                    button.layer.borderWidth = 1
                    button.layer.borderColor = UIColor.greenColor().CGColor
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // This function counts time in seconds
    func updateCounter() {
        timerCounter+=1
        
        let strSeconds = String(format: "%02d", timerCounter % 60)
        let strMinutes = String(format: "%02d", timerCounter / 60)
        
        timerLabel.text = strMinutes + ":" + strSeconds
    }
    
    func startTimer() {
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(ViewController.updateCounter), userInfo: nil, repeats: true)
    }
    
    func gameOver(){
        gameTimer.invalidate()
    }
    
    func restartGame(){
        gameTimer.invalidate()
        timerCounter = 0
        movesCounter = 0
        timerLabel.text = startTime
        movesLabel.text = startMove
        RandomizeLayout()
    }
    
    @IBAction func stopGame(sender: AnyObject) {
        gameOver()
    }
    
    @IBAction func refreshTimer(sender: AnyObject) {
        restartGame()
    }
}

