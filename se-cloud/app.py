import socket
import json
from confluent_kafka import Producer
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Kafka settings
BROKER = 'localhost:9092'
TOPIC = 'project-topic'
GROUP_ID = 'test-group'

# Sample data
search_term_data = [
    { 'id': 1, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 169 },
    { 'id': 2, 'folder': 'histories', 'name': '1kinghenryiv', 'frequency': 160 },
    { 'id': 3, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 179 },
    { 'id': 4, 'folder': 'histories', 'name': '2kinghenryiv', 'frequency': 340 }
]

# Function to create a Kafka Producer
def create_kafka_producer(broker, group_id):
    conf = {
        'bootstrap.servers': broker,
        'group.id': group_id,
        'client.id': socket.gethostname()
    }
    producer = Producer(conf)
    logging.info("Created Kafka producer")
    return producer

# Function to publish search term data to Kafka
def publish_search_term_data():
    producer = create_kafka_producer(BROKER, GROUP_ID)
    for record in search_term_data:
        # Convert record to JSON string and send to Kafka
        message = json.dumps(record)
        producer.produce(TOPIC, key=str(record['id']), value=message)
        print(f"Produced record to Kafka: {message}")
        logging.info(f"Produced record to Kafka: {message}")
    producer.flush()

if __name__ == "__main__":
    print("Sending search term data to Kafka")
    publish_search_term_data()
