//
//  SampleViewController.swift
//  GameofSingle15
//
//  Created by Koichi Okada on 6/10/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    var gameObject: GameObject!
    @IBOutlet var dimensionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var x = gameObject.dimensionX
        var y = gameObject.dimensionY
        self.dimensionLabel.text = (x.description) + " x " + (y.description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
