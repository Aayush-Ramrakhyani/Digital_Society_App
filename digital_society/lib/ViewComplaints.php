<?php

include('connection.php');

$sql="select * from Complaints";

$result=mysqli_query($con,$sql);

$response=array();


while ($row = mysqli_fetch_array($result)) {
    array_push($response, array(
        'ID' => $row['ID'],
        'houseno' => $row['houseno'],
        'Title' => $row['Title'],
        'Description' => $row['Description'],
        'Date' => $row['Date'],
        'FinishDate' => $row['FinishDate'],
        'Action' => $row['Action'],
        'Feedback' => $row['Feedback'],
        'Status' => $row['Status'],
    ));
}

echo json_encode($response);

mysqli_close($con);

?>