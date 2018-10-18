//
//  Labels.swift
//  WhiLight
//
//  Created by Fabio Giolito on 11/7/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

extension UITextView {

    func convertHashtags(text:String) {

        let textRange = NSMakeRange(0, text.count)
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.beginEditing()
        
        attrString.addAttribute(.font, value: UIFont.body(), range: textRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.grayDark(), range: textRange)

        do {
            let hashtagPattern = "(?:\\s|^)(#(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b"
            let regex = try NSRegularExpression(pattern: hashtagPattern, options: .anchorsMatchLines)
            let results = regex.matches(in: text, options: .withoutAnchoringBounds, range: textRange)
            let array = results.map { (text as NSString).substring(with: $0.range) }
            
            for hashtag in array {

                let hashtagRange = (attrString.string as NSString).range(of: hashtag)
                let hashtagString = String(hashtag.characters.dropFirst())

                print(hashtagString)
                attrString.addAttribute(.link, value: "https://weheartit.com/pictures/\(hashtagString)", range: hashtagRange)

            }
            attrString.endEditing()
        }
        catch {
            attrString.endEditing()
        }

        self.attributedText = attrString
    }
}

