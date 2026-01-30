<?php
/**
 * Environment Variable Loader
 * MiConsul Legacy Integration - Modernization Phase 2
 * 
 * Loads environment variables from .env file
 */

class EnvLoader {
    private static bool $loaded = false;
    private static array $vars = [];

    /**
     * Load environment variables from .env file
     * @param string $path Path to .env file
     * @return bool Success status
     */
    public static function load(string $path = null): bool {
        if (self::$loaded) {
            return true;
        }

        $envFile = $path ?? dirname(__DIR__) . '/.env';

        if (!file_exists($envFile)) {
            error_log("EnvLoader: .env file not found at {$envFile}");
            return false;
        }

        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

        foreach ($lines as $line) {
            // Skip comments
            if (strpos(trim($line), '#') === 0) {
                continue;
            }

            // Parse key=value
            $parts = explode('=', $line, 2);
            if (count($parts) === 2) {
                $key = trim($parts[0]);
                $value = trim($parts[1]);
                
                // Remove quotes if present
                $value = trim($value, '"\'');
                
                self::$vars[$key] = $value;
                
                // Set as environment variable if not already set
                if (getenv($key) === false) {
                    putenv("{$key}={$value}");
                }
            }
        }

        self::$loaded = true;
        return true;
    }

    /**
     * Get environment variable
     * @param string $key Variable name
     * @param mixed $default Default value if not found
     * @return mixed
     */
    public static function get(string $key, $default = null) {
        // First check loaded vars
        if (isset(self::$vars[$key])) {
            return self::$vars[$key];
        }

        // Then check system environment
        $value = getenv($key);
        if ($value !== false) {
            return $value;
        }

        return $default;
    }

    /**
     * Check if environment variable exists
     * @param string $key Variable name
     * @return bool
     */
    public static function has(string $key): bool {
        return isset(self::$vars[$key]) || getenv($key) !== false;
    }
}
