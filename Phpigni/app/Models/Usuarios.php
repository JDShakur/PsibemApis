<?php
namespace App\Models;

use CodeIgniter\Model;


class Usuarios extends Model
{
    protected $table = 'usuarios';
    protected $primaryKey = 'id';
    protected $allowedFields = ['uid', 'email','password_hash', 'nome', 'telefone', 'data', 'sexo','apelido', 'created_at', 'updated_at','ativo'];
    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';
}