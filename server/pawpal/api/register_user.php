<?php
	header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}
	if (!isset($_POST['profile_image']) || !isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
		http_response_code(400);
		echo json_encode(array('error' => 'Bad Request'));
		exit();
	}

	$email = $_POST['email'];
	$name = $_POST['name'];
	$phone = $_POST['phone'];
	$password = $_POST['password'];
	$hashedpassword = sha1($password);
	$encodeimage = $_POST['profile_image'];
	$decodedimage = base64_decode($encodeimage);
	
	// Check if email already exists
	$sqlcheckmail = "SELECT * FROM `tbl_users` WHERE `email` = '$email'";
	$result = $conn->query($sqlcheckmail);
	if ($result->num_rows > 0){
		$response = array('status' => 'failed', 'message' => 'Email already registered');
		sendJsonResponse($response);
		exit();
	}
	// Insert new user into database
	$sqlregister = "INSERT INTO `tbl_users`(`name`, `email`, `password`, `phone`) VALUES ('$name','$email','$hashedpassword', '$phone')";
	try{
		if ($conn->query($sqlregister) === TRUE){
			$last_id = $conn->insert_id;
			$filename = "user_profile_".$last_id.".png";
			$path = "../assets/user_profile/".$filename;
			file_put_contents($path, $decodedimage);

			$sqlupdateimage = "UPDATE `tbl_users` SET `profile_image` = '$filename' WHERE `user_id` = '$last_id'";
			$conn->query($sqlupdateimage);

			// Registration successful
			$response = array('status' => 'success', 'message' => 'Registration successful');
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'message' => 'Registration failed');
			sendJsonResponse($response);
		}
	}catch(Exception $e){
		$response = array('status' => 'failed', 'message' => $e->getMessage());
		sendJsonResponse($response);
	}


//	function to send json response	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}


?>