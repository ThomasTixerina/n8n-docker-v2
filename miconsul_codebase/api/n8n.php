<?php
/**
 * n8n API Endpoint
 * MiConsul Legacy Integration - Modernization Phase 2
 * 
 * Secure API for n8n to query and interact with legacy database
 * 
 * Endpoints:
 * GET  ?action=get_patient_history&patient_id=123
 * GET  ?action=get_daily_sales&date=2025-01-29
 * GET  ?action=get_appointments&date=2025-01-29
 * GET  ?action=get_birthdays&date=2025-01-29
 * GET  ?action=get_doctor_availability&doctor_id=5
 * POST ?action=create_appointment
 * POST ?action=update_patient
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Authorization, Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../includes/EnvLoader.php';
require_once __DIR__ . '/../includes/Security.php';
require_once __DIR__ . '/../includes/Database.php';

// Initialize
EnvLoader::load();
Security::init();

// Validate authentication
if (!Security::validateToken()) {
    Security::sendError('Unauthorized', 401);
}

// Rate limiting
$clientIP = Security::getClientIP();
if (!Security::checkRateLimit($clientIP, 100, 60)) {
    Security::sendError('Rate limit exceeded', 429);
}

// Get action
$action = Security::sanitizeString($_GET['action'] ?? '');

if (empty($action)) {
    Security::sendError('Action required', 400);
}

try {
    $result = handleAction($action);
    echo json_encode([
        'success' => true,
        'data' => $result,
        'timestamp' => date('c')
    ]);
} catch (Exception $e) {
    error_log("API Error: " . $e->getMessage());
    Security::sendError($e->getMessage(), 500);
}

/**
 * Route action to appropriate handler
 */
function handleAction(string $action): array {
    switch ($action) {
        case 'get_patient_history':
            return getPatientHistory();
        
        case 'get_daily_sales':
            return getDailySales();
        
        case 'get_appointments':
            return getAppointments();
        
        case 'get_birthdays':
            return getBirthdays();
        
        case 'get_doctor_availability':
            return getDoctorAvailability();
        
        case 'create_appointment':
            return createAppointment();
        
        case 'update_patient':
            return updatePatient();
        
        case 'check_first_visit':
            return checkFirstVisit();
        
        case 'health':
            return ['status' => 'healthy', 'version' => '2.0'];
        
        default:
            throw new InvalidArgumentException("Unknown action: {$action}");
    }
}

/**
 * Get patient visit and payment history
 */
function getPatientHistory(): array {
    $patientId = Security::sanitizeInt($_GET['patient_id'] ?? null);
    
    if (!$patientId) {
        throw new InvalidArgumentException('patient_id required');
    }

    // Get patient basic info
    $patient = Database::selectOne(
        "SELECT id, nombre, apellido, email, telefono, fecha_nacimiento, created_at
         FROM pacientes 
         WHERE id = ?",
        [$patientId]
    );

    if (!$patient) {
        throw new Exception('Patient not found');
    }

    // Get visit history
    $visits = Database::select(
        "SELECT id, fecha, tipo_consulta, doctor_id, notas, total
         FROM consultas 
         WHERE paciente_id = ?
         ORDER BY fecha DESC
         LIMIT 50",
        [$patientId]
    );

    // Get payment history
    $payments = Database::select(
        "SELECT id, fecha, monto, metodo_pago, referencia
         FROM pagos 
         WHERE paciente_id = ?
         ORDER BY fecha DESC
         LIMIT 50",
        [$patientId]
    );

    return [
        'patient' => $patient,
        'visits' => $visits,
        'payments' => $payments,
        'total_visits' => count($visits),
        'total_payments' => count($payments)
    ];
}

/**
 * Get sales for a specific date
 */
function getDailySales(): array {
    $date = Security::sanitizeDate($_GET['date'] ?? date('Y-m-d'));
    
    if (!$date) {
        $date = date('Y-m-d');
    }

    $sales = Database::select(
        "SELECT v.id, v.fecha, v.total, v.estado,
                p.nombre as paciente_nombre, p.apellido as paciente_apellido,
                d.nombre as doctor_nombre
         FROM ventas v
         LEFT JOIN pacientes p ON v.paciente_id = p.id
         LEFT JOIN doctores d ON v.doctor_id = d.id
         WHERE DATE(v.fecha) = ?
         ORDER BY v.fecha DESC",
        [$date]
    );

    $totalAmount = array_sum(array_column($sales, 'total'));

    return [
        'date' => $date,
        'sales' => $sales,
        'count' => count($sales),
        'total_amount' => $totalAmount
    ];
}

/**
 * Get appointments for a specific date
 */
function getAppointments(): array {
    $date = Security::sanitizeDate($_GET['date'] ?? date('Y-m-d'));
    
    if (!$date) {
        $date = date('Y-m-d');
    }

    $appointments = Database::select(
        "SELECT c.id, c.fecha, c.hora, c.tipo_consulta, c.estado, c.notas,
                p.id as paciente_id, p.nombre, p.apellido, p.telefono, p.email,
                d.nombre as doctor_nombre
         FROM citas c
         LEFT JOIN pacientes p ON c.paciente_id = p.id
         LEFT JOIN doctores d ON c.doctor_id = d.id
         WHERE DATE(c.fecha) = ?
         ORDER BY c.hora ASC",
        [$date]
    );

    return [
        'date' => $date,
        'appointments' => $appointments,
        'count' => count($appointments)
    ];
}

