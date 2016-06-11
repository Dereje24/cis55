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
    
    let pickerDataSource = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]]
    
    let sliderDefaultValue = 10
    let pickerDefaultValue = 3
    
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
        return pickerDataSource[component][row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Row: " + pickerDataSource[component][row])
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        self.cutOffTime.text = currentValue.description
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
