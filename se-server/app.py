import threading
from flask import Flask, jsonify, request
from flask_cors import CORS
from confluent_kafka import Consumer, KafkaError, Producer
import socket
import logging
import json
import tarfile
import os

app = Flask(__name__)
app.config.from_object(__name__)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# enable CORS
CORS(app, resources={r'/*': {'origins': '*'}})

# Kafka settings
BROKER = 'localhost:9092'  # Change this to your Kafka broker address
GROUP_ID = 'test-group'
TOPIC = 'project-topic' 
INVERTED_INDEX_TOPIC = 'inverted-index-topic'
TOP_N_WORDS_TOPIC = 'top-n-topic'

search_term_data = []

# Function to create a Kafka Producer
def create_kafka_producer(broker):
    conf = {
        'bootstrap.servers': broker,
        'client.id': socket.gethostname()
    }
    producer = Producer(conf)
    return producer

# # Function to create a Kafka consumer
def create_kafka_consumer(broker, group_id, topic):
    conf = {
        'bootstrap.servers': broker,
        'group.id': group_id,
        'auto.offset.reset': 'earliest',
        'client.id': socket.gethostname()
    }
    consumer = Consumer(conf)
    consumer.subscribe([topic])
    return consumer

def consume_messages(consumer):
    messages_dict = {}
    while True:
        msg = consumer.poll(timeout=1.0)
        if msg is None:
            break 
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                break
            else:
                print(f"Error: {msg.error()}")
                continue
        key = msg.key().decode("utf-8")
        value = json.loads(msg.value().decode("utf-8"))
        messages_dict[key] = value
    return messages_dict

def process_text_file(file_obj, filename, folder_name):
    try:
        content = file_obj.read().decode("utf-8")
        return {
            "folder": folder_name,
            "name": filename, 
            "content": content
        }
    except UnicodeDecodeError:
        return None

def extract_and_process_tar_gz(file, producer):
    text_files_content = []
    root_folder = None

    with tarfile.open(fileobj=file, mode="r:gz") as tar:
        members = [member for member in tar.getmembers() if member.isfile()]
        
        if members:
            root_folder = members[0].name.split(os.sep)[0]

        for member in members:
            file_obj = tar.extractfile(member)
            if file_obj:
                relative_path = os.path.relpath(member.name, root_folder)
                folder_path, filename = os.path.split(relative_path)
                
                folder_name = os.path.basename(folder_path) if folder_path else "N/A"
                
                text_file_info = process_text_file(file_obj, filename, folder_name)
                if text_file_info:
                    text_files_content.append(text_file_info)
                    producer.produce(TOPIC, key=str(text_file_info['name']), value=json.dumps(text_file_info).encode('utf-8'))
    
    return text_files_content

@app.route('/api/search', methods=['GET'])
def search_term():
    term = request.args.get("term")
    if not term:
        return jsonify({"error": "No search term provided"}), 400

    result = inverted_index_dict.get(term, {})
    print(result)
    return jsonify({
        "status": "success",
        "data": result
    })

@app.route("/api/topn", methods=["GET"])
def top_n():
    n = request.args.get("n")
    if not n or not n.isdigit():
        return jsonify({"error": "Invalid or missing N value"}), 400

    n = int(n)
    sorted_top_n_words = dict(
        sorted(top_n_words_dict.items(), key=lambda item: item[1]['total_frequency'], reverse=True)
    )
    top_n_result = dict(list(sorted_top_n_words.items())[:n])
    print(top_n_result)
    return jsonify({
        "status": "success",
        "data": top_n_result
    })

# route handle file upload + unzip file + process .txt files (extract folder structure, assign doc id)
# for every document, produce hadoop job (kafka event)
# consume hadoop job completion event (kafka event) -> inverted index update + top n terms update

# 2 dictionaries to store the inverted index and top n terms
@app.route("/api/upload", methods=["POST"])
def upload_files():
    global inverted_index_dict, top_n_words_dict
    producer = create_kafka_producer(BROKER)
    if 'files' not in request.files:
        return jsonify({"error": "No files part in the request"}), 400

    files = request.files.getlist("files")

    if not files:
        return jsonify({"error": "No files uploaded"}), 400

    all_file_contents = []
    for file in files:
        if file.filename.endswith(".tar.gz"):
            # Process .tar.gz file
            try:
                extracted_contents = extract_and_process_tar_gz(file, producer)
                all_file_contents.extend(extracted_contents)
            except Exception as e:
                return jsonify({"error": f"Failed to process tar.gz file: {str(e)}"}), 400
        else:
            text_file_info = process_text_file(file, file.filename, "N/A")
            if text_file_info:
                producer.produce(TOPIC, key=str(text_file_info['name']), value=json.dumps(text_file_info).encode('utf-8'))
                all_file_contents.append(text_file_info)
    
    producer.flush()

    inverted_index_consumer = create_kafka_consumer(BROKER, GROUP_ID, INVERTED_INDEX_TOPIC)
    top_n_words_consumer = create_kafka_consumer(BROKER, GROUP_ID, TOP_N_WORDS_TOPIC)

    inverted_index_dict = consume_messages(inverted_index_consumer)
    top_n_words_dict = consume_messages(top_n_words_consumer)

    inverted_index_consumer.close()
    top_n_words_consumer.close()

    return jsonify({
        "inverted_index": inverted_index_dict,
        "top_n_words": top_n_words_dict,
        "file_contents": all_file_contents
    })


if __name__ == '__main__':
    # consumer_thread = threading.Thread(target=consume_messages)
    # consumer_thread.start()

    print("Server started on port 5001")
    app.run(host='0.0.0.0', port=5001)
    