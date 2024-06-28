<?php

include('connection.php');

$sql="select * from members";

$result=mysqli_query($con,$sql);

$response=array();


while ($row = mysqli_fetch_array($result)) {
    array_push($response, array(
        'houseno' => $row['houseno'],
        'familyname' => $row['familyname'],
        'password' => $row['password'],
    ));
}

echo json_encode($response);

mysqli_close($con);

?>