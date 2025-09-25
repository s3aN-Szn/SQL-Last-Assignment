# Clinic Booking System — SQL schema + Node.js CRUD App

This project contains:
- `clinic_schema.sql` — SQL file that creates the `clinic_db` database and schema.
- Node.js + Express application for CRUD operations on Patients and Appointments.

## Prerequisites
- Node.js (>=14)
- MySQL server
- npm (comes with Node.js)

## Setup database
1. Start MySQL server.
2. Run the SQL file to create the database and tables:

```bash
mysql -u root -p < clinic_schema.sql
