//
//  LoginTests.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 09/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import XCTest
@testable import MatchboxDropbox

class LoginTests: XCTestCase {

    var loginViewController:LoginViewController?
    
    override func setUp() {
        super.setUp()
        
        loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: LoginViewController.Identifier) as? LoginViewController
        
    }
    
    /**
    Test that the login view controller isn't nil and is of type LoginViewController
     */
    func testIsLoginViewController() {
        
        guard let loginViewController = loginViewController else {
            XCTFail("The VC shouldn't be nil")
            return
        }
        
        XCTAssertTrue(loginViewController.isKind(of: LoginViewController.self), "The VC should be of type LoginViewController")
    }
    
    /**
    Test that the login view controller's outlets are connected
     */
    func testOutlets() {

        guard let loginViewController = loginViewController else {
            XCTFail("The VC shouldn't be nil")
            return
        }
        
        // call view on the vc to load the view so we can check outlets
        let _ = loginViewController.view
        XCTAssertNotNil(loginViewController.signInButton, "The Signin button shouldn't be nil")
        
    }
    
    /**
    Test that all strings on the login view controller are localised
     */
    func testStrings() {
        
        guard let loginViewController = loginViewController,
            let _ = loginViewController.view else {
            XCTFail("The VC shouldn't be nil")
            return
        }
        
        // The login button should have correctly localised text
        XCTAssertTrue(loginViewController.signInButton.titleLabel?.text == NSLocalizedString("button_signIn", comment: "Login Button text"), "The Login button's text should be localised.")
    }
    
    /**
    Test that a valid oauth token reply sets the token in the app
     */
    func testOauthReplyValid() {
        
        let oauthUrl = URL(string: "matchbox://redirect/#access_token=ABC&something_else=DEF")!
        let result = APIHelper.shared.getAccessTokenFrom(oauthUrl: oauthUrl)
        XCTAssertTrue(result && APIHelper.shared.accessToken == "ABC", "This is a valid oauth reply with a token")
        
    }
    
    /**
     Test that a valid oauth token reply where the access_token fragment isn't first sets the token in the app
     */
    func testOauthReplyValidBackwards() {
       
        let oauthUrl = URL(string: "matchbox://redirect/#something_else=DEF&access_token=ABC")!
        let result = APIHelper.shared.getAccessTokenFrom(oauthUrl: oauthUrl)
        XCTAssertTrue(result && APIHelper.shared.accessToken == "ABC", "This is a valid oauth reply with a token")
        
    }
    
    /**
     Test that a callback with no token fails
     */
    func testOauthReplyInvalid() {
        
        let oauthUrl = URL(string: "matchbox://redirect/#something_else=DEF")!
        let result = APIHelper.shared.getAccessTokenFrom(oauthUrl: oauthUrl)
        XCTAssertFalse(result, "This is an invalid oauth reply")
    }
    
    /**
    Test that a stored oauth token causes an automatic login
     */
    func testStoredOauthToken() {
        
        guard let loginViewController = loginViewController,
            let _ = loginViewController.view else {
                XCTFail("The VC shouldn't be nil")
                return
        }
        
        APIHelper.shared.accessToken = "ABC"
        
        let _ = loginViewController.view
        loginViewController.viewDidAppear(true)
        XCTAssertTrue(loginViewController.signInButton.isHidden, "This login button should be hidden")
        
    }
    
    /**
    Test that no oauth token doesn't cause an automatic login
     */
    func testNoStoredOauthToken() {
        
        guard let loginViewController = loginViewController,
            let _ = loginViewController.view else {
                XCTFail("The VC shouldn't be nil")
                return
        }
        APIHelper.shared.accessToken = nil
        let _ = loginViewController.view
        loginViewController.viewDidAppear(true)
        XCTAssertFalse(loginViewController.signInButton.isHidden, "This login button should not be hidden")
        
    }
}
