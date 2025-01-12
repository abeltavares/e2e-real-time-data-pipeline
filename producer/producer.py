import os
import time
import random
import json
import logging
import signal
import sys
from faker import Faker
from confluent_kafka import Producer

fake = Faker()

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Kafka configuration
kafka_broker = os.getenv("KAFKA_BROKER")
if not kafka_broker:
    raise ValueError("KAFKA_BROKER environment variable is not set.")

kafka_config = {
    'bootstrap.servers': kafka_broker
}
producer = Producer(kafka_config)

topic = 'clickstream'

def generate_clickstream_event():
    return {
        "event_id": fake.uuid4(),
        "user_id": fake.uuid4(),
        "event_type": fake.random_element(elements=("page_view", "add_to_cart", "purchase", "logout")),
        "url": fake.uri_path(),
        "session_id": fake.uuid4(),
        "device": fake.random_element(elements=("mobile", "desktop", "tablet")),
        "geo_location": {
            "lat": float(fake.latitude()),
            "lon": float(fake.longitude())
        },
        "purchase_amount": float(random.uniform(0.0, 500.0)) if fake.boolean(chance_of_getting_true=30) else None
    }

def delivery_report(err, msg):
    if err is not None:
        logger.error(f"Message delivery failed: {err}")
    else:
        logger.info(f"Message delivered to {msg.topic()} [{msg.partition()}]")

def signal_handler(sig, frame):
    logger.info("Data generation stopped.")
    producer.flush()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

if __name__ == "__main__":
    try:
        while True:
            event = generate_clickstream_event()
            try:
                producer.produce(topic, key=event["session_id"], value=json.dumps(event), callback=delivery_report)
            except BufferError as e:
                logger.error(f"Buffer error: {e}")
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
            logger.info(json.dumps(event, indent=2))
            time.sleep(1)
            producer.poll(1)
    except KeyboardInterrupt:
        logger.info("Data generation stopped.")
    finally:
        producer.flush()