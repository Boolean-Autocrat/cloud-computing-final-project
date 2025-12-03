import json
from confluent_kafka import Consumer
from confluent_kafka.cimpl import KafkaError
import boto3
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

# Kafka consumer configuration
conf = {
    'bootstrap.servers': os.getenv('KAFKA_BOOTSTRAP_SERVERS'),
    'group.id': "alert-service-group",
    'auto.offset.reset': 'earliest',
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': os.getenv('KAFKA_API_KEY'),
    'sasl.password': os.getenv('KAFKA_API_SECRET'),
}
consumer = Consumer(conf)
consumer.subscribe(['raw-vitals'])

# DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('health-monitor-alerts')

def process_message(msg):
    vital = json.loads(msg.value())
    patient_id = vital['patient_id']
    heart_rate = vital['heart_rate']

    if heart_rate > 100 or heart_rate < 60:
        try:
            table.put_item(
                Item={
                    'patient_id': patient_id,
                    'timestamp': datetime.now().isoformat(),
                    'heart_rate': heart_rate
                }
            )
            print("ALERT: Patient ID:", patient_id, "Heart Rate:", heart_rate)
            print(f"Alert stored for {patient_id}")
        except Exception as e:
            print(f"Failed to write to DynamoDB: {e}")

while True:
    msg = consumer.poll(1.0)

    if msg is None:
        continue
    if msg.error():
        if msg.error().code() == KafkaError._PARTITION_EOF:
            continue
        else:
            print(msg.error())
            break

    try:
        process_message(msg)
    except Exception as e:
        print(f"Error processing message: {e}")

consumer.close()
