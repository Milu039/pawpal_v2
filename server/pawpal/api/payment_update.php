<?php
include_once("dbconnect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['billplz'])) {

    $billplz = $_POST['billplz'];
    
    $xkey = 'your_xsignature_key';
    
    // Build signature
    $signing = 'billplzid'.$billplz['id']
             . '|billplzpaid_at'.$billplz['paid_at']
             . '|billplzpaid'.$billplz['paid'];

    $signed = hash_hmac('sha256', $signing, 'xkey'); // ⚠️ use your Billplz X-Signature key

    if ($signed !== $billplz['x_signature']) {
        http_response_code(403);
        exit;
    }

    if ($billplz['paid'] === 'true') {
       
    }

    http_response_code(200);
    exit; // ⬅️ VERY IMPORTANT (no UI here)
}

$userid   = $_GET['userid'] ?? '';
$petid    = $_GET['petid'] ?? '';
$category = $_GET['category'] ?? '';
$credit   = $_GET['credit'] ?? '';
$name     = $_GET['name'] ?? '';
$email    = $_GET['email'] ?? '';
$phone    = $_GET['phone'] ?? '';
$receiptid = $_GET['billplz']['id'] ?? 'N/A';

$paidstatus = "Success";

$sql = "INSERT INTO tbl_donations (user_id, pet_id, category, donate)
        VALUES ('$userid', '$petid', '$category', 'RM $credit')";
$conn->query($sql);

?>

<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<title>Payment Receipt</title>
</head>
<body>

<center><h4>Payment Receipt</h4></center>

<table class="w3-table w3-striped">
<tr><td>Receipt</td><td><?= htmlspecialchars($receiptid) ?></td></tr>
<tr><td>Name</td><td><?= htmlspecialchars($name) ?></td></tr>
<tr><td>Email</td><td><?= htmlspecialchars($email) ?></td></tr>
<tr><td>Phone</td><td><?= htmlspecialchars($phone) ?></td></tr>
<tr><td>Paid Amount</td><td>RM <?= htmlspecialchars($credit) ?></td></tr>
<tr>
  <td>Status</td>
  <td class="w3-text-green"><?= $paidstatus ?></td>
</tr>
</table>

</body>
</html>
