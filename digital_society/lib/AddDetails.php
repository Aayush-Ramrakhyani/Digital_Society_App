<?php

include('connection.php');

$houseno=$_POST['houseno'];
$familyname=$_POST['familyname'];
$totalmembers=$_POST['totalmembers'];
$password=$_POST['password'];

$sql="insert into members (houseno,familyname,totalmembers,password) values ('$houseno','$familyname','$totalmembers','$password')";

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