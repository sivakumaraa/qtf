<?php
/**
 * QuarryForce Database Class
 * PDO wrapper for MySQL operations
 */

class Database {
    private $pdo;
    private $host;
    private $user;
    private $pass;
    private $name;
    private $port;

    public function __construct($host = DB_HOST, $user = DB_USER, $pass = DB_PASS, $name = DB_NAME, $port = DB_PORT) {
        $this->host = $host;
        $this->user = $user;
        $this->pass = $pass;
        $this->name = $name;
        $this->port = $port;
        $this->connect();
    }

    private function connect() {
        try {
            $dsn = "mysql:host={$this->host};port={$this->port};dbname={$this->name};charset=utf8mb4";
            $this->pdo = new PDO($dsn, $this->user, $this->pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        } catch (PDOException $e) {
            $this->error('Database connection failed: ' . $e->getMessage());
        }
    }

    /**
     * Execute a SELECT query
     */
    public function query($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            $this->error('Query error: ' . $e->getMessage());
            return [];
        }
    }

    public function queryOne($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            $result = $stmt->fetch();
            return $result ?: null;
        } catch (PDOException $e) {
            $this->error('Query error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Execute INSERT/UPDATE/DELETE
     */
    public function execute($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->rowCount();
        } catch (PDOException $e) {
            $this->error('Execute error: ' . $e->getMessage());
            return 0;
        }
    }

    /**
     * Get last insert ID
     */
    public function lastId() {
        return $this->pdo->lastInsertId();
    }

    /**
     * Log and return error
     */
    private function error($message) {
        if (LOGGING_ENABLED) {
            error_log('[' . date('Y-m-d H:i:s') . '] ' . $message);
        }
    }

    /**
     * Check if database is connected
     */
    public function isConnected() {
        return $this->pdo !== null;
    }
}

// Create global database instance
$db = new Database();

?>
