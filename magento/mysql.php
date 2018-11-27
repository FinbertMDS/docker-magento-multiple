<?php

while (true) {
    try {
        $dbHost = getenv('MYSQL_HOST');
        $dbName = getenv('MYSQL_DATABASE');
        $dbPassword = getenv('MYSQL_ROOT_PASSWORD');
        $conn = new PDO(
            sprintf('mysql:host=%s;dbname=%s', $dbHost, $dbName),
            'root',
            $dbPassword);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "Connect to database ".$dbName." successfully.";
        exit();
    } catch (Exception $e) {
        sleep(3);
        echo "...";
    }
}