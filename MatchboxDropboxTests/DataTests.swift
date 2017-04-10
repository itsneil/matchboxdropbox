//
//  DataTests.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import XCTest
import CoreData
@testable import MatchboxDropbox

class DataTests: XCTestCase {
    
    var managedObjectContext:NSManagedObjectContext?
    
    /**
    Add a simple managed object into our in-memory store
     - parameters name: The filename
     - parameters withPath: The path
     - returns: The item from the store, or nil if failed
     */
    func addObject(withName name:String, withPath path:String) -> DropboxItem? {
        
        if let moc = self.managedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "DropboxItem", in: moc) {
            
            let item = DropboxItem(entity: entity, insertInto: moc)
            item.itemId = NSUUID().uuidString
            item.name = name
            item.path_root = path
            
            do {
                try moc.save()
                return item
            } catch {
                return nil
            }
            
        }
        
        return nil
    }
    
    override func setUp() {
        super.setUp()
        self.managedObjectContext = DataManager.shared.managedObjectContext//setupMOC()
    }
    
    override func tearDown() {
        super.tearDown()
        self.managedObjectContext = nil
    }
    
    /**
    Test adding just one object into the managed object context
     */
    func testAddingOneObject() {
        
        let name = "1"
        let path = "/"
        
        guard let object = self.addObject(withName: name, withPath: path) else {
            XCTFail("Did not insert object correctly")
            return
        }
        
        XCTAssertEqual(object.name ?? "", name)
        
    }
    
    /**
    Test adding and fetching 10,000 objects using the view model
     */
    func testAddingTenThousandObjects() {
        
        let randomPath = "/"+NSUUID().uuidString
        
        for index in 1...10000 {
            
            if let _ = self.addObject(withName: "\(index)", withPath: randomPath) {
                continue
            } else {
                XCTFail("Could not insert object at index \(index)")
            }
        }
        
        // create a viewmodel with the path that handles the fetch
        let viewModel = BrowseViewModel()
        viewModel.setViewModel(withDelegate: nil, forPath: randomPath)
        XCTAssertTrue(viewModel.getCount(forSection: 0) == 10000, "The fetched results controller should have 10000 objects in it")
    }
    
    /**
    Test adding 26 items then grab a random item and see if it matches. 
     The Viewmodel sorts in alphabetical order so 26 = A-Z
     */
    func testAdd26AndGetRandom() {
        
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M" ,"N" ,"O" ,"P" ,"Q" ,"R" ,"S" ,"T" ,"U" ,"V" ,"W" ,"X" ,"Y" ,"Z"]
        let randomPath = "/"+NSUUID().uuidString
        
        for letter in alphabet {
            if let _ = self.addObject(withName: letter, withPath: randomPath) {
                continue
            } else {
                XCTFail("Could not insert object \(letter)")
            }
        }
        
        let viewModel = BrowseViewModel()
        viewModel.setViewModel(withDelegate: nil, forPath: randomPath)
        
        let random = randomNumber(inRange: 0...alphabet.count-1)
        let object = viewModel.getItem(forIndexPath: IndexPath(row: random, section: 0))
        let letter = alphabet[random]
        
        XCTAssertTrue(object?.name == letter, "Random object should match it's input letter")
        
    }
    
    /**
    random number generator accepting a range and returning a number between them
     */
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 0...9) -> T {
        let length = (range.upperBound - range.lowerBound + 1).toIntMax()
        let value = arc4random().toIntMax() % length + range.lowerBound.toIntMax()
        return T(value)
    }
}
