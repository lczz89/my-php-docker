<?php 
try{
    $conn = new PDO("mysql:host=mysql:3306;dbname=test", "root", "root");
    echo "连接成功\n";
    $stmt = $conn->prepare("SELECT * FROM name");
    $stmt->execute();
    $stmt->setFetchMode(PDO::FETCH_ASSOC);
    foreach ($stmt->fetchAll() as $key => $value) {
        echo $value["name"] . "\n";
    }
}catch(PDOException $e){
    echo $e->getMessage();
}