import http from "k6/http";
import { sleep } from "k6";

export const options = {
  stages: [
    { duration: "2m", target: 100 }, // ramp up to 100 users over 2 minutes
    { duration: "5m", target: 100 }, // stay at 100 users for 5 minutes
    { duration: "2m", target: 0 }, // ramp down to 0 users
  ],
};

export default function () {
  const url = "http://localhost:8080/ingest";
  const payload = JSON.stringify({
    patient_id: "test-patient",
    heart_rate: 80,
    blood_pressure: "120/80",
    temperature: 98.6,
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post(url, payload, params);
  sleep(1);
}
