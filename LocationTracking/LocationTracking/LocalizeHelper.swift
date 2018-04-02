//
//  MLocalizeHelper.swift
//  MoneySaver
//
//  Created by ThuyPH on 8/21/17.
//  Copyright © 2017 McLab. All rights reserved.
//

import UIKit

// Use "LocalizedString(key)" the same way you would use "NSLocalizedString(key,comment)"
func LocalizedString(key: String) -> String {
    return LocalizeHelper.sharedLocalSystem().localizedString(forKey: key)
}

// "language" can be (for american english): "en", "en-US", "english". Analogous for other languages.
func LocalizationSetLanguage(language: String) {
    return LocalizeHelper.sharedLocalSystem().setLanguage(lang: language)
}

func LocalizationGetStringOverLanguage(language: String, key: String) -> String {
    return LocalizeHelper.sharedLocalSystem().getStringOverLanguage(lang: language, customKey: key)
}

private var singleLocalSystem: LocalizeHelper? = nil

private var myBundle: Bundle? = nil

class LocalizeHelper: NSObject {
    
    class func sharedLocalSystem() -> LocalizeHelper {
        // lazy instantiation
        if singleLocalSystem == nil {
            singleLocalSystem = LocalizeHelper()
        }
        return singleLocalSystem!
    }
    
    override init() {
        super.init()
        
        // use systems main bundle as default bundle
        myBundle = Bundle.main
        
    }
    
    func localizedString(forKey key: String) -> String {
        // this is almost exactly what is done when calling the macro NSLocalizedString(@"Text",@"comment")
        // the difference is: here we do not use the systems main bundle, but a bundle
        // we selected manually before (see "setLanguage")
        return myBundle!.localizedString(forKey: key, value: "", table: nil)
    }
    
    func setLanguage(lang: String) {
        // path to this languages bundle
        let path: String? = Bundle.main.path(forResource: lang, ofType: "lproj")
        if path == nil {
            // there is no bundle for that language
            // use main bundle instead
            myBundle = Bundle.main
        }
        else {
            // use this bundle as my bundle from now on:
            myBundle = Bundle(path: path!)
            // to be absolutely shure (this is probably unnecessary):
            if myBundle == nil {
                myBundle = Bundle.main
            }
        }
    }
    
    func getStringOverLanguage(lang: String, customKey: String) -> String {
        let path: String? = Bundle.main.path(forResource: lang, ofType: "lproj")
        let customBundle = Bundle(path: path!)
        let customString = customBundle!.localizedString(forKey: customKey, value: "", table: nil)
        return customString
    }
}
