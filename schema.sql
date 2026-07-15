-- ============================================================
--  EsSalud Citas - Esquema de Base de Datos (MySQL 8+)
-- ============================================================
DROP DATABASE IF EXISTS essalud_citas;
CREATE DATABASE essalud_citas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE essalud_citas;

-- ------------------------------------------------------------
-- PACIENTES (usuarios que inician sesión con DNI)
-- ------------------------------------------------------------
CREATE TABLE pacientes (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    dni             VARCHAR(8) NOT NULL UNIQUE,
    nombres         VARCHAR(100) NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    email           VARCHAR(150),
    telefono        VARCHAR(20),
    password_hash   VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- ESPECIALIDADES
-- ------------------------------------------------------------
CREATE TABLE especialidades (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    descripcion     VARCHAR(255),
    icono_path      TEXT,
    activa          BOOLEAN DEFAULT TRUE
);

-- ------------------------------------------------------------
-- MEDICOS
-- ------------------------------------------------------------
CREATE TABLE medicos (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombres             VARCHAR(100) NOT NULL,
    apellidos           VARCHAR(100) NOT NULL,
    colegiatura         VARCHAR(20),
    especialidad_id     BIGINT NOT NULL,
    activo              BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (especialidad_id) REFERENCES especialidades(id)
);

-- ------------------------------------------------------------
-- HORARIOS DISPONIBLES (slots que un médico ofrece)
-- ------------------------------------------------------------
CREATE TABLE horarios (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    medico_id       BIGINT NOT NULL,
    fecha           DATE NOT NULL,
    hora_inicio     TIME NOT NULL,
    hora_fin        TIME NOT NULL,
    disponible      BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (medico_id) REFERENCES medicos(id)
);

-- ------------------------------------------------------------
-- CITAS
-- ------------------------------------------------------------
CREATE TABLE citas (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id         BIGINT NOT NULL,
    medico_id           BIGINT NOT NULL,
    especialidad_id     BIGINT NOT NULL,
    horario_id          BIGINT,
    fecha               DATE NOT NULL,
    hora                TIME NOT NULL,
    estado              ENUM('PENDIENTE','CONFIRMADA','CANCELADA','ATENDIDA') DEFAULT 'PENDIENTE',
    motivo              VARCHAR(255),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    FOREIGN KEY (medico_id) REFERENCES medicos(id),
    FOREIGN KEY (especialidad_id) REFERENCES especialidades(id),
    FOREIGN KEY (horario_id) REFERENCES horarios(id)
);

-- ------------------------------------------------------------
-- NOTIFICACIONES
-- ------------------------------------------------------------
CREATE TABLE notificaciones (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id     BIGINT NOT NULL,
    icono           VARCHAR(20) DEFAULT 'bell',
    titulo          VARCHAR(150) NOT NULL,
    mensaje         VARCHAR(255) NOT NULL,
    leida           BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
);

-- ============================================================
--  DATOS SEMILLA (equivalentes a los datos "quemados" del HTML)
-- ============================================================

INSERT INTO especialidades (nombre, descripcion, icono_path) VALUES
('Cardiología', 'Salud del corazón y sistema circulatorio', 'M20.8 4.6a5.5 5.5 0 00-7.8 0L12 5.6l-1-1a5.5 5.5 0 00-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 000-7.8z'),
('Pediatría', 'Atención médica para niños y adolescentes', 'M9 12h.01M15 12h.01M9.5 15.5c.8.7 1.8 1 2.5 1s1.7-.3 2.5-1M12 3a9 9 0 100 18 9 9 0 000-18z'),
('Dermatología', 'Diagnóstico y tratamiento de la piel', 'M12 2v4M12 18v4M4.9 4.9l2.8 2.8M16.3 16.3l2.8 2.8M2 12h4M18 12h4M4.9 19.1l2.8-2.8M16.3 7.7l2.8-2.8'),
('Traumatología', 'Lesiones óseas, articulares y musculares', 'M6 9V4.5a2.5 2.5 0 015 0V9m4 0V4.5a2.5 2.5 0 015 0V9M4 9h16l-1 10a2 2 0 01-2 2H7a2 2 0 01-2-2L4 9z'),
('Ginecología', 'Salud femenina y reproductiva', 'M12 21C12 21 4 15.5 4 9.5C4 6.46 6.46 4 9.5 4C11 4 12.3 4.7 13 5.8C13.7 4.7 15 4 16.5 4C19.54 4 22 6.46 22 9.5'),
('Oftalmología', 'Cuidado y salud visual', 'M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8zM12 15a3 3 0 100-6 3 3 0 000 6z'),
('Medicina General', 'Consulta médica integral', 'M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z'),
('Psicología', 'Salud mental y bienestar emocional', 'M12 20h9M16.5 3.5a2.1 2.1 0 013 3L7 19l-4 1 1-4L16.5 3.5z');

INSERT INTO medicos (nombres, apellidos, colegiatura, especialidad_id) VALUES
('Carlos', 'Mendoza', 'CMP-45123', 1),
('Ana', 'Salazar', 'CMP-38210', 3),
('Luis', 'Fernández', 'CMP-51022', 7),
('Rosa', 'Quispe', 'CMP-29981', 2);

-- Paciente demo (password real: "essalud", ya hasheada con BCrypt)
INSERT INTO pacientes (dni, nombres, apellidos, email, telefono, password_hash) VALUES
('1234567', 'María Elena', 'Torres Ríos', 'maria.torres@example.com', '987654321', '$2b$12$Qy6nq887FqrMd8fbWm5BteKBnhE1x2qa6p4BqrMkiXNs4dHF/wQia');

INSERT INTO notificaciones (paciente_id, icono, titulo, mensaje, leida) VALUES
(1, 'bell', 'Recordatorio de cita', 'Tu cita con Dr. Carlos Mendoza (Cardiología) es el 26 de mayo, 09:30 AM.', FALSE),
(1, 'check', 'Cita confirmada', 'Tu cita con Dra. Ana Salazar (Dermatología) fue confirmada para el 2 de junio.', FALSE);
