<?php
    header("Access-Control-Allow-Origin: *");
    include 'dbconnect.php';

    // Ensure we are receiving a POST request
    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        echo json_encode(array('failed' => 'Method Not Allowed'));
        exit();
    }
    
    // Check for the keys sent by Flutter. 
    // Note: Flutter is sending 'reason' and 'is_checked'
    if (!isset($_POST['user_id']) || !isset($_POST['pet_id']) || !isset($_POST['reason'])) {
        echo json_encode(array('failed' => 'Missing required fields: user_id, pet_id, or reason'));
        exit();
    }

    $user_id = (int)$_POST['user_id'];
    $pet_id = (int)$_POST['pet_id'];
    $adoption_reason = $_POST['reason'];
    $adopted_status = isset($_POST['is_checked']) ? (int)$_POST['is_checked'] : 0; 

    // Validate owner check
    // Ensure the user isn't trying to adopt their own pet
    $checkSql = "SELECT * FROM tbl_pets WHERE user_id = ? AND pet_id = ?";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param("ii", $user_id, $pet_id);
    $checkStmt->execute();
    if ($checkStmt->get_result()->num_rows > 0) {
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'You cannot adopt your own pet.'
        ));
        exit();
    }
    // Validate duplicate submission
    // Prevent the same user from applying for the same pet twice
    $checkSql1 = "SELECT * FROM tbl_adoptions WHERE user_id = ? AND pet_id = ?";
    $checkStmt1 = $conn->prepare($checkSql1);
    $checkStmt1->bind_param("ii", $user_id, $pet_id);
    $checkStmt1->execute();
    if ($checkStmt1->get_result()->num_rows > 0) {
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'You have already submitted an application for this pet.'
        ));
        exit();
    }
    // Validate pet availability
    // We check the tbl_adoptions to see if any application for this pet is already 'finalized' (status 1)
    $checkSql2 = "SELECT * FROM tbl_adoptions WHERE pet_id = ? AND adopted_status = 1";
    $checkStmt2 = $conn->prepare($checkSql2);
    $checkStmt2->bind_param("i", $pet_id);
    $checkStmt2->execute();
    if ($checkStmt2->get_result()->num_rows > 0) {
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'This pet has already been adopted by someone else.'
        ));
        exit();
    }

    // Insert the new adoption application
    // We set adopted_status to 0 (or the value of is_checked) because it is a new 'pending' request
    $sql = "INSERT INTO `tbl_adoptions`(`pet_id`, `user_id`, `adoption_reason`, `adopted_status`) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iisi", $pet_id, $user_id, $adoption_reason, $adopted_status);

    if ($stmt->execute()) {
        echo json_encode(array(
            'status' => 'success', 
            'message' => 'Adoption request submitted successfully!'
        ));
    } else {
        // If the query fails, return the specific DB error for debugging
        echo json_encode(array(
            'status' => 'failed',
            'message' => 'Database error: ' . $conn->error
        ));
    }
?>