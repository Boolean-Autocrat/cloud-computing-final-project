
from fastapi import FastAPI
from pydantic import BaseModel
from confluent_kafka import Producer
import json
import socket

app = FastAPI()

# Kafka producer configuration
conf = {
    'bootstrap.servers': "YOUR_CONFLUENT_CLOUD_BOOTSTRAP_SERVER",
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': 'YOUR_CONFLUENT_CLOUD_API_KEY',
    'sasl.password': 'YOUR_CONFLUENT_CLOUD_API_SECRET',
    'client.id': socket.gethostname()
}
producer = Producer(conf)

class Vital(BaseModel):
    patient_id: str
    heart_rate: int
    blood_pressure: str
    temperature: float

@app.post("/ingest")
async def ingest_vitals(vital: Vital):
    producer.produce('raw-vitals', key=vital.patient_id, value=json.dumps(vital.dict()))
    producer.flush()
    return {"status": "ok"}
