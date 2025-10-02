-- =====================================
-- CREATE DATABASE
-- =====================================
CREATE DATABASE Ndhuma_Clinic;

USE Ndhuma_Clinic;

-- =====================================
-- CREATE TABLES
-- =====================================

-- Patient table
CREATE TABLE Patient (
    PatientID INT IDENTITY(1,1) CONSTRAINT PK_Patient PRIMARY KEY,
    PatientName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Doctor table
CREATE TABLE Doctor (
    DoctorID INT IDENTITY(1,1) CONSTRAINT PK_Doctor PRIMARY KEY,
    DoctorName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Services table
CREATE TABLE Service (
    ServiceID INT IDENTITY(1,1) CONSTRAINT PK_Service PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL
);

-- Appointment table
CREATE TABLE Appointment (
    AppointmentID INT IDENTITY(1,1) CONSTRAINT PK_Appointment PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    ServiceID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Scheduled','Completed','No-Show','Cancelled')) DEFAULT 'Scheduled',
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT FK_Appointment_Service FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID),
    CONSTRAINT UQ_Doctor_Booking UNIQUE (DoctorID, AppointmentDate) -- prevent double booking
);

-- Payment table
CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) CONSTRAINT PK_Payment PRIMARY KEY,
    AppointmentID INT NOT NULL,
    Amount DECIMAL(10,2),
    PaymentStatus VARCHAR(20) CHECK (PaymentStatus IN ('Paid','Unpaid','Partial')) DEFAULT 'Unpaid',
    PaymentDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Payment_Appointment FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

-- =====================================
-- INSERT DATA
-- =====================================

-- Insert patients
INSERT INTO Patient (PatientName) VALUES
('Alice Johnson'), ('Michael Smith'), ('Thandi Nkosi'), ('David Brown'),
('Sarah Williams'), ('James Peterson'), ('Nomsa Dlamini'), ('John King'),
('Emily Carter'), ('Sipho Mthembu'), ('Grace Adams'), ('Daniel White'),
('Karen Hughes'), ('Peter Jacobs'), ('Olivia Scott'), ('Samuel Harris'),
('Lerato Molefe'), ('Matthew Wright'), ('Sophia Clark'), ('Jason Lee');

-- Insert doctors
INSERT INTO Doctor (DoctorName, Specialization) VALUES
('Dr. Adams', 'Cardiology'),
('Dr. Naidoo', 'Dermatology'),
('Dr. Brown', 'Pediatrics'),
('Dr. Smith', 'Orthopedics'),
('Dr. Jacobs', 'General Practice');

-- Insert services
INSERT INTO Service (ServiceName, Cost) VALUES
('General Consultation', 300.00),
('Cardiac Checkup', 1200.00),
('Skin Treatment', 800.00),
('Child Wellness Exam', 500.00),
('Orthopedic Assessment', 1000.00),
('Emergency Visit', 1500.00);

-- Insert appointments
INSERT INTO Appointment (PatientID, DoctorID, ServiceID, AppointmentDate, Status) VALUES
(1, 1, 2, '2025-09-05 09:00:00', 'Completed'),
(2, 2, 3, '2025-09-05 10:00:00', 'Completed'),
(3, 3, 4, '2025-09-05 11:00:00', 'No-Show'),
(4, 5, 1, '2025-09-05 13:00:00', 'Cancelled'),
(5, 4, 5, '2025-09-06 09:00:00', 'Completed'),
(6, 1, 2, '2025-09-06 10:00:00', 'Completed'),
(7, 2, 3, '2025-09-06 11:00:00', 'No-Show'),
(8, 5, 6, '2025-09-06 12:00:00', 'Scheduled'),
(9, 3, 4, '2025-09-07 09:00:00', 'Completed'),
(10, 4, 1, '2025-09-07 10:00:00', 'Completed'),
(11, 1, 2, '2025-09-07 11:00:00', 'Cancelled'),
(12, 5, 6, '2025-09-08 09:00:00', 'Scheduled'),
(13, 2, 3, '2025-09-08 10:00:00', 'Completed'),
(14, 3, 4, '2025-09-08 11:00:00', 'Completed'),
(15, 4, 5, '2025-09-08 12:00:00', 'Completed'),
(16, 5, 1, '2025-09-09 09:00:00', 'No-Show'),
(17, 1, 6, '2025-09-09 10:00:00', 'Completed'),
(18, 2, 2, '2025-09-09 11:00:00', 'Completed'),
(19, 3, 5, '2025-09-09 12:00:00', 'Cancelled'),
(20, 4, 6, '2025-09-10 09:00:00', 'Completed'),
(1, 5, 1, '2025-09-10 10:00:00', 'Completed'),
(2, 3, 4, '2025-09-10 11:00:00', 'Scheduled'),
(3, 2, 3, '2025-09-10 12:00:00', 'Completed'),
(4, 1, 2, '2025-09-11 09:00:00', 'No-Show'),
(5, 4, 5, '2025-09-11 10:00:00', 'Completed');

