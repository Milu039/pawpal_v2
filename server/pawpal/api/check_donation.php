<?php
header("Access-Control-Allow-Origin: *"); 
header('Content-Type: application/json');
include 'dbconnect.php';

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Updated to include 'category' and 'donate' (the item description/amount)
    if (!isset($_POST['user_id']) || !isset($_POST['pet_id']) || !isset($_POST['category']) || !isset($_POST['donate'])) {
        echo json_encode(array('status' => 'failed', 'message' => 'Required parameters are missing.'));
        exit();
    }

    $user_id  = $_POST['user_id'];
    $pet_id   = $_POST['pet_id'];
    $category = $_POST['category'];
    $donate   = $_POST['donate'];

    // 1. Ownership Check: Prevent users from donating to their own pet
    $checkSql = "SELECT * FROM tbl_pets WHERE user_id = ? AND pet_id = ?";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param("ii", $user_id, $pet_id);
    $checkStmt->execute();
    $result = $checkStmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(array('status' => 'failed', 'message' => 'You are the owner of this pet.'));
        $checkStmt->close();
        exit();
    }
    $checkStmt->close();

    // 2. Handling Different Categories
    if ($category == "Money") {
        // For Money, we just return success so Flutter can proceed to PaymentScreen
        echo json_encode(array('status' => 'success', 'message' => 'Proceed to payment.'));
    } else {
        // For Food/Medical, we insert directly into tbl_donations now
        $insertSql = "INSERT INTO tbl_donations (user_id, pet_id, category, donate) VALUES (?, ?, ?, ?)";
        $insertStmt = $conn->prepare($insertSql);
        $insertStmt->bind_param("iiss", $user_id, $pet_id, $category, $donate);
        
        if ($insertStmt->execute()) {
            echo json_encode(array('status' => 'success', 'message' => 'Donation recorded successfully.'));
        } else {
            echo json_encode(array('status' => 'failed', 'message' => 'Database error: ' . $insertStmt->error));
        }
        $insertStmt->close();
    }

    $conn->close();
} else {
    echo json_encode(array('status' => 'failed', 'message' => 'Invalid request method.'));
}
?>