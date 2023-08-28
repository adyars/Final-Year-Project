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
request = requests.get('https://www.bernama.com/bm/politik/')
html = request.content
title = ''
# Create a new batch
batch = db.batch()

# Set to store unique headlines
unique_headlines = set()

# Get existing headlines from Firebase
existing_headlines = set()
collection_ref = db.collection("Gov")
docs = collection_ref.stream()
for doc in docs:
    data = doc.to_dict()
    existing_headlines.add(data['Title'])

# Create some soup
soup = BeautifulSoup(html, 'html.parser')

temp = soup.find(class_="col pt-3")
body = temp.find(class_='col-sm-12 col-md-12 col-lg-12')
content = temp.find(class_='row')
eContent = content.findAll(class_='col-12 col-sm-12 col-md-3 col-lg-3 mb-3 mb-md-0 mb-lg-0')
# print(eContent)
for articletemp in content.findAll(class_='col-12 col-sm-12 col-md-3 col-lg-3 mb-3 mb-md-0 mb-lg-0'):
    # print(articletemp)
    for titles in articletemp.findAll(class_="col-7 col-md-12 col-lg-12 mb-3"):
        # print(titles)
        for textTitle in titles.find('h6'):
            title = textTitle.text
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

        for tempimage in articletemp.findAll(class_='col-5 col-md-12 col-lg-12 mb-3'):
            for images in tempimage.findAll('img'):
                image = images.get('src')
                print(image)

                # Generate a new UUID for the document ID
                doc_id = db.collection("Gov").document().id

                # Create a new document reference with the generated ID
                Gov = db.collection("Gov").document(doc_id)

                batch.set(Gov, {
                    'Title': title,
                    'Link': link,
                    'Image': image,
                    'Tag': 2
                })

# Commit the batch after processing all articles
batch.commit()
