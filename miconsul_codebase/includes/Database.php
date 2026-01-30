<?php
/**
 * Database Connection Handler
 * MiConsul Legacy Integration - Modernization Phase 2
 * 
 * Provides secure PDO database connections with prepared statements
 */

require_once __DIR__ . '/EnvLoader.php';

class Database {
    private static ?PDO $connection = null;
    private static array $config = [];

    /**
     * Get database connection (singleton pattern)
     * @return PDO
     */
    public static function getConnection(): PDO {
        if (self::$connection === null) {
            self::connect();
        }
        return self::$connection;
    }

    /**
     * Initialize database connection
     */
    private static function connect(): void {
        EnvLoader::load();

        self::$config = [
            'host' => EnvLoader::get('DB_HOST', 'localhost'),
            'port' => EnvLoader::get('DB_PORT', '3306'),
            'name' => EnvLoader::get('DB_NAME', 'miconsul'),
            'user' => EnvLoader::get('DB_USER', 'root'),
            'pass' => EnvLoader::get('DB_PASS', ''),
            'charset' => EnvLoader::get('DB_CHARSET', 'utf8mb4'),
        ];

        $dsn = sprintf(
            "mysql:host=%s;port=%s;dbname=%s;charset=%s",
            self::$config['host'],
            self::$config['port'],
            self::$config['name'],
            self::$config['charset']
        );

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES 'utf8mb4'",
        ];

        try {
            self::$connection = new PDO($dsn, self::$config['user'], self::$config['pass'], $options);
        } catch (PDOException $e) {
            error_log("Database connection failed: " . $e->getMessage());
            throw new RuntimeException("Database connection failed");
        }
    }

    /**
     * Execute a SELECT query with prepared statement
     * @param string $sql SQL query with placeholders
     * @param array $params Parameters to bind
     * @return array Query results
     */
    public static function select(string $sql, array $params = []): array {
        $stmt = self::getConnection()->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /**
     * Execute a SELECT query and return single row
     * @param string $sql SQL query with placeholders
     * @param array $params Parameters to bind
     * @return array|null Single row or null
     */
    public static function selectOne(string $sql, array $params = []): ?array {
        $stmt = self::getConnection()->prepare($sql);
        $stmt->execute($params);
        $result = $stmt->fetch();
        return $result ?: null;
    }

    /**
     * Execute an INSERT query
     * @param string $table Table name
     * @param array $data Associative array of column => value
     * @return int|string Last insert ID
     */
    public static function insert(string $table, array $data) {
        $columns = array_keys($data);
        $placeholders = array_fill(0, count($columns), '?');

        $sql = sprintf(
            "INSERT INTO `%s` (`%s`) VALUES (%s)",
            $table,
            implode('`, `', $columns),
            implode(', ', $placeholders)
        );

        $stmt = self::getConnection()->prepare($sql);
        $stmt->execute(array_values($data));
        
        return self::getConnection()->lastInsertId();
    }

    /**
     * Execute an UPDATE query
     * @param string $table Table name
     * @param array $data Associative array of column => value
     * @param string $where WHERE clause with placeholders
     * @param array $whereParams Parameters for WHERE clause
     * @return int Number of affected rows
     */
    public static function update(string $table, array $data, string $where, array $whereParams = []): int {
        $setClauses = [];
        foreach (array_keys($data) as $column) {
            $setClauses[] = "`{$column}` = ?";
        }

        $sql = sprintf(
            "UPDATE `%s` SET %s WHERE %s",
            $table,
            implode(', ', $setClauses),
            $where
        );

        $params = array_merge(array_values($data), $whereParams);
        $stmt = self::getConnection()->prepare($sql);
        $stmt->execute($params);
        
        return $stmt->rowCount();
    }

    /**
     * Execute a DELETE query
     * @param string $table Table name
     * @param string $where WHERE clause with placeholders
     * @param array $params Parameters to bind
     * @return int Number of affected rows
     */
    public static function delete(string $table, string $where, array $params = []): int {
        $sql = sprintf("DELETE FROM `%s` WHERE %s", $table, $where);
        $stmt = self::getConnection()->prepare($sql);
        $stmt->execute($params);
        
        return $stmt->rowCount();
    }

    /**
     * Begin a transaction
     */
    public static function beginTransaction(): void {
        self::getConnection()->beginTransaction();
    }

    /**
     * Commit a transaction
     */
    public static function commit(): void {
        self::getConnection()->commit();
    }

    /**
     * Rollback a transaction
     */
    public static function rollback(): void {
        self::getConnection()->rollBack();
    }

    /**
     * Close the database connection
     */
    public static function close(): void {
        self::$connection = null;
    }
}
