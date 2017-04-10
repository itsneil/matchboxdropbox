# Neil Skinner's Matchbox Dropbox Challenge
Here is my submission to the Dropbox client coding test. It can do the following
* Sign in with the oauth url
* Sign out by invalidating the access token
* Access the dropbox API to list files and folders
* Browse within folders
* "Load more" button in large directories
* Little thumbnail viewer when tapping on an image file

# Archetecture
The app is written in Swift 3.0, targetting iOS 10.3 using URLSessions for networking, Core Data for data and an MVVM pattern. We have a collection of unit tests that check the Login page and some Core Data operations via the View Model. Each class is heavily commented and strings are referenced from Localizable.

# Authentication
I use the dropbox oauth url (not an API) that opens in the safari browser, I chose to do this instead of an embedded webview as I wanted to demonstrate app listening to custom url schemes which I have defined as matchbox://redirect/.
The access token is stored in the UserDefaults so when you load the app with a valid token you don't need to oauth again. I am aware how insecure storing the token in userdefaults is, however for rapid development it is sufficient for now. I would use the keychain going forward should the app be developed further.

Logging out is done by calling the invalidate token endpoint and upon success it clears the local storage and returns the user to the log in page.

# Browsing
This is implemented using an MVVM pattern which is a subtle extension to Apple's MVC recommendation. The idea is that the View is as dumb as can be and unlike MVC does not directly access the model, it holds a reference to the ViewModel class that deals with API calls and Core Data requests.

Each ViewModel is identified by a path string (i.e "/") and holds it's own reference to an API class and keeps track of the cursor, hasMore and the data in the form of a private NSFetchedResultsController. The View accesses this information by calling methods in the view model and the View is only accessed by delegate methods to update the UI. The ViewModel also handles any user input from the View (i.e selecting cells)

The ViewController simply creates a ViewModel with the path it wants to display and the ViewModel creates an API instance (with said path) and sets up a NSFetchedResultsController with itself as a delegate. The API uses URLSessions to connect to the API and check for valid JSON before kicking off an Operation on an NSOperationQueue to parse the JSON and create DropboxItem NSManagedObjects.

If you tap on a folder then the app pushes a new BrowseViewController to the stack, sets up the ViewModel with the new path which then allows you to view the contents. 
If you tap on a file that's an image, with a size of under 20MB then the app will call the dropbox thumbnail endpoint and display an image in a UIAlertController :)
If you tap on a file that's not an image, or too large, you'll get a nice message saying nothing will happen.

If you pull to refresh any BrowseViewController the app will delete all DropboxItems in Core Data matching the path and get a fresh copy from the API.

# Testing
The app has a collection of unit tests that check the LoginViewController and some Core Data / ViewModel operations. Going forward it would be good to get some API testing in there too. I uploaded 20,000 10 byte files to my dropbox account in order to test large directories and confirm the "Load More" cell works. I also ran the app through Instruments several times to check for leaks.

# Going Forward
The first and foremost I would definately like to secure the access token before the app goes public as it would be very easy to plug an iPhone in via USB and extract the .plist file and have access to the logged-in dropbox account.

I would like to implement a better form of pagination for large folders, whilst Core Data and UITableViews are happy with 10000 objects it's not the best user experience. I would like to implement infinite scrolling in both directions so a smaller "window" of data is visible to the user and upon scrolling to the end of it a fresh batch is loaded.

I just scratched the surface with the thumbnail popup, I would love to be able to offer greater range of previews or generate share URLs when tapping on files.

Currently the app has no form of offline functionality which means it would probably perform poorly in less than ideal network conditions. It would work going forward to cache locally all the successful API call JSON in order for the user to have limited functionality.



