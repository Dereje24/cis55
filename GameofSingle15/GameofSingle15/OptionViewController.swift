//
//  OptionViewController.swift
//  GameofSingle15
//
//  Created by Koichi Okada on 6/7/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit

class OptionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var pickerX: UIPickerView!
    @IBOutlet var cutOffTime: UILabel!
    @IBOutlet var sliderX: UISlider!
    
    var collectionIndex: Int = 0
    
    let pickerDataSource = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]]
    
    let sliderDefaultValue = 10
    let pickerDefaultValue = 3

    let collectionItems: [String] = ["apple", "cherry", "grapes", "mangoes", "orange", "papaya", "peaches", "strawberry", "sugarapple", "watermelon"]
    
    var dimensions: [String: Int] = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pickerX.dataSource = self
        self.pickerX.delegate = self
        // Set default values for horizontal and vertical
        self.pickerX.selectRow(self.pickerDefaultValue, inComponent: 0, animated: true)
        self.pickerX.selectRow(self.pickerDefaultValue, inComponent: 1, animated: true)
        
        self.sliderX.setValue(Float(self.sliderDefaultValue), animated: true)
        self.cutOffTime.text = sliderDefaultValue.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource[0].count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerDataSource[component][row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("inComponent: " + component.description)
        print("Row: " + self.pickerDataSource[component][row])
        
        let xy: [String] = ["x", "y"]
        self.dimensions[xy[component]] = Int(self.pickerDataSource[component][row])
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        self.cutOffTime.text = currentValue.description
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
        if segue.identifier == "doneSegue" {
            let sampleview = segue.destinationViewController as! SampleViewController
            if self.dimensions["x"] == nil || self.dimensions["y"] == nil {
                self.dimensions["x"] = 4
                self.dimensions["y"] = 4
            }
            
            sampleview.gameObject = GameObject(x: self.dimensions["x"]!, y: self.dimensions["y"]!, gameTime: Int(self.cutOffTime.text!)!, theme: self.collectionItems[self.collectionIndex])
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        // cell.lblSample.text = "Label\(indexPath.row)"
        cell.imageItem.image = UIImage(named: self.collectionItems[indexPath.row])

        return cell
    }
        
    // Section number
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
        
    // Number of cells to be displayed
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.collectionItems.count
    }
        
    // Called when a collection Cell is tapped
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print("Selected Index: \(indexPath.row)")
            self.collectionIndex = indexPath.row
            print("Selected Item: \(self.collectionItems[indexPath.row])")
    }
}
