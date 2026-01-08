<?php
header("Access-Control-Allow-Origin: *"); 
header('Content-Type: application/json'); // Ensure the browser/app knows it is JSON
include 'dbconnect.php';

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Check if required POST data exists to avoid PHP "Undefined index" notices
    if (!isset($_POST['user_id']) || !isset($_POST['pet_id'])) {
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'Required parameters are missing.'
        ));
        exit();
    }

    $user_id = $_POST['user_id'];
    $pet_id = $_POST['pet_id'];
    $selectedDonationType = $_POST['type'];
    $donated = $_POST['donated'];

    // 1. Prepare and execute the ownership check
    $checkSql = "SELECT * FROM tbl_pets WHERE user_id = ? AND pet_id = ?";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param("ii", $user_id, $pet_id);
    $checkStmt->execute();
    $result = $checkStmt->get_result();

    if ($result->num_rows > 0) {
        // User IS the owner - prevent donation
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'You are the owner of this pet. You cannot donate to your own listing.'
        ));
    } else {
        
        $submitdonation = "INSERT INTO `tbl_donations`(`user_id`, `pet_id`, `category`, `donate`,) VALUES (?,?,?,?)";
        $submitstmt = $conn->prepare($submitdonation);
        $submitstmt->bind_param("iiss", $user_id, $pet_id, $selectedDonationType, $donated);
        $submitstmt->execute();

        echo json_encode(array(
            'status' => 'success',
            'message' => 'Validation passed.'
        ));
    }

    // Clean up
    $checkStmt->close();
    $conn->close();
} else {
    // Handle non-POST requests
    echo json_encode(array(
        'status' => 'failed',
        'message' => 'Invalid request method.'
    ));
}
?>