<?php

include('connection.php');

$Head=$_POST['Head'];
$Date=$_POST['Date'];
$Content=$_POST['Content'];
$IssueBy=$_POST['IssueBy'];

$sql="insert into Notice (Head,Date,Content,IssueBy) values ('$Head','$Date','$Content','$IssueBy')";

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