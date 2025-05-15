<?php

include '../connection.php';

$userEmail = $_POST['Email'];

$sqlQuery =  "SELECT * FROM usuarioslogin WHERE email ='$userEmail'";

$resultadoquery =  $connectnow ->  query($sqlQuery);

if($resultadoquery->num_rows > 0){
    echo json_encode(array("sucesso"=>true));
}
else{
    echo json_encode(array("sucesso"=>false));
}