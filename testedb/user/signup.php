<?php

include'../conection.php';

$userUid =  $_POST['UsuarioUID'];
$userEmail = $_POST['Email'];
$userSenha = md5( $_POST['senha']);
$userApelido = $_POST['Apelido'];
$userName = $_POST['Nome'];
$userTelefone =$_POST['telefone'];
$userData = $_POST['data'];
$userSexo = $_POST['sexo'];

$sqlQuery = "INSERT Into usuarioslogin SET email = '$userEmail',apelido = '$userApelido', senha = '$userSenha, nome ='$userName'',telefone = '$userTelefone', sexo = '$userSexo',data = '$userData',firebase_uid = '$userUid' ";

$resultadoquery =  $connectnow ->  query($sqlQuery);

if($resultadoquery){
    echo json_encode(array("sucesso"=>true));
}
else{
    echo json_encode(array("sucesso"=>false));
}