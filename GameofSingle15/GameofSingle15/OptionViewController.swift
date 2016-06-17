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
    
    
    @IBOutlet var soundsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var playSwitch: UISwitch!
    @IBOutlet var conclusionSwitch: UISwitch!
    @IBOutlet var moveSwitch: UISwitch!
    
    let pickerDataSource = ["Easy(3x3)", "Medium(Default 4x4)", "Hard(5x5)"]
    let pickerDefaultValue = 1
    
    let sliderDefaultValue = 10
    var sliderIntValue = 0

    var rows: Int = 4
    var cols: Int = 4
    
    var sounds: [String: Bool] = [String: Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pickerX.dataSource = self
        self.pickerX.delegate = self
        // Set default values for picker
        self.pickerX.selectRow(self.pickerDefaultValue, inComponent: 0, animated: true)

        self.sliderX.setValue(Float(self.sliderDefaultValue), animated: true)
        self.cutOffTime.text = sliderDefaultValue.description

        initializeSounds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    /*
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerDataSource[row]
    }
    */
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.rows = row + 3
        self.cols = self.rows
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        pickerLabel.text = self.pickerDataSource[row]
        pickerLabel.font = UIFont(name: (pickerLabel.font?.fontName)!, size: 17)
        //pickerLabel.font = UIFont(name: "System", size: 14) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.Left
        return pickerLabel
    }

    // get changed slider data for totalTime
    @IBAction func sliderChanged(sender: UISlider) {
        self.sliderIntValue = Int(sender.value)
        self.cutOffTime.text = self.sliderIntValue.description
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if segue.identifier == "settingSegue" {
            let sampleview = segue.destinationViewController as! ViewController

            getSoundConfiguration()

            // set all setting data in GameObject
            // pass the data to Main ViewController
            sampleview.gameObject = GameObject(rows: self.rows, cols: self.cols, totalTime: self.sliderIntValue, sounds: sounds)
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // Sound configurations
    
    // initialize sound configurations
    func initializeSounds() {
        soundsSwitch.setOn(true, animated: true)
        moveSwitch.setOn(true, animated: true)
        conclusionSwitch.setOn(true, animated: true)
        playSwitch.setOn(true, animated: true)
        timerSwitch.setOn(true, animated: true)
        
        soundsSwitch.addTarget(self, action: #selector(OptionViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // set switch configuration when sounds status is switched
    func stateChanged(switchState: UISwitch) {
        if (switchState.on) {
            moveSwitch.setOn(true, animated: true)
            conclusionSwitch.setOn(true, animated: true)
            playSwitch.setOn(true, animated: true)
            timerSwitch.setOn(true, animated: true)
            moveSwitch.enabled = true
            conclusionSwitch.enabled = true
            playSwitch.enabled = true
            timerSwitch.enabled = true
        } else {
            moveSwitch.setOn(false, animated: true)
            conclusionSwitch.setOn(false, animated: true)
            playSwitch.setOn(false, animated: true)
            timerSwitch.setOn(false, animated: true)
            moveSwitch.enabled = false
            conclusionSwitch.enabled = false
            playSwitch.enabled = false
            timerSwitch.enabled = false
        }
    }
    
    // get current sound configurations
    func getSoundConfiguration() {
        sounds["sounds"] = soundsSwitch.on
        sounds["move"] = moveSwitch.on
        sounds["gameconclusion"] = conclusionSwitch.on
        sounds["gameplay"] = playSwitch.on
        sounds["timer"] = timerSwitch.on
    }
}