/**
 * Get patients with birthdays on a specific date
 */
function getBirthdays(): array {
    $date = Security::sanitizeDate($_GET['date'] ?? date('Y-m-d'));
    
    if (!$date) {
        $date = date('Y-m-d');
    }

    $monthDay = date('m-d', strtotime($date));

    $patients = Database::select(
        "SELECT id, nombre, apellido, email, telefono, fecha_nacimiento,
                TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) as edad
         FROM pacientes
         WHERE DATE_FORMAT(fecha_nacimiento, '%m-%d') = ?
         AND activo = 1",
        [$monthDay]
    );

    return [
        'date' => $date,
        'patients' => $patients,
        'count' => count($patients)
    ];
}

/**
 * Get doctor availability
 */
function getDoctorAvailability(): array {
    $doctorId = Security::sanitizeInt($_GET['doctor_id'] ?? null);
    $date = Security::sanitizeDate($_GET['date'] ?? date('Y-m-d'));
    
    if (!$doctorId) {
        throw new InvalidArgumentException('doctor_id required');
    }

    // Get doctor info
    $doctor = Database::selectOne(
        "SELECT id, nombre, especialidad, horario_inicio, horario_fin
         FROM doctores 
         WHERE id = ?",
        [$doctorId]
    );

    if (!$doctor) {
        throw new Exception('Doctor not found');
    }

    // Get booked slots
    $booked = Database::select(
        "SELECT hora FROM citas 
         WHERE doctor_id = ? AND DATE(fecha) = ? AND estado != 'cancelada'",
        [$doctorId, $date]
    );

    $bookedSlots = array_column($booked, 'hora');

    return [
        'doctor' => $doctor,
        'date' => $date,
        'booked_slots' => $bookedSlots
    ];
}

/**
 * Create a new appointment (POST)
 */
function createAppointment(): array {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new InvalidArgumentException('POST method required');
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $patientId = Security::sanitizeInt($input['patient_id'] ?? null);
    $doctorId = Security::sanitizeInt($input['doctor_id'] ?? null);
    $fecha = Security::sanitizeDate($input['date'] ?? '') . ' ' . ($input['time'] ?? '09:00:00');
    $tipo = Security::sanitizeString($input['type'] ?? 'consulta');
    $notas = Security::sanitizeString($input['notes'] ?? '');

    if (!$patientId || !$doctorId) {
        throw new InvalidArgumentException('patient_id and doctor_id required');
    }

    $appointmentId = Database::insert('citas', [
        'paciente_id' => $patientId,
        'doctor_id' => $doctorId,
        'fecha' => $fecha,
        'tipo_consulta' => $tipo,
        'notas' => $notas,
        'estado' => 'programada',
        'created_at' => date('Y-m-d H:i:s')
    ]);

    return [
        'appointment_id' => $appointmentId,
        'message' => 'Appointment created successfully'
    ];
}

/**
 * Update patient information (POST)
 */
function updatePatient(): array {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new InvalidArgumentException('POST method required');
    }

    $input = json_decode(file_get_contents('php://input'), true);

    $patientId = Security::sanitizeInt($input['patient_id'] ?? null);
    
    if (!$patientId) {
        throw new InvalidArgumentException('patient_id required');
    }

    $updateData = [];
    $allowedFields = ['nombre', 'apellido', 'email', 'telefono', 'direccion'];

    foreach ($allowedFields as $field) {
        if (isset($input[$field])) {
            $updateData[$field] = Security::sanitizeString($input[$field]);
        }
    }

    if (isset($input['email'])) {
        $updateData['email'] = Security::sanitizeEmail($input['email']);
    }

    if (empty($updateData)) {
        throw new InvalidArgumentException('No valid fields to update');
    }

    $updateData['updated_at'] = date('Y-m-d H:i:s');

    $affected = Database::update('pacientes', $updateData, 'id = ?', [$patientId]);

    return [
        'patient_id' => $patientId,
        'updated_fields' => array_keys($updateData),
        'affected_rows' => $affected
    ];
}

/**
 * Check if this is patient's first visit (for fidelization)
 */
function checkFirstVisit(): array {
    $patientId = Security::sanitizeInt($_GET['patient_id'] ?? null);
    
    if (!$patientId) {
        throw new InvalidArgumentException('patient_id required');
    }

    $visits = Database::selectOne(
        "SELECT COUNT(*) as visit_count FROM consultas WHERE paciente_id = ?",
        [$patientId]
    );

    $isFirst = ($visits['visit_count'] ?? 0) <= 1;

    // If first visit, get patient contact info for welcome message
    $patient = null;
    if ($isFirst) {
        $patient = Database::selectOne(
            "SELECT id, nombre, apellido, email, telefono 
             FROM pacientes WHERE id = ?",
            [$patientId]
        );
    }

    return [
        'patient_id' => $patientId,
        'is_first_visit' => $isFirst,
        'visit_count' => $visits['visit_count'] ?? 0,
        'patient' => $patient
    ];
}
