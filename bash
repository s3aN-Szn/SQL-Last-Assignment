
---

# 4) API Quick Reference (Postman-ready examples)

- `POST http://localhost:3000/patients`
  - Body (JSON):
    ```json
    {
      "first_name": "Test",
      "last_name": "Patient",
      "email": "test.patient@example.com",
      "phone": "+254700123456",
      "date_of_birth": "1990-01-01",
      "gender": "female"
    }
    ```

- `GET http://localhost:3000/patients`
- `GET http://localhost:3000/patients/1`
- `PUT http://localhost:3000/patients/1`
  - Body:
    ```json
    { "phone": "+254700000000" }
    ```

- `DELETE http://localhost:3000/patients/1`

- `POST http://localhost:3000/appointments`
  - Body:
    ```json
    {
      "patient_id": 1,
      "doctor_id": 1,
      "scheduled_at": "2025-10-01 09:00:00",
      "duration_minutes": 30,
      "reason": "Follow-up"
    }
    ```

- `GET http://localhost:3000/appointments`
- `GET http://localhost:3000/appointments?patient_id=1`
- `GET http://localhost:3000/appointments/1`
- `PUT http://localhost:3000/appointments/1`
- `DELETE http://localhost:3000/appointments/1`

---

# 5) Grading checklist mapping to your evaluation criteria

- **Complete implementation (40%)**: `clinic_schema.sql` includes DB, tables, constraints and sample data. Node app implements CRUD for two entities.
- **Code quality (30%)**: code is modular in a single file for clarity; comments and clear SQL constraints are included. (If you want, I can split Express handlers into controllers/routes.)
- **Visualizations (20%)**: not required by this question — but if needed, I can add a small React or Streamlit dashboard using the API to visualize appointments per day / doctor.
- **Streamlit app (10%)**: not requested for this database/CRUD question. The earlier assignment had Streamlit — I can combine both if you want.

---

If you want me to:
- Split the Express app into `routes/`, `controllers/`, and `db/` files (cleaner, better code structure) — I’ll produce that.
- Add input validation (Joi) and better error handling + unit tests — I can scaffold that.
- Create a full GitHub repo (I can provide all files ready-to-copy or prepare a zipped archive) — say which you prefer.

Which next step should I do for you? (e.g., split code into modules, add authentication, or produce files in a zipped repo)
