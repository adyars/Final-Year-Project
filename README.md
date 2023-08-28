# Final-Year-Project

NewsWiz: Fake News Validation Portal using Web Scrapping and String Matching algorithm.

A mobile application using Flutter framework and dart.

Project insight
- It's not a mobile application using Machine Language or Neural Networks to detect whether a news is fake.
- It's an app that compares rumors/news that users received from an unknown source and compare it with a database of the latest news.

How it works
- Data from multiple news site will be Web Scrapped using BeautifulSoup Python into firebase database.
- Entered input from a user will be sent to the String-Matching function by sending HTTP GET Request to Flask API.
- Flask API will receive the input and starts the String-Matching function.
- FuzzyWuzzy library was used to compare the received data and the data in firebase database.
- Comparison with highest rating will be returned back to display at user's screen.
