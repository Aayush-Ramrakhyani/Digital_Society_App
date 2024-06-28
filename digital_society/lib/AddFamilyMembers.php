<?php

include('connection.php');

$houseno=$_POST['houseno'];
$name=$_POST['name'];
$contactno=$_POST['contactno'];
$age=$_POST['age'];
$gender=$_POST['gender'];

$sql="insert into FamilyDetails (houseno,name,contactno,age,gender) values ('$houseno','$name','$contactno','$age','$gender')";

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