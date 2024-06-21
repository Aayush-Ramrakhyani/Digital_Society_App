<?php

include('connection.php');

$sql="select * from Notice";

$result=mysqli_query($con,$sql);

$response=array();


while ($row = mysqli_fetch_array($result)) {
    array_push($response, array(
        'ID' => $row['ID'],
        'Head' => $row['Head'],
        'Content' => $row['Content'],
        'Date' => $row['Date'],
        'IssueBy' => $row['IssueBy'],
    ));
}

echo json_encode($response);

mysqli_close($con);

?>