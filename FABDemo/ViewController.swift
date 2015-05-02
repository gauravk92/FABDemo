//
//  ViewController.swift
//  FABDemo
//
//  Created by Gaurav Khanna on 4/27/15.
//  Copyright (c) 2015 Gaurav Khanna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fab = FABView(frame: CGRectZero)
        self.view.addSubview(fab)
        //self.view.backgroundColor = UIColor.blackColor()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

