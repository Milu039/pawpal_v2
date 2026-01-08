<?php
header("Access-Control-Allow-Origin: *"); 

if($_SERVER['REQUEST_METHOD'] == 'POST') {

    include 'dbconnect.php';

    $user_id = $_POST['user_id'];
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $image = $_POST['image'];

    $sqlUpdateProfile = "
        UPDATE tbl_users 
        SET name='$name', phone='$phone' 
        WHERE user_id='$user_id'
    ";

    if($image == "NA") {
        $decodedimage = "NA";
    }else{
        $decodedimage = base64_decode($image);
    }

    if ($conn->query($sqlUpdateProfile) === TRUE) {
        $path = "../assets/user_profile/user_profile_".$user_id.".png";
			if ($decodedimage != "NA") {
				file_put_contents($path, $decodedimage);
                $sqlupdateimage = "
                    UPDATE tbl_users 
                    SET profile_image = 'user_profile_".$user_id.".png' 
                    WHERE user_id='$user_id'";

                $conn->query($sqlupdateimage);
			}
        echo json_encode(array("status" => "success", "message" => "Profile updated successfully."));
    } else {
        echo json_encode(array("status" => "error", "message" => "Error updating profile: " . $conn->error));
    }

    $conn->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method."));
}
?>