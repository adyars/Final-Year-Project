import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from fuzzywuzzy import fuzz

# Initialize the Firebase Admin SDK
cred = credentials.Certificate("newswizdb-fc765-firebase-adminsdk-7zvc5-474be9fcfb.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

data_list = []


def fetch_data(collection_name):
    titles = []
    links = []
    images = []

    collection_ref = db.collection(collection_name)
    docs = collection_ref.get()

    for doc in docs:
        data = doc.to_dict()
        title = data.get("Title")
        link = data.get("Link")
        image = data.get("Image")
        titles.append(title)
        links.append(link)
        images.append(image)

    return titles, links, images


def string(search, tag):
    global data_list

    print(search)
    print(tag)

    bestMatch = ''
    bestScore = 0
    data_list.clear()

    # Define tag mappings to corresponding collections
    tag_collection_mapping = {
        '1': 'Bencana',
        '2': 'Economy',
        '3': 'Safety',  # Replace with the actual collection name for tag 3
        '4': 'Education',  # Replace with the actual collection name for tag 4
        '5': 'Transport',  # Replace with the actual collection name for tag 5
        '6': 'Gov',  # Replace with the actual collection name for tag 6
        '7': 'Crime',  # Replace with the actual collection name for tag 7
        '8': 'Health',  # Replace with the actual collection name for tag 8
        '9': 'Consumer',  # Replace with the actual collection name for tag 9
    }

    if tag in tag_collection_mapping:
        collection_name = tag_collection_mapping[tag]
        titles, links, images = fetch_data(collection_name)

        for listTitle, linklist, imagelis in zip(titles, links, images):
            rat = fuzz.token_set_ratio(listTitle, search)
            if rat >= bestScore or rat > 50:
                if rat > 50:
                    # Check if the bestMatch is not already in data_list before appending
                    if not any(d['Title'] == listTitle for d in data_list):
                        bestMatch = listTitle
                        bestScore = rat
                        bestLink = linklist
                        bestImage = imagelis

                        data_dict = {
                            'Title': bestMatch,
                            'Score': bestScore,
                            'link': bestLink,
                            'image': bestImage,
                        }

                        data_list.append(data_dict)

        if not data_list:
            print("No match found")
            return None

    else:
        print("Invalid tag")
        return None

    return data_list
