from bs4 import BeautifulSoup
import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Initialize Firebase
cred = credentials.Certificate("newswizdb-fc765-firebase-adminsdk-7zvc5-474be9fcfb.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Creates a header
headers = {'User-agent': 'Mozilla/5.0'}

# Request the webpage
request = requests.get('https://www.utusan.com.my/ekonomi/')
html = request.content

# Create a new batch
batch = db.batch()

# Set to store unique headlines
unique_headlines = set()

# Get existing headlines from Firebase
existing_headlines = set()
collection_ref = db.collection("Economy")
docs = collection_ref.stream()
for doc in docs:
    data = doc.to_dict()
    existing_headlines.add(data['Title'])

# Create some soup
soup = BeautifulSoup(html, 'html.parser')

temp = soup.find(class_='site-content')
body = temp.find(
    class_='elementor-section elementor-top-section elementor-element elementor-element-145e8ced elementor-section-boxed elementor-section-height-default elementor-section-height-default')

for articletemp in body.findAll("article"):
    for titles in articletemp.findAll('h3'):
        title = titles.text
        print(title)

        # Check for duplicates in Firebase and currently scraped data
        if title in existing_headlines:
            # Skip adding this headline to Firebase if it already exists
            print("Duplicate found. Skipping this headline.")
            continue

        # Add the headline to the set of unique headlines
        unique_headlines.add(title)

        link = None
        for links in titles.findAll('a'):
            link = links.get('href')
            print(link)

        for tempimage in articletemp.findAll(class_='elementor-post__thumbnail'):
            for images in tempimage.findAll('img'):
                image = images.get('src')
                print(image)

                # Generate a new UUID for the document ID
                doc_id = db.collection("Economy").document().id

                # Create a new document reference with the generated ID
                Ekonomi = db.collection("Economy").document(doc_id)

                batch.set(Ekonomi, {
                    'Title': title,
                    'Link': link,
                    'Image': image,
                    'Tag': 2
                })

# Commit the batch after processing all articles
batch.commit()
