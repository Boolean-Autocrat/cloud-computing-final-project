
import json
from confluent_kafka import Consumer, KafkaError
import boto3
from datetime import datetime

# Kafka consumer configuration
conf = {
    'bootstrap.servers': "YOUR_CONFLUENT_CLOUD_BOOTSTRAP_SERVER",
    'group.id': "alert-service-group",
    'auto.offset.reset': 'earliest',
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': 'YOUR_CONFLUENT_CLOUD_API_KEY',
    'sasl.password': 'YOUR_CONFLUENT_CLOUD_API_SECRET',
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
        print(f"Alert for patient {patient_id}: Heart rate is {heart_rate}")
        table.put_item(
            Item={
                'patient_id': patient_id,
                'timestamp': datetime.now().isoformat(),
                'heart_rate': heart_rate
            }
        )

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

    process_message(msg)

consumer.close()
