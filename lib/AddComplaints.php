<?php

include('connection.php');

$houseno=$_POST['houseno'];
$Title=$_POST['Title'];
$Description=$_POST['Description'];
$Date=$_POST['Date'];
$Status=$_POST['Status'];

$sql="insert into Complaints (houseno,Title,Description,Date,Status) values ('$houseno','$Title','$Description','$Date','$Status')";

if(mysqli_query($con,$sql))
{
    echo json_encode(array('response'=>"successfully added"));
}
else
{
    echo json_encode(array('response'=>"Failed"));
}
mysqli_close($con);

?>
