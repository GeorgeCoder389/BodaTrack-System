-- Create database
CREATE DATABASE IF NOT EXISTS bodatrack;
USE bodatrack;

-- SACCOS table
CREATE TABLE saccos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    contact VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'sacco_official', 'rider', 'authority') NOT NULL,
    sacco_id INT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sacco_id) REFERENCES saccos(id) ON DELETE SET NULL
);

-- Riders table (additional rider-specific info)
CREATE TABLE riders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    sacco_id INT NOT NULL,
    license_number VARCHAR(50),
    license_expiry DATE,
    insurance_number VARCHAR(50),
    insurance_expiry DATE,
    motorcycle_reg VARCHAR(50),
    motorcycle_model VARCHAR(50),
    status ENUM('pending', 'active', 'inactive', 'suspended') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (sacco_id) REFERENCES saccos(id)
);

-- Trips table
CREATE TABLE trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rider_id INT NOT NULL,
    start_location VARCHAR(255),
    end_location VARCHAR(255),
    start_time DATETIME,
    end_time DATETIME,
    distance_km DECIMAL(10,2),
    fare DECIMAL(10,2),
    status ENUM('ongoing', 'completed', 'cancelled') DEFAULT 'ongoing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES riders(id) ON DELETE CASCADE
);

-- GPS Logs table for tracking
CREATE TABLE gps_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rider_id INT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_name VARCHAR(255),
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES riders(id) ON DELETE CASCADE
);

-- Alerts table
CREATE TABLE alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('document_expiry', 'emergency', 'system', 'compliance') NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    message TEXT NOT NULL,
    rider_id INT,
    sacco_id INT,
    status ENUM('unread', 'read', 'resolved') DEFAULT 'unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES riders(id) ON DELETE SET NULL,
    FOREIGN KEY (sacco_id) REFERENCES saccos(id) ON DELETE SET NULL
);

-- System Logs table
CREATE TABLE system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255),
    details TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert sample data
INSERT INTO saccos (name, location, contact) VALUES
('Boda Boda SACCO', 'Nairobi CBD', '0700000000'),
('Green Riders SACCO', 'Westlands', '0711111111'),
('Safe Ride SACCO', 'Kilimani', '0722222222');

-- Insert admin user (password: admin123)
INSERT INTO users (username, password, full_name, email, role, status) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Administrator', 'admin@bodatrack.com', 'admin', 'active');

-- Insert authority user (password: authority123)
INSERT INTO users (username, password, full_name, email, role, status) VALUES
('authority', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Transport Authority', 'authority@bodatrack.com', 'authority', 'active');