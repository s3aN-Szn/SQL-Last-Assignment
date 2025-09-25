// index.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');

const app = express();
const port = process.env.PORT || 3000;
app.use(bodyParser.json());

// create DB pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'clinic_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// --- Patients CRUD ---
// Create patient
app.post('/patients', async (req, res) => {
  try {
    const { first_name, last_name, email, phone, date_of_birth, gender } = req.body;
    const [result] = await pool.execute(
      `INSERT INTO patients (first_name,last_name,email,phone,date_of_birth,gender) VALUES (?,?,?,?,?,?)`,
      [first_name, last_name, email, phone, date_of_birth, gender]
    );
    const [rows] = await pool.execute('SELECT * FROM patients WHERE id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Read all patients (with pagination)
app.get('/patients', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    const [rows] = await pool.execute('SELECT * FROM patients ORDER BY id DESC LIMIT ? OFFSET ?', [limit, offset]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Read single patient
app.get('/patients/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM patients WHERE id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Patient not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update patient
app.put('/patients/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const fields = ['first_name','last_name','email','phone','date_of_birth','gender'];
    const updates = [];
    const values = [];
    for (const f of fields) {
      if (req.body[f] !== undefined) {
        updates.push(`${f} = ?`);
        values.push(req.body[f]);
      }
    }
    if (!updates.length) return res.status(400).json({ error: 'No fields to update' });
    values.push(id);
    const sql = `UPDATE patients SET ${updates.join(', ')} WHERE id = ?`;
    await pool.execute(sql, values);
    const [rows] = await pool.execute('SELECT * FROM patients WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete patient
app.delete('/patients/:id', async (req, res) => {
  try {
    const [result] = await pool.execute('DELETE FROM patients WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Patient not found' });
    res.json({ message: 'Patient deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Appointments CRUD ---
// Create appointment
app.post('/appointments', async (req, res) => {
  try {
    const { patient_id, doctor_id, scheduled_at, duration_minutes, reason } = req.body;
    const [result] = await pool.execute(
      `INSERT INTO appointments (patient_id, doctor_id, scheduled_at, duration_minutes, reason) VALUES (?,?,?,?,?)`,
      [patient_id, doctor_id, scheduled_at, duration_minutes || 30, reason]
    );
    const [rows] = await pool.execute('SELECT * FROM appointments WHERE id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    // handle duplicate booking unique constraint
    if (err && err.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ error: 'Doctor already has an appointment at that scheduled_at' });
    } else {
      res.status(500).json({ error: err.message });
    }
  }
});

// Read all appointments (with optional patient or doctor filter)
app.get('/appointments', async (req, res) => {
  try {
    const { patient_id, doctor_id, limit = 50, offset = 0 } = req.query;
    let sql = 'SELECT a.*, p.first_name AS patient_first, p.last_name AS patient_last, d.first_name AS doctor_first, d.last_name AS doctor_last FROM appointments a JOIN patients p ON a.patient_id = p.id JOIN doctors d ON a.doctor_id = d.id';
    const conditions = [];
    const values = [];
    if (patient_id) { conditions.push('a.patient_id = ?'); values.push(patient_id); }
    if (doctor_id)  { conditions.push('a.doctor_id = ?'); values.push(doctor_id); }
    if (conditions.length) sql += ' WHERE ' + conditions.join(' AND ');
    sql += ' ORDER BY a.scheduled_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));
    const [rows] = await pool.execute(sql, values);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Read single appointment
app.get('/appointments/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM appointments WHERE id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Appointment not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update appointment
app.put('/appointments/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const fields = ['patient_id','doctor_id','scheduled_at','duration_minutes','status','reason'];
    const updates = [];
    const values = [];
    for (const f of fields) {
      if (req.body[f] !== undefined) {
        updates.push(`${f} = ?`);
        values.push(req.body[f]);
      }
    }
    if (!updates.length) return res.status(400).json({ error: 'No fields to update' });
    values.push(id);
    const sql = `UPDATE appointments SET ${updates.join(', ')} WHERE id = ?`;
    await pool.execute(sql, values);
    const [rows] = await pool.execute('SELECT * FROM appointments WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      res.status(409).json({ error: 'Doctor already has an appointment at that scheduled_at' });
    } else {
      res.status(500).json({ error: err.message });
    }
  }
});

// Delete appointment
app.delete('/appointments/:id', async (req, res) => {
  try {
    const [result] = await pool.execute('DELETE FROM appointments WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Appointment not found' });
    res.json({ message: 'Appointment deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Health check
app.get('/', (req, res) => res.send('Clinic CRUD API is running'));

// Start server
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
