//
//  InitialViewController.swift
//  GameofSingle15
//
//  Created by Koichi Okada on 6/7/16.
//  Copyright © 2016 GregSimons. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var instruBtn: UIButton!
    
    @IBOutlet weak var setBtn: UIButton!
    
    @IBOutlet weak var recBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bounceEffect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        bounceEffect()
    }
    
    func bounceEffect(){
        playBtn.transform = CGAffineTransformMakeScale(0.9, 0.9)
        instruBtn.transform = CGAffineTransformMakeScale(0.9, 0.9)
        setBtn.transform = CGAffineTransformMakeScale(0.9, 0.9)
        recBtn.transform = CGAffineTransformMakeScale(0.9, 0.9)
        
        UIView.animateWithDuration(4.0,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 5.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.playBtn.transform = CGAffineTransformIdentity
                                    //self.playBtn.frame = CGRectMake( 87, 245, 200, 60)
                                    self.instruBtn.transform = CGAffineTransformIdentity
                                    self.setBtn.transform = CGAffineTransformIdentity
                                    self.recBtn.transform = CGAffineTransformIdentity
            }, completion: nil)
        
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
