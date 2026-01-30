<?php
/**
 * Security Utilities
 * MiConsul Legacy Integration - Modernization Phase 2
 * 
 * Provides input sanitization, token validation, and security helpers
 */

require_once __DIR__ . '/EnvLoader.php';

class Security {
    private static ?string $apiToken = null;
    
    /**
     * Initialize security with API token from environment
     */
    public static function init(): void {
        EnvLoader::load();
        self::$apiToken = EnvLoader::get('N8N_API_TOKEN');
    }

    /**
     * Validate Bearer token from Authorization header
     * @return bool
     */
    public static function validateToken(): bool {
        if (empty(self::$apiToken)) {
            self::init();
        }

        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (empty($authHeader)) {
            return false;
        }

        // Check Bearer format
        if (!preg_match('/^Bearer\s+(.+)$/i', $authHeader, $matches)) {
            return false;
        }

        $providedToken = trim($matches[1]);
        
        // Constant-time comparison to prevent timing attacks
        return hash_equals(self::$apiToken ?? '', $providedToken);
    }

    /**
     * Sanitize string input - remove dangerous characters
     * @param mixed $input Input to sanitize
     * @return string
     */
    public static function sanitizeString($input): string {
        if (!is_string($input)) {
            $input = (string) $input;
        }

        // Remove null bytes
        $input = str_replace(chr(0), '', $input);
        
        // Trim whitespace
        $input = trim($input);
        
        // Convert special characters to HTML entities
        $input = htmlspecialchars($input, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        
        return $input;
    }

    /**
     * Sanitize integer input
     * @param mixed $input Input to sanitize
     * @return int|null
     */
    public static function sanitizeInt($input): ?int {
        if (!is_numeric($input)) {
            return null;
        }
        return (int) $input;
    }

    /**
     * Sanitize email input
     * @param string $email Email to sanitize
     * @return string|null Sanitized email or null if invalid
     */
    public static function sanitizeEmail(string $email): ?string {
        $email = filter_var(trim($email), FILTER_SANITIZE_EMAIL);
        return filter_var($email, FILTER_VALIDATE_EMAIL) ? $email : null;
    }

    /**
     * Sanitize date input
     * @param string $date Date string
     * @param string $format Expected format
     * @return string|null
     */
    public static function sanitizeDate(string $date, string $format = 'Y-m-d'): ?string {
        $dt = DateTime::createFromFormat($format, trim($date));
        if ($dt && $dt->format($format) === trim($date)) {
            return $dt->format($format);
        }
        return null;
    }

    /**
     * Rate limiting check (basic implementation)
     * @param string $identifier Client identifier (IP, user ID, etc.)
     * @param int $maxRequests Maximum requests allowed
     * @param int $windowSeconds Time window in seconds
     * @return bool True if within limits
     */
    public static function checkRateLimit(string $identifier, int $maxRequests = 100, int $windowSeconds = 60): bool {
        $cacheFile = sys_get_temp_dir() . '/rate_limit_' . md5($identifier);
        
        $now = time();
        $data = ['requests' => [], 'first' => $now];
        
        if (file_exists($cacheFile)) {
            $data = json_decode(file_get_contents($cacheFile), true) ?: $data;
        }
        
        // Filter requests within the window
        $data['requests'] = array_filter($data['requests'], function($timestamp) use ($now, $windowSeconds) {
            return ($now - $timestamp) < $windowSeconds;
        });
        
        // Check limit
        if (count($data['requests']) >= $maxRequests) {
            return false;
        }
        
        // Add current request
        $data['requests'][] = $now;
        file_put_contents($cacheFile, json_encode($data));
        
        return true;
    }

    /**
     * Generate secure random token
     * @param int $length Length in bytes
     * @return string Hex-encoded token
     */
    public static function generateToken(int $length = 32): string {
        return bin2hex(random_bytes($length));
    }

    /**
     * Send JSON error response and exit
     * @param string $message Error message
     * @param int $code HTTP status code
     */
    public static function sendError(string $message, int $code = 400): void {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error' => $message,
            'timestamp' => date('c')
        ]);
        exit;
    }

    /**
     * Get client IP address
     * @return string
     */
    public static function getClientIP(): string {
        $headers = ['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'];
        
        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                return trim($ips[0]);
            }
        }
        
        return '0.0.0.0';
    }
}
