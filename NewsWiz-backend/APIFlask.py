from flask import Flask, request, jsonify
import String_match

app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def match():
    try:
        searchQuery = request.args.get('search')
        tagQuery = str(request.args.get('tag'))

        # Call the String_match.string() function to get the data
        data_list = String_match.string(searchQuery, tagQuery)

        finaList = data_list

        if not finaList:
            return jsonify({'error': 'Empty'}), 200

        print(finaList)
        # Return the data as a JSON response
        return jsonify(finaList)

    except Exception as e:
        error_message = str(e)
        return jsonify({'error': error_message}), 500


if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0')
