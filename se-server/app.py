import threading
from flask import Flask, jsonify, request
from flask_cors import CORS
from confluent_kafka import Consumer, KafkaError
import socket
import logging
import json

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

# search_term_data = [
#     { 'id': 1, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 169 },
#     { 'id': 2, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 160 },
#     { 'id': 3, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 179 },
#     { 'id': 4, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 340 }
# ]
search_term_data = []

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

# Function to create a Kafka consumer
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

def consume_messages():
    global search_term_data
    consumer = create_kafka_consumer(BROKER, GROUP_ID, TOPIC)
    try:
        while True:
            msg = consumer.poll(1.0)  # Poll for new messages
            if msg is None:
                logging.info("No new messages")
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    logging.info("Reached end of partition")
                else:
                    logging.error(f"Consumer error: {msg.error()}")
                continue
            # Decode JSON message and store it
            data = json.loads(msg.value().decode('utf-8'))
            search_term_data.append(data)
            print(f"Received message: {data}")
            logging.info(f"Received message: {data}")
    except Exception as e:
        logging.error(f"Error consuming messages: {e}")
    finally:
        consumer.close()

@app.route('/api/search', methods=['GET'])
def search_term():
    print("data: " + str(search_term_data))
    return jsonify({
        'status': 'success',
        'data': search_term_data
    })

@app.route('/api/topn', methods=['GET'])
def top_n():
    print("data: " + str(top_n_data))
    return jsonify({
        'status': 'success',
        'data': top_n_data
    })


if __name__ == '__main__':
    consumer_thread = threading.Thread(target=consume_messages)
    consumer_thread.start()

    print("Server started on port 5001")
    app.run(host='0.0.0.0', port=5001)
    