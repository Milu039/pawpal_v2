<?php
header("Access-Control-Allow-Origin: *"); // running as chrome app

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    include 'dbconnect.php';
    
    $results_per_page = 10;

    if (isset($_GET['curpage'])) {
        $curpage = (int)$_GET['curpage'];
    } else {
        $curpage = 1;
    }

    $page_first_result = ($curpage - 1) * $results_per_page;

    // Base query
    $baseQuery = "
        SELECT 
            p.pet_id,
            p.user_id,
            p.pet_name,
            p.pet_type,
            p.category,
            p.description,
            p.image_paths,
            p.lat,
            p.lng,
            p.created_at,
            u.name,
            u.email,
            u.phone,
            u.reg_date
        FROM tbl_pets p
        JOIN tbl_users u ON p.user_id = u.user_id
    ";

    // Search logic
    if (isset($_GET['search'] ) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $sqlLoadPets = $baseQuery . "
            WHERE p.pet_name LIKE '%$search%' 
               OR p.pet_type LIKE '%$search%'
               OR p.category LIKE '%$search%'
               OR p.description LIKE '%$search%'
            ORDER BY p.pet_id DESC";
            
    } else if (isset($_GET['type']) && !empty($_GET['type'])) { //filter logic
        $type = $conn->real_escape_string($_GET['type']);
        $sqlLoadPets = $baseQuery . "WHERE p.pet_type = '$type' ORDER BY p.pet_id DESC";
    }else {
        $sqlLoadPets = $baseQuery . " ORDER BY p.pet_id DESC";
    }

    // Execute query for count
    $result = $conn->query($sqlLoadPets);
    $number_of_result = $result->num_rows;
    $number_of_page = ceil($number_of_result / $results_per_page);

    // Add LIMIT for pagination
    $sqlLoadPets .= " LIMIT $page_first_result, $results_per_page";
    $result = $conn->query($sqlLoadPets);

    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }

        $response = array(
            'status' => 'success', 
            'data' => $petdata,
            'numofpage' => $number_of_page, 
            'numberofresult' => $number_of_result
        );

        sendJsonResponse($response);
    } else {
        $response = array(
            'status' => 'failed', 
            'data' => null,
            'numofpage' => $number_of_page, 
            'numberofresult' => $number_of_result
        );

        sendJsonResponse($response);
    }

} else {
    $response = array('status' => 'failed');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
