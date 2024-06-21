<?php

include('connection.php');

$sql="select * from FamilyDetails";

$result=mysqli_query($con,$sql);

$response=array();


while ($row = mysqli_fetch_array($result)) {
    array_push($response, array(
        'houseno' => $row['houseno'],
        'name' => $row['name'],
        'contactno' => $row['contactno'],
        'age' => $row['age'],
        'gender' => $row['gender'],
    ));
}

echo json_encode($response);

mysqli_close($con);

?>