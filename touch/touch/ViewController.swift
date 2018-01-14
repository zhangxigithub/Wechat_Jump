//
//  ViewController.swift
//  touch
//
//  Created by zhangxi on 14/01/2018.
//  Copyright © 2018 zhangxi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var l: UILabel!
    var start : Date?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        start = Date()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let interval = Date().timeIntervalSince(start!)
        
        l.text = String(format:"%f",interval)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

