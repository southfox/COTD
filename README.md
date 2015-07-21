# COTD
Building a “Capybara of the Day (COTD)” application. 

- It should return a random image of a capybara, pulled from a Google Images search. 

- The image should change every day. The idea is to have a single featured capybara for each 24 hour period

- It should not show the same image more than once a week.

- A user should be able to add search terms and return specific images; for example, entering “swimming” in the box would return a single random image from a search for ‘capybara swimming’.

- Users should be able to “like” the image and view a thumbnail list of the top 10 most-liked images.

--------------------------------------------------------------------------------

3 components:

- client (mobile iOS for my taste). Language C++ for iOS.

- parse database / REST/Json api

- google search engine framework for iOS

Using C++ under iOS.

--------------------------------------------------------------------------------

The application starts, and the screen shows only the image of the capybara pulled from google search images.
The application saves the capybara url pulled, the id of the device and the date in parse.com table user_image
Tap the screen: it shows an input field, we can add search terms, tapping OK the google search images will be called and we pull the first image
Tap like button: saves the info in image_likes
Double tap de screen: shows the 10 most-liked images in the list

--------------------------------------------------------------------------------


1. create the database with the 2 tables in parse.com, take note of the api key.
	user: javier.fuchs@gmail.com (database COTD)
2. create a empty project with cocoa pods libraries that includes: google search engine and parse library (use the api key here)
	Using json approach https://www.googleapis.com/customsearch/v1?key=AIzaSyADOPSjmHQYFFf9ZnWTqVQ3kPRwr5ND6l8&cx=003054679763599795063:tka3twkxrbw&q=capybara
	cocoa pods library does not exist anymore for iOS
3. create the 2 entities for image_likes: COTDImage and user_image: COTDUserImage
4. using the UI designer in Xcode create the single view that will show the picture of the capybara
5. add a toolbar with 1 button: like calls action likeImage()
6. add 2 gesture recognisers: single-tap calls action showsInputField(), double-tap calls action showsTenMostLiked()
7. create a singleton class COTDParse that will be doing all the parse api calls: add the following methods (identifyDeviceIntoCloud, tenMostLikedCapybarasFromCloud, incrementLikedCapybaraIntoCloud)
8. create a singleton class COTDGoogleSearch that will be doing all the google api calls: searchByTerm

Estimation:
1. 15 min
2. 20 min
3. 15 min
4. 30 min
5. 15 min
6. 10 min
7. 45 min
8. 30 min
Total: 3 hours

