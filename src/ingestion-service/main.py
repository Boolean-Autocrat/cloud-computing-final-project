from fastapi import FastAPI
from pydantic import BaseModel
from confluent_kafka import Producer
import json
import socket
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI()

conf = {
    'bootstrap.servers': os.getenv('KAFKA_BOOTSTRAP_SERVERS'),
    'security.protocol': 'SASL_SSL',
    'sasl.mechanisms': 'PLAIN',
    'sasl.username': os.getenv('KAFKA_API_KEY'),
    'sasl.password': os.getenv('KAFKA_API_SECRET'),
    'client.id': socket.gethostname(),
}

producer = Producer(conf)

class Vital(BaseModel):
    patient_id: str
    heart_rate: int
    blood_pressure: str
    temperature: float

@app.post("/ingest")
async def ingest_vitals(vital: Vital):
    producer.poll(0)
    
    producer.produce(
        'raw-vitals', 
        key=vital.patient_id, 
        value=json.dumps(vital.model_dump())
    )
    
    producer.flush(timeout=1) 
    
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)