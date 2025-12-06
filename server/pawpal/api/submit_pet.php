<?php
    header("Access-Control-Allow-Origin: *");
    include 'dbconnect.php';

    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        http_response_code(405);
        echo json_encode(array('error' => 'Method Not Allowed'));
        exit();
    }

    // Required fields
    if (
        !isset($_POST['pet_name']) ||!isset($_POST['pet_type']) ||!isset($_POST['category']) ||!isset($_POST['description']) ||!isset($_POST['image_paths']) ||!isset($_POST['lat']) ||!isset($_POST['lng']))
    {
        http_response_code(400);
        echo json_encode(array('error' => 'Bad Request: Missing required fields'));
        exit();
    }

    // Collect POST variables
    $userId = $_POST['user_id'];
    //parse user id into int 
    $newuserId = (int)$userId;
    $petName = $_POST['pet_name'];
    $petType = $_POST['pet_type'];
    $category = $_POST['category'];
    $description = addslashes($_POST['description']);
    $jsonImages = $_POST['image_paths'];
    $imageArray = json_decode($jsonImages, true);
    $lat = $_POST['lat'];
    $lng = $_POST['lng'];

    // SQL Insert Query
    $sqlinsert = "INSERT INTO `tbl_pets`
        (`user_id`, `pet_name`, `pet_type`, `category`, `description`, `lat`, `lng`)
        VALUES ('$newuserId','$petName','$petType','$category','$description','$lat','$lng')";

    try {
        if ($conn->query($sqlinsert) === TRUE) {
            $last_id = $conn->insert_id;
            $saved_filenames = array();

			if (is_array($imageArray) && count($imageArray) > 0) {
                foreach ($imageArray as $index => $base64String) {
                    // Decode the individual base64 string
                    $decodedImage = base64_decode($base64String);

                    $filename = "pet_" . $last_id . "_" . $index . ".png";
                    $path = "../assets/pets/" . $filename;
                    // Save the file to the folder
                    file_put_contents($path, $decodedImage);

                    $saved_filenames[] = $filename;
                }

                $str_filenames = implode(",", $saved_filenames);
                $sql_update = "UPDATE `tbl_pets` SET `image_paths` = '$str_filenames' WHERE `pet_id` = '$last_id'";
                $conn->query($sql_update);
            }

            $response = array('status' => 'success', 'message' => 'Pet submitted successfully');
            sendJsonResponse($response);
        } else {
            $response = array('status' => 'failed', 'message' => 'Submit failed');
            sendJsonResponse($response);
        }
    } catch (Exception $e) {
        $response = array('status' => 'failed', 'message' => $e->getMessage());
        sendJsonResponse($response);
    }

    // JSON Response Function
    function sendJsonResponse($sentArray)
    {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }
?>
