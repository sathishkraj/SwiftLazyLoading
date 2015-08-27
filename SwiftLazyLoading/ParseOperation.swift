//
//  ParseOperation.swift
//  SwiftLazyLoading
//
//  Created by Sathish Kumar on 24/09/14.
//  Copyright (c) 2014 Sathish Kumar. All rights reserved.
//

import UIKit

let kIDStr: NSString = "id"
let kNameStr: NSString = "im:name";
let kImageStr: NSString = "im:image";
let kArtistStr: NSString = "im:artist";
let kEntryStr: NSString = "entry";

class ParseOperation: NSOperation , NSXMLParserDelegate {
   
    var errorHandler: ((error: NSError?) -> ())? = nil
    var appRecordList: NSArray? = nil
    var dataToParse: NSData? = nil
    var workingArray: NSMutableArray? = nil
    var workingEntry: AppRecord? = nil
    var workingPropertyString: NSMutableString? = nil
    var elementsToParse: NSArray? = nil
    var storingCharacterData: Bool = false
    
    init(data: NSData?) {
        super.init()
        self.dataToParse = data
        self.elementsToParse = NSArray(objects: kIDStr, kNameStr, kImageStr, kArtistStr)
    }
    
    override func main() {
        self.workingArray = NSMutableArray()
        self.workingPropertyString = NSMutableString()
        
        let parser = NSXMLParser(data: self.dataToParse!)
        parser.delegate = self
        parser.parse()
        
        if !self.cancelled {
            self.appRecordList = NSArray(array: self.workingArray!)
        }
        
        self.workingArray = nil;
        self.workingPropertyString = nil;
        self.dataToParse = nil;
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == kEntryStr {
            self.workingEntry = AppRecord()
        }
        self.storingCharacterData = self.elementsToParse!.containsObject(elementName)
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.workingEntry != nil {
            if self.storingCharacterData
            {
                let trimmedString: NSString = self.workingPropertyString!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                self.workingPropertyString!.setString("")
                if elementName == kIDStr {
                    self.workingEntry!.appURLString = trimmedString
                } else if elementName == kNameStr {
                    self.workingEntry!.appName = trimmedString
                } else if elementName == kImageStr {
                    self.workingEntry!.imageURLString = trimmedString
                } else if elementName == kArtistStr {
                    self.workingEntry!.artist = trimmedString
                }
            }
            else if elementName == kEntryStr
            {
                self.workingArray!.addObject(self.workingEntry!)
                self.workingEntry = nil;
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if self.storingCharacterData {
            self.workingPropertyString!.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        if (self.errorHandler != nil) {
          self.errorHandler!(error: parseError)
        }
    }
    
}
