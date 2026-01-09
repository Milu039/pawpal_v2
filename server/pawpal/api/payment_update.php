<?php
//error_reporting(0);
include_once("dbconnect.php");

$xkey = '2850b0be02d82da4ef2e82aabb1e60d8485329c8ff260da61c4687448bd58d0ec160ed6793c7b60ac168cce513aff823611842dd77de6526ec1feec91a56ce34';

$category = $_GET['category'];
$petid = $_GET['petid'];
$email = $_GET['email']; 
$phone = $_GET['phone']; 
$name = $_GET['name']; 
$credit = $_GET['credit']; 
$userid = $_GET['userid'];

$data = array(
    'id' =>  $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'] ,
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
if ($paidstatus=="true"){
    $paidstatus = "Success";
}else{
    $paidstatus = "Failed";
}
$receiptid = $_GET['billplz']['id'];
$signing = '';
foreach ($data as $key => $value) {
    $signing.= 'billplz'.$key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}
 
$signed= hash_hmac('sha256', $signing, $xkey);
if ($signed === $data['x_signature']) {
    if ($paidstatus == "Success"){ //payment success
    

        $sql = "INSERT INTO tbl_donations (user_id, pet_id, category, donate)
            VALUES ('$userid', '$petid', '$category', 'RM $credit')";
        
        if ($conn->query($sql) === TRUE){
             //print receipt for success transaction
            echo "
            <html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
            <body>
            <center><h4>Receipt</h4></center>
            <table class='w3-table w3-striped'>
            <th>Item</th><th>Description</th>
            <tr><td>Receipt</td><td>$receiptid</td></tr>
            <tr><td>Name</td><td>$name</td></tr>
            <tr><td>Email</td><td>$email</td></tr>
            <tr><td>Phone</td><td>$phone</td></tr>
            <tr><td>Paid Amount</td><td>RM$credit</td></tr>
            <tr><td>Paid Status</td><td class='w3-text-green'>$paidstatus</td></tr>
            </table><br>
            </body>
            </html>";
        }else{
              echo "
            <html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
            <body>
            <center><h4>Receipt</h4></center>
            <table class='w3-table w3-striped'>
            <th>Item</th><th>Description</th>
            <tr><td>Receipt</td><td>$receiptid</td></tr>
            <tr><td>Name</td><td>$name</td></tr>
            <tr><td>Email</td><td>$email</td></tr>
            <tr><td>Phone</td><td>$phone</td></tr>
            <tr><td>Paid</td><td>RM $credit</td></tr>
            <tr><td>Paid Status</td><td class='w3-text-red'>$paidstatus</td></tr>
            </table><br>
            
            </body>
            </html>";
        }
    }
    else 
    {
        //print receipt for failed transaction
         echo "
        <html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
        <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
        <body>
        <center><h4>Receipt</h4></center>
        <table class='w3-table w3-striped'>
        <th>Item</th><th>Description</th>
        <tr><td>Receipt</td><td>$receiptid</td></tr>
        <tr><td>Name</td><td>$name</td></tr>
        <tr><td>Email</td><td>$email</td></tr>
        <tr><td>Phone</td><td>$phone</td></tr>
        <tr><td>Paid</td><td>RM $credit</td></tr>
        <tr><td>Paid Status</td><td class='w3-text-red'>$paidstatus</td></tr>
        </table><br>
        
        </body>
        </html>";
    }
}

?>