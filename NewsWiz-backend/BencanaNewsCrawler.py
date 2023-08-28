from bs4 import BeautifulSoup
import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
from datetime import datetime
import pytz

# Creates a header


from bs4 import BeautifulSoup
import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
import pytz
import schedule
import time

# Declare the variables outside any function to make them accessible to all functions.
headers = {'User-agent': 'Mozilla/5.0'}
page_url = None
page_text = None
main = None

cred = credentials.Certificate("newswizdb-fc765-firebase-adminsdk-7zvc5-474be9fcfb.json")
firebase_admin.initialize_app(cred)


# Function to scrape the webpage and add data to Firestore
def scrape_and_add_to_firestore():
    global page_url, page_text, main  # Declare page_url as global to modify the value inside the function
    print("process started")
    # Requests the webpage
    request = requests.get('https://sebenarnya.my/category/nasional/bencana/')
    html = request.content

    # Create some soup
    soup = BeautifulSoup(html, 'html.parser')
    # Used to easily read the HTML that we scraped
    soup.prettify()

    # Finds all the headers in BBC Home
    soup.find(id='td-outer-wrap')

    for h3 in soup.find_all('h3'):
        h3.extract()
        h3.decompose()
        h3.clear()

    for nextEle in soup.find_all(class_="page-nav td-pb-padding-side"):
        nextEle.extract()
        nextEle.decompose()
        nextEle.clear()

    body = soup.find(id='td-outer-wrap')

    main = body.find(class_='td-ss-main-content')

    # tz = pytz.timezone('Asia/Singapore')
    # time = datetime.now(tz).strftime('%Y-%m-%d %H:%M:%S')

    db = firestore.client()

    # Initialize the batch outside the loop
    batch = db.batch()

    # Set initial page URL
    page_url = 'https://sebenarnya.my/category/nasional/bencana/'

    # Set to store unique headlines
    unique_headlines = set()

    # Get existing headlines from Firebase
    existing_headlines = set()
    collection_ref = db.collection("Bencana")
    docs = collection_ref.stream()
    for doc in docs:
        data = doc.to_dict()
        existing_headlines.add(data['Title'])

    while page_url:
        # Request the webpage
        request = requests.get(page_url)
        html = request.content

        # Create the soup
        soup = BeautifulSoup(html, 'html.parser')

        # Find the relevant content on the page
        main = soup.find(class_='td-ss-main-content')

        for news in main.find_all('a'):
            headlines = news.get('title')

            # Check for duplicates in Firebase and currently scraped data
            if headlines in existing_headlines:
                # Stop scraping when duplicates are found in Firebase
                print("Duplicates found. Stopping web scraping.")
                page_url = None
                break

            # Add the headline to the set
            unique_headlines.add(headlines)

            link = news.get('href')
            for temp in news.find_all('img'):
                image = temp.get('src')

                # Generate a new UUID for the document ID
                doc_id = db.collection("Bencana").document().id

                # Create a new document reference with the generated ID
                Bencana = db.collection("Bencana").document(doc_id)

                batch.set(Bencana, {
                    'Title': headlines,
                    'Link': link,
                    'Image': image,
                    'Tag': 1
                })

        if page_url is None:
            break

        # Find the link to the next page
        next_page_link = soup.find(class_="page-nav td-pb-padding-side")
        page_url = None
        page_text = None

        for nextPage in next_page_link.findAll('a'):
            page_url = nextPage.get('href')
            page_text = nextPage.text.strip()
            if page_url is not None and '/page/' in page_url and 'SEBELUMNYA' not in page_text:
                print(page_text)
                print(page_url)
                break
        else:
            page_url = None

        # Commit the batch outside the loop
        batch.commit()

    # Instead of setting page_url to None, simply return from the function to stop the loop
    if page_url is None:
        return


if __name__ == "__main__":
    print("Starting the scraping process...")

    while True:
        # Print the timestamp before calling the function
        print("Scraping started at:", datetime.datetime.now())

        # Call the function directly
        scrape_and_add_to_firestore()

        # Wait for 4 hours before calling the function again
        time.sleep(4 * 60 * 60)