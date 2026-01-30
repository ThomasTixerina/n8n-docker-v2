<?php
/**
 * Webhook Helper
 * MiConsul Legacy Integration - Modernization Phase 2
 * 
 * Sends webhooks to n8n workflows
 */

require_once __DIR__ . '/EnvLoader.php';
require_once __DIR__ . '/Security.php';

class Webhook {
    private static ?string $baseUrl = null;

    /**
     * Initialize webhook base URL
     */
    private static function init(): void {
        if (self::$baseUrl === null) {
            EnvLoader::load();
            self::$baseUrl = EnvLoader::get('N8N_WEBHOOK_URL', 'http://localhost:5678/webhook');
        }
    }

    /**
     * Send webhook to n8n
     * @param string $path Webhook path (e.g., 'first-sale')
     * @param array $data Payload data
     * @return array Response from n8n
     */
    public static function trigger(string $path, array $data): array {
        self::init();

        $url = rtrim(self::$baseUrl, '/') . '/' . ltrim($path, '/');
        
        // Add timestamp and source
        $data['_meta'] = [
            'source' => 'miconsul-legacy',
            'timestamp' => date('c'),
            'request_id' => Security::generateToken(8)
        ];

        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Accept: application/json',
                'X-Source: miconsul-legacy'
            ],
            CURLOPT_TIMEOUT => 30,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_SSL_VERIFYPEER => true,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            error_log("Webhook failed to {$url}: {$error}");
            return [
                'success' => false,
                'error' => $error,
                'http_code' => $httpCode
            ];
        }

        $decoded = json_decode($response, true);
        
        return [
            'success' => $httpCode >= 200 && $httpCode < 300,
            'http_code' => $httpCode,
            'response' => $decoded ?? $response
        ];
    }

    /**
     * Trigger first sale event (Fidelización)
     * @param int $patientId Patient ID
     * @param array $saleData Sale information
     * @return array
     */
    public static function triggerFirstSale(int $patientId, array $saleData): array {
        return self::trigger('first-sale', [
            'event' => 'first_sale',
            'patient_id' => $patientId,
            'sale' => $saleData
        ]);
    }

    /**
     * Trigger appointment reminder
     * @param int $appointmentId Appointment ID
     * @param array $details Appointment details
     * @return array
     */
    public static function triggerAppointmentReminder(int $appointmentId, array $details): array {
        return self::trigger('appointment-reminder', [
            'event' => 'appointment_reminder',
            'appointment_id' => $appointmentId,
            'details' => $details
        ]);
    }

    /**
     * Trigger custom event
     * @param string $eventName Event name
     * @param array $data Event data
     * @return array
     */
    public static function triggerCustom(string $eventName, array $data): array {
        return self::trigger('custom-event', [
            'event' => $eventName,
            'data' => $data
        ]);
    }

    /**
     * Asynchronous webhook trigger (fire and forget)
     * @param string $path Webhook path
     * @param array $data Payload data
     */
    public static function triggerAsync(string $path, array $data): void {
        self::init();

        $url = rtrim(self::$baseUrl, '/') . '/' . ltrim($path, '/');
        
        $data['_meta'] = [
            'source' => 'miconsul-legacy',
            'timestamp' => date('c'),
            'async' => true
        ];

        $payload = json_encode($data);

        // Fire and forget using exec
        $cmd = sprintf(
            'curl -X POST -H "Content-Type: application/json" -d %s %s > /dev/null 2>&1 &',
            escapeshellarg($payload),
            escapeshellarg($url)
        );

        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            // Windows
            pclose(popen("start /B " . $cmd, "r"));
        } else {
            // Unix/Linux
            exec($cmd);
        }
    }
}
