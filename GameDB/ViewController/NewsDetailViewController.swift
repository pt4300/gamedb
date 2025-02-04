//
//  NewsDetailViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 1/5/21.
//

import UIKit
import WebKit
class NewsDetailViewController: UIViewController,UITextViewDelegate {
    
    var htmlString:String?
    @IBOutlet weak var newsView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        newsView.delegate = self
        if let input = htmlString{
            let data = input.data(using: .utf8)
            let font = UIFont.systemFont(ofSize: 72)
            let attributes = [NSAttributedString.Key.font: font]
            
            let attributeString = try? NSAttributedString(data: data!, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)

            newsView.attributedText = attributeString

            
        }
        
        
        // Do any additional setup after loading the view.
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    


}
