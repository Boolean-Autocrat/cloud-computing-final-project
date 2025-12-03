import React, { useState } from "react";
import "./App.css";

function App() {
  const [formData, setFormData] = useState({
    patient_id: "",
    heart_rate: "",
    blood_pressure: "",
    temperature: "",
  });
  const [status, setStatus] = useState("");

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus("Sending...");

    const payload = {
      ...formData,
      heart_rate: parseInt(formData.heart_rate),
      temperature: parseFloat(formData.temperature),
    };

    try {
      const response = await fetch("/ingest", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      if (response.ok) {
        setStatus("✅ Vitals Submitted Successfully!");
        setFormData({
          patient_id: "",
          heart_rate: "",
          blood_pressure: "",
          temperature: "",
        });
      } else {
        setStatus("❌ Submission Failed.");
      }
    } catch (error) {
      console.error("Error:", error);
      setStatus("❌ Network Error.");
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🏥 HealthMonitor Dashboard</h1>
        <div className="card">
          <h2>Input Patient Vitals</h2>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Patient ID:</label>
              <input
                type="text"
                name="patient_id"
                value={formData.patient_id}
                onChange={handleChange}
                required
                placeholder="e.g. p-123"
              />
            </div>
            <div className="form-group">
              <label>Heart Rate (BPM):</label>
              <input
                type="number"
                name="heart_rate"
                value={formData.heart_rate}
                onChange={handleChange}
                required
                placeholder="e.g. 80"
              />
            </div>
            <div className="form-group">
              <label>Blood Pressure:</label>
              <input
                type="text"
                name="blood_pressure"
                value={formData.blood_pressure}
                onChange={handleChange}
                required
                placeholder="e.g. 120/80"
              />
            </div>
            <div className="form-group">
              <label>Temperature (°F):</label>
              <input
                type="number"
                step="0.1"
                name="temperature"
                value={formData.temperature}
                onChange={handleChange}
                required
                placeholder="e.g. 98.6"
              />
            </div>
            <button type="submit" className="submit-btn">
              Submit Vitals
            </button>
          </form>
          {status && <p className="status-msg">{status}</p>}
        </div>
      </header>
    </div>
  );
}

export default App;
