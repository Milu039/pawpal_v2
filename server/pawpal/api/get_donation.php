<?php
header("Access-Control-Allow-Origin: *"); 

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    include 'dbconnect.php';
    
    // Check if user_id is provided, as history is specific to a user
    if (!isset($_GET['user_id'])) {
        $response = array('status' => 'failed', 'message' => 'User ID is required');
        sendJsonResponse($response);
        exit();
    }

    $user_id = $conn->real_escape_string($_GET['user_id']);
    $results_per_page = 10;

    if (isset($_GET['curpage'])) {
        $curpage = (int)$_GET['curpage'];
    } else {
        $curpage = 1;
    }

    $page_first_result = ($curpage - 1) * $results_per_page;

    // Base query: JOIN with tbl_pets to get the pet_name for the history list
    $baseQuery = "
        SELECT 
            d.user_id,
            d.pet_id,
            d.category,
            d.donate,
            d.reg_date,
            p.pet_name
        FROM tbl_donations d
        JOIN tbl_pets p ON d.pet_id = p.pet_id
        WHERE d.user_id = '$user_id'
    ";

    // Filtering logic
    $filter = "";
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $filter .= " AND (p.pet_name LIKE '%$search%' OR d.donate LIKE '%$search%')";
    }
    
    if (isset($_GET['category']) && !empty($_GET['category'])) {
        $category = $conn->real_escape_string($_GET['category']);
        $filter .= " AND d.category = '$category'";
    }

    $sqlLoadDonations = $baseQuery . $filter . " ORDER BY d.reg_date DESC";

    // Execute query to find total count for pagination
    $result = $conn->query($sqlLoadDonations);
    $number_of_result = $result->num_rows;
    $number_of_page = ceil($number_of_result / $results_per_page);

    // Add LIMIT for pagination
    $sqlLoadDonations .= " LIMIT $page_first_result, $results_per_page";
    $result = $conn->query($sqlLoadDonations);

    if ($result && $result->num_rows > 0) {
        $donationData = array();
        while ($row = $result->fetch_assoc()) {
            $donationData[] = $row;
        }

        $response = array(
            'status' => 'success', 
            'data' => $donationData,
            'numofpage' => $number_of_page, 
            'numberofresult' => $number_of_result
        );
        sendJsonResponse($response);
    } else {
        $response = array(
            'status' => 'failed', 
            'data' => null,
            'numofpage' => 0, 
            'numberofresult' => 0
        );
        sendJsonResponse($response);
    }

} else {
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>