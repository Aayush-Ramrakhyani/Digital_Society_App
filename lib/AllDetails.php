<?php

include('connection.php');

$sql = "SELECT * FROM members 
        JOIN FamilyDetails ON members.houseno = FamilyDetails.houseno";

$result = mysqli_query($con, $sql);

$response = array();

while ($row = mysqli_fetch_array($result)) {
    // Structure the data
    if (array_key_exists($row['houseno'], $response)) {
        
        array_push($response[$row['houseno']]['family'], array(
            'name' => $row['name'],
            'contactno' => $row['contactno'],
            'age' => $row['age'],
            'gender' => $row['gender']
        ));
    } else {
        
        $response[$row['houseno']] = array(
            'houseno' => $row['houseno'],
            'familyname' => $row['familyname'],
            'family' => array(
                array(
                    'name' => $row['name'],
                    'contactno' => $row['contactno'],
                    'age' => $row['age'],
                    'gender' => $row['gender']
                )
            )
        );
    }
}

// Encode the response into JSON format
echo json_encode(array_values($response));

mysqli_close($con);

?>
