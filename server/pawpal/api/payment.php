<?php
error_reporting(0);
//include_once("dbconnect.php");

$email = $_GET['email']; 
$phone = $_GET['phone']; 
$name = $_GET['name']; 
$credit = $_GET['credits']; 
$userid = $_GET['userid'];
$petid = $_GET['petid'];    
$category = $_GET['category']; 


$api_key = '43a5ca4b-0426-4a86-bba0-6187c107d0aa';
$collection_id = '0u96dbb0';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';


$data = array(
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $phone,
    'name' => $name,
    'amount' => $credit * 100, 
    'description' => 'Payment for '.$userid,
    'callback_url' => "https://canorcannot.com/JIACHING/pawpal/api/return_url",
    'redirect_url' => "https://canorcannot.com/JIACHING/pawpal/api/payment_update.php?userid=$userid&email=$email&name=$name&phone=$phone&credit=$credit&petid=$petid&category=$category" 
);


$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) ); 

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

echo "<pre>".print_r($bill, true)."</pre>";
header("Location: {$bill['url']}");
?>