from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
app.config.from_object(__name__)

# enable CORS
CORS(app, resources={r'/*': {'origins': '*'}})

search_term_data = [
    { 'id': 1, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 169 },
    { 'id': 2, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 160 },
    { 'id': 3, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 179 },
    { 'id': 4, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 340 }
]

top_n_data = [
    { 'term': 'KING', 'frequency': 5000 },
    { 'term': 'HENRY', 'frequency': 4500 },
    { 'term': 'THE', 'frequency': 4000 },
    { 'term': 'FOURTH', 'frequency': 3500 },
    { 'term': 'SIR', 'frequency': 3000 },
    { 'term': 'WALTER', 'frequency': 2500 },
    { 'term': 'BLUNT', 'frequency': 2000 },
    { 'term': 'OWEN', 'frequency': 1500 },
    { 'term': 'GELNDOWER', 'frequency': 1000 },
    { 'term': 'RICHARD', 'frequency': 500 }
]


@app.route('/api/search', methods=['GET'])
def search_term():
    print(request.args.get('term'))
    return jsonify({
        'status': 'success',
        'data': search_term_data
    })

@app.route('/api/topn', methods=['GET'])
def top_n():
    print(request.args.get('n'))
    return jsonify({
        'status': 'success',
        'data': top_n_data
    })


if __name__ == '__main__':
    app.run(port=5001)