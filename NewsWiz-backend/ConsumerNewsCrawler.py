from bs4 import BeautifulSoup
import requests
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import pytz
import schedule
import time

# Initialize Firebase
cred = credentials.Certificate("newswizdb-fc765-firebase-adminsdk-7zvc5-474be9fcfb.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Creates a header
headers = {'User-agent': 'Mozilla/5.0'}


def scrape_and_add_to_firestore():
    # Set initial page URL
    page_url = 'https://sebenarnya.my/category/sosial/kepenggunaan/'

    # Set to store unique headlines
    unique_headlines = set()

    # Get existing headlines from Firebase
    existing_headlines = set()
    collection_ref = db.collection("Consumer")
    docs = collection_ref.stream()
    for doc in docs:
        data = doc.to_dict()
        existing_headlines.add(data['Title'])

    while page_url:
        # Request the webpage
        request = requests.get(page_url, headers=headers)
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
                doc_id = db.collection("Consumer").document().id

                # Create a new document reference with the generated ID
                Consumer = db.collection("Consumer").document(doc_id)

                Consumer.set({
                    'Title': headlines,
                    'Link': link,
                    'Image': image,
                    'Tag': 9
                })

        if page_url is None:
            break

        # Find the link to the next page
        next_page_link = soup.find(class_="page-nav td-pb-padding-side")

        for nextPage in next_page_link.find_all('a'):
            page_url = nextPage.get('href')
            page_text = nextPage.text.strip()
            if page_url is not None and '/page/' in page_url and 'SEBELUMNYA' not in page_text and '/11/' not in page_url:
                print(page_text)
                print(page_url)
                break
        else:
            page_url = None

    print("Scraping and data insertion completed.")


if __name__ == "__main__":
    print("Starting the scraping process...")

    while True:
        print("Scraping started at:", datetime.now())

        scrape_and_add_to_firestore()

        print("Waiting for 4 hours before scraping again...")
        time.sleep(4 * 60 * 60)