-- Insert payments
INSERT INTO Payment (AppointmentID, Amount, PaymentStatus) VALUES
(1, 1200.00, 'Paid'),
(2, 800.00, 'Paid'),
(5, 1000.00, 'Paid'),
(6, 1200.00, 'Unpaid'),
(9, 500.00, 'Paid'),
(10, 300.00, 'Paid'),
(13, 800.00, 'Partial'),
(14, 500.00, 'Paid'),
(15, 1000.00, 'Paid'),
(17, 1500.00, 'Paid'),
(18, 1200.00, 'Unpaid'),
(20, 1500.00, 'Paid'),
(21, 300.00, 'Paid'),
(23, 800.00, 'Paid'),
(25, 1000.00, 'Unpaid');

-- =====================================
-- ADVANCED QUERIES
-- =====================================

-- 1. Total Revenue Collected
SELECT SUM(Amount) AS TotalRevenue
FROM Payment
WHERE PaymentStatus = 'Paid';

-- 2. Revenue by Doctor
SELECT d.DoctorName, SUM(p.Amount) AS Revenue
FROM Doctor d
JOIN Appointment a ON d.DoctorID = a.DoctorID
JOIN Payment p ON a.AppointmentID = p.AppointmentID
WHERE p.PaymentStatus = 'Paid'
GROUP BY d.DoctorName
ORDER BY Revenue DESC;

-- 3. Most Popular Service
SELECT s.ServiceName, COUNT(*) AS TimesBooked
FROM Service s
JOIN Appointment a ON s.ServiceID = a.ServiceID
GROUP BY s.ServiceName
ORDER BY TimesBooked DESC;

-- 4. Unpaid Balances per Patient
SELECT p.PatientName, SUM(pay.Amount) AS OutstandingBalance
FROM Patient p
JOIN Appointment a ON p.PatientID = a.PatientID
JOIN Payment pay ON a.AppointmentID = pay.AppointmentID
WHERE pay.PaymentStatus IN ('Unpaid','Partial')
GROUP BY p.PatientName
HAVING SUM(pay.Amount) > 0
ORDER BY OutstandingBalance DESC;

-- 5. Doctor Utilization
SELECT d.DoctorName,
       COUNT(a.AppointmentID) AS TotalAppointments,
       SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
       SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows
FROM Doctor d
LEFT JOIN Appointment a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorName
ORDER BY TotalAppointments DESC;

-- 6. Daily Revenue Report
SELECT CAST(a.AppointmentDate AS DATE) AS Day,
       SUM(p.Amount) AS TotalCollected
FROM Appointment a
JOIN Payment p ON a.AppointmentID = p.AppointmentID
WHERE p.PaymentStatus = 'Paid'
GROUP BY CAST(a.AppointmentDate AS DATE)
ORDER BY Day;

-- 7. Patients with Most Appointments
SELECT p.PatientName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Patient p
JOIN Appointment a ON p.PatientID = a.PatientID
GROUP BY p.PatientName
ORDER BY TotalAppointments DESC;

-- 8. Cancelled Appointments Summary
SELECT d.DoctorName, COUNT(*) AS CancelledCount
FROM Appointment a
JOIN Doctor d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Cancelled'
GROUP BY d.DoctorName
ORDER BY CancelledCount DESC;
