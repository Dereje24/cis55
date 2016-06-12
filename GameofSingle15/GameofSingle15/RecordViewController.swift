//
//  RecordViewController.swift
//  GameofSingle15
//
//  Created by Koichi Okada on 6/7/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit
import CoreData

class RecordViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    let moc = DataController().managedObjectContext // instance of our managedObjectContext
    var frcMove : NSFetchedResultsController!
    var frcTime : NSFetchedResultsController!
    var moveArr = [MoveRecords]() // Declare an array to store move records
    var timeArr = [TimeRecords]() // Declare an array to store time records

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateRecordsOnLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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

    func updateRecordsOnLabel(){
        
        if(!fetch()){
            // showBestMoveLabel.text = "No Record Yet"
            // showBestTimeLabel.text = "No Record Yet"
            print("No Record Yet")
        }
        else{
            let convertedInt = timeArr[0].iTime.integerValue
            
            let strSeconds = String(format: "%02d", convertedInt % 60)
            let strMinutes = String(format: "%02d", convertedInt / 60)
            
            // showBestMoveLabel.text = "Move Rec: " + String(moveArr[0].iMove)
            // showBestTimeLabel.text = "Time Rec: " + strMinutes + ":" + strSeconds
            print("Move Rec: " + String(moveArr[0].iMove))
            print("Time Rec: " + strMinutes + ":" + strSeconds)
        }
    }
}
